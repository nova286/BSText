import UIKit
import BSText

final class YYTextStyleGalleryViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupScrollView()
        buildContent()
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 14
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24)
        ])
    }

    private func buildContent() {
        stackView.addArrangedSubview(DemoPanel(title: "Attributes", subtitle: "CoreText/TextKit 常见属性") {
            let textView = DemoTextFactory.readOnlyTextView()
            textView.attributedText = DemoTextFactory.attributeGalleryText()
            textView.heightAnchor.constraint(equalToConstant: 270).isActive = true
            return textView
        })

        stackView.addArrangedSubview(DemoPanel(title: "Attachment & Backed String", subtitle: "Emoji、mention、文件和表格附件") {
            let textView = DemoTextFactory.readOnlyTextView()
            textView.attributedText = DemoTextFactory.attachmentText(containerWidth: UIScreen.main.bounds.width - 64)
            textView.heightAnchor.constraint(equalToConstant: 300).isActive = true
            return textView
        })

        stackView.addArrangedSubview(DemoPanel(title: "Tap Highlights", subtitle: "点击蓝色关键词查看高亮回调") {
            let label = BSLabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            label.textContainerInset = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
            label.layer.borderColor = UIColor.separator.cgColor
            label.layer.borderWidth = 1
            label.layer.cornerRadius = 8
            label.attributedText = DemoTextFactory.highlightText { [weak label] view, text, range, _ in
                guard let label else { return }
                let selected = (text as NSString).substring(with: range)
                DemoToast.show("Tapped \(selected)", in: label)
                view.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.06)
                UIView.animate(withDuration: 0.35) {
                    view.backgroundColor = .clear
                }
            }
            label.heightAnchor.constraint(equalToConstant: 126).isActive = true
            return label
        })
    }
}

final class SocialTimelineDemoViewController: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let modeControl = UISegmentedControl(items: ["Async", "Sync"])
    private let fpsLabel = UILabel()
    private var displayLink: CADisplayLink?
    private var frameCount = 0
    private var lastTime = Date()
    private let items = SocialPost.fixture(count: 80)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupToolbar()
        setupTableView()
        startFPS()
    }

    private func setupToolbar() {
        modeControl.selectedSegmentIndex = 0
        modeControl.addTarget(self, action: #selector(modeChanged), for: .valueChanged)
        modeControl.translatesAutoresizingMaskIntoConstraints = false

        fpsLabel.font = .monospacedDigitSystemFont(ofSize: 13, weight: .medium)
        fpsLabel.textColor = .systemGreen
        fpsLabel.textAlignment = .right
        fpsLabel.translatesAutoresizingMaskIntoConstraints = false

        let toolbar = UIView()
        toolbar.backgroundColor = .secondarySystemBackground
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.addSubview(modeControl)
        toolbar.addSubview(fpsLabel)
        view.addSubview(toolbar)

        NSLayoutConstraint.activate([
            toolbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 52),

            modeControl.leadingAnchor.constraint(equalTo: toolbar.leadingAnchor, constant: 16),
            modeControl.centerYAnchor.constraint(equalTo: toolbar.centerYAnchor),
            modeControl.widthAnchor.constraint(equalToConstant: 150),

            fpsLabel.trailingAnchor.constraint(equalTo: toolbar.trailingAnchor, constant: -16),
            fpsLabel.centerYAnchor.constraint(equalTo: toolbar.centerYAnchor),
            fpsLabel.leadingAnchor.constraint(greaterThanOrEqualTo: modeControl.trailingAnchor, constant: 12)
        ])
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemGroupedBackground
        tableView.register(SocialPostCell.self, forCellReuseIdentifier: SocialPostCell.reuseIdentifier)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 52),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func startFPS() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateFPS))
        displayLink?.add(to: .main, forMode: .common)
    }

    @objc private func updateFPS() {
        frameCount += 1
        let now = Date()
        let elapsed = now.timeIntervalSince(lastTime)
        guard elapsed >= 1 else { return }
        fpsLabel.text = String(format: "%.0f FPS", Double(frameCount) / elapsed)
        frameCount = 0
        lastTime = now
    }

    @objc private func modeChanged() {
        tableView.reloadData()
    }

    deinit {
        displayLink?.invalidate()
    }
}

extension SocialTimelineDemoViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SocialPostCell.reuseIdentifier, for: indexPath) as! SocialPostCell
        cell.configure(with: items[indexPath.row], async: modeControl.selectedSegmentIndex == 0)
        return cell
    }
}

