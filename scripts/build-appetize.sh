#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DERIVED_DATA="$ROOT_DIR/build/DerivedData"
OUTPUT_DIR="$ROOT_DIR/build/Appetize"
APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/HabitVotes.app"
ZIP_PATH="$OUTPUT_DIR/HabitVotes-Appetize.zip"
LOG_PATH="$OUTPUT_DIR/xcodebuild.log"

rm -rf "$DERIVED_DATA" "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

xcodebuild \
  -project "$ROOT_DIR/HabitVotes.xcodeproj" \
  -scheme HabitVotes \
  -configuration Debug \
  -sdk iphonesimulator \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO \
  build 2>&1 | tee "$LOG_PATH"

if [ ! -d "$APP_PATH" ]; then
  echo "Expected app was not created at: $APP_PATH" >&2
  exit 1
fi

(
  cd "$(dirname "$APP_PATH")"
  zip -qry "$ZIP_PATH" "$(basename "$APP_PATH")"
)

echo "Created $ZIP_PATH"
