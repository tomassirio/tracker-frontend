# Build stage
FROM ghcr.io/cirruslabs/flutter:stable AS build

# Set working directory
WORKDIR /app

# Copy pubspec file
COPY pubspec.yaml ./

# Get dependencies (this will generate pubspec.lock)
RUN flutter pub get

# Copy the rest of the application
COPY . .

# Build web application
RUN flutter build web --release

# Runtime stage - use nginx to serve the static files
FROM nginx:alpine

# Copy the built web app to nginx html directory
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy custom nginx configuration
COPY docker/nginx/nginx.conf /etc/nginx/conf.d/default.conf

# Copy and set up entrypoint script
COPY docker/scripts/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Expose port 51538
EXPOSE 51538

# Use custom entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]

