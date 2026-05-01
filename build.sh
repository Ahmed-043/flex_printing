#!/bin/bash
# Download Flutter
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:`pwd`/flutter/bin"

# Get dependencies and build for web
flutter pub get
flutter build web