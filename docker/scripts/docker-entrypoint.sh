#!/bin/sh
set -e

INDEX_FILE="/usr/share/nginx/html/index.html"

# Create a backup of the original index.html if it doesn't exist
if [ ! -f "${INDEX_FILE}.template" ]; then
    cp "${INDEX_FILE}" "${INDEX_FILE}.template"
fi

# Restore from template for fresh substitution
cp "${INDEX_FILE}.template" "${INDEX_FILE}"

# Inject Google Maps API Key if provided
if [ -n "${GOOGLE_MAPS_API_KEY}" ]; then
    echo "Injecting Google Maps API Key into index.html"
    sed -i "s|{{GOOGLE_MAPS_API_KEY}}|${GOOGLE_MAPS_API_KEY}|g" "${INDEX_FILE}"
else
    echo "Warning: GOOGLE_MAPS_API_KEY not provided. Google Maps functionality may not work."
fi

# Inject backend URLs with defaults
# Use relative paths so the browser makes requests to the same origin (nginx proxy)
# This allows nginx to proxy to internal Kubernetes services
COMMAND_URL="${COMMAND_BASE_URL:-/api/command}"
QUERY_URL="${QUERY_BASE_URL:-/api/query}"
AUTH_URL="${AUTH_BASE_URL:-/api/auth}"

echo "Injecting backend URLs into index.html"
echo "  Command Base URL: ${COMMAND_URL}"
echo "  Query Base URL: ${QUERY_URL}"
echo "  Auth Base URL: ${AUTH_URL}"

sed -i "s|{{COMMAND_BASE_URL}}|${COMMAND_URL}|g" "${INDEX_FILE}"
sed -i "s|{{QUERY_BASE_URL}}|${QUERY_URL}|g" "${INDEX_FILE}"
sed -i "s|{{AUTH_BASE_URL}}|${AUTH_URL}|g" "${INDEX_FILE}"

echo "Starting nginx..."
exec nginx -g "daemon off;"