final class RichTextEditorDemoViewController: UIViewController {
    private let textView = BSTextView()
    private let searchField = UITextField()
    private let parser = BSTextMarkdownParser()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupEditor()
        setupToolbar()
        loadInitialText()
    }

    private func setupEditor() {
        searchField.placeholder = "Search in document"
        searchField.borderStyle = .roundedRect
        searchField.autocorrectionType = .no
        searchField.addTarget(self, action: #selector(searchChanged), for: .editingChanged)
        searchField.translatesAutoresizingMaskIntoConstraints = false

        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .systemFont(ofSize: 16)
        textView.backgroundColor = .secondarySystemGroupedBackground
        textView.layer.cornerRadius = 8
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 14, bottom: 18, right: 14)

        view.addSubview(searchField)
        view.addSubview(textView)

        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            textView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 12),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -64)
        ])
    }

    private func setupToolbar() {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.items = [
            UIBarButtonItem(title: "B", style: .plain, target: self, action: #selector(toggleBold)),
            UIBarButtonItem(title: "I", style: .plain, target: self, action: #selector(toggleItalic)),
            UIBarButtonItem(title: "Tag", style: .plain, target: self, action: #selector(insertTag)),
            UIBarButtonItem(title: "File", style: .plain, target: self, action: #selector(insertFile)),
            UIBarButtonItem(title: "MD", style: .plain, target: self, action: #selector(renderMarkdown)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .undo, target: self, action: #selector(undoText)),
            UIBarButtonItem(barButtonSystemItem: .redo, target: self, action: #selector(redoText))
        ]
        view.addSubview(toolbar)

        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    private func loadInitialText() {
        textView.text = """
        # BSText Draft

        Select text and tap B or I.
        Insert a tag, a file attachment, or render this markdown into attributed text.

        ## Checklist
        - Rich edit
        - Inline attachment
        - Search highlight
        - Undo / redo
        """
    }

    @objc private func toggleBold() {
        textView.toggleBold()
    }

    @objc private func toggleItalic() {
        textView.toggleItalic()
    }

    @objc private func insertTag() {
        textView.insertAttachment(BSTextAttachment.mentionAttachment(username: "BSText", color: .systemPurple))
        textView.insertText(" ")
    }

    @objc private func insertFile() {
        textView.insertAttachment(BSTextAttachment.fileAttachment(filename: "demo-notes", fileType: "md"))
        textView.insertText("\n")
    }

    @objc private func renderMarkdown() {
        textView.attributedText = parser.parse(textView.text)
    }

    @objc private func undoText() {
        textView.undoManager?.undo()
    }

    @objc private func redoText() {
        textView.undoManager?.redo()
    }

    @objc private func searchChanged() {
        guard let query = searchField.text, !query.isEmpty else {
            return
        }
        let current = NSMutableAttributedString(attributedString: textView.attributedText ?? NSAttributedString(string: textView.text ?? ""))
        let baseString = current.string as NSString
        current.removeAttribute(NSAttributedString.Key.backgroundColor, range: NSRange(location: 0, length: current.length))
        var searchRange = NSRange(location: 0, length: baseString.length)
        while true {
            let found = baseString.range(of: query, options: NSString.CompareOptions.caseInsensitive, range: searchRange)
            guard found.location != NSNotFound else { break }
            current.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.systemYellow.withAlphaComponent(0.55), range: found)
            let nextLocation = found.location + found.length
            searchRange = NSRange(location: nextLocation, length: baseString.length - nextLocation)
        }
        textView.attributedText = current
    }
}

final class LayoutLabDemoViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupScrollView()
        buildContent()
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 14
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24)
        ])
    }

    private func buildContent() {
        stackView.addArrangedSubview(DemoPanel(title: "Async Fragment Debug", subtitle: "滚动时只布局 viewport 内文本片段") {
            let textView = DemoTextFactory.readOnlyTextView()
            textView.debugOptions = [.showFragments]
            textView.viewportLayoutEnabled = true
            textView.attributedText = DemoTextFactory.longLayoutText()
            textView.heightAnchor.constraint(equalToConstant: 280).isActive = true
            return textView
        })

        stackView.addArrangedSubview(DemoPanel(title: "Vertical Form", subtitle: "兼容 YYLabel 的 verticalForm 示例") {
            let label = BSLabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.verticalForm = true
            label.numberOfLines = 0
            label.textAlignment = .center
            label.textContainerInset = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
            label.attributedText = DemoTextFactory.verticalText()
            label.layer.borderWidth = 1
            label.layer.borderColor = UIColor.separator.cgColor
            label.layer.cornerRadius = 8
            label.heightAnchor.constraint(equalToConstant: 160).isActive = true
            return label
        })

        stackView.addArrangedSubview(DemoPanel(title: "Truncation & Insets", subtitle: "多行、内边距、line break 和自适应高度") {
            let label = BSLabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 3
            label.lineBreakMode = .byTruncatingTail
            label.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
            label.layer.borderWidth = 1
            label.layer.borderColor = UIColor.separator.cgColor
            label.layer.cornerRadius = 8
            label.attributedText = DemoTextFactory.truncationText()
            label.heightAnchor.constraint(equalToConstant: 128).isActive = true
            return label
        })
    }
}

