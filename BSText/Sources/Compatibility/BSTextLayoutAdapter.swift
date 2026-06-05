import UIKit

@available(iOS 13.0, *)
public class BSTextLayout: NSObject {
    public private(set) var textBoundingRect: CGRect = .zero
    public private(set) var textBoundingSize: CGSize = .zero

    private var container: BSTextContainer?
    private var text: NSAttributedString?

    public var isPrecomputed: Bool = false
    public var precomputationProgress: Double = 0

    public init?(container: BSTextContainer, text: NSAttributedString?) {
        guard let text = text else { return nil }
        self.container = container
        self.text = text
        super.init()
        container.setAssociatedLayout(self)
        calculateLayout()
    }

    public func precomputeLayout(completion: (() -> Void)? = nil) {
        calculateLayout()
        isPrecomputed = true
        precomputationProgress = 1
        completion?()
    }

    public func invalidateLayout() {
        isPrecomputed = false
        precomputationProgress = 0
        calculateLayout()
    }

    public func draw(in context: CGContext, boundingRect: CGRect, fraction: CGFloat) {
        guard let text = text else { return }
        context.saveGState()
        UIGraphicsPushContext(context)
        text.draw(in: boundingRect)
        UIGraphicsPopContext()
        context.restoreGState()
    }

    public func lineIndex(for point: CGPoint) -> Int {
        return point.y < textBoundingRect.maxY ? 0 : max(0, numberOfLines() - 1)
    }

    public func closestLineIndex(for point: CGPoint) -> Int {
        return lineIndex(for: point)
    }

    public func closestPosition(to point: CGPoint) -> UITextPosition? {
        return nil
    }

    public func textRange(at point: CGPoint) -> BSTextRange? {
        guard let text = text, textBoundingRect.contains(point) else { return nil }
        return BSTextRange(range: NSRange(location: 0, length: text.length))
    }

    public func rect(for range: BSTextRange) -> CGRect {
        return textBoundingRect
    }

    public func selectionRects(for range: BSTextRange) -> [BSTextSelectionRect] {
        let rect = BSTextSelectionRect()
        rect.rect = textBoundingRect
        rect.lineRect = textBoundingRect
        rect.containsStart = true
        rect.containsEnd = true
        return [rect]
    }

    public func numberOfLines() -> Int {
        guard let text = text else { return 0 }
        return max(1, text.string.components(separatedBy: .newlines).count)
    }

    public func lineRect(at index: Int) -> CGRect {
        return index < numberOfLines() ? textBoundingRect : .zero
    }

    public func lineRange(at index: Int) -> NSRange {
        guard let text = text, index == 0 else { return NSRange(location: 0, length: 0) }
        return NSRange(location: 0, length: text.length)
    }

    private func calculateLayout() {
        guard let text = text else {
            textBoundingRect = .zero
            textBoundingSize = .zero
            return
        }

        let width = container?.size.width ?? CGFloat.greatestFiniteMagnitude
        let boundingRect = text.boundingRect(
            with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )

        textBoundingSize = CGSize(width: ceil(boundingRect.width), height: ceil(boundingRect.height))
        textBoundingRect = CGRect(origin: .zero, size: textBoundingSize)
    }
}

@available(iOS 13.0, *)
public class BSTextLayoutCacheManager {
    public static let shared = BSTextLayoutCacheManager()

    private var layoutCache: [String: BSTextLayout] = [:]

    private init() {}

    public func cacheLayout(_ layout: BSTextLayout, for key: String) {
        layoutCache[key] = layout
    }

    public func cachedLayout(for key: String) -> BSTextLayout? {
        return layoutCache[key]
    }

    public func removeCachedLayout(for key: String) {
        layoutCache.removeValue(forKey: key)
    }

    public func clearAllCache() {
        layoutCache.removeAll()
    }
}

@available(iOS 13.0, *)
public class BSTextContainer: NSObject {
    public var size: CGSize = CGSize(width: 0, height: CGFloat.greatestFiniteMagnitude) {
        didSet { invalidateLayout() }
    }

    public var maximumNumberOfRows: Int = 0 {
        didSet { invalidateLayout() }
    }

    public var linePositionModifier: BSTextLinePositionModifier?

    public var path: UIBezierPath? {
        didSet { invalidateLayout() }
    }

    public var exclusionPaths: [UIBezierPath] = [] {
        didSet { invalidateLayout() }
    }

    public var textContainerInset: UIEdgeInsets = .zero {
        didSet { invalidateLayout() }
    }

    private weak var associatedLayout: BSTextLayout?

    public override init() {
        super.init()
    }

    private func invalidateLayout() {
        associatedLayout?.invalidateLayout()
    }

    func setAssociatedLayout(_ layout: BSTextLayout) {
        associatedLayout = layout
    }
}

public class BSTextRange: NSObject {
    public private(set) var range: NSRange

    public init(range: NSRange) {
        self.range = range
        super.init()
    }
}

public class BSTextSelectionRect: NSObject {
    public var rect: CGRect = .zero
    public var containsStart: Bool = false
    public var containsEnd: Bool = false
    public var isVertical: Bool = false
    public var lineRect: CGRect = .zero
}
