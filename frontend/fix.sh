#!/bin/bash
# Run this from: ~/GitHub\ Projects/game/frontend
# Usage: bash fix.sh

echo "🔧 Fixing Teen Patti project..."

# 1. Create correct folder structure
mkdir -p lib/game lib/screens lib/providers lib/config

# 2. Copy all dart files from the fix folder
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cp "$SCRIPT_DIR/lib/game/"*.dart lib/game/
cp "$SCRIPT_DIR/lib/screens/"*.dart lib/screens/
cp "$SCRIPT_DIR/lib/providers/"*.dart lib/providers/
cp "$SCRIPT_DIR/lib/config/"*.dart lib/config/
cp "$SCRIPT_DIR/lib/main.dart" lib/
cp "$SCRIPT_DIR/pubspec.yaml" .

# 3. Clean old build artifacts
flutter clean
rm -rf .dart_tool

# 4. Get dependencies
flutter pub get

# 5. Build
echo "🏗️  Building web app..."
flutter build web --release

echo "✅ Done! Check build/web folder"
