.PHONY: help format analyze test verify clean build run docker clean-verify test-watch

# Default target
help:
	@echo "Available commands:"
	@echo "  make verify       - Run format, analyze, and test (like mvn verify)"
	@echo "  make format       - Format all Dart code"
	@echo "  make analyze      - Run static analysis"
	@echo "  make test         - Run all tests"
	@echo "  make test-watch   - Run tests continuously (re-run on file changes)"
	@echo "  make clean        - Clean build artifacts"
	@echo "  make build        - Build the web application"
	@echo "  make run          - Run the application in Chrome"
	@echo "  make docker       - Build Docker image"
	@echo "  make clean-verify - Clean and verify"

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

# Watch mode for tests (uses a simple loop since Flutter doesn't have native watch)
test-watch:
	@echo "👀 Running tests in watch mode (Ctrl+C to stop)..."
	@echo "Watching for file changes..."
	@while true; do \
		clear; \
		echo "🧪 Running tests... ($(shell date '+%H:%M:%S'))"; \
		flutter test --coverage || true; \
		echo "\n⏸️  Waiting for changes (press Ctrl+C to stop)..."; \
		sleep 3; \
	done
