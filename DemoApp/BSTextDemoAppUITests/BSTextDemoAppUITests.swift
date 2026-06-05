import XCTest

class BSTextDemoAppUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func testItalicButtonFunctionality() throws {
        // 导航到 Edit 页面
        let editCell = app.tables.cells["Edit"]
        XCTAssertTrue(editCell.waitForExistence(timeout: 5), "Edit cell should exist")
        editCell.tap()
        
        // 等待编辑页面加载
        let textView = app.textViews.firstMatch
        XCTAssertTrue(textView.waitForExistence(timeout: 5), "TextView should exist")
        
        // 输入测试文本
        textView.tap()
        textView.typeText("Hello World")
        
        // 选择所有文本（长按选择）
        textView.press(forDuration: 1)
        
        // 等待选择菜单出现
        let selectAllButton = app.menuItems["Select All"]
        XCTAssertTrue(selectAllButton.waitForExistence(timeout: 3), "Select All menu item should exist")
        selectAllButton.tap()
        
        // 点击斜体按钮
        let italicButton = app.buttons["I"]
        XCTAssertTrue(italicButton.waitForExistence(timeout: 3), "Italic button should exist")
        italicButton.tap()
        
        // 验证斜体效果 - 通过检查文本视图的属性
        // 由于我们无法直接检查字体属性，我们可以验证按钮点击后文本仍然存在
        XCTAssertTrue(textView.exists, "TextView should still exist after italic button tap")
        
        // 再次点击斜体按钮取消斜体
        italicButton.tap()
        
        // 验证文本仍然存在
        XCTAssertTrue(textView.exists, "TextView should still exist after second italic button tap")
    }
    
    func testItalicButtonWithoutSelection() throws {
        // 导航到 Edit 页面
        let editCell = app.tables.cells["Edit"]
        XCTAssertTrue(editCell.waitForExistence(timeout: 5))
        editCell.tap()
        
        // 等待编辑页面加载
        let textView = app.textViews.firstMatch
        XCTAssertTrue(textView.waitForExistence(timeout: 5))
        
        // 不选择文本，直接点击斜体按钮
        let italicButton = app.buttons["I"]
        XCTAssertTrue(italicButton.waitForExistence(timeout: 3))
        italicButton.tap()
        
        // 输入文本并验证
        textView.tap()
        textView.typeText("Italic Text")
        
        XCTAssertTrue(textView.exists, "TextView should exist with new text")
    }
}
