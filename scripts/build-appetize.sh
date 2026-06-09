#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DERIVED_DATA="$ROOT_DIR/build/DerivedData"
OUTPUT_DIR="$ROOT_DIR/build/Appetize"
APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/HabitVotes.app"
ZIP_PATH="$OUTPUT_DIR/HabitVotes-Appetize.zip"
TAR_PATH="$OUTPUT_DIR/HabitVotes-Appetize.tar.gz"
LOG_PATH="$OUTPUT_DIR/xcodebuild.log"
PROJECT_FILE="$ROOT_DIR/HabitVotes.xcodeproj/project.pbxproj"
PROJECT_BACKUP="$OUTPUT_DIR/project.pbxproj.backup"

rm -rf "$DERIVED_DATA" "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"
cp "$PROJECT_FILE" "$PROJECT_BACKUP"

restore_project() {
  cp "$PROJECT_BACKUP" "$PROJECT_FILE"
}

trap restore_project EXIT

# Appetize needs only the main simulator .app bundle. The widget remains in the
# Xcode project, but is skipped here to avoid extension/app-group signing issues
# in anonymous CI simulator builds.
perl -0pi -e 's/\n\t\t\t\t10000000000000000000001E \/\* HabitVotesWidget\.appex in Embed Foundation Extensions \*\/,//' "$PROJECT_FILE"
perl -0pi -e 's/\n\t\t\t\t770000000000000000000001 \/\* PBXTargetDependency \*\/,//' "$PROJECT_FILE"

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
  tar -czf "$TAR_PATH" "$(basename "$APP_PATH")"
)

echo "Created $ZIP_PATH"
echo "Created $TAR_PATH"
