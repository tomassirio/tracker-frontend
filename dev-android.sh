#!/bin/bash

# Android Development Script
# This script helps run the Flutter app on Android with proper configuration

set -e

echo "🤖 Starting Android Development Environment"
echo "==========================================="

# Load environment variables from .env file if it exists
if [ -f .env ]; then
    echo "📝 Loading environment variables from .env file..."
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "⚠️  No .env file found. Using default values."
    echo "   Create a .env file with the following variables:"
    echo "   - GOOGLE_MAPS_API_KEY"
    echo "   - COMMAND_BASE_URL (optional)"
    echo "   - QUERY_BASE_URL (optional)"
    echo "   - AUTH_BASE_URL (optional)"
fi

# Set default values if not provided
COMMAND_URL="${COMMAND_BASE_URL:-http://10.0.2.2:8081/api/1}"
QUERY_URL="${QUERY_BASE_URL:-http://10.0.2.2:8082/api/1}"
AUTH_URL="${AUTH_BASE_URL:-http://10.0.2.2:8083/api/1}"
MAPS_KEY="${GOOGLE_MAPS_API_KEY:-YOUR_GOOGLE_MAPS_API_KEY_HERE}"

echo ""
echo "📡 API Configuration:"
echo "   Command URL: $COMMAND_URL"
echo "   Query URL:   $QUERY_URL"
echo "   Auth URL:    $AUTH_URL"
echo "   Maps Key:    ${MAPS_KEY:0:20}..."
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    echo "   Please install Flutter from https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check for connected Android devices
echo "📱 Checking for Android devices..."
DEVICES=$(flutter devices | grep android)

if [ -z "$DEVICES" ]; then
    echo "❌ No Android devices found"
    echo ""
    echo "   Please either:"
    echo "   1. Start an Android emulator: flutter emulators --launch <emulator_id>"
    echo "   2. Connect a physical Android device with USB debugging enabled"
    echo ""
    echo "   Available emulators:"
    flutter emulators
    exit 1
fi

echo "✅ Found Android device(s):"
echo "$DEVICES"
echo ""

# Run Flutter app with environment variables
echo "🚀 Starting Flutter app on Android..."
echo ""

# Export environment variables for the build
export COMMAND_BASE_URL="$COMMAND_URL"
export QUERY_BASE_URL="$QUERY_URL"
export AUTH_BASE_URL="$AUTH_URL"
export GOOGLE_MAPS_API_KEY="$MAPS_KEY"

# Run the app
flutter run -d android

echo ""
echo "✅ Development session ended"
