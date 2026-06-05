import UIKit
import BSText

class AttributeDemoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let textView = BSTextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.font = .systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        view.addSubview(textView)
        
        let attributedText = NSMutableAttributedString()
        
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16)
        ]
        attributedText.append(NSAttributedString(string: "Bold Text\n", attributes: boldAttributes))
        
        let italicAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.italicSystemFont(ofSize: 16)
        ]
        attributedText.append(NSAttributedString(string: "Italic Text\n", attributes: italicAttributes))
        
        let colorAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.systemBlue
        ]
        attributedText.append(NSAttributedString(string: "Colored Text\n", attributes: colorAttributes))
        
        let underlineAttributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        attributedText.append(NSAttributedString(string: "Underlined Text\n", attributes: underlineAttributes))
        
        let strikethroughAttributes: [NSAttributedString.Key: Any] = [
            .strikethroughStyle: NSUnderlineStyle.single.rawValue
        ]
        attributedText.append(NSAttributedString(string: "Strikethrough Text\n", attributes: strikethroughAttributes))
        
        let shadow = NSShadow()
        shadow.shadowOffset = CGSize(width: 2, height: 2)
        shadow.shadowColor = UIColor.gray
        let shadowAttrs: [NSAttributedString.Key: Any] = [.shadow: shadow]
        attributedText.append(NSAttributedString(string: "Shadow Text", attributes: shadowAttrs))
        
        textView.attributedText = attributedText
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
}

class EditDemoViewController: UIViewController {
    private var textView: BSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        textView = BSTextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.text = "Edit sample text\n中文编辑示例"
        view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.barStyle = .default
        
        let boldButton = UIBarButtonItem(title: "B", style: .plain, target: self, action: #selector(toggleBold))
        boldButton.setTitleTextAttributes([.font: UIFont.boldSystemFont(ofSize: 16)], for: .normal)
        
        let italicButton = UIBarButtonItem(title: "I", style: .plain, target: self, action: #selector(toggleItalic))
        italicButton.setTitleTextAttributes([.font: UIFont.italicSystemFont(ofSize: 16)], for: .normal)
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [boldButton, flexibleSpace, italicButton]
        
        view.addSubview(toolbar)
        
        NSLayoutConstraint.activate([
            toolbar.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 16),
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc func toggleBold() {
        textView.toggleBold()
    }
    
    @objc func toggleItalic() {
        textView.toggleItalic()
    }
}

class EmoticonDemoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.font = .systemFont(ofSize: 32)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        view.addSubview(textView)
        
        let attributedText = NSMutableAttributedString()
        let emojis = ["🎉", "🚀", "💡", "🎯", "🌟", "💪", "🔥", "✨", "❤️", "😊"]
        for (index, emoji) in emojis.enumerated() {
            let attachment = BSTextAttachment.emojiAttachment(emoji: emoji)
            attributedText.append(NSAttributedString(attachment: attachment))
            if index < emojis.count - 1 {
                attributedText.append(NSAttributedString(string: "  "))
            }
        }
        textView.attributedText = attributedText
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
}

class TagDemoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 22, left: 18, bottom: 22, right: 18)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.attributedText = Self.mixedTagText()
        view.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 260)
        ])
    }

    private static func mixedTagText() -> NSAttributedString {
        let bodyFont = UIFont.systemFont(ofSize: 17)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        paragraphStyle.lineBreakMode = .byWordWrapping

        let attributes: [NSAttributedString.Key: Any] = [
            .font: bodyFont,
            .foregroundColor: UIColor.label,
            .paragraphStyle: paragraphStyle
        ]

        let attributedText = NSMutableAttributedString(string: "Tags: ", attributes: attributes)
        let tags = [
            "#iOS", "#Swift", "#BSText", "#TextKit", "#UIKit",
            "#CoreText", "#AsyncRender", "#Markdown", "#Attachment", "#Layout"
        ]

        for tag in tags {
            let attachmentString = NSMutableAttributedString(attachment: InlineTagAttachment(title: tag, font: bodyFont))
            attachmentString.addAttributes(attributes, range: NSRange(location: 0, length: attachmentString.length))
            attributedText.append(attachmentString)
            attributedText.append(NSAttributedString(string: " ", attributes: attributes))
        }

        attributedText.append(NSAttributedString(
            string: "These tags should wrap naturally and keep the following plain text aligned with the same paragraph flow.",
            attributes: attributes
        ))

        return attributedText
    }
}

private final class InlineTagAttachment: NSTextAttachment {
    private let tagSize: CGSize
    private let baselineOffset: CGFloat

    init(title: String, font: UIFont) {
        let chipFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        let text = NSAttributedString(string: title, attributes: [
            .font: chipFont,
            .foregroundColor: UIColor.systemBlue
        ])
        let insets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        let textSize = text.size()
        tagSize = CGSize(
            width: ceil(textSize.width + insets.left + insets.right),
            height: ceil(textSize.height + insets.top + insets.bottom)
        )
        baselineOffset = round((font.capHeight - tagSize.height) / 2)

        super.init(data: nil, ofType: nil)

        let renderer = UIGraphicsImageRenderer(size: tagSize)
        image = renderer.image { _ in
            UIColor.systemBlue.withAlphaComponent(0.12).setFill()
            UIBezierPath(roundedRect: CGRect(origin: .zero, size: tagSize), cornerRadius: 6).fill()
            UIColor.systemBlue.withAlphaComponent(0.2).setStroke()
            UIBezierPath(
                roundedRect: CGRect(origin: CGPoint(x: 0.5, y: 0.5), size: CGSize(width: tagSize.width - 1, height: tagSize.height - 1)),
                cornerRadius: 6
            ).stroke()
            text.draw(at: CGPoint(x: insets.left, y: insets.top))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        CGRect(x: 0, y: baselineOffset, width: tagSize.width, height: tagSize.height)
    }
}

class MarkdownDemoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let textView = BSTextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.font = .systemFont(ofSize: 15)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        view.addSubview(textView)
        