private final class DemoPanel: UIView {
    init(title: String, subtitle: String, content: () -> UIView) {
        super.init(frame: .zero)
        backgroundColor = .secondarySystemGroupedBackground
        layer.cornerRadius = 8

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.textColor = .label

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 13)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 2

        let contentView = content()
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, contentView])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private struct SocialPost {
    let author: String
    let handle: String
    let body: NSAttributedString
    let imageColor: UIColor
    let stats: String

    static func fixture(count: Int) -> [SocialPost] {
        let authors = ["ibireme", "BSText Team", "TextKit Lab", "iOS Rendering", "Markdown Bot"]
        let topics = [
            "YYText 的 Demo 给人的感觉是完整、真实、能压测。BSText 现在也应该把属性、附件、编辑和异步渲染放进同一条产品化体验里。",
            "A long feed cell mixes bold title, colored tags, mentions, emoji attachments and inline file tokens. Smooth scrolling is where async text drawing becomes obvious.",
            "TextKit 2 keeps IME and selection reliable, while BSText layers viewport invalidation, attachment rendering and compatibility APIs on top.",
            "Tap highlights, Markdown parsing and rich attachments are more convincing when they appear in a timeline instead of isolated toy snippets."
        ]

        return (0..<count).map { index in
            SocialPost(
                author: authors[index % authors.count],
                handle: "@demo\(index)",
                body: DemoTextFactory.socialBody(topics[index % topics.count], index: index),
                imageColor: DemoPalette.colors[index % DemoPalette.colors.count],
                stats: "\(128 + index * 3) likes  \(24 + index) reposts  \(8 + index % 20) comments"
            )
        }
    }
}

private final class SocialPostCell: UITableViewCell {
    static let reuseIdentifier = "SocialPostCell"

    private let cardView = UIView()
    private let avatarView = UILabel()
    private let authorLabel = UILabel()
    private let handleLabel = UILabel()
    private let bodyLabel = BSLabel()
    private let mediaView = UIView()
    private let statsLabel = UILabel()
    private var bodyHeightConstraint: NSLayoutConstraint?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with post: SocialPost, async: Bool) {
        avatarView.text = String(post.author.prefix(1)).uppercased()
        authorLabel.text = post.author
        handleLabel.text = post.handle
        bodyLabel.attributedText = post.body
        bodyLabel.displaysAsynchronously = async
        bodyHeightConstraint?.constant = measuredBodyHeight(for: post.body)
        mediaView.backgroundColor = post.imageColor.withAlphaComponent(0.2)
        mediaView.layer.borderColor = post.imageColor.cgColor
        statsLabel.text = post.stats
    }

    private func measuredBodyHeight(for attributedText: NSAttributedString) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let horizontalMargins: CGFloat = 12 + 12 + 14 + 14
        let availableWidth = max(220, screenWidth - horizontalMargins)
        let bounds = attributedText.boundingRect(
            with: CGSize(width: availableWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        return max(44, ceil(bounds.height) + 14)
    }

    private func setupView() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .secondarySystemGroupedBackground
        cardView.layer.cornerRadius = 8
        contentView.addSubview(cardView)

        avatarView.font = .boldSystemFont(ofSize: 17)
        avatarView.textAlignment = .center
        avatarView.textColor = .white
        avatarView.backgroundColor = .systemIndigo
        avatarView.layer.cornerRadius = 22
        avatarView.layer.masksToBounds = true
        avatarView.translatesAutoresizingMaskIntoConstraints = false

        authorLabel.font = .boldSystemFont(ofSize: 16)
        handleLabel.font = .systemFont(ofSize: 13)
        handleLabel.textColor = .secondaryLabel

        bodyLabel.numberOfLines = 0
        bodyLabel.textContainerInset = .zero
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false

        mediaView.layer.cornerRadius = 8
        mediaView.layer.borderWidth = 1
        mediaView.translatesAutoresizingMaskIntoConstraints = false

        let mediaTitle = UILabel()
        mediaTitle.text = "Inline media placeholder"
        mediaTitle.font = .boldSystemFont(ofSize: 15)
        mediaTitle.textColor = .label
        mediaTitle.translatesAutoresizingMaskIntoConstraints = false
        mediaView.addSubview(mediaTitle)

        statsLabel.font = .systemFont(ofSize: 12)
        statsLabel.textColor = .secondaryLabel

        let nameStack = UIStackView(arrangedSubviews: [authorLabel, handleLabel])
        nameStack.axis = .vertical
        nameStack.spacing = 2

        let header = UIStackView(arrangedSubviews: [avatarView, nameStack])
        header.axis = .horizontal
        header.spacing = 12
        header.alignment = .center

        let stack = UIStackView(arrangedSubviews: [header, bodyLabel, mediaView, statsLabel])
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(stack)

        bodyHeightConstraint = bodyLabel.heightAnchor.constraint(equalToConstant: 86)
        bodyHeightConstraint?.priority = .required

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            avatarView.widthAnchor.constraint(equalToConstant: 44),
            avatarView.heightAnchor.constraint(equalToConstant: 44),
            bodyHeightConstraint!,
            mediaView.heightAnchor.constraint(equalToConstant: 118),

            mediaTitle.leadingAnchor.constraint(equalTo: mediaView.leadingAnchor, constant: 14),
            mediaTitle.bottomAnchor.constraint(equalTo: mediaView.bottomAnchor, constant: -14),

            stack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
            stack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            stack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -14)
        ])
    }
}

