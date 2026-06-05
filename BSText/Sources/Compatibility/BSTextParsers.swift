import UIKit

public class BSTextSimpleEmoticonParser: NSObject, BSTextParser {
    public var emoticonMapper: [String: UIImage] = [:]

    public override init() {
        super.init()
    }

    public func parse(_ text: String) -> NSAttributedString {
        let mutableString = NSMutableAttributedString(string: text)
        let fullRange = NSRange(location: 0, length: mutableString.length)
        mutableString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16), range: fullRange)

        let parsedString = text
        var attachments: [(range: NSRange, attachment: NSTextAttachment, length: Int)] = []

        for (emoticon, image) in emoticonMapper {
            var searchRange = parsedString.startIndex..<parsedString.endIndex
            while let range = parsedString.range(of: emoticon, range: searchRange) {
                let nsRange = NSRange(range, in: parsedString)

                let attachment = NSTextAttachment()
                attachment.image = image
                attachment.bounds = CGRect(x: 0, y: -4, width: 16, height: 16)

                let attachmentString = NSAttributedString(attachment: attachment)
                let mutableAttachment = NSMutableAttributedString(attributedString: attachmentString)
                mutableAttachment.addAttribute(.font, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: 0, length: mutableAttachment.length))

                attachments.append((range: nsRange, attachment: attachment, length: emoticon.count))

                searchRange = range.upperBound..<parsedString.endIndex
            }
        }

        for (_, item) in attachments.enumerated().reversed() {
            let replacement = NSMutableAttributedString(attachment: item.attachment)
            replacement.addAttribute(.font, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: 0, length: replacement.length))
            mutableString.replaceCharacters(in: item.range, with: replacement)
        }

        return mutableString
    }
}

public class BSTextSimpleMarkdownParser: NSObject, BSTextParser {

    public enum MarkdownStyle {
        case light
        case dark
    }

    public var headerFontSize: CGFloat = 24
    public var bodyFontSize: CGFloat = 16
    public var themeColor: UIColor = .systemBlue
    public var codeBackgroundColor: UIColor = .systemGray5
    public var useDarkTheme: Bool = false

    public override init() {
        super.init()
    }

    public func setColorWithDarkTheme() {
        useDarkTheme = true
        themeColor = .systemOrange
        codeBackgroundColor = UIColor(white: 0.15, alpha: 1.0)
    }

    public func parse(_ text: String) -> NSAttributedString {
        let mutableString = NSMutableAttributedString()
        let lines = text.components(separatedBy: "\n")

        for line in lines {
            if line.hasPrefix("# ") {
                let headerText = String(line.dropFirst(2))
                let headerAttrs = createHeaderAttributes(level: 1)
                mutableString.append(NSAttributedString(string: headerText + "\n", attributes: headerAttrs))
            } else if line.hasPrefix("## ") {
                let headerText = String(line.dropFirst(3))
                let headerAttrs = createHeaderAttributes(level: 2)
                mutableString.append(NSAttributedString(string: headerText + "\n", attributes: headerAttrs))
            } else if line.hasPrefix("### ") {
                let headerText = String(line.dropFirst(4))
                let headerAttrs = createHeaderAttributes(level: 3)
                mutableString.append(NSAttributedString(string: headerText + "\n", attributes: headerAttrs))
            } else if line.hasPrefix("> ") {
                let quoteText = String(line.dropFirst(2))
                let quoteAttrs = createQuoteAttributes()
                mutableString.append(NSAttributedString(string: quoteText + "\n", attributes: quoteAttrs))
            } else if line.hasPrefix("- ") || line.hasPrefix("* ") {
                let listText = "• " + String(line.dropFirst(2))
                let listAttrs = createBodyAttributes()
                mutableString.append(NSAttributedString(string: listText + "\n", attributes: listAttrs))
            } else if line.hasPrefix("```") {
                continue
            } else {
                let bodyAttrs = createBodyAttributes()
                mutableString.append(NSAttributedString(string: line + "\n", attributes: bodyAttrs))
            }
        }

        return parseInlineFormatting(mutableString)
    }

