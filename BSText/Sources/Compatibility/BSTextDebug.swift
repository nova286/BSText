import UIKit

public class BSTextDebugOption: NSObject {
    public var baselineColor: UIColor?
    public var ctFrameBorderColor: UIColor?
    public var ctLineFillColor: UIColor?
    public var cgGlyphBorderColor: UIColor?

    public override init() {
        super.init()
    }

    public static func setSharedDebugOption(_ option: BSTextDebugOption?) {
        sharedDebugOption = option
    }

    public static var sharedDebugOption: BSTextDebugOption?

    public static func debugOption() -> BSTextDebugOption {
        return BSTextDebugOption()
    }
}

public extension BSTextDebugOptions {
    static let None: BSTextDebugOptions = []
    static let ShowFragments: BSTextDebugOptions = .showFragments
    static let ShowBaseline: BSTextDebugOptions = .showLineFragments
    static let ShowLineNumbers: BSTextDebugOptions = .showTextContainer
    static let ShowInlineImages: BSTextDebugOptions = .showSelection
}
