#!/bin/bash

# Development Setup Script for Flutter Component Library
# This script sets up the development environment with pre-commit hooks
# and installs necessary dependencies for CDN deployment.

set -e

echo "🚀 Setting up Flutter Component Library Development Environment..."

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}❌ Error: Not in a git repository${NC}"
    exit 1
fi

echo -e "${BLUE}📦 Installing Flutter dependencies...${NC}"
flutter pub get

echo -e "${BLUE}🔧 Setting up pre-commit hooks...${NC}"

# Create .git/hooks directory if it doesn't exist
mkdir -p .git/hooks

# Create pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash

# Pre-commit hook for Flutter Component Library
echo "🔍 Running pre-commit checks..."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to run command and check result
run_check() {
    local cmd="$1"
    local desc="$2"

    echo -e "${YELLOW}Running: $desc${NC}"
    if eval "$cmd"; then
        echo -e "${GREEN}✅ $desc passed${NC}"
        return 0
    else
        echo -e "${RED}❌ $desc failed${NC}"
        echo -e "${RED}Please fix the issues before committing${NC}"
        return 1
    fi
}

# Check if we're committing changes to components directory
COMPONENTS_CHANGED=$(git diff --cached --name-only | grep -E "^lib/components/" | wc -l)

if [ "$COMPONENTS_CHANGED" -gt 0 ]; then
    echo -e "${BLUE}📦 Component changes detected, running extended checks...${NC}"

    # Format changed Dart files
    STAGED_DART_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep "\.dart$" | tr '\n' ' ')
    if [ -n "$STAGED_DART_FILES" ]; then
        echo -e "${YELLOW}🧹 Formatting staged Dart files...${NC}"
        dart format --set-exit-if-changed $STAGED_DART_FILES

        # Re-stage formatted files
        git add $STAGED_DART_FILES
    fi

    # Run analysis on component files
    if ! run_check "flutter analyze --fatal-infos --fatal-warnings lib/components/" "Dart Analysis"; then
        exit 1
    fi

    # Run tests
    if ! run_check "flutter test" "Flutter Tests"; then
        exit 1
    fi

    # Build registry to test the build process
    if ! run_check "dart run build_registry.dart" "Registry Build"; then
        exit 1
    fi

    echo -e "${GREEN}✅ All pre-commit checks passed!${NC}"
else
    echo -e "${BLUE}ℹ️  No component changes detected, running basic checks...${NC}"

    # Basic formatting and analysis
    STAGED_DART_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep "\.dart$" | tr '\n' ' ')
    if [ -n "$STAGED_DART_FILES" ]; then
        dart format --set-exit-if-changed $STAGED_DART_FILES
        git add $STAGED_DART_FILES
    fi

    flutter analyze
fi

echo -e "${GREEN}🎉 Pre-commit checks completed successfully!${NC}"
exit 0
EOF

# Make pre-commit hook executable
chmod +x .git/hooks/pre-commit

echo -e "${BLUE}🔨 Creating additional development scripts...${NC}"

# Create a development test script
cat > scripts/test-all.sh << 'EOF'
#!/bin/bash

# Comprehensive testing script for Flutter Component Library

echo "🧪 Running comprehensive tests..."

echo "📊 Running unit and widget tests..."
flutter test --coverage

echo "🔍 Running static analysis..."
flutter analyze

echo "🧹 Running format check..."
dart format --set-exit-if-changed .

echo "📦 Building component registry..."
dart run build_registry.dart

echo "✅ All tests completed!"
echo "📈 Coverage report generated in coverage/"
EOF

chmod +x scripts/test-all.sh

# Create a clean build script
cat > scripts/clean-build.sh << 'EOF'
#!/bin/bash

# Clean build script for development

echo "🧹 Cleaning previous builds..."

# Clean Flutter build cache
flutter clean

# Remove generated dist directory
rm -rf dist/

# Remove coverage directory
rm -rf coverage/

echo "📦 Installing dependencies..."
flutter pub get

echo "🔨 Building component registry..."
dart run build_registry.dart

echo "✅ Clean build completed!"
EOF

chmod +x scripts/clean-build.sh

