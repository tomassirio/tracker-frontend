# Tracker Frontend Helm Chart

Helm chart for deploying the Tracker Frontend with nginx reverse proxy to internal backend services.

## Quick Deploy

### Development
```bash
helm upgrade --install tracker-frontend-dev ./chart \
  --namespace wanderer-dev \
  --set nameSuffix=-dev \
  --set application.googleMapsApiKey="YOUR_API_KEY"
```

### Production
```bash
helm upgrade --install tracker-frontend ./chart \
  --namespace wanderer \
  --set application.googleMapsApiKey="YOUR_API_KEY"
```

## Architecture

The frontend uses **nginx as a reverse proxy** to connect to internal Kubernetes services:

- Browser requests `/api/query/trips/public` 
- Nginx proxies to `http://tracker-query-dev.wanderer-dev.svc.cluster.local:32002/api/1/trips/public`
- Backend services use **internal service names** (no ingress needed for backend-to-frontend communication)

This approach:
- ✅ Uses internal Kubernetes service discovery
- ✅ No need for external backend URLs
- ✅ Single domain for frontend and API
- ✅ Better security (backends don't need public ingress)
