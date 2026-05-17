#!/usr/bin/env bash

LOG_FILE="build_errors.log"

run_build() {
    echo "=========================================================="
    echo " Google Cloud Shell - Native Flutter APK Build Script"
    echo " Logging all output and errors to: $LOG_FILE"
    echo "=========================================================="

    # Do not exit immediately on error so we can capture the final status and output
    set +e

    # 1. Clean previous failed builds and caches
    echo "🧹 [1/4] Cleaning previous builds..."
    flutter clean

    # 2. Safely regenerate ONLY the necessary platform files to perfectly match 
    #    YOUR Google Cloud Shell's local Flutter SDK version. 
    echo "✨ [2/4] Regenerating and repairing platform files (Android, iOS)..."
    rm -rf android/build.gradle android/app/build.gradle android/settings.gradle android/gradle/
    flutter create . --platforms=android,ios,web --org com.example

    # 3. Pull in all pub packages
    echo "📦 [3/4] Fetching dependencies..."
    flutter pub get

    # 4. Trigger the native Release APK build
    echo "🔨 [4/4] Building Flutter APK (Release)..."
    # Using the verbose (-v) flag to capture deep gradle stacktraces and detailed errors
    flutter build apk --release -v

    BUILD_STATUS=$?

    echo "=========================================================="
    if [ $BUILD_STATUS -eq 0 ]; then
        echo "✅ Build Complete Successfully!"
        echo " Your APK is located at: build/app/outputs/flutter-apk/app-release.apk"
    else
        echo "❌ Build Failed with exit code $BUILD_STATUS!"
        echo " All error logs have been saved to '$LOG_FILE'."
        echo " Please open the '$LOG_FILE' file, copy its contents,"
        echo " and provide them to AI Studio to troubleshoot the error."
    fi
    echo "=========================================================="

    return $BUILD_STATUS
}

# Clear previous log file if it exists
> "$LOG_FILE"

# Run the build function, capture ALL output using tee, and return the real status
run_build 2>&1 | tee -a "$LOG_FILE"
exit ${PIPESTATUS[0]}
