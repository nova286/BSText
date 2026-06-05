import UIKit

@available(iOS 13.0, *)
public extension BSTextView {

    var displaysAsynchronously: Bool {
        get { return _displaysAsynchronously }
        set { _displaysAsynchronously = newValue }
    }

    var ignoreCommonProperties: Bool {
        get { return _ignoreCommonProperties }
        set { _ignoreCommonProperties = newValue }
    }

    var bs_textParser: BSTextParser? {
        get { return _textParser }
        set { _textParser = newValue }
    }

    private static var _displaysAsynchronouslyKey: UInt8 = 0
    private static var _ignoreCommonPropertiesKey: UInt8 = 0
    private static var _textParserKey: UInt8 = 0

    private var _displaysAsynchronously: Bool {
        get {
            return objc_getAssociatedObject(self, &BSTextView._displaysAsynchronouslyKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &BSTextView._displaysAsynchronouslyKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var _ignoreCommonProperties: Bool {
        get {
            return objc_getAssociatedObject(self, &BSTextView._ignoreCommonPropertiesKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &BSTextView._ignoreCommonPropertiesKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var _textParser: BSTextParser? {
        get {
            return objc_getAssociatedObject(self, &BSTextView._textParserKey) as? BSTextParser
        }
        set {
            objc_setAssociatedObject(self, &BSTextView._textParserKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
