#!/usr/bin/env bash
set -euo pipefail

SCHEME="Textual (Standard Release)"
PROJECT="Sources/App/Textual App.xcodeproj"
BUILD_DIR="$(pwd)/build"
DERIVED_DATA="$BUILD_DIR/DerivedData"

# To sign with a real cert instead of ad-hoc, pass CODE_SIGN_IDENTITY:
#   CODE_SIGN_IDENTITY="Apple Development: you@example.com" ./build.sh
# Default ad-hoc identity is set in Configurations/Build/Code Signing Identity.xcconfig.

echo "Building Textual..."
echo "  Scheme: $SCHEME"
echo "  Output: $BUILD_DIR/Textual.app"
echo ""

EXTRA_ARGS=()
if [[ -n "${CODE_SIGN_IDENTITY:-}" ]]; then
    EXTRA_ARGS+=("CODE_SIGN_IDENTITY=$CODE_SIGN_IDENTITY")
fi

xcodebuild \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -destination "platform=macOS,arch=arm64" \
    -derivedDataPath "$DERIVED_DATA" \
    CONFIGURATION_BUILD_DIR="$BUILD_DIR" \
    "${EXTRA_ARGS[@]}" \
    build

echo ""
echo "Done. App at: $BUILD_DIR/Textual.app"
