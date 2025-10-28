#!/bin/bash

# Build script for Quick Annotator

set -e

echo "Building Quick Annotator..."

# Clean previous builds
rm -rf build/

# Create build directory
mkdir -p build

# Compile all Swift files
swiftc -o build/QuickAnnotator \
    -sdk /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk \
    -target x86_64-apple-macosx12.0 \
    -framework Cocoa \
    -module-name QuickAnnotator \
    QuickAnnotator/main.swift \
    QuickAnnotator/AppDelegate.swift \
    QuickAnnotator/Models/Annotation.swift \
    QuickAnnotator/Models/CircleAnnotation.swift \
    QuickAnnotator/Models/TextAnnotation.swift \
    QuickAnnotator/Managers/AnnotationManager.swift \
    QuickAnnotator/Managers/ClipboardManager.swift \
    QuickAnnotator/Managers/HistoryStore.swift \
    QuickAnnotator/Views/CanvasView.swift \
    QuickAnnotator/Views/CanvasView+MouseHandling.swift \
    QuickAnnotator/Views/MainViewController.swift \
    QuickAnnotator/Views/ToolbarView.swift

echo "✅ Build completed successfully!"
echo "Binary located at: build/QuickAnnotator"
echo ""
echo "To create an app bundle, use Xcode or run:"
echo "  xcodebuild -project QuickAnnotator.xcodeproj -scheme QuickAnnotator -configuration Release"
