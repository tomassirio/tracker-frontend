# Use nginx to serve the pre-built static files
FROM nginx:alpine

# Copy the pre-built web app (built in GitHub Actions) to nginx html directory
COPY build/web /usr/share/nginx/html

# Copy custom nginx configuration
COPY docker/nginx/nginx.conf /etc/nginx/conf.d/default.conf

# Copy and set up entrypoint script
COPY docker/scripts/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Expose port 51538
EXPOSE 51538

# Use custom entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]
