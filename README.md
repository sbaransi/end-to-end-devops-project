# Hello DevOps Flask Application

A Python Flask application packaged with Docker and deployed to Kubernetes using the `helmchart` Helm chart.

## Endpoints

- `GET /` - displays the root greeting
- `GET /health` - health-check endpoint

The application listens on port `5000` by default.

## Run directly with Python

Python 3 with `venv` support is required. From the project root, create a virtual environment:

```bash
python3 -m venv venv
```

Activate the virtual environment on Linux or macOS:

```bash
source venv/bin/activate
```

Or activate it in Windows PowerShell:

```powershell
venv\Scripts\Activate.ps1
```

Then install the dependencies and run the application:

```bash
pip install -r requirements.txt
python3 app.py
```

Open <http://localhost:5000> or test from the terminal:

```bash
curl http://localhost:5000
curl http://localhost:5000/health
```

## Run with Docker

```bash
docker build -t flask-aws-monitor:local .
docker run --rm -p 5000:5000 flask-aws-monitor:local
```

## Deploy locally with Minikube and Helm

Run every command in this section from the directory that contains `Dockerfile`, `app.py`, and `helmchart` (the project root). Ensure Docker, Minikube, `kubectl`, and Helm are installed before continuing.

### 1. Start and verify Minikube

```bash
docker info
minikube start --driver=docker
minikube update-context
kubectl config use-context minikube
kubectl get nodes
```

The Minikube node must show `Ready` before continuing.

### 2. Build the image inside Minikube

```bash
minikube image build -t flask-aws-monitor:local .
minikube image ls
```

Expected image:
```text
docker.io/library/flask-aws-monitor:local
```

### 3. Validate and install the Helm chart

```bash
helm lint ./helmchart
helm template flask-monitor ./helmchart

helm upgrade --install flask-monitor ./helmchart --reset-values
```

### 4. Verify the Deployment

```bash
kubectl get deployment flask-monitor -o jsonpath='{.spec.template.spec.containers[0].image}{" "}{.spec.template.spec.containers[0].imagePullPolicy}{"\n"}'

kubectl get pods
kubectl get configmap flask-monitor-cm
kubectl rollout status deployment/flask-monitor
```

To update the Gunicorn configuration while preserving the current Service and Ingress settings, run for example:

```bash
helm upgrade flask-monitor ./helmchart --reuse-values --set config.gunicorn_workers=3 --set config.gunicorn_threads=4
```

The Deployment checksum changes automatically when the ConfigMap changes, so Helm creates replacement Pods with the updated environment variables.

### 5. Access the application using ClusterIP

```bash
kubectl port-forward service/flask-monitor 5000:5000
```

Keep that terminal open and browse to <http://localhost:5000>.

### 6. Optional: expose the application with a LoadBalancer

A `LoadBalancer` Service keeps its internal `ClusterIP` access and also adds an external address. Install or update the release with:

```bash
helm upgrade --install flask-monitor ./helmchart --reset-values --set service_type=LoadBalancer
```

Run the Minikube tunnel in a separate terminal and keep it open:

```bash
minikube tunnel
```

In another terminal, wait for the external address:

```bash
kubectl get service flask-monitor --watch
```

When the `EXTERNAL-IP` column is no longer `<pending>`, press `Ctrl+C` to stop watching. Replace `YOUR_EXTERNAL_IP` below with the displayed address:

```bash
curl http://YOUR_EXTERNAL_IP:5000/health
```

### 7. Optional: expose the application with Ingress

Enable the Minikube Ingress addon:

```bash
minikube addons enable ingress
```

Enable the chart's Ingress resource:

```bash
helm upgrade --install flask-monitor ./helmchart --reset-values --set ingress.enabled=true
```

Wait for the Ingress to become ready:

```bash
kubectl get ingress flask-monitor --watch
```

The default hostname is `flask-monitor.local`. Get the Minikube IP with `minikube ip`, then map that IP to `flask-monitor.local` in your system's hosts file (`/etc/hosts` on Linux/macOS, or `C:\Windows\System32\drivers\etc\hosts` on Windows).

Open <http://flask-monitor.local> in your browser.

## Deploy an updated application version

After changing `app.py` or the Dockerfile, rebuild the image and restart the Deployment:

```bash
minikube image build -t flask-aws-monitor:local .
kubectl rollout restart deployment/flask-monitor
kubectl rollout status deployment/flask-monitor
```

## Troubleshooting

If Kubernetes is unreachable:

```bash
minikube start --driver=docker
minikube update-context
kubectl config use-context minikube
```

If a Pod shows `ImagePullBackOff`, compare the available and configured images:

```bash
minikube image ls
kubectl get deployment flask-monitor -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

If a Pod shows `CrashLoopBackOff`, inspect its events and previous logs:

```bash
kubectl describe pods -l app=flask-monitor
kubectl logs -l app=flask-monitor --all-containers=true --prefix --previous --tail=100
```

## Upgrade and rollback

```bash
helm history flask-monitor
helm upgrade flask-monitor ./helmchart --reuse-values
helm rollback flask-monitor REVISION
```