import UIKit

public class BSTextBorder: NSObject {
    public var lineStyle: BSTextBorderLineStyle = .none
    public var strokeWidth: CGFloat = 0
    public var strokeColor: UIColor = .clear
    public var fillColor: UIColor = .clear
    public var cornerRadius: CGFloat = 0
    public var insets: UIEdgeInsets = .zero

    public static func border(with color: UIColor, cornerRadius: CGFloat) -> BSTextBorder {
        let border = BSTextBorder()
        border.fillColor = color
        border.cornerRadius = cornerRadius
        return border
    }

    public static func border(with color: UIColor) -> BSTextBorder {
        return border(with: color, cornerRadius: 0)
    }
}

public enum BSTextBorderLineStyle: Int {
    case none = 0
    case single = 1
    case thick = 2
    case double = 3
}

public class BSTextShadow: NSObject {
    public var offset: CGSize = .zero
    public var blurRadius: CGFloat = 0
    public var color: UIColor = .clear

    public static func shadow() -> BSTextShadow {
        return BSTextShadow()
    }

    public convenience init(offset: CGSize, blurRadius: CGFloat, color: UIColor) {
        self.init()
        self.offset = offset
        self.blurRadius = blurRadius
        self.color = color
    }

    public func createShadow() -> NSShadow {
        let shadow = NSShadow()
        shadow.shadowOffset = offset
        shadow.shadowBlurRadius = blurRadius
        shadow.shadowColor = color
        return shadow
    }
}

public class BSTextInnerShadow: BSTextShadow {}

public class BSTextBackgroundBorder: BSTextBorder {
    public override init() {
        super.init()
        lineStyle = .none
    }
}

public class BSTextBlockBorder: BSTextBorder {
    public var blockBorderInsets: UIEdgeInsets = .zero
}

public class BSTextTextDecoration: NSObject {
    public var textDecorationStyle: BSTextDecorationStyle = .single
    public var strokeColor: UIColor?
    public var lineStyle: NSUnderlineStyle = .single
}

public enum BSTextDecorationStyle: Int {
    case single = 0
    case thick = 1
    case double = 2
}

public class BSTextUnderline: BSTextTextDecoration {
    public override init() {
        super.init()
        lineStyle = .single
    }
}

public class BSTextStrikethrough: BSTextTextDecoration {
    public override init() {
        super.init()
        lineStyle = .single
    }
}

public extension NSMutableAttributedString {
    func bs_setTextShadow(_ shadow: BSTextShadow, range: NSRange) {
        guard range.location + range.length <= length else { return }
        let nsShadow = shadow.createShadow()
        addAttribute(NSAttributedString.Key.shadow, value: nsShadow, range: range)
        addAttribute(BS.textShadowAttribute, value: shadow, range: range)
    }

    func bs_setTextBorder(_ border: BSTextBorder, range: NSRange) {
        guard range.location + range.length <= length else { return }
        addAttribute(BS.textBorderAttribute, value: border, range: range)
    }

    func bs_setTextUnderline(style: NSUnderlineStyle = .single, color: UIColor? = nil, range: NSRange) {
        guard range.location + range.length <= length else { return }
        addAttribute(.underlineStyle, value: style.rawValue, range: range)
        if let color = color {
            addAttribute(.underlineColor, value: color, range: range)
        }
    }

    func bs_setTextStrikethrough(style: NSUnderlineStyle = .single, color: UIColor? = nil, range: NSRange) {
        guard range.location + range.length <= length else { return }
        addAttribute(.strikethroughStyle, value: style.rawValue, range: range)
        if let color = color {
            addAttribute(.strikethroughColor, value: color, range: range)
        }
    }

    func bs_setTextBackedString(_ backedString: BSTextBackedString, range: NSRange) {
        guard range.location + range.length <= length else { return }
        addAttribute(NSAttributedString.Key(rawValue: "BS.text.backed"), value: backedString, range: range)
    }
}

public class BSTextBackedString: NSObject {
    public var string: String?
    public init(string: String?) {
        self.string = string
        super.init()
    }
}

public class BSTextBinding: NSObject {
    public var id: String = ""
    public init(id: String) {
        self.id = id
        super.init()
    }
}

public extension NSMutableAttributedString {
    func bs_setTextBinding(_ binding: BSTextBinding, range: NSRange) {
        guard range.location + range.length <= length else { return }
        addAttribute(BS.textBindingAttribute, value: binding, range: range)
    }
}
