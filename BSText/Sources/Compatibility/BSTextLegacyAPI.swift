import UIKit

public protocol BSCompatible: AnyObject {}

public extension BSCompatible {
    var bs: BSWrapper<Self> { BSWrapper(object: self) }
}

public struct BSWrapper<Base> {
    public let object: Base
    init(object: Base) { self.object = object }
}

public extension NSMutableAttributedString {
    var bs: BSAttributedStringWrapper { BSAttributedStringWrapper(attributedString: self) }
}

public struct BSAttributedStringWrapper {
    public let attributedString: NSMutableAttributedString
    init(attributedString: NSMutableAttributedString) { self.attributedString = attributedString }
}

public extension BSAttributedStringWrapper {
    var font: UIFont? {
        get { attributedString.attribute(.font, at: 0, effectiveRange: nil) as? UIFont }
        set {
            if let range = fullRange {
                attributedString.addAttribute(.font, value: newValue ?? UIFont.systemFont(ofSize: 17), range: range)
            }
        }
    }

    var color: UIColor? {
        get { attributedString.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor }
        set {
            if let range = fullRange {
                attributedString.addAttribute(.foregroundColor, value: newValue ?? UIColor.black, range: range)
            }
        }
    }

    var lineSpacing: CGFloat {
        get {
            guard let style = attributedString.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle else { return 0 }
            return style.lineSpacing
        }
        set {
            if let range = fullRange {
                attributedString.addAttribute(.paragraphStyle, value: {
                    let style = NSMutableParagraphStyle()
                    style.lineSpacing = newValue
                    return style
                }(), range: range)
            }
        }
    }

    private var fullRange: NSRange? {
        guard attributedString.length > 0 else { return nil }
        return NSRange(location: 0, length: attributedString.length)
    }
}

public extension NSMutableAttributedString {
    func bs_setFont(_ font: UIFont) {
        if length > 0 {
            addAttribute(.font, value: font, range: NSRange(location: 0, length: length))
        }
    }

    func bs_setColor(_ color: UIColor) {
        if length > 0 {
            addAttribute(.foregroundColor, value: color, range: NSRange(location: 0, length: length))
        }
    }

    func bs_set(color: UIColor, range: NSRange) {
        guard range.location + range.length <= length else { return }
        addAttribute(.foregroundColor, value: color, range: range)
    }

    func bs_setFont(_ font: UIFont, range: NSRange) {
        guard range.location + range.length <= length else { return }
        addAttribute(.font, value: font, range: range)
    }

    func bs_setLineSpacing(_ lineSpacing: CGFloat) {
        guard length > 0 else { return }
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpacing
        addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: length))
    }

    func bs_setLineSpacing(_ lineSpacing: CGFloat, range: NSRange) {
        guard range.location + range.length <= length else { return }
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpacing
        addAttribute(.paragraphStyle, value: style, range: range)
    }

    func bs_setTextHighlightRange(_ range: NSRange, color: UIColor?, backgroundColor: UIColor?, tapAction: BSHighlightTapAction?) {
        guard range.location + range.length <= length else { return }
        let highlight = BSTextHighlight()
        highlight.color = color
        highlight.backgroundColor = backgroundColor
        highlight.tapAction = tapAction
        addAttribute(BS.textHighlightAttribute, value: highlight, range: range)
    }

    func bs_setTextHighlight(_ highlight: BSTextHighlight, range: NSRange) {
        guard range.location + range.length <= length else { return }
        addAttribute(BS.textHighlightAttribute, value: highlight, range: range)
    }
}

public typealias BSHighlightTapAction = (UIView, String, NSRange, CGRect) -> Void

public class BSTextHighlight: NSObject {
    public var color: UIColor?
    public var backgroundColor: UIColor?
    public var tapAction: BSHighlightTapAction?
    public var longPressAction: BSHighlightTapAction?

    public override init() {
        super.init()
    }

    public init(color: UIColor?, backgroundColor: UIColor?, tapAction: BSHighlightTapAction? = nil) {
        self.color = color
        self.backgroundColor = backgroundColor
        self.tapAction = tapAction
        super.init()
    }
}

public class BS {
    public static let textHighlightAttribute = NSAttributedString.Key("BS.text.highlight")
    public static let textBorderAttribute = NSAttributedString.Key("BS.text.border")
    public static let textShadowAttribute = NSAttributedString.Key("BS.text.shadow")
    public static let textAttachmentAttribute = NSAttributedString.Key("BS.text.attachment")
    public static let textBindingAttribute = NSAttributedString.Key("BS.text.binding")
}