# Create deployment script for manual testing
cat > scripts/deploy-test.sh << 'EOF'
#!/bin/bash

# Test deployment script (for development testing only)

echo "🚀 Preparing for test deployment..."

# Build registry
dart run build_registry.dart

# Validate dist structure
if [ ! -f "dist/registry.json" ]; then
    echo "❌ Registry file not found!"
    exit 1
fi

echo "📋 Registry summary:"
jq -r '.registry | "Name: \(.name)\nVersion: \(.version)\nComponents: \(.totalComponents)"' dist/registry.json

echo "🗂️ Files in dist:"
find dist -type f | sort

echo "📊 Registry validation:"
if jq empty dist/registry.json 2>/dev/null; then
    echo "✅ Registry JSON is valid"
else
    echo "❌ Registry JSON is invalid"
    exit 1
fi

echo "🌐 Ready for deployment!"
EOF

chmod +x scripts/deploy-test.sh

echo -e "${BLUE}📚 Setting up development documentation...${NC}"

# Create development README
cat > DEVELOPMENT.md << 'EOF'
# Development Guide

This document provides instructions for setting up the development environment and contributing to the Flutter Component Library.

## Prerequisites

- Flutter SDK 3.19.6 or later
- Dart SDK 3.3.4 or later
- Git
- jq (for JSON processing in scripts)

## Setup

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd my_custom_component
   ```

2. Run the setup script:
   ```bash
   chmod +x scripts/setup-dev.sh
   ./scripts/setup-dev.sh
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

## Development Workflow

### Making Changes

1. Make your changes to the components in `lib/components/`
2. The pre-commit hooks will automatically:
   - Format your code with `dart format`
   - Run static analysis with `flutter analyze`
   - Run tests with `flutter test`
   - Build the component registry to validate the build process

### Running Tests

```bash
# Run all tests with coverage
./scripts/test-all.sh

# Or run manually
flutter test --coverage
flutter analyze
```

### Building Registry

```bash
# Build the component registry
dart run build_registry.dart

# Clean build
./scripts/clean-build.sh
```

### Testing Deployment

```bash
# Test the deployment process locally
./scripts/deploy-test.sh
```

## Project Structure

```
my_custom_component/
├── lib/
│   └── components/           # Component files
├── dist/                     # Built files for CDN
│   ├── registry.json         # Component registry manifest
│   └── components/           # Copied component files
├── scripts/                 # Development scripts
├── test/                     # Test files
├── .github/workflows/        # CI/CD workflows
└── build_registry.dart      # Registry build script
```

## Registry Format

The `registry.json` file contains:

- Registry metadata (name, version, description)
- Component list with paths, versions, checksums
- Detailed component information including dependencies

Example:
```json
{
  "registry": {
    "name": "my_custom_component",
    "version": "1.0.0",
    "description": "Flutter component library",
    "totalComponents": 20
  },
  "components": {
    "button": {
      "path": "components/button.dart",
      "version": "1.0.0",
      "checksum": "sha256hash",
      "fileSize": 1234,
      "lastModified": "2025-10-26T21:26:23.640788"
    }
  }
}
```

## Code Quality

- All code must pass `flutter analyze` with no errors or warnings
- Tests should be added for new components
- Use `dart format` for consistent code formatting
- Follow the analysis options in `analysis_options.yaml`

## Deployment

The registry is automatically deployed to Cloudflare Pages when:

1. Changes are pushed to the `main` branch
2. A new tag is created (`v*.*.*`)

The deployment process is handled by the GitHub Actions workflow in `.github/workflows/ci-cd.yml`.
EOF

echo -e "${GREEN}✅ Development environment setup completed!${NC}"
echo ""
echo -e "${BLUE}📋 Available commands:${NC}"
echo "  • ./scripts/test-all.sh     - Run comprehensive tests"
echo "  • ./scripts/clean-build.sh  - Clean and build"
echo "  • ./scripts/deploy-test.sh  - Test deployment process"
echo "  • dart run build_registry.dart - Build component registry"
echo ""
echo -e "${YELLOW}💡 Pre-commit hooks are now active. They will run automatically when you commit.${NC}"
echo -e "${BLUE}📚 See DEVELOPMENT.md for detailed documentation.${NC}"