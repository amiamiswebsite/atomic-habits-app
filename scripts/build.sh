#!/bin/sh
set -eu

xcodebuild \
  -project HabitVotes.xcodeproj \
  -scheme HabitVotes \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  build