        let markdown = """
# Heading Level 1

**Bold text** and *italic text* supported.

- List item 1
- List item 2
- List item 3

> Blockquote example

`Code snippet`

---

## Heading Level 2

[Link text](https://example.com)
"""
        let parser = BSTextMarkdownParser()
        textView.attributedText = parser.parse(markdown)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
}

class HighlightDemoViewController: UIViewController {
    let searchField = UITextField()
    let textView = BSTextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        searchField.placeholder = "Search..."
        searchField.borderStyle = .roundedRect
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.addTarget(self, action: #selector(searchText), for: .editingChanged)
        view.addSubview(searchField)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.font = .systemFont(ofSize: 14)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.text = """
This is a sample text for search testing.
The BSText framework supports powerful search functionality.
You can search for keywords like "search", "text", or "framework".
Try typing in the search field above!
"""
        view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            textView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    @objc func searchText() {
        guard let searchText = searchField.text, !searchText.isEmpty else {
            textView.attributedText = NSAttributedString(string: textView.text)
            return
        }
        
        let indexer = BSTextSearchIndexer()
        indexer.indexText(textView.text)
        let results = indexer.search(searchText)
        
        if results.count > 0 {
            let attributedText = NSMutableAttributedString(string: textView.text)
            for result in results {
                attributedText.addAttribute(.backgroundColor, value: UIColor.yellow, range: result.range)
            }
            textView.attributedText = attributedText
        } else {
            textView.attributedText = NSAttributedString(string: textView.text)
        }
    }
}

class CopyPasteDemoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let textView = BSTextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.text = "Try copying and pasting text here..."
        view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
}

class UndoRedoDemoViewController: UIViewController, UITextViewDelegate {
    private let textView = BSTextView()
    private var undoButton: UIBarButtonItem!
    private var redoButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        textView.font = .systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.text = "Type something and try undo/redo..."
        view.addSubview(textView)
        
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        
        undoButton = UIBarButtonItem(barButtonSystemItem: .undo, target: self, action: #selector(performUndo))
        redoButton = UIBarButtonItem(barButtonSystemItem: .redo, target: self, action: #selector(performRedo))
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [undoButton, flexibleSpace, redoButton]
        
        view.addSubview(toolbar)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 200),
            
            toolbar.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 16),
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 44)
        ])

        refreshUndoRedoButtons()
    }

    func textViewDidChange(_ textView: UITextView) {
        refreshUndoRedoButtons()
    }

    @objc private func performUndo() {
        textView.undoManager?.undo()
        refreshUndoRedoButtons()
    }

    @objc private func performRedo() {
        textView.undoManager?.redo()
        refreshUndoRedoButtons()
    }

    @objc private func refreshUndoRedoButtons() {
        undoButton?.isEnabled = textView.undoManager?.canUndo == true
        redoButton?.isEnabled = textView.undoManager?.canRedo == true
    }
}

class TableDemoViewController: UIViewController {
    private let textView = BSTextView()
    private var lastRenderedWidth: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Table Support"
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.font = .systemFont(ofSize: 16)
        textView.textContainerInset = UIEdgeInsets(top: 18, left: 12, bottom: 18, right: 12)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        view.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let availableWidth = floor(textView.bounds.width - textView.textContainerInset.left - textView.textContainerInset.right)
        guard availableWidth > 0, abs(availableWidth - lastRenderedWidth) > 0.5 else { return }
        lastRenderedWidth = availableWidth
        renderTableContent(width: availableWidth)
    }

    private func renderTableContent(width: CGFloat) {
        let attributedText = NSMutableAttributedString()
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18)
        ]
        attributedText.append(NSAttributedString(string: "Markdown Table Demo\n\n", attributes: titleAttributes))
        
        // Create table from markdown
        let markdownTable = """
| Feature | Status | Priority |
|:--------|:------:|---------:|
| Rich Text | ✅ | High |
| Markdown | ✅ | High |
| Table | ✅ | Medium |
| Syntax Highlight | ✅ | Medium |
"""
        
        let tableAttachment = BSTextTableAttachment.tableAttachment(from: markdownTable)
        tableAttachment.displaySize = CGSize(width: width, height: tableAttachment.displaySize.height)
        
        if let tableImage = tableAttachment.renderTable() {
            tableAttachment.image = tableImage
            attributedText.append(NSAttributedString(attachment: tableAttachment))
        }
        
        attributedText.append(NSAttributedString(string: "\n\n"))
        
        let description = NSAttributedString(string: "This demonstrates BSText's table support. Tables are rendered as images within the text view.", attributes: [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.systemGray
        ])
        attributedText.append(description)
        
        textView.attributedText = attributedText
    }
}
