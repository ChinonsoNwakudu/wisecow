# Cow wisdom web server

## Wisecow Application - Kubernetes Deployment Guide

This guide will help you **containerize**, **deploy**, and **secure** the Wisecow application on a local Kubernetes cluster (Minikube).  
You will also set up TLS for secure HTTPS access using a locally trusted certificate.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [1. Clone the Repository](#1-clone-the-repository)
- [2. Build and Push the Docker Image](#2-build-and-push-the-docker-image)
- [3. Start Minikube](#3-start-minikube)
- [4. Deploy Wisecow to Kubernetes](#4-deploy-wisecow-to-kubernetes)
- [5. Set Up TLS with mkcert](#5-set-up-tls-with-mkcert)
- [6. Create the TLS Secret](#6-create-the-tls-secret)
- [7. Update /etc/hosts](#7-update-etchosts)
- [8. Start Minikube Tunnel](#8-start-minikube-tunnel)
- [9. Access the Application](#9-access-the-application)
- [10. CI/CD Pipeline](#10-cicd-pipeline)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

- [Docker](https://www.docker.com/products/docker-desktop/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Minikube](https://minikube.sigs.k8s.io/docs/)
- [mkcert](https://github.com/FiloSottile/mkcert) (`brew install mkcert`)
- [GitHub account](https://github.com/)

---

## 1. Clone the Repository

```sh
git clone https://github.com/nyrahul/wisecow.git
cd wisecow
```

---

## 2. Build and Push the Docker Image

> **Note:** Update the image name as needed for your Docker Hub or registry.

```sh
docker build -t <your-dockerhub-username>/wisecow:latest .
docker push <your-dockerhub-username>/wisecow:latest
```

Update the `deployment.yaml` to use your image if necessary.

---

## 3. Start Minikube

```sh
minikube start
```

---

## 4. Deploy Wisecow to Kubernetes

Apply the manifests:

```sh
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml
```

---

## 5. Set Up TLS with mkcert

Install mkcert if you haven't:

```sh
brew install mkcert
mkcert -install
```

Generate a certificate for `wisecow.local`:

```sh
mkcert wisecow.local
```

This creates `wisecow.local.pem` and `wisecow.local-key.pem`.

---

## 6. Create the TLS Secret

```sh
kubectl create secret tls wisecow-tls \
  --cert=wisecow.local.pem \
  --key=wisecow.local-key.pem
```

If the secret already exists, update it:

```sh
kubectl create secret tls wisecow-tls \
  --cert=wisecow.local.pem \
  --key=wisecow.local-key.pem \
  --dry-run=client -o yaml | kubectl apply -f -
```

---

## 7. Update /etc/hosts

Add this line to your `/etc/hosts` file:

```
127.0.0.1 wisecow.local
```

Or, if using Minikube’s IP:

```sh
minikube ip
```
Then add:
```
<minikube-ip> wisecow.local
```

---

## 8. Start Minikube Tunnel

In a new terminal window, run:

```sh
minikube tunnel
```

Leave this running.

---

## 9. Access the Application

Open your browser and go to:

```
https://wisecow.local
```

You should see the Wisecow app with a secure padlock (no warning).

---

## 10. Automated CI/CD with GitHub Actions Self-Hosted Runner

This project uses a **self-hosted GitHub Actions runner** on your local machine to enable full CI/CD automation with Minikube.  
Every push to the `main` branch will:

1. Build and push the Docker image to Docker Hub.
2. Automatically deploy the latest image to your local Minikube cluster using `kubectl apply`.

### How to Set Up the Self-Hosted Runner

1. **Register the runner:**
   - Go to your repository on GitHub → Settings → Actions → Runners → New self-hosted runner.
   - Follow the instructions for your OS (macOS/Linux/Windows).

2. **Start the runner:**
   ```sh
   cd actions-runner
   ./run.sh
   ```

3. **Add your Minikube kubeconfig as a GitHub secret:**
   - Copy the contents of `~/.kube/config`.
   - Go to GitHub → Settings → Secrets and variables → Actions → New repository secret.
   - Name it `KUBECONFIG` and paste the contents.

4. **Add your Docker Hub credentials as secrets:**
   - `DOCKERHUB_USERNAME`
   - `DOCKERHUB_TOKEN`

5. **Ensure your `.github/workflows/deploy.yaml` uses `runs-on: self-hosted` for both jobs.**

Now, every push to `main` will trigger a build and deploy to your local Minikube cluster automatically!

> **Note:** The self-hosted runner must be running on the same machine as your Minikube cluster and have access to Docker and kubectl.

---
---

## Troubleshooting

- **Browser says "Not Secure":**  
  Make sure you used `mkcert` and created the secret as above.
- **Cannot access `wisecow.local`:**  
  - Check `/etc/hosts` entry.
  - Ensure `minikube tunnel` is running.
  - Check Ingress and Service status:
    ```sh
    kubectl get ingress
    kubectl get svc
    ```
- **TLS Secret errors:**  
  Update the secret as shown in step 6.

---

## Notes

- Do **not** commit your certificate or key files (`wisecow.local.pem`, `wisecow.local-key.pem`). They are in `.gitignore`.
- Each user should generate their own certificate for local development.

---

**Enjoy your secure Wisecow deployment!**