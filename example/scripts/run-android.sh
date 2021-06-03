#!/usr/bin/env bash

flutter build apk --debug --target-platform=android-arm,android-arm64
flutter run -d $1 --use-application-binary=build/app/outputs/apk/debug/app-debug.apk
