#!/usr/bin/env bash

flutter build apk --release --target-platform=android-arm,android-arm64
flutter run -d $1 --use-application-binary=build/app/outputs/apk/release/app-release.apk