    private func createHeaderAttributes(level: Int) -> [NSAttributedString.Key: Any] {
        let fontSize: CGFloat
        switch level {
        case 1: fontSize = headerFontSize
        case 2: fontSize = headerFontSize * 0.85
        default: fontSize = headerFontSize * 0.75
        }

        return [
            .font: UIFont.boldSystemFont(ofSize: fontSize),
            .foregroundColor: themeColor
        ]
    }

    private func createQuoteAttributes() -> [NSAttributedString.Key: Any] {
        return [
            .font: UIFont.italicSystemFont(ofSize: bodyFontSize),
            .foregroundColor: useDarkTheme ? UIColor.lightGray : UIColor.darkGray
        ]
    }

    private func createBodyAttributes() -> [NSAttributedString.Key: Any] {
        return [
            .font: UIFont.systemFont(ofSize: bodyFontSize),
            .foregroundColor: useDarkTheme ? UIColor.white : UIColor(white: 0.1, alpha: 1.0)
        ]
    }

    private func parseInlineFormatting(_ attributedString: NSMutableAttributedString) -> NSMutableAttributedString {
        let text = attributedString.string
        let mutable = NSMutableAttributedString(attributedString: attributedString)

        let boldPattern = "\\*\\*(.+?)\\*\\*"
        let italicPattern = "(?<!\\*)\\*(?!\\*)(.+?)(?<!\\*)\\*(?!\\*)"
        let codePattern = "`(.+?)`"

        if let regex = try? NSRegularExpression(pattern: boldPattern) {
            let matches = regex.matches(in: text, range: NSRange(location: 0, length: text.count))
            for match in matches.reversed() {
                if let range = Range(match.range(at: 1), in: text) {
                    let boldText = String(text[range])
                    let boldFont = UIFont.boldSystemFont(ofSize: bodyFontSize)
                    let attrs: [NSAttributedString.Key: Any] = [.font: boldFont]
                    let replacement = NSAttributedString(string: boldText, attributes: attrs)
                    mutable.replaceCharacters(in: match.range, with: replacement)
                }
            }
        }

        if let regex = try? NSRegularExpression(pattern: italicPattern) {
            let currentText = mutable.string
            let matches = regex.matches(in: currentText, range: NSRange(location: 0, length: currentText.count))
            for match in matches.reversed() {
                if match.range(at: 1).location + match.range(at: 1).length <= currentText.count {
                    if let range = Range(match.range(at: 1), in: currentText) {
                        let italicText = String(currentText[range])
                        let italicFont = UIFont.italicSystemFont(ofSize: bodyFontSize)
                        let attrs: [NSAttributedString.Key: Any] = [.font: italicFont]
                        let replacement = NSAttributedString(string: italicText, attributes: attrs)
                        mutable.replaceCharacters(in: match.range, with: replacement)
                    }
                }
            }
        }

        if let regex = try? NSRegularExpression(pattern: codePattern) {
            let currentText = mutable.string
            let matches = regex.matches(in: currentText, range: NSRange(location: 0, length: currentText.count))
            for match in matches.reversed() {
                if match.range(at: 1).location + match.range(at: 1).length <= currentText.count {
                    if let range = Range(match.range(at: 1), in: currentText) {
                        let codeText = String(currentText[range])
                        let attrs: [NSAttributedString.Key: Any] = [
                            .font: UIFont.monospacedSystemFont(ofSize: bodyFontSize - 1, weight: .regular),
                            .backgroundColor: codeBackgroundColor
                        ]
                        let replacement = NSAttributedString(string: codeText, attributes: attrs)
                        mutable.replaceCharacters(in: match.range, with: replacement)
                    }
                }
            }
        }

        return mutable
    }
}

@available(iOS 13.0, *)
public extension BSTextView {
    var textParser: BSTextParser? {
        get { return nil }
        set { }
    }
}