private enum DemoTextFactory {
    static func readOnlyTextView() -> BSTextView {
        let textView = BSTextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.backgroundColor = .systemBackground
        textView.layer.borderColor = UIColor.separator.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.font = .systemFont(ofSize: 16)
        textView.textContainerInset = UIEdgeInsets(top: 14, left: 12, bottom: 14, right: 12)
        return textView
    }

    static func attributeGalleryText() -> NSAttributedString {
        let text = NSMutableAttributedString()
        append("Font, Color, Shadow\n", to: text, font: .boldSystemFont(ofSize: 22), color: .label)
        append("Bold ", to: text, font: .boldSystemFont(ofSize: 17), color: .label)
        append("Italic ", to: text, font: .italicSystemFont(ofSize: 17), color: .label)
        append("Monospace ", to: text, font: .monospacedSystemFont(ofSize: 16, weight: .medium), color: .systemTeal)
        append("Stroke\n\n", to: text, font: .systemFont(ofSize: 17), color: .systemRed)

        let shadowRangeStart = text.length
        append("Soft shadow and underline with custom colors\n", to: text, font: .systemFont(ofSize: 17), color: .label)
        text.bs_setTextShadow(BSTextShadow(offset: CGSize(width: 0, height: 2), blurRadius: 3, color: UIColor.black.withAlphaComponent(0.25)), range: NSRange(location: shadowRangeStart, length: text.length - shadowRangeStart))
        text.bs_setTextUnderline(style: .single, color: .systemBlue, range: NSRange(location: shadowRangeStart, length: text.length - shadowRangeStart))

        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 6
        paragraph.firstLineHeadIndent = 18
        paragraph.headIndent = 18
        let paragraphText = NSAttributedString(
            string: "\nParagraph layout: first line indent, line spacing, custom color and mixed scripts. 中文段落、English words and numbers 12345 share the same attributed pipeline.\n",
            attributes: [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.secondaryLabel,
                .paragraphStyle: paragraph
            ]
        )
        text.append(paragraphText)

        let chipStart = text.length
        append("\nText border / background border / block marker", to: text, font: .boldSystemFont(ofSize: 16), color: .systemIndigo)
        let border = BSTextBorder.border(with: UIColor.systemIndigo.withAlphaComponent(0.14), cornerRadius: 4)
        border.strokeColor = .systemIndigo
        border.strokeWidth = 1
        text.bs_setTextBorder(border, range: NSRange(location: chipStart, length: text.length - chipStart))
        return text
    }

