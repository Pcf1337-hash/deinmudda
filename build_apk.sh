#!/bin/bash

# APK Build Script for Konsum Tracker Pro
# This script builds the Android APK with optimized settings to prevent installation issues

echo "🔧 Building Android APK for Konsum Tracker Pro..."
echo "📋 Configuration:"
echo "   - Compile SDK: 35"
echo "   - Target SDK: 35"
echo "   - Minification: Disabled (to prevent APK corruption)"
echo "   - Resource Shrinking: Disabled"
echo "   - Signing: Debug keystore included"
echo ""

# Clean previous builds
echo "🧹 Cleaning previous builds..."
if command -v flutter &> /dev/null; then
    flutter clean
fi

cd android
if command -v ./gradlew &> /dev/null; then
    ./gradlew clean
else
    gradle clean
fi
cd ..

# Get dependencies
echo "📦 Getting Flutter dependencies..."
if command -v flutter &> /dev/null; then
    flutter pub get
else
    echo "⚠️  Flutter not found in PATH. Please install Flutter first."
    echo "    Download from: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Build APK
echo "🏗️  Building APK..."
flutter build apk --release

# Check if build was successful
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    echo "✅ APK build successful!"
    echo "📱 APK location: build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    echo "🔍 APK Info:"
    ls -lh build/app/outputs/flutter-apk/app-release.apk
    echo ""
    echo "📋 Installation Instructions:"
    echo "   1. Enable 'Unknown Sources' in Android Settings > Security"
    echo "   2. Transfer the APK to your Android device"
    echo "   3. Open the APK file and install"
    echo ""
    echo "🐛 If you still get 'invalid package' error, try:"
    echo "   - Restart your Android device"
    echo "   - Clear installer cache: Settings > Apps > Package Installer > Storage > Clear Cache"
    echo "   - Try installing via ADB: adb install -r app-release.apk"
else
    echo "❌ APK build failed!"
    echo "💡 Common solutions:"
    echo "   - Check that Android SDK is properly installed"
    echo "   - Ensure Java 8 or 11 is installed"
    echo "   - Run 'flutter doctor' to check for issues"
    exit 1
fi