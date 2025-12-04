# Monitoring Setup Guide

This guide explains how to deploy and use the monitoring stack (Prometheus + Grafana) for the app-demo application.

## Prerequisites

- EKS cluster running
- `kubectl` configured to access the cluster
- Helm 3 installed

## Installation Steps

### 1. Install Helm (if not already installed)

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

### 2. Add Helm Repositories

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

### 3. Create Monitoring Namespace

```bash
kubectl apply -f k8s/monitoring-namespace.yaml
```

### 4. Install Prometheus

```bash
helm install prometheus prometheus-community/prometheus \
  --namespace monitoring \
  --values k8s/prometheus-values.yaml
```

### 5. Install Grafana

```bash
helm install grafana grafana/grafana \
  --namespace monitoring \
  --values k8s/grafana-values.yaml
```

## Accessing the Dashboards

### Get Prometheus URL

```bash
kubectl get svc -n monitoring prometheus-server
```

Access Prometheus at the LoadBalancer external IP on port 80.

### Get Grafana URL and Password

```bash
# Get the LoadBalancer URL
kubectl get svc -n monitoring grafana

# Get the admin password (default: admin)
kubectl get secret -n monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

Access Grafana at the LoadBalancer external IP:

- **Username**: `admin`
- **Password**: Use the password from the command above (or `admin` if using our values file)

## Viewing Metrics

### 1. Application Metrics Endpoint

Your Flask app now exposes metrics at:

```
http://<app-service-url>/metrics
```

### 2. Prometheus Targets

In Prometheus UI, go to **Status → Targets** to verify that your app pods are being scraped.

### 3. Grafana Dashboard

1. Log in to Grafana
2. Go to **Dashboards**
3. You should see "App Demo Metrics" dashboard pre-configured
4. View request rates and latencies

## Key Metrics Available

- `flask_http_request_total` - Total HTTP requests
- `flask_http_request_duration_seconds` - Request latency
- `flask_http_request_exceptions_total` - Failed requests

## Troubleshooting

### Prometheus not scraping pods

Check pod annotations:

```bash
kubectl describe pod -l app=app-demo
```

Verify annotations are present:

```yaml
prometheus.io/scrape: "true"
prometheus.io/port: "5000"
prometheus.io/path: "/metrics"
```

### Grafana datasource not working

Verify Prometheus service name:

```bash
kubectl get svc -n monitoring
```

The datasource URL should match: `http://prometheus-server.monitoring.svc.cluster.local`
