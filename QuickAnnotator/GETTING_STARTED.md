# Getting Started with Quick Annotator

## Quick Start

This MacOS app lets you quickly annotate screenshots with circles and text, then copy back to clipboard for sharing.

### Prerequisites
- MacOS 12.0+
- Xcode 14.0+ (for building)

### Installation Options

#### Option 1: Build with Xcode (Recommended)
```bash
open QuickAnnotator.xcodeproj
# Press CMD+R to build and run
```

#### Option 2: Build from Command Line
```bash
./build.sh
# Run the binary
./build/QuickAnnotator
```

#### Option 3: Use xcodebuild
```bash
xcodebuild -project QuickAnnotator.xcodeproj -scheme QuickAnnotator -configuration Release
# App will be in build/Release/
```

## First Use

1. **Take a screenshot** using MacOS screenshot tools (CMD+SHIFT+4)
2. **Launch Quick Annotator**
3. The screenshot auto-pastes into the app
4. **Add annotations:**
   - Click "Circle" → click-drag to draw
   - Click "Text" → click to place → type
   - Select a color from the palette
5. **Copy result:** Press CMD+C (or click "Copy to Clipboard")
6. **Paste anywhere:** Slack, Messages, Gmail, etc.

## Tutorial: First Annotation

Let's annotate a screenshot in 30 seconds:

1. Press `CMD+SHIFT+4` and capture part of your screen
2. Launch the app - your screenshot appears automatically
3. Click the red color circle in the toolbar
4. Click "Circle" button (or press `CMD+CTRL+C`)
5. Click-and-drag on the image to draw a red circle
6. Double-click anywhere to add text
7. Type your comment and press Return
8. Press `CMD+C` to copy the annotated image
9. Open Slack/Messages and press `CMD+V` to paste

Done! Your annotated screenshot is ready to share.

## Tips & Tricks

### Speed Tips
- **Double-click anywhere** for quick text placement (works in any mode)
- **Press CMD+C twice** - once to copy, app closes automatically
- **Use keyboard shortcuts** for mode switching (CMD+CTRL+C for circles, CMD+CTRL+T for text)

### Editing
- **Move annotations**: Click and drag in Select mode
- **Resize circles**: Select a circle, then drag the handles
- **Edit text**: Double-click existing text
- **Delete**: Select and press Delete/Backspace
- **Undo mistakes**: CMD+Z (up to 50 levels)

### Color Selection
Three high-visibility colors are available:
- 🔴 **Red** - Best for most backgrounds
- 🟡 **Yellow** - Great for dark images
- 🔵 **Cyan** - Stands out on warm tones

### Workflow Examples

**Bug Reports:**
```
Screenshot → Circle the bug → Add description → Copy → Paste in issue tracker
```

**Design Feedback:**
```
Screenshot → Circle multiple areas → Number them with text → Copy → Email to designer
```

**Shopping Lists:**
```
Screenshot website → Circle items → Add notes → Copy → Text to partner
```

## Troubleshooting

**Q: App doesn't paste my screenshot automatically**
- Make sure the screenshot is in your clipboard (CMD+SHIFT+4 then CMD+CTRL to copy)
- Try manually pressing CMD+V in the app

**Q: Can't see my annotations**
- Make sure you've selected a color from the palette
- Check that you're not in text-editing mode (press ESC)

**Q: Text is too small/large**
- Font size is fixed at 12pt in v1
- Auto-scaling is planned for v2

**Q: Lost my annotations**
- Use CMD+Z to undo
- Annotations are stored in history (backend only in v1)

**Q: How do I save to a file?**
- Currently clipboard-only (by design for speed)
- File export is planned for v2

## Next Steps

- Read [README.md](README.md) for detailed features
- Review [PROJECT_SPEC.md](PROJECT_SPEC.md) for technical details
- Check the roadmap for upcoming features

## Keyboard Shortcuts Cheat Sheet

| Action | Shortcut |
|--------|----------|
| Paste image | `CMD+V` |
| Copy & close | `CMD+C` |
| Circle mode | `CMD+CTRL+C` |
| Text mode | `CMD+CTRL+T` |
| Quick text | `Double-click` |
| Undo | `CMD+Z` |
| Redo | `CMD+SHIFT+Z` |
| Delete | `Delete` or `Backspace` |
| Deselect | `ESC` |

## Support

For issues or questions:
1. Check [PROJECT_SPEC.md](PROJECT_SPEC.md) for technical details
2. Review the troubleshooting section above
3. Open an issue with:
   - MacOS version
   - Xcode version
   - Steps to reproduce
   - Expected vs actual behavior
