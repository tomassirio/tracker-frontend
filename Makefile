I.PHONY: help format analyze test verify clean build run

# Default target
help:
	@echo "Available commands:"
	@echo "  make verify    - Run format, analyze, and test (like mvn verify)"
	@echo "  make format    - Format all Dart code"
	@echo "  make analyze   - Run static analysis"
	@echo "  make test      - Run all tests"
	@echo "  make clean     - Clean build artifacts"
	@echo "  make build     - Build the web application"
	@echo "  make run       - Run the application in Chrome"
	@echo "  make docker    - Build Docker image"

# Main verification command (equivalent to mvn spotless:apply clean verify)
verify: format analyze test
	@echo "✅ All checks passed!"

# Format all Dart code
format:
	@echo "🎨 Formatting Dart code..."
	@dart format .

# Run static analysis
analyze:
	@echo "🔍 Running static analysis..."
	@flutter analyze

# Run all tests with coverage
test:
	@echo "🧪 Running tests..."
	@flutter test --coverage

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	@flutter clean
	@rm -rf build/
	@rm -rf .dart_tool/

# Build web application
build:
	@echo "🏗️  Building web application..."
	@flutter build web --release

# Run application in Chrome
run:
	@echo "🚀 Running application..."
	@flutter run -d chrome

# Build Docker image
docker:
	@echo "🐳 Building Docker image..."
	@docker build -f docker/Dockerfile -t tracker-frontend:latest .

# Full clean + verify
clean-verify: clean verify

# Watch mode for tests
test-watch:
	@echo "👀 Running tests in watch mode..."
	@flutter test --coverage --watch

