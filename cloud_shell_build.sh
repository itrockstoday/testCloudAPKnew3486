#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "=========================================================="
echo " Google Cloud Shell - Native Flutter APK Build Script"
echo "=========================================================="

# 1. Clean previous failed builds and caches
echo "🧹 [1/4] Cleaning previous builds..."
flutter clean

# 2. Safely regenerate ONLY the necessary platform files to perfectly match 
#    YOUR Google Cloud Shell's local Flutter SDK version. 
#    This eliminates all the Gradle/Kotlin version mismatch errors you've been seeing.
echo "✨ [2/4] Regenerating and repairing platform files (Android, iOS)..."
# Taking out the currently corrupted nested gradle config to let Flutter rebuild it perfectly
rm -rf android/build.gradle android/app/build.gradle android/settings.gradle android/gradle/
flutter create . --platforms=android,ios,web --org com.example

# 3. Pull in all pub packages
echo "📦 [3/4] Fetching dependencies..."
flutter pub get

# 4. Trigger the native Release APK build
echo "🔨 [4/4] Building Flutter APK (Release)..."
flutter build apk --release

echo "=========================================================="
echo "✅ Build Complete!"
echo " Your APK is located at: build/app/outputs/flutter-apk/app-release.apk"
echo " You can download it directly from your Cloud Shell console using the file explorer."
echo "=========================================================="
