import UIKit
import CoreText

@available(iOS 13.0, *)
open class BSLabel: UIView {

    public var text: String? {
        didSet {
            updateAttributedText()
        }
    }

    public var attributedText: NSAttributedString? {
        didSet {
            setNeedsDisplay()
        }
    }

    public var font: UIFont = .systemFont(ofSize: 17) {
        didSet {
            updateAttributedText()
        }
    }

    public var textColor: UIColor = .label {
        didSet {
            updateAttributedText()
        }
    }

    public var textAlignment: NSTextAlignment = .natural {
        didSet {
            updateAttributedText()
        }
    }

    public var lineBreakMode: NSLineBreakMode = .byTruncatingTail {
        didSet {
            updateAttributedText()
        }
    }

    public var numberOfLines: Int = 1 {
        didSet {
            setNeedsDisplay()
        }
    }

    public var displaysAsynchronously: Bool = false

    public var ignoreCommonProperties: Bool = false

    public var textParser: BSTextParser?

    public var linePositionModifier: BSTextLinePositionModifier?

    public var textContainerPath: UIBezierPath?

    public var verticalForm: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }

    public var exclusionPaths: [UIBezierPath] = [] {
        didSet {
            setNeedsDisplay()
        }
    }

    public var textContainerInset: UIEdgeInsets = .zero {
        didSet {
            setNeedsDisplay()
        }
    }

    public var highlightTapAction: BSHighlightTapAction?
    public var highlightLongPressAction: BSHighlightTapAction?

    public var textLayout: BSTextLayout?

    private var _textLayout: BSTextLayout?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear
        isUserInteractionEnabled = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        addGestureRecognizer(longPressGesture)
    }

    private func updateAttributedText() {
        guard !ignoreCommonProperties else {
            setNeedsDisplay()
            return
        }

        guard let text = text, !text.isEmpty else {
            attributedText = nil
            return
        }

        let mutableString = NSMutableAttributedString(string: text)
        mutableString.bs_setFont(font)
        mutableString.bs_setColor(textColor)

        let style = NSMutableParagraphStyle()
        style.alignment = textAlignment
        style.lineBreakMode = lineBreakMode
        mutableString.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: mutableString.length))

        if numberOfLines > 0 {
            style.lineBreakMode = lineBreakMode
        }

        if let parser = textParser {
            attributedText = parser.parse(text)
        } else {
            attributedText = mutableString
        }
    }

    open override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        if ignoreCommonProperties, let layout = textLayout {
            layout.draw(in: context, boundingRect: rect, fraction: 1.0)
            return
        }

        guard let attributedText = attributedText else { return }

        let textRect = rect.inset(by: textContainerInset)

        var finalText = attributedText
        if let parser = textParser, let text = text {
            finalText = parser.parse(text)
        }

        if verticalForm {
            drawVerticalText(finalText, in: textRect, context: context)
            return
        }

        let boundingRect = finalText.boundingRect(
            with: CGSize(width: textRect.width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )

        var drawRect = textRect
        switch textAlignment {
        case .center:
            drawRect.origin.x = textRect.origin.x + (textRect.width - boundingRect.width) / 2
        case .right:
            drawRect.origin.x = textRect.origin.x + textRect.width - boundingRect.width
        default:
            break
        }

        if numberOfLines > 0 {
            let maxHeight = boundingRect.height > textRect.height ? textRect.height : boundingRect.height
            drawRect.size.height = min(maxHeight, textRect.height)
        } else {
            drawRect.size.height = boundingRect.height
        }

        UIGraphicsPushContext(context)
        finalText.draw(in: drawRect)
        UIGraphicsPopContext()
    }

    private func drawVerticalText(_ attributedText: NSAttributedString, in textRect: CGRect, context: CGContext) {
        let verticalText = NSMutableAttributedString(attributedString: attributedText)
        let fullRange = NSRange(location: 0, length: verticalText.length)
        verticalText.addAttribute(NSAttributedString.Key(kCTVerticalFormsAttributeName as String), value: true, range: fullRange)

        let framesetter = CTFramesetterCreateWithAttributedString(verticalText)
        let frameAttributes = [
            kCTFrameProgressionAttributeName: CTFrameProgression.rightToLeft.rawValue
        ] as CFDictionary
        let coreTextRect = CGRect(
            x: textRect.minX,
            y: bounds.height - textRect.maxY,
            width: textRect.width,
            height: textRect.height
        )
        let path = CGPath(rect: coreTextRect, transform: nil)
        let frame = CTFramesetterCreateFrame(framesetter, CFRange(location: 0, length: verticalText.length), path, frameAttributes)

        context.saveGState()
        context.textMatrix = .identity
        context.translateBy(x: 0, y: bounds.height)
        context.scaleBy(x: 1, y: -1)
        CTFrameDraw(frame, context)
        context.restoreGState()
    }

    open override var intrinsicContentSize: CGSize {
        guard let attributedText = attributedText else {
            return CGSize(width: UIView.noIntrinsicMetric, height: font.lineHeight)
        }

        let maxWidth = bounds.width > 0 ? bounds.width : .greatestFiniteMagnitude
        let boundingRect = attributedText.boundingRect(
            with: CGSize(width: maxWidth - textContainerInset.left - textContainerInset.right, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )

        return CGSize(
            width: ceil(boundingRect.width + textContainerInset.left + textContainerInset.right),
            height: ceil(boundingRect.height + textContainerInset.top + textContainerInset.bottom)
        )
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let attributedText = attributedText else { return }

        let location = gesture.location(in: self)
        let textRect = bounds.inset(by: textContainerInset)

        var text = attributedText.string
        if textParser != nil, let originalText = self.text {
            text = originalText
        }

        attributedText.enumerateAttributes(in: NSRange(location: 0, length: attributedText.length)) { attrs, range, _ in
            if let highlight = attrs[BS.textHighlightAttribute] as? BSTextHighlight {
                let rangeRect = self.rectForRange(range, in: textRect)
                if rangeRect.contains(location) {
                    highlight.tapAction?(self, text, range, rangeRect)
                    highlightTapAction?(self, text, range, rangeRect)
                }
            }
        }
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        guard let attributedText = attributedText else { return }

        let location = gesture.location(in: self)
        let textRect = bounds.inset(by: textContainerInset)

        var text = attributedText.string
        if textParser != nil, let originalText = self.text {
            text = originalText
        }

        attributedText.enumerateAttributes(in: NSRange(location: 0, length: attributedText.length)) { attrs, range, _ in
            if let highlight = attrs[BS.textHighlightAttribute] as? BSTextHighlight {
                let rangeRect = self.rectForRange(range, in: textRect)
                if rangeRect.contains(location) {
                    highlight.longPressAction?(self, text, range, rangeRect)
                    highlightLongPressAction?(self, text, range, rangeRect)
                }
            }
        }
    }

    private func rectForRange(_ range: NSRange, in rect: CGRect) -> CGRect {
        guard let attributedText = attributedText else { return rect }

        let mutableText = NSMutableAttributedString(attributedString: attributedText)
        let substring = mutableText.attributedSubstring(from: range)

        let boundingRect = substring.boundingRect(
            with: CGSize(width: rect.width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )

        return CGRect(
            x: rect.origin.x,
            y: rect.origin.y,
            width: boundingRect.width,
            height: boundingRect.height
        )
    }
}

public protocol BSTextParser {
    func parse(_ text: String) -> NSAttributedString
}

public protocol BSTextLinePositionModifier {
    func modifyLinePositions(_ positions: inout [CGFloat], lineHeight: CGFloat, font: UIFont)
}

public class BSTextLinePositionSimpleModifier: NSObject, BSTextLinePositionModifier {
    public var fixedLineHeight: CGFloat = 0

    public override init() {
        super.init()
    }

    public func modifyLinePositions(_ positions: inout [CGFloat], lineHeight: CGFloat, font: UIFont) {
        guard fixedLineHeight > 0 else { return }

        for i in 0..<positions.count {
            positions[i] = CGFloat(i) * fixedLineHeight
        }
    }
}
