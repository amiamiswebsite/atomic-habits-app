#!/bin/sh
set -eu

(
  cd HabitVotesCore
  swift run HabitVotesCoreChecks
)

xcodebuild \
  -project HabitVotes.xcodeproj \
  -scheme HabitVotes \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  test
