#!/usr/bin/env bash

LOG_FILE="build_errors.log"

# 1. Clear previous log file if it exists
> "$LOG_FILE"

# 2. FIX: Globally redirect all stdout and stderr into tee right out of the gate.
# This bypasses subshell buffering issues and guarantees every single character 
# hitting your terminal is instantly committed to the file.
exec > >(tee -i -a "$LOG_FILE") 2>&1

run_build() {
    echo "=========================================================="
    echo " Google Cloud Shell - Native Flutter APK Build Script"
    echo " Logging all output and errors to: $LOG_FILE"
    echo "=========================================================="

    # Do not exit immediately on error so we can capture the final status and output
    set +e

    # 0. Set up Android SDK
    echo "⚙️ [1/5] Setting up Android SDK..."
    export ANDROID_HOME="$HOME/android-sdk"
    export ANDROID_SDK_ROOT="$HOME/android-sdk"
    
    if [ ! -d "$ANDROID_HOME/cmdline-tools/latest/bin" ]; then
        echo "   Downloading Android SDK Command-line Tools..."
        mkdir -p "$ANDROID_HOME/cmdline-tools"
        wget -q "https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip" -O cmd-tools.zip
        unzip -q cmd-tools.zip -d "$ANDROID_HOME/cmdline-tools"
        rm cmd-tools.zip
        mv "$ANDROID_HOME/cmdline-tools/cmdline-tools" "$ANDROID_HOME/cmdline-tools/latest"
    fi

    export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"

    echo "   Accepting SDK licenses..."
    yes | "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --licenses > /dev/null 2>&1 || true

    echo "   Installing platform tools and build tools..."
    "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" "platform-tools" "platforms;android-34" "build-tools;34.0.0" > /dev/null 2>&1

    echo "   Configuring Flutter to use the SDK..."
    flutter config --android-sdk="$ANDROID_HOME"
    yes | flutter doctor --android-licenses > /dev/null 2>&1 || true

    # 1. Clean previous failed builds and caches
    echo "🧹 [2/5] Cleaning previous builds..."
    flutter clean

    # 2. Safely regenerate ONLY the necessary platform files to perfectly match 
    #    YOUR Google Cloud Shell's local Flutter SDK version. 
    echo "✨ [3/5] Regenerating and repairing platform files (Android, iOS)..."
    rm -rf android/build.gradle android/app/build.gradle android/settings.gradle android/gradle/
    flutter create . --platforms=android,ios,web --org com.example

    # 3. Pull in all pub packages
    echo "📦 [4/5] Fetching dependencies..."
    flutter pub get

    # 4. Trigger the native Release APK build
    echo "🔨 [5/5] Building Flutter APK (Release)..."
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

# Run the build function directly.
# (Global logging is already handled perfectly by the exec command above)
run_build
exit $?
