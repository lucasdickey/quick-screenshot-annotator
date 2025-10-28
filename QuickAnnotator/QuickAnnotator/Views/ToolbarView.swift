import Cocoa

protocol ToolbarDelegate: AnyObject {
    func toolbarDidSelectMode(_ mode: EditMode)
    func toolbarDidSelectColor(_ color: AnnotationColor)
    func toolbarDidRequestCopy()
    func toolbarDidRequestClearAll()
}

class ToolbarView: NSView {
    
    weak var delegate: ToolbarDelegate?
    
    private var circleButton: NSButton!
    private var textButton: NSButton!

    private var colorButtons: [AnnotationColor: NSButton] = [:]
    private var currentMode: EditMode = .select
    private var currentColor: AnnotationColor = .red
    private var colorButtonsContainer: NSView!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        
        var xOffset: CGFloat = 20
        let buttonWidth: CGFloat = 80
        let buttonHeight: CGFloat = 32
        let spacing: CGFloat = 10
        let yPos = (bounds.height - buttonHeight) / 2

        // Circle button
        circleButton = createButton(
            title: "Oval",
            frame: NSRect(x: xOffset, y: yPos, width: buttonWidth, height: buttonHeight),
            action: #selector(circleModeSelected)
        )
        addSubview(circleButton)
        xOffset += buttonWidth + spacing

        // Text button
        textButton = createButton(
            title: "Text",
            frame: NSRect(x: xOffset, y: yPos, width: buttonWidth, height: buttonHeight),
            action: #selector(textModeSelected)
        )
        addSubview(textButton)
        xOffset += buttonWidth + spacing * 3
        
        // Color buttons container
        let colorSize: CGFloat = 32
        let colorContainerWidth: CGFloat = CGFloat(AnnotationColor.allCases.count) * (colorSize + spacing)
        colorButtonsContainer = NSView(frame: NSRect(x: xOffset, y: yPos, width: colorContainerWidth, height: colorSize))
        addSubview(colorButtonsContainer)

        var colorXOffset: CGFloat = 0
        for color in AnnotationColor.allCases {
            let colorButton = NSButton(frame: NSRect(x: colorXOffset, y: 0, width: colorSize, height: colorSize))
            colorButton.bezelStyle = .circular
            colorButton.isBordered = true
            colorButton.wantsLayer = true
            colorButton.layer?.backgroundColor = color.nsColor.cgColor
            colorButton.layer?.cornerRadius = colorSize / 2
            colorButton.layer?.borderWidth = 2
            colorButton.layer?.borderColor = NSColor.gray.cgColor
            colorButton.target = self
            colorButton.action = #selector(colorSelected(_:))
            colorButton.tag = color.hashValue

            colorButtonsContainer.addSubview(colorButton)
            colorButtons[color] = colorButton
            colorXOffset += colorSize + spacing
        }

        colorButtonsContainer.isHidden = true // Hidden by default
        xOffset += colorContainerWidth + spacing * 2
        
        // Copy button
        let copyButton = createButton(
            title: "Copy to Clipboard",
            frame: NSRect(x: bounds.width - 180, y: yPos, width: 160, height: buttonHeight),
            action: #selector(copyButtonPressed)
        )
        copyButton.autoresizingMask = [.minXMargin]
        copyButton.bezelStyle = .rounded
        copyButton.keyEquivalent = "\r" // Return key
        addSubview(copyButton)
        
        // Update initial state
        updateButtonStates()
        updateColorStates()
    }
    
    private func createButton(title: String, frame: NSRect, action: Selector) -> NSButton {
        let button = NSButton(frame: frame)
        button.title = title
        button.bezelStyle = .rounded
        button.target = self
        button.action = action
        return button
    }
    
    // MARK: - Actions

    @objc private func circleModeSelected() {
        // Toggle circle mode
        if currentMode == .circle {
            currentMode = .select
        } else {
            currentMode = .circle
        }
        updateButtonStates()
        delegate?.toolbarDidSelectMode(currentMode)
    }

    @objc private func textModeSelected() {
        // Toggle text mode
        if currentMode == .text {
            currentMode = .select
        } else {
            currentMode = .text
        }
        updateButtonStates()
        delegate?.toolbarDidSelectMode(currentMode)
    }
    
    @objc private func colorSelected(_ sender: NSButton) {
        // Find which color was selected
        for (color, button) in colorButtons {
            if button == sender {
                currentColor = color
                updateColorStates()
                delegate?.toolbarDidSelectColor(color)
                break
            }
        }
    }
    
    @objc private func copyButtonPressed() {
        delegate?.toolbarDidRequestCopy()
    }
    
    // MARK: - State Management

    private func updateButtonStates() {
        circleButton.state = currentMode == .circle ? .on : .off
        textButton.state = currentMode == .text ? .on : .off

        // Show color picker only when in circle or text mode
        colorButtonsContainer.isHidden = (currentMode == .select)
    }
    
    private func updateColorStates() {
        for (color, button) in colorButtons {
            if color == currentColor {
                button.layer?.borderColor = NSColor.black.cgColor
                button.layer?.borderWidth = 3
            } else {
                button.layer?.borderColor = NSColor.gray.cgColor
                button.layer?.borderWidth = 2
            }
        }
    }
    
    // Public method to programmatically select mode
    func selectMode(_ mode: EditMode) {
        currentMode = mode
        updateButtonStates()
        delegate?.toolbarDidSelectMode(mode)
    }
}
