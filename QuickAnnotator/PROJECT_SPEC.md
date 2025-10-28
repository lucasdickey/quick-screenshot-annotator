# Project Spec: Quick Screenshot Annotator (MacOS)

## Overview
A lightweight MacOS native app for rapidly annotating screenshots with circles and text, then copying the result back to clipboard for immediate sharing.

## Core Workflow
1. User takes screenshot → copies to clipboard
2. User switches to app → pastes image (CMD+V or automatic paste detection)
3. User adds circle outlines and/or text annotations
4. User copies result (CMD+C) → flattened PNG goes to clipboard, window closes
5. User pastes into Slack/Messages/Gmail/etc.

---

## Functional Requirements

### Image Input
- **Paste from clipboard** (CMD+V or on app activation if clipboard contains image)
- Support PNG, JPG formats
- Display image at actual size or scale to fit window (maintain aspect ratio)
- No file system operations (open/save dialogs)

### Circle Annotations
- **Creation**: Click-and-drag to draw circle outline (click = center, drag = radius)
- **Properties**:
  - No fill (outline only)
  - Stroke width: 3-4 pixels
  - Color: Choose from 2-3 preset bright colors (red, yellow, cyan recommended)
- **Editing**:
  - Drag to move entire circle
  - Resize handles on selection (8 handles around bounding box)
  - Delete via Delete/Backspace key when selected

### Text Annotations
- **Creation**: Click to place text insertion point → text input box appears
- **Properties**:
  - Font size: Default 12pt (manual size adjustment for v1)
  - Color: Same 2-3 preset options as circles
  - Font: System default (San Francisco)
- **Editing**:
  - Double-click existing text to edit content
  - Drag to move text box
  - Delete via Delete/Backspace key when selected

### UI Components

**Toolbar** (top or side of window):
- **Mode toggles**: 
  - Circle button (toggle on/off)
  - Text button (toggle on/off)
  - Select/Move button (default mode)
- **Color palette**: 2-3 color swatches always visible
- **Action buttons**:
  - "Copy to Clipboard" button
  - Clear All (with confirmation)

**Keyboard Shortcuts**:
- `CMD+V`: Paste image
- `CMD+C`: Copy annotated image to clipboard & close window
- `CMD+Z`: Undo
- `CMD+SHIFT+Z`: Redo
- `CMD+CTRL+C`: Toggle Circle mode
- `CMD+CTRL+T`: Toggle Text mode
- `Delete/Backspace`: Delete selected annotation
- `ESC`: Deselect / exit current mode
- `Double-click`: Quick text placement (regardless of mode)

### Interaction Modes

**Select/Move Mode** (default):
- Click annotation to select it
- Drag to move selected annotation
- Show selection handles on circles for resizing
- Double-click text to edit

**Circle Mode**:
- Click-and-drag creates new circle
- Automatically returns to Select mode after creation

**Text Mode**:
- Click places text box, ready for typing
- Automatically returns to Select mode after placing

### Output
- **Format**: Flattened PNG (all layers merged)
- **Destination**: System clipboard
- **Behavior**: After copying, window closes (or clears for next annotation)

---

## Technical Architecture

### Technology Stack
- **Language**: Swift
- **Framework**: SwiftUI or AppKit (AppKit recommended for precise drawing control)
- **Min OS**: MacOS 12.0+

### Core Components

1. **ImageCanvasView**: Main drawing surface
   - Renders base image
   - Renders all annotations
   - Handles mouse events (click, drag, double-click)
   - Manages selection state

2. **AnnotationManager**:
   - Stores array of annotations (circles & text)
   - Handles undo/redo stack
   - Serializes annotations for history (v1 backend only)

3. **CircleAnnotation** (model):
   - Properties: centerX, centerY, radius, color, strokeWidth
   - Draw method
   - Hit-test method

4. **TextAnnotation** (model):
   - Properties: x, y, text, fontSize, color
   - Draw method
   - Hit-test method

5. **ClipboardManager**:
   - Reads image from clipboard
   - Writes flattened PNG to clipboard

6. **HistoryStore** (v1 backend):
   - Saves each completed annotation session
   - Metadata: timestamp, image dimensions
   - Stored in app's Application Support directory
   - UI for browsing history: v2

### Color Presets
- **Red**: #FF3B30 (iOS/MacOS system red)
- **Yellow**: #FFCC00 (high visibility)
- **Cyan**: #00D9FF (contrasts with most backgrounds)

---

## Phase Breakdown

### Phase 1 (MVP - Current Spec)
✅ All features described above
✅ Backend history collection
✅ Manual font sizing (12pt default)

### Phase 2 (Future)
- History UI (browse past annotations)
- Auto-scaling font size based on image dimensions
- Screenshot keyboard shortcut interception (SHIFT+CMD+CTRL+4)
- Arrow annotations
- Additional color customization
- Export to file option

---

## UI Mockup (Conceptual)

```
┌─────────────────────────────────────────────┐
│ [🔵 Circle] [T Text] [↖️ Select]  ⚫🟡🔵    │  ← Toolbar
├─────────────────────────────────────────────┤
│                                             │
│        [Screenshot Image]                   │
│                                             │
│     🔴 ← Circle annotation                  │
│                                             │
│          "Fix this button" ← Text          │
│                                             │
│                                             │
├─────────────────────────────────────────────┤
│          [Copy to Clipboard] [Clear All]    │  ← Actions
└─────────────────────────────────────────────┘
```

---

## Success Criteria
- Launch app → paste image → add 2 circles + 1 text → copy → paste into Slack **in under 15 seconds**
- Annotations are clearly visible on diverse image backgrounds
- No crashes with images up to 4K resolution
- Smooth 60fps interaction on MacBook Pro M1+

---

## Out of Scope (Explicit)
❌ Opening image files from disk  
❌ Saving to disk  
❌ Resizing/cropping images  
❌ Blur, arrows, or other annotation shapes (v1)  
❌ Custom colors beyond 3 presets (v1)  
❌ Multi-page/batch annotation  
❌ Cloud sync  

---

## Development Notes

### Implementation Progress
- [ ] Project setup
- [ ] Basic window and UI layout
- [ ] Clipboard paste functionality
- [ ] Canvas view for image display
- [ ] Circle annotation creation
- [ ] Text annotation creation
- [ ] Selection and editing
- [ ] Undo/redo system
- [ ] Copy to clipboard
- [ ] History backend storage
- [ ] Keyboard shortcuts
- [ ] Testing and polish
