# Docker Configuration

## Multi-Platform Support

The Docker images built by CI/CD support multiple platforms:
- **linux/amd64** (x86_64) - Standard servers and development machines
- **linux/arm64** (ARM64) - Raspberry Pi 3/4/5, AWS Graviton, Apple Silicon

Images from the GitHub Container Registry automatically work on both platforms.

## Building the Docker Image

### Using Docker directly:

For local platform (default):
```bash
docker build -f docker/Dockerfile -t tracker-frontend:latest .
```

For multi-platform builds (requires Docker Buildx):
```bash
docker buildx build --platform linux/amd64,linux/arm64 -f docker/Dockerfile -t tracker-frontend:latest .
```

### Using docker-compose:

```bash
cd docker
docker-compose build
```

## Running the Container

### Using Docker directly:

Run on port 51538 with Google Maps API key:
```bash
docker run -p 51538:51538 -e GOOGLE_MAPS_API_KEY=your_api_key_here tracker-frontend:latest
```

Run without Google Maps (if not needed):
```bash
docker run -p 51538:51538 tracker-frontend:latest
```

### Using docker-compose:

First, set your Google Maps API key as an environment variable:
```bash
export GOOGLE_MAPS_API_KEY=your_api_key_here
cd docker
docker-compose up
```

Or create a `.env` file in the docker directory:
```
GOOGLE_MAPS_API_KEY=your_api_key_here
```

Then run:
```bash
cd docker
docker-compose up
```

This will start the frontend on `http://localhost:51538`

## Port Configuration

The application is configured to run on port 51538 by default. This can be modified in:
- `docker-compose.yml`: Change the port mapping
- `nginx/nginx.conf`: Change the listen port

## Folder Structure

```
docker/
├── Dockerfile              # Main Dockerfile for building the application
├── docker-compose.yml      # Docker Compose configuration
├── DOCKER.md              # This documentation file
├── nginx/
│   └── nginx.conf         # Nginx configuration for serving the Flutter web app
└── scripts/
    └── docker-entrypoint.sh  # Entrypoint script for environment variable injection
```

