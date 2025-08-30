# mariadb — Library chart guide (single database)

Overview
- This chart is a library that renders a single MariaDB custom resource and a matching Secret from a `database` object in charts/mariadb/values.yaml.
- No global defaults are used unless noted; the templates provide sensible defaults for many fields and will auto-generate passwords when omitted.

Files under charts/mariadb
- Chart.yaml (type: library)
- values.yaml (example values showing the single `database` block)
- values.schema.json (JSON Schema for editor autocompletion)
- templates/mariadb.yaml (renders one MariaDB CR from .Values.database)
- secrets.yaml (renders the Secret from .Values.database)

Values reference
Below are all supported keys under the top-level `database` block. Types and defaults are listed where applicable.

- enabled (boolean)
  - default: false
  - description: Enable rendering of the MariaDB CR and Secret.

- name (string)
  - default: "mariadb"
  - description: Kubernetes resource name for the MariaDB CR and used as a label on the Secret. Used to derive a default secretName when secretName is not set.

- secretName (string)
  - default: "<name>-user" (where <name> is the value of `name`)
  - description: Name of the Secret resource that will contain username/password/root-password. If omitted, the chart will use "<name>-user".

- database (string)
  - default: "appdb"
  - description: Logical database name that the MariaDB CR should create/manage.

- username (string)
  - default: "root"
  - description: Database user the MariaDB operator will create/ensure exists and which will be stored in the Secret.

- password (string)
  - default: omitted
  - description: Plain-text password to store in the Secret for `username`. If omitted, the template will generate a random password at render time (randAlphaNum).

- rootPassword (string)
  - default: omitted
  - description: Plain-text root password to store in the Secret. If omitted, the template will generate a random password at render time.

- replicas (integer)
  - default: 1
  - description: Number of MariaDB replicas to request in the MariaDB CR spec.

- port (integer)
  - default: 3306
  - description: TCP port the MariaDB instance listens on.

- storage (object)
  - size (string)
    - default: "1Gi"
    - description: Persistent volume claim size for the MariaDB storage.
  - storageClassName (string)
    - default: "local-path"
    - description: StorageClass to use for the PVC.

- resources (object)
  - requests (object)
    - cpu (string)
      - default: "100m"
      - description: CPU request for the MariaDB pods.
    - memory (string)
      - default: "256Mi"
      - description: Memory request for the MariaDB pods.
  - limits (object)
    - cpu (string)
      - default: "500m"
      - description: CPU limit for the MariaDB pods.
    - memory (string)
      - default: "512Mi"
      - description: Memory limit for the MariaDB pods.

Behavior notes
- Password generation: when `password` or `rootPassword` is not provided the chart uses Helm's randAlphaNum() function during template rendering to generate values. These values are different on each render unless you provide explicit passwords.
- Defaults: the templates include safe defaults for name, secretName, database, username, replicas, port, storage and resource values so you can enable the chart with minimal configuration.
- Operator requirement: the chart renders k8s.mariadb.com/v1alpha1 MariaDB resources — you must have the MariaDB operator/CRD installed in the target cluster for the CR to be usable.

Examples
- Minimal enable (let chart generate passwords):
  helm template my-release ./charts/mariadb \
    --set database.enabled=true \
    --set database.name=keycloak-mariadb \
    --set database.database=keycloak \
    --set database.username=keycloak \
    --show-only charts/mariadb/templates/mariadb.yaml,charts/mariadb/secrets.yaml

- Provide explicit credentials and overrides (deterministic):
  helm template my-release ./charts/mariadb \
    -f charts/mariadb/values.yaml \
    --set database.enabled=true \
    --set database.name=keycloak-mariadb \
    --set database.secretName=keycloak-mariadb-user \
    --set database.database=keycloak \
    --set database.username=keycloak \
    --set database.password=supersecret \
    --set database.rootPassword=verysecret

Notes and recommendations
- For CI reproducibility or audits, prefer supplying explicit passwords from a secure source instead of relying on randAlphaNum during templating.
- If you plan to deploy multiple databases, consider creating a wrapper chart that depends on this library and instantiates multiple MariaDB resources using subcharts or generated templates.

If you want, I can also add a small example parent chart that includes mariadb as a dependency and demonstrates values-only multi-database deployment.
