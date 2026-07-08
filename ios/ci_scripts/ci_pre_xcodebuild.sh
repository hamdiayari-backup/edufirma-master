#!/bin/sh

# Fail this script if any subcommand fails.
set -e

cd "$CI_PRIMARY_REPOSITORY_PATH"

export PATH="$PATH:$HOME/flutter/bin"

# Refresh Flutter build metadata before Xcode compiles the app.
flutter pub get
flutter build ios --config-only --release

exit 0
