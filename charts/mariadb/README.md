# MariaDB Helm Chart

Ein Helm Chart zum Deployen mehrerer MariaDB Datenbanken in einem Kubernetes Cluster mit automatischer Benutzer- und Verbindungsverwaltung.

## Features

- **Multi-DB Support**: Mehrere Datenbanken in einem Release
- **Automatische Credentials**: Root-Passwort und App-User-Passwörter werden vom mariadb-operator generiert
- **Connection CRs**: Automatische JDBC-URL-Generierung für Spring Boot und andere Apps
- **Stabile Passwörter**: Passwörter werden nur beim ersten Deploy generiert, nicht bei jedem Upgrade rotiert
- **RW/RO User**: Separate Read-Write und Read-Only User pro Datenbank
- **Longhorn Default**: Verwendet Longhorn als Standard Storage Class

## Voraussetzungen

- Kubernetes 1.20+
- [mariadb-operator](https://github.com/mariadb-operator/mariadb-operator) v0.28+ installiert
- (Optional) Longhorn Storage Class für Persistente Volumes

## Schnellstart

**Minimales Deployment mit einer DB:**

```yaml
# values.yaml
databases:
  - name: myapp
```

```bash
helm install myapp-db ./charts/mariadb -n myapp
```

Fertig. Der Operator erstellt:
- MariaDB Instanz `myapp`
- User `myapp-rw` mit Lese/Schreib-Zugriff
- User `myapp-ro` mit Lese-Zugriff
- Secret `myapp-rw-dsn` mit JDBC URL
- Secret `myapp-ro-dsn` mit JDBC URL

## Multiple Datenbanken

Eine ArgoCD Application pro Namespace, mehrere DBs in `values.yaml`:

```yaml
databases:
  - name: cache
  - name: todoapp
  - name: links
```

Jede DB ist vollständig isoliert mit eigenen Secrets und Usern.

## Konfiguration

### Minimale Konfiguration

Nur `name` ist erforderlich:

```yaml
databases:
  - name: cache
```

Alle anderen Parameter haben Defaults:
- `database`: defaults zu `.name`
- `replicas`: 1
- `port`: 3306
- `storage.size`: 1Gi
- `storage.storageClassName`: longhorn
- `resources.requests.cpu`: 100m
- `resources.requests.memory`: 256Mi
- `resources.limits.cpu`: 500m
- `resources.limits.memory`: 512Mi

### Pro-DB Overrides

Einzelne DBs können Defaults überschreiben:

```yaml
databases:
  - name: cache
  - name: bigdb
    replicas: 3
    storage:
      size: "10Gi"
      storageClassName: "local-path"
    resources:
      requests:
        cpu: "500m"
        memory: "1Gi"
      limits:
        cpu: "2000m"
        memory: "2Gi"
  - name: todoapp
    database: "todo_production"  # anderer DB-Name als CR-Name
```

## Erstellte Ressourcen

Für jede DB namens `todoapp` entstehen:

| Ressource | Name | Zweck |
|---|---|---|
| MariaDB | `todoapp` | MariaDB Instanz |
| Secret | `todoapp-root` | Root-Passwort (auto-generiert) |
| User | `todoapp-rw` | Read-Write User |
| Grant | `todoapp-rw-grant` | RW Berechtigungen |
| Secret | `todoapp-rw-secret` | RW User Passwort |
| User | `todoapp-ro` | Read-Only User |
| Grant | `todoapp-ro-grant` | RO Berechtigungen |
| Secret | `todoapp-ro-secret` | RO User Passwort |
| Connection | `todoapp-rw` | Connection Objekt (RW) |
| Connection | `todoapp-ro` | Connection Objekt (RO) |
| Secret | `todoapp-rw-dsn` | JDBC URL + Credentials (RW) |
| Secret | `todoapp-ro-dsn` | JDBC URL + Credentials (RO) |

Die DSN-Secrets enthalten je:
- `jdbc-url`: `jdbc:mariadb://todoapp.namespace.svc.cluster.local:3306/todoapp`
- `username`: `todoapp-rw` oder `todoapp-ro`
- `password`: generiertes Passwort

## Verwendung in Apps

### Spring Boot

```yaml
# deployment.yaml
env:
  - name: SPRING_DATASOURCE_URL
    valueFrom:
      secretKeyRef:
        name: todoapp-rw-dsn
        key: jdbc-url
  - name: SPRING_DATASOURCE_USERNAME
    valueFrom:
      secretKeyRef:
        name: todoapp-rw-dsn
        key: username
  - name: SPRING_DATASOURCE_PASSWORD
    valueFrom:
      secretKeyRef:
        name: todoapp-rw-dsn
        key: password
```

Spring Boot übernimmt `SPRING_DATASOURCE_*` automatisch als Property Override.

### Andere Frameworks

Alle Daten liegen im Secret `{{ db-name }}-rw-dsn`:
- `jdbc-url`: vollständige JDBC URL (host bereits aufgelöst)
- `username`: User-Name
- `password`: Passwort

```bash
# Secrets auslesen
kubectl get secret todoapp-rw-dsn -o jsonpath='{.data.jdbc-url}' | base64 -d
kubectl get secret todoapp-rw-dsn -o jsonpath='{.data.username}' | base64 -d
kubectl get secret todoapp-rw-dsn -o jsonpath='{.data.password}' | base64 -d
```

## Mit ArgoCD deployen

**Eine Application pro Namespace mit allen DBs:**

```yaml
# gitops-repo/apps/bootfleet/mariadb.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: bootfleet-databases
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/MartinWittlinger/automatic-funicular
    targetRevision: HEAD
    path: charts/mariadb
    helm:
      valuesInline:
        databases:
          - name: cache
          - name: todoapp
          - name: links
  destination:
    server: https://kubernetes.default.svc
    namespace: bootfleet
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

Neue DB = eine Zeile hinzufügen + commit.

## Passwort Management

### Root-Passwort
- Wird vom mariadb-operator auto-generiert (`generate: true`)
- Gespeichert in Secret `{{ name }}-root` (key: `password`)
- Nur für Admin-Tasks nötig

### App-User Passwörter
- Werden beim ersten Helm Deploy generiert (`randAlphaNum 24`)
- Mit `helm.sh/resource-policy: keep` Annotation geschützt
- Passwörter sind stabil nach dem ersten Deploy (keine Rotation bei Upgrades)
- Der mariadb-operator überwacht die Secrets (Label `k8s.mariadb.com/watch`) und synchronisiert DB-User-Passwörter automatisch

## Troubleshooting

**Connection pending?**
```bash
kubectl describe connection todoapp-rw -n myapp
```

**User-Erstellung fehlgeschlagen?**
```bash
kubectl describe grant todoapp-rw-grant -n myapp
kubectl logs -l app.kubernetes.io/name=mariadb-operator -n mariadb-operator
```

**Secret hat wrong values?**
```bash
kubectl get secret todoapp-rw-dsn -o yaml
```

**Datenbank existiert nicht?**
```bash
kubectl describe mariadb todoapp -n myapp
# Auf status.phase warten bis Ready
```

## Version History

| Version | Änderungen |
|---|---|
| 0.8.0 | Array-basiertes Multi-DB Deployment, secretTemplate mit JDBC-URL, Longhorn default |
| 0.7.0 | Dynamische Naming, Connection CRs, lookup-stabile Passwörter, generate: true für root |
| 0.6.0 | Initiales Release mit einzelner DB pro Release |

## Support

Für Issues oder Fragen: siehe [automatic-funicular Repository](https://github.com/MartinWittlinger/automatic-funicular)
