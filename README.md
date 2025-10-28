# QSA (Quick Screenshot Annotator)

A lightweight MacOS native app for rapidly annotating screenshots with circles and text.

## Features

- ✅ Paste images from clipboard (CMD+V)
- ✅ Add circle outline annotations
- ✅ Add text annotations
- ✅ Three color presets (Red, Yellow, Cyan)
- ✅ Move and resize annotations
- ✅ Undo/Redo support (CMD+Z / CMD+SHIFT+Z)
- ✅ Copy annotated image back to clipboard (CMD+C)
- ✅ Session history tracking (backend only, UI coming in v2)

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `CMD+V` | Paste image from clipboard |
| `CMD+C` | Copy annotated image & close window |
| `CMD+Z` | Undo |
| `CMD+SHIFT+Z` | Redo |
| `CMD+CTRL+C` | Toggle Circle mode |
| `CMD+CTRL+T` | Toggle Text mode |
| `Delete/Backspace` | Delete selected annotation |
| `ESC` | Deselect / return to Select mode |
| `Double-click` | Quick text placement (any mode) |

## Building

### Requirements
- MacOS 12.0 or later
- Xcode 14.0 or later
- Swift 5.0 or later

### Build Instructions

1. Open the project in Xcode:
```bash
open QuickAnnotator.xcodeproj
```

2. Build and run (CMD+R) or build for release:
```bash
xcodebuild -project QuickAnnotator.xcodeproj -scheme QuickAnnotator -configuration Release
```

Alternatively, use the provided build script:
```bash
./build.sh
```

The compiled app will be in the `build/Release` directory.

## Usage

1. Take a screenshot (or copy any image to clipboard)
2. Launch QSA
3. Image auto-pastes (or press CMD+V)
4. Add annotations:
   - **Circle**: Click "Circle" button (or CMD+CTRL+C), then click-drag
   - **Text**: Click "Text" button (or CMD+CTRL+T), then click to place
   - Or just double-click anywhere to quickly add text
5. Edit annotations:
   - Click to select
   - Drag to move
   - Drag circle handles to resize
   - Double-click text to edit
6. Press CMD+C (or click "Copy to Clipboard") to save and close
7. Paste into Slack, Messages, Gmail, etc.

## Architecture

See [PROJECT_SPEC.md](PROJECT_SPEC.md) for detailed technical specifications.

### Project Structure
```
QuickAnnotator/
├── QuickAnnotator/
│   ├── Models/
│   │   ├── Annotation.swift
│   │   ├── CircleAnnotation.swift
│   │   └── TextAnnotation.swift
│   ├── Managers/
│   │   ├── AnnotationManager.swift
│   │   ├── ClipboardManager.swift
│   │   └── HistoryStore.swift
│   ├── Views/
│   │   ├── CanvasView.swift
│   │   ├── CanvasView+MouseHandling.swift
│   │   ├── MainViewController.swift
│   │   └── ToolbarView.swift
│   ├── AppDelegate.swift
│   ├── main.swift
│   └── Info.plist
├── PROJECT_SPEC.md
└── README.md
```

## Roadmap

### Phase 1 (Current) ✅
- All core annotation features
- Clipboard integration
- Undo/redo
- Backend history storage

### Phase 2 (Planned)
- History UI browser
- Auto-scaling text size
- Screenshot keyboard shortcut interception
- Arrow annotations
- Custom colors
- Export to file

## License

MIT License - See LICENSE file for details

## Contributing

This project follows the specifications in PROJECT_SPEC.md. Please reference that document when making changes.
