import UIKit
import BSText

final class ViewController: UIViewController {
    fileprivate struct DemoSection {
        let title: String
        let subtitle: String
        let items: [DemoItem]
    }

    fileprivate struct DemoItem {
        let title: String
        let subtitle: String
        let badge: String
        let accentColor: UIColor
        let factory: () -> UIViewController
    }

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private lazy var sections: [DemoSection] = [
        DemoSection(
            title: "Showcase",
            subtitle: "对标 YYText Demo 的核心展示页",
            items: [
                DemoItem(title: "YYText Style Gallery", subtitle: "富文本属性、边框、阴影、附件与高亮交互", badge: "Rich", accentColor: .systemIndigo) { YYTextStyleGalleryViewController() },
                DemoItem(title: "Social Timeline", subtitle: "微博信息流、异步绘制开关与复杂图文混排", badge: "Feed", accentColor: .systemPink) { SocialTimelineDemoViewController() },
                DemoItem(title: "Rich Text Editor", subtitle: "编辑器工具栏、Markdown、附件插入与搜索高亮", badge: "Edit", accentColor: .systemTeal) { RichTextEditorDemoViewController() },
                DemoItem(title: "Layout Lab", subtitle: "竖排、路径/排除区、截断、debug fragment 与自适应", badge: "Layout", accentColor: .systemOrange) { LayoutLabDemoViewController() }
            ]
        ),
        DemoSection(
            title: "Compatibility",
            subtitle: "保留原有 DemoApp 的单点能力验证",
            items: [
                DemoItem(title: "Attribute", subtitle: "基础富文本属性", badge: "A", accentColor: .systemBlue) { AttributeDemoViewController() },
                DemoItem(title: "Edit", subtitle: "文本编辑与粗斜体切换", badge: "I", accentColor: .systemGreen) { EditDemoViewController() },
                DemoItem(title: "Emoticon", subtitle: "Emoji 附件", badge: ":)", accentColor: .systemYellow) { EmoticonDemoViewController() },
                DemoItem(title: "Tag", subtitle: "标签/mention 附件", badge: "@", accentColor: .systemPurple) { TagDemoViewController() },
                DemoItem(title: "Markdown", subtitle: "Markdown parser", badge: "MD", accentColor: .systemMint) { MarkdownDemoViewController() },
                DemoItem(title: "Table", subtitle: "Markdown table attachment", badge: "Tbl", accentColor: .systemBrown) { TableDemoViewController() },
                DemoItem(title: "Highlight", subtitle: "搜索高亮", badge: "Hi", accentColor: .systemRed) { HighlightDemoViewController() },
                DemoItem(title: "CopyPaste", subtitle: "复制粘贴", badge: "CP", accentColor: .systemCyan) { CopyPasteDemoViewController() },
                DemoItem(title: "UndoRedo", subtitle: "撤销重做", badge: "UR", accentColor: .systemGray) { UndoRedoDemoViewController() },
                DemoItem(title: "Async", subtitle: "异步渲染压力列表", badge: "FPS", accentColor: .systemGreen) { AsyncDemoViewController() },
                DemoItem(title: "Resize", subtitle: "可拖拽调整的复杂富文本容器", badge: "↕", accentColor: .systemBlue) { ResizeDemoViewController() }
            ]
        )
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "BSText Demo"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemGroupedBackground
        setupTableView()
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(DemoCell.self, forCellReuseIdentifier: DemoCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 86
        tableView.tableHeaderView = DemoHeaderView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 168))
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].items.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        sections[section].subtitle
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DemoCell.reuseIdentifier, for: indexPath) as! DemoCell
        cell.configure(with: sections[indexPath.section].items[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = sections[indexPath.section].items[indexPath.row]
        let viewController = item.factory()
        viewController.title = item.title
        navigationController?.pushViewController(viewController, animated: true)
    }
}

private final class DemoHeaderView: UIView {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let metricsStack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .systemGroupedBackground

        titleLabel.text = "BSText 3.0 Showcase"
        titleLabel.font = .boldSystemFont(ofSize: 28)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1

        subtitleLabel.text = "富文本渲染、编辑、图文混排、异步布局和交互高亮的完整 Demo 集。"
        subtitleLabel.font = .systemFont(ofSize: 15)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 2

        metricsStack.axis = .horizontal
        metricsStack.spacing = 8
        metricsStack.distribution = .fillEqually
        [
            ("TextKit 2", "Core"),
            ("Async", "Render"),
            ("Attach", "Media")
        ].forEach { metricsStack.addArrangedSubview(MetricPill(title: $0.0, subtitle: $0.1)) }

        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, metricsStack])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
}

private final class MetricPill: UIView {
    init(title: String, subtitle: String) {
        super.init(frame: .zero)
        backgroundColor = .secondarySystemGroupedBackground
        layer.cornerRadius = 8

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 15)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 11)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            heightAnchor.constraint(equalToConstant: 54)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private final class DemoCell: UITableViewCell {
    static let reuseIdentifier = "DemoCell"

    private let badgeLabel = UILabel()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func configure(with item: ViewController.DemoItem) {
        accessibilityIdentifier = item.title
        accessibilityLabel = item.title
        badgeLabel.text = item.badge
        badgeLabel.backgroundColor = item.accentColor.withAlphaComponent(0.16)
        badgeLabel.textColor = item.accentColor
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
    }

    private func setupView() {
        accessoryType = .disclosureIndicator
        backgroundColor = .secondarySystemGroupedBackground

        badgeLabel.font = .boldSystemFont(ofSize: 12)
        badgeLabel.textAlignment = .center
        badgeLabel.layer.cornerRadius = 8
        badgeLabel.layer.masksToBounds = true
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1

        subtitleLabel.font = .systemFont(ofSize: 13)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 2

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(badgeLabel)
        contentView.addSubview(textStack)

        NSLayoutConstraint.activate([
            badgeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            badgeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            badgeLabel.widthAnchor.constraint(equalToConstant: 44),
            badgeLabel.heightAnchor.constraint(equalToConstant: 34),

            textStack.leadingAnchor.constraint(equalTo: badgeLabel.trailingAnchor, constant: 14),
            textStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            textStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            textStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14)
        ])
    }
}
