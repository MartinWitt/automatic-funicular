# 🚋 Automatic Funicular 🚋
## *All Aboard the Cheapest Harbor in the Helm Universe!*

Welcome to the **Automatic Funicular** - where Helm charts go to catch a ride up the steep slopes of Kubernetes complexity! 🏔️

This repository is basically a discount warehouse for utility Helm charts. Think of it as the maritime equivalent of a dollar store, but for your containerized dreams. We don't promise luxury, but we guarantee functionality (and maybe a chuckle or two).

## 🛟 What's Docked at This Fine Harbor?

### ⚓ ingressutil
*"Because setting up ingresses shouldn't feel like navigating through a storm"*

Our star attraction! This little beauty is a library chart that creates standardized ingress resources with TLS certificates. It's like having a lighthouse guide your traffic safely to shore, complete with fancy SSL certificates that would make even the most paranoid sea captain proud.

**Features:**
- 🔒 Automatic TLS certificate management (because security is not a joke, unlike this README)
- 🎯 Configurable routing (your packets will never get lost at sea)
- 📝 Customizable annotations (for when you need to leave notes for future sailors)
- 🚢 Supports custom service names and ports (flexible as a ship's rigging)

## 🚂 How to Ride This Funicular

### Step 1: Add This Harbor to Your Fleet
```bash
helm repo add automatic-funicular https://github.com/MartinWitt/automatic-funicular
helm repo update
```

### Step 2: All Aboard! (Using the ingressutil chart)

Create a `values.yaml` file for your journey:

```yaml
ingress:
  enabled: true
  subdomain: "my-awesome-app"
  baseUrl: "example.com"
  port: 80
  clusterIssuer: "letsencrypt-prod"  # or whatever certificate fairy you trust
  
  # Optional goodies (because we're generous like that)
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/rate-limit: "100"  # keep the traffic civilized
```

Then deploy it like a boss:

```bash
helm install my-ingress automatic-funicular/ingressutil -f values.yaml
```

## 🎭 Why "Automatic Funicular"?

Great question! A funicular is a cable railway that helps you get up steep hills without breaking a sweat. Similarly, these Helm charts help you get up the steep learning curve of Kubernetes ingress management without breaking your sanity. The "automatic" part is because we like to pretend everything just works magically (spoiler: it usually does).

## 🤝 Contributing to This Magnificent Harbor

Found a bug? Want to add another chart to our collection? Think our jokes are terrible? 

1. Fork this repository (it's free, unlike most harbors)
2. Create a feature branch (`git checkout -b my-awesome-chart`)
3. Add your changes (make them funnier than what's here)
4. Submit a pull request (we promise to review it faster than a funicular going downhill)

## ⚠️ Warning Labels

- This harbor operates on a "works on my machine" basis
- No charts were harmed in the making of this repository
- Side effects may include: increased productivity, reduced Kubernetes stress, and uncontrollable urge to make more nautical puns
- Not suitable for production environments where humor is prohibited

## 📜 License

This project is licensed under the "Do Whatever You Want With It" license. Seriously, we're just happy someone found this useful enough to read this far.

---

*"Life's too short for boring Helm charts"* ⛵

*Made with ❤️ (and way too much caffeine) by someone who thinks funiculars are cooler than they probably are.*
