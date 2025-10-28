# Requirements Conversation Log

This document captures the original requirements and the clarification process that shaped the final project specification.

---

## Original User Request

**Date**: October 27, 2025

### Initial Problem Statement

> I have a common use case that I'd like to simplify with a very simple native MacOS app: quickly annotate a screenshot with a circle and/or text.

### Use Cases Provided

**Example 1**: I take a screenshot of another app, circle a piece of the UX, add a comment about what I'd change, share with a teammate via Slack app.

**Example 2**: Screenshot part of a website, circle an item I want to buy, add a comment, share with my wife via Messages app.

**Example 3**: Screenshot entire screen, circle 4 areas of copy/styling mismatches, add comments for each, paste into Gmail, email it to my designer.

### Initial Requirements

**Explicitly Stated:**
1. Accept paste from OS clipboard (or custom screenshot keyboard bindings like SHIFT+CMD+CTRL+4, but rather than going to clipboard it goes to this app)
2. Support multiple circle shape annotations (no fill in the circle, as it's just an outline)
3. Support multiple text annotations
4. Default to color contrast for circle shape or text that they are sufficiently legible on the underlying image
5. Push edits and output back to the clipboard for pasting into any client of my choice that supports PNGs in-line

**Explicitly NOT Needed:**
- Re-sizing, cropping, color changes or any other visual, graphic, UX or design tool features
- Open existing images
- Save an image
- Other file system manipulation

---

## Clarifying Questions Asked

### 1. Circle Drawing Interaction
**Question**: How should users create circles?
- Click-and-drag (click center, drag to set radius)?
- Two clicks (click center, click edge)?
- Should circles be resizable/movable after creation?

### 2. Text Placement
**Question**: 
- Click-to-place then type in a text box?
- Should text be editable/movable after placing?
- Any preference on font size or should it auto-scale based on image size?

### 3. Mode Switching
**Question**: How should users switch between adding circles vs. adding text?
- Toggle buttons in a toolbar?
- Keyboard shortcuts (e.g., 'C' for circle, 'T' for text)?
- Always ready for both (e.g., click-drag = circle, double-click = text)?

### 4. Workflow Completion
**Question**: How do users indicate they're done annotating?
- "Copy to Clipboard" button?
- CMD+C keyboard shortcut?
- Automatic on window close?

### 5. Editing Capabilities
**Question**: Do you want ability to:
- Delete annotations after placing them?
- Undo/redo functionality?
- Or keep it simple: once placed, it's permanent?

### 6. Screenshot Interception
**Question**: The SHIFT+CMD+CTRL+4 interception is technically complex and requires accessibility permissions. Should we:
- Start with clipboard paste only for v1 (simpler, faster to build)?
- Or is screenshot interception a must-have for initial version?

### 7. Visual Details - Stroke Width
**Question**: Any preference for circle stroke width? (e.g., 3-4 pixels for visibility?)

### 8. Color Contrast Implementation
**Question**: Should the app automatically choose high-contrast colors by analyzing the image, or would you like 2-3 preset bright colors that work on most backgrounds (like red, yellow, cyan)?

---

## User's Clarifications & Decisions

### Circle Drawing (Question 1)
**Decision**: 
> "Let's go ahead and just do a click-and-drag, and the circles should be resizable after creation."

**Impact**: Implemented click-drag for center+radius, with 8 resize handles on selected circles.

---

### Text Placement (Question 2)
**Decision**:
> "It should be click-to-place, then type in a box. The text should be editable after the fact, and the font size should just auto-scale based upon image size, but be sort of contextually aware in terms of not being too large in a smaller image, or vice versa. If that's too challenging, then we start with manually editing at first, with the default being size 12 in most font sets."

**Impact**: 
- Phase 1: Implemented 12pt fixed font size with manual editing
- Phase 2: Planned auto-scaling based on image dimensions
- Double-click to edit existing text

---

### Mode Switching (Question 3)
**Decision**:
> "Toggle buttons in a tool board would probably be easiest. Then, we can support shortcuts that should probably include a command or control attached to a letter, since the user could be actively typing into a text field, and so the key binding would already be in the forefront."
> 
> "And yes, it should always be ready for both in terms of click-drag for circle and double-click for text. That's a good idea."

**Impact**: 
- Toolbar with Select/Circle/Text toggle buttons
- Keyboard shortcuts: CMD+CTRL+C (circle), CMD+CTRL+T (text)
- Double-click works in any mode for quick text placement

---

### Workflow Completion (Question 4)
**Decision**:
> "If they just did the copy to clipboard (or Command-C), then it should just save to the clipboard and close. We could keep a historical memory or history that could be cleared out later as well, but let's save that for a phase II feature. Alternatively, let's keep it for phase I in terms of gathering it, and then push it to phase II for exposing it to the user. Let's start cataloging it immediately."

**Impact**: 
- CMD+C copies to clipboard and closes window
- Phase 1: Backend history collection (HistoryStore)
- Phase 2: UI for browsing history

---

### Editing Capabilities (Question 5)
**Decision**:
> "People should be able to delete annotations after placing them. Let's support undo and redo with the standard key bindings. No need to have an icon for it because I won't be using it."

**Impact**: 
- Delete with Delete/Backspace key
- Undo: CMD+Z
- Redo: CMD+SHIFT+Z
- 50 levels of undo history
- No toolbar buttons for undo/redo (keyboard only)

---

### Screenshot Interception (Question 6)
**Decision**:
> "Let's not hijack the key binding, but maybe just start with a clipboard paste for v1 if that's simplest."

**Impact**: 
- Phase 1: Clipboard paste only (CMD+V + auto-paste on activation)
- Phase 2: Screenshot interception via SHIFT+CMD+CTRL+4

---

### Circle Stroke Width (Question 7)
**Decision**:
> "Let's go with 3-4 pixels for clear visibility, but not being too fat."

**Impact**: Implemented 3.5 pixel stroke width for all circle annotations.

---

### Color Contrast (Question 8)
**Decision**:
> "Let's just choose 2-3 bright color preset options, and have them always visible."

**Impact**: 
- Three preset colors: Red (#FF3B30), Yellow (#FFCC00), Cyan (#00D9FF)
- Always visible in toolbar
- No automatic color analysis
- No custom color picker (Phase 2 consideration)

---

## Key Design Decisions Summary

### Prioritized for Phase 1 (Implemented)
1. ✅ Click-drag circle creation with resize handles
2. ✅ Click-to-place text with 12pt fixed size
3. ✅ Toolbar with mode toggles + keyboard shortcuts
4. ✅ CMD+C to copy and auto-close window
5. ✅ Full undo/redo support (50 levels)
6. ✅ Delete individual annotations
7. ✅ Clipboard paste only (no screenshot interception)
8. ✅ 3.5px stroke width for circles
9. ✅ Three preset colors (red, yellow, cyan)
10. ✅ Backend history collection
11. ✅ Double-click for quick text placement

### Deferred to Phase 2
1. ⏭️ Auto-scaling font size based on image dimensions
2. ⏭️ Screenshot keyboard shortcut interception
3. ⏭️ History UI browser
4. ⏭️ Custom color picker
5. ⏭️ Additional annotation types (arrows, rectangles)

---

## Requirements Evolution

### From "Color Contrast" to "Three Presets"

**Original**: "Default to color contrast for circle shape or text that they are sufficiently legible"

**Clarified**: User chose 2-3 preset bright colors instead of automatic color analysis

**Rationale**: Simpler implementation, predictable behavior, sufficient for most use cases

---

### From "Screenshot Binding" to "Clipboard First"

**Original**: "Custom screenshot keyboard bindings like SHIFT+CMD+CTRL+4... goes to this app"

**Clarified**: Start with clipboard paste for v1, defer interception to v2

**Rationale**: Faster to build, no accessibility permissions needed, still achieves core workflow

---

### From "Auto-Scale Font" to "Fixed 12pt First"

**Original**: "Font size should just auto-scale based upon image size"

**Clarified**: "If that's too challenging, then we start with manually editing at first, with the default being size 12"

**Rationale**: Pragmatic approach - deliver working MVP faster, enhance later

---

### From "Simple Copy" to "Copy and Close"

**Original**: "Push edits and output back to the clipboard"

**Clarified**: "Copy to clipboard (or Command-C), then it should just save to the clipboard and close"

**Rationale**: Streamlined workflow - user is done when they copy, so auto-close makes sense

---

### Addition: History Tracking

**Not in Original**: History/memory feature

**Added During Clarification**: 
> "We could keep a historical memory or history... let's keep it for phase I in terms of gathering it, and then push it to phase II for exposing it to the user. Let's start cataloging it immediately."

**Rationale**: Start collecting data now, build UI later when patterns are understood

---

### Addition: Double-Click Quick Text

**Not in Original**: Quick text placement without mode switching

**Suggested During Q&A**: "Always ready for both (e.g., click-drag = circle, double-click = text)?"

**User Response**: "And yes, it should always be ready for both... That's a good idea."

**Rationale**: Improves workflow speed - text is most common, should be fastest to add

---

## Final Specification Alignment

All clarifications were incorporated into PROJECT_SPEC.md, resulting in:

### Core Workflow (15 seconds or less)
1. Screenshot → Clipboard
2. Launch app → Auto-paste
3. Annotate (circles + text)
4. CMD+C → Copy & Close
5. Paste anywhere

### Success Criteria
- ✅ All Phase 1 features from clarified requirements
- ✅ < 15 second workflow from screenshot to share
- ✅ Clear, visible annotations on diverse backgrounds
- ✅ No file system operations (clipboard only)
- ✅ Smooth interaction with undo/redo

---

## Lessons Learned

### What Worked Well
1. **Iterative clarification** - Starting broad, then drilling into specifics
2. **Explicit non-requirements** - User stated what NOT to build
3. **Phase separation** - Clear v1 vs v2 boundaries
4. **Pragmatic tradeoffs** - "If too challenging, start simpler" approach

### Key Requirements Techniques Used
1. **Concrete examples** - User provided 3 real use cases
2. **Interactive dialogue** - Back-and-forth refinement
3. **Technical transparency** - Discussing complexity (screenshot interception)
4. **Prioritization** - What's essential vs nice-to-have

---

## Documentation Chain

This conversation led to:
1. **REQUIREMENTS_LOG.md** (this file) - The conversation
2. **PROJECT_SPEC.md** - The formal specification
3. **STATUS.md** - Implementation tracking
4. **README.md** - User-facing documentation
5. **GETTING_STARTED.md** - Quick start guide

Each subsequent document builds on the requirements established here.

---

**Last Updated**: October 27, 2025  
**Status**: Requirements finalized, Phase 1 complete  
**Next**: Testing and validation against use cases
