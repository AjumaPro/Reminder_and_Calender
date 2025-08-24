#!/bin/bash

echo "Generating Hive adapters..."
flutter packages pub run build_runner build --delete-conflicting-outputs

echo "Build complete!" 