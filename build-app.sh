#!/bin/bash
set -e

# Configuration
APP_NAME="Launcher"
BUNDLE_ID="com.aiwangfeng.Launcher"
VERSION="1.0.0"

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/.build/release"
APP_BUNDLE="$SCRIPT_DIR/build/$APP_NAME.app"
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "🔨 Building release version..."
swift build -c release

echo "📦 Creating app bundle..."
rm -rf "$APP_BUNDLE"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Copy executable
cp "$BUILD_DIR/$APP_NAME" "$MACOS_DIR/"

# Copy resources bundle if exists
if [ -d "$BUILD_DIR/Launcher_Launcher.bundle" ]; then
    cp -r "$BUILD_DIR/Launcher_Launcher.bundle" "$RESOURCES_DIR/"
fi

# Copy icons
cp "$SCRIPT_DIR/icons/"*.png "$RESOURCES_DIR/" 2>/dev/null || true
cp "$SCRIPT_DIR/AppIcon.icns" "$RESOURCES_DIR/" 2>/dev/null || true

# Create Info.plist
cat > "$CONTENTS_DIR/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleDisplayName</key>
    <string>$APP_NAME</string>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
</dict>
</plist>
EOF

echo "✅ App bundle created at: $APP_BUNDLE"
echo ""
echo "To sign the app, run:"
echo "  codesign --deep --force --verify --verbose --sign \"Developer ID Application: YOUR_NAME (TEAM_ID)\" --options runtime --entitlements Launcher.entitlements \"$APP_BUNDLE\""
echo ""
echo "To notarize for distribution:"
echo "  1. Create a ZIP: ditto -c -k --keepParent \"$APP_BUNDLE\" Launcher.zip"
echo "  2. Submit: xcrun notarytool submit Launcher.zip --apple-id YOUR_APPLE_ID --password YOUR_APP_PASSWORD --team-id YOUR_TEAM_ID --wait"
echo "  3. Staple: xcrun stapler staple \"$APP_BUNDLE\""