    static func attachmentText(containerWidth: CGFloat) -> NSAttributedString {
        let text = NSMutableAttributedString()
        append("Inline emoji: ", to: text, font: .boldSystemFont(ofSize: 16), color: .label)
        ["🎉", "🚀", "💡", "🔥"].forEach {
            text.append(NSAttributedString(attachment: BSTextAttachment.emojiAttachment(emoji: $0)))
            text.append(NSAttributedString(string: " "))
        }

        text.append(NSAttributedString(string: "\n\n"))
        append("Mentions: ", to: text, font: .boldSystemFont(ofSize: 16), color: .label)
        ["designer", "engineer", "reviewer"].forEach {
            text.append(NSAttributedString(attachment: BSTextAttachment.mentionAttachment(username: $0, color: .systemPurple)))
            text.append(NSAttributedString(string: " "))
        }

        text.append(NSAttributedString(string: "\n\n"))
        append("Files: ", to: text, font: .boldSystemFont(ofSize: 16), color: .label)
        text.append(NSAttributedString(attachment: BSTextAttachment.fileAttachment(filename: "YYText-style-demo", fileType: "swift")))
        text.append(NSAttributedString(string: "\n\n"))

        let markdown = """
        | Feature | Status | Notes |
        |:--|:--:|--:|
        | Rich text | Ready | 18 attrs |
        | Attachments | Ready | inline |
        | Async | Ready | feed |
        """
        let table = BSTextTableAttachment.tableAttachment(from: markdown)
        table.displaySize = CGSize(width: max(260, containerWidth), height: 150)
        table.image = table.renderTable()
        text.append(NSAttributedString(attachment: table))
        return text
    }

    static func highlightText(action: BSHighlightTapAction?) -> NSAttributedString {
        let body = "BSText supports tappable highlights like @mentions, #topics#, and inline links. Try tapping @BSText or #YYTextDemo#."
        let text = NSMutableAttributedString(string: body, attributes: [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.label
        ])
        ["@mentions", "#topics#", "inline links", "@BSText", "#YYTextDemo#"].forEach { token in
            let range = (body as NSString).range(of: token)
            guard range.location != NSNotFound else { return }
            text.bs_set(color: .systemBlue, range: range)
            text.bs_setTextHighlightRange(range, color: .systemBlue, backgroundColor: UIColor.systemBlue.withAlphaComponent(0.15), tapAction: action)
        }
        return text
    }

    static func socialBody(_ body: String, index: Int) -> NSAttributedString {
        let text = NSMutableAttributedString(string: body + "\n", attributes: [
            .font: UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor.label
        ])
        append("#BSText# ", to: text, font: .boldSystemFont(ofSize: 15), color: .systemBlue)
        append("@ibireme ", to: text, font: .boldSystemFont(ofSize: 15), color: .systemPink)
        text.append(NSAttributedString(attachment: BSTextAttachment.emojiAttachment(emoji: index.isMultiple(of: 2) ? "🚀" : "✨")))
        text.append(NSAttributedString(string: " "))
        text.append(NSAttributedString(attachment: BSTextAttachment.fileAttachment(filename: "trace-\(index)", fileType: "log")))
        return text
    }

    static func longLayoutText() -> NSAttributedString {
        let parser = BSTextMarkdownParser()
        let block = """
        # Layout stress
        **BSText** uses viewport invalidation and fragment-level rendering.

        - Mixed paragraph
        - Markdown parsing
        - Attachments
        - Debug overlays

        Long content repeats to exercise layout while scrolling. 中文、English、numbers and punctuation are mixed to force line breaking decisions.

        """
        return parser.parse(String(repeating: block, count: 12))
    }

    static func verticalText() -> NSAttributedString {
        NSMutableAttributedString(string: "竖排兼容示例\nVertical form sample\n混排文本 123 ABC", attributes: [
            .font: UIFont.systemFont(ofSize: 18, weight: .medium),
            .foregroundColor: UIColor.label
        ])
    }

    static func truncationText() -> NSAttributedString {
        NSMutableAttributedString(string: "This paragraph is intentionally longer than the visible area. It demonstrates multi-line truncation with insets, clear bounds, and consistent line breaking for real product copy instead of a one-line toy string.", attributes: [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.label
        ])
    }

    private static func append(_ string: String, to text: NSMutableAttributedString, font: UIFont, color: UIColor) {
        text.append(NSAttributedString(string: string, attributes: [.font: font, .foregroundColor: color]))
    }
}

private enum DemoPalette {
    static let colors: [UIColor] = [.systemIndigo, .systemTeal, .systemPink, .systemOrange, .systemGreen, .systemBlue]
}

private enum DemoToast {
    static func show(_ message: String, in view: UIView) {
        let label = UILabel()
        label.text = message
        label.font = .boldSystemFont(ofSize: 13)
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.78)
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12),
            label.heightAnchor.constraint(equalToConstant: 34),
            label.widthAnchor.constraint(greaterThanOrEqualToConstant: 140)
        ])

        label.alpha = 0
        UIView.animate(withDuration: 0.18, animations: {
            label.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.18, delay: 1.0, options: []) {
                label.alpha = 0
            } completion: { _ in
                label.removeFromSuperview()
            }
        }
    }
}
