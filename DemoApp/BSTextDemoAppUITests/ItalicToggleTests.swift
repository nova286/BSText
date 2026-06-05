import XCTest
import UIKit
import BSText
import CoreText

class ItalicToggleTests: XCTestCase {
    
    func testItalicTraitToggle() {
        // 测试从普通字体切换到斜体
        let regularFont = UIFont.systemFont(ofSize: 16)
        var traits = regularFont.fontDescriptor.symbolicTraits
        
        // 初始状态不应该是斜体
        XCTAssertFalse(traits.contains(.traitItalic), "Regular font should not have italic trait")
        
        // 添加斜体特性
        traits.insert(.traitItalic)
        XCTAssertTrue(traits.contains(.traitItalic), "Traits should now contain italic")
        
        // 创建新字体
        if let newDescriptor = regularFont.fontDescriptor.withSymbolicTraits(traits) {
            let italicFont = UIFont(descriptor: newDescriptor, size: regularFont.pointSize)
            XCTAssertTrue(italicFont.fontDescriptor.symbolicTraits.contains(.traitItalic), 
                        "New font should be italic")
        } else {
            XCTFail("Failed to create italic font descriptor")
        }
    }
    
    func testItalicTraitRemove() {
        // 测试从斜体切换回普通字体
        let italicFont = UIFont.italicSystemFont(ofSize: 16)
        var traits = italicFont.fontDescriptor.symbolicTraits
        
        // 初始状态应该是斜体
        XCTAssertTrue(traits.contains(.traitItalic), "Italic font should have italic trait")
        
        // 移除斜体特性
        traits.remove(.traitItalic)
        XCTAssertFalse(traits.contains(.traitItalic), "Traits should no longer contain italic")
        
        // 创建新字体
        if let newDescriptor = italicFont.fontDescriptor.withSymbolicTraits(traits) {
            let regularFont = UIFont(descriptor: newDescriptor, size: italicFont.pointSize)
            XCTAssertFalse(regularFont.fontDescriptor.symbolicTraits.contains(.traitItalic), 
                        "New font should not be italic")
        } else {
            XCTFail("Failed to create regular font descriptor")
        }
    }
    
    func testBoldItalicCombination() {
        // 测试同时具有粗体和斜体的情况
        let boldFont = UIFont.boldSystemFont(ofSize: 16)
        var traits = boldFont.fontDescriptor.symbolicTraits
        
        // 添加斜体
        traits.insert(.traitItalic)
        
        if let newDescriptor = boldFont.fontDescriptor.withSymbolicTraits(traits) {
            let boldItalicFont = UIFont(descriptor: newDescriptor, size: boldFont.pointSize)
            let newTraits = boldItalicFont.fontDescriptor.symbolicTraits
            
            XCTAssertTrue(newTraits.contains(.traitBold), "Font should be bold")
            XCTAssertTrue(newTraits.contains(.traitItalic), "Font should be italic")
            
            // 移除斜体但保留粗体
            var modifiedTraits = newTraits
            modifiedTraits.remove(.traitItalic)
            
            if let regularBoldDescriptor = boldItalicFont.fontDescriptor.withSymbolicTraits(modifiedTraits) {
                let regularBoldFont = UIFont(descriptor: regularBoldDescriptor, size: boldItalicFont.pointSize)
                let finalTraits = regularBoldFont.fontDescriptor.symbolicTraits
                
                XCTAssertTrue(finalTraits.contains(.traitBold), "Font should still be bold")
                XCTAssertFalse(finalTraits.contains(.traitItalic), "Font should no longer be italic")
            } else {
                XCTFail("Failed to create bold non-italic font descriptor")
            }
        } else {
            XCTFail("Failed to create bold italic font descriptor")
        }
    }

    func testTextViewToggleItalicAppliesFontToSelectedRange() {
        let textView = BSTextView(frame: CGRect(x: 0, y: 0, width: 320, height: 120))
        textView.font = .systemFont(ofSize: 16)
        textView.text = "Hello World"
        textView.selectedRange = NSRange(location: 0, length: 5)

        textView.toggleItalic()

        XCTAssertEqual(coreTextItalicShear(in: textView.textStorage, at: 0), 0.35, accuracy: 0.001)
        XCTAssertEqual((textView.textStorage.attribute(.obliqueness, at: 0, effectiveRange: nil) as? NSNumber)?.floatValue, 0.35)
    }

    func testTextViewToggleItalicAppliesSyntheticSlantToSelectedChineseText() {
        let textView = BSTextView(frame: CGRect(x: 0, y: 0, width: 320, height: 120))
        textView.font = .systemFont(ofSize: 16)
        textView.text = "中文编辑示例"
        textView.selectedRange = NSRange(location: 0, length: 2)

        textView.toggleItalic()

        XCTAssertEqual(coreTextItalicShear(in: textView.textStorage, at: 0), 0.35, accuracy: 0.001)
        XCTAssertEqual((textView.textStorage.attribute(.obliqueness, at: 0, effectiveRange: nil) as? NSNumber)?.floatValue, 0.35)
    }

    func testTextViewToggleItalicAppliesToInsertedTextWithoutSelection() {
        let textView = BSTextView(frame: CGRect(x: 0, y: 0, width: 320, height: 120))
        textView.font = .systemFont(ofSize: 16)
        textView.text = ""
        textView.selectedRange = NSRange(location: 0, length: 0)

        textView.toggleItalic()
        textView.insertText("Italic")

        XCTAssertEqual(coreTextItalicShear(in: textView.textStorage, at: 0), 0.35, accuracy: 0.001)
        XCTAssertEqual((textView.textStorage.attribute(.obliqueness, at: 0, effectiveRange: nil) as? NSNumber)?.floatValue, 0.35)
    }

    func testTextViewToggleItalicAppliesSyntheticSlantToInsertedChineseText() {
        let textView = BSTextView(frame: CGRect(x: 0, y: 0, width: 320, height: 120))
        textView.font = .systemFont(ofSize: 16)
        textView.text = ""
        textView.selectedRange = NSRange(location: 0, length: 0)

        textView.toggleItalic()
        textView.insertText("中文")

        XCTAssertEqual(coreTextItalicShear(in: textView.textStorage, at: 0), 0.35, accuracy: 0.001)
        XCTAssertEqual((textView.textStorage.attribute(.obliqueness, at: 0, effectiveRange: nil) as? NSNumber)?.floatValue, 0.35)
    }

    func testTextViewToggleItalicSurvivesFocusBeforeInsertedText() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 120))
        let textView = BSTextView(frame: window.bounds)
        window.addSubview(textView)
        window.makeKeyAndVisible()

        textView.font = .systemFont(ofSize: 16)
        textView.text = ""
        textView.selectedRange = NSRange(location: 0, length: 0)

        textView.toggleItalic()
        textView.becomeFirstResponder()
        textView.insertText("Italic")

        XCTAssertEqual(coreTextItalicShear(in: textView.textStorage, at: 0), 0.35, accuracy: 0.001)
    }

    func testTextViewToggleItalicSurvivesResponderRoundTripBeforeInsertedText() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 120))
        let textView = BSTextView(frame: window.bounds)
        window.addSubview(textView)
        window.makeKeyAndVisible()

        textView.font = .systemFont(ofSize: 16)
        textView.text = ""
        textView.selectedRange = NSRange(location: 0, length: 0)

        textView.becomeFirstResponder()
        textView.toggleItalic()
        textView.resignFirstResponder()
        textView.becomeFirstResponder()
        textView.insertText("Italic")

        XCTAssertEqual(coreTextItalicShear(in: textView.textStorage, at: 0), 0.35, accuracy: 0.001)
        XCTAssertEqual((textView.textStorage.attribute(.obliqueness, at: 0, effectiveRange: nil) as? NSNumber)?.floatValue, 0.35)
    }

    func testMarkdownParserAppliesItalicFontToItalicText() {
        let parser = BSTextMarkdownParser()
        let attributed = parser.parse("**Bold text** and *italic text* supported.")
        let nsString = attributed.string as NSString
        let italicRange = nsString.range(of: "italic text")

        XCTAssertNotEqual(italicRange.location, NSNotFound)
        let font = attributed.attribute(.font, at: italicRange.location, effectiveRange: nil) as? UIFont
        XCTAssertTrue(font?.fontDescriptor.symbolicTraits.contains(.traitItalic) == true)
    }

    private func coreTextItalicShear(in attributedString: NSAttributedString, at location: Int) -> CGFloat {
        let key = NSAttributedString.Key(kCTFontAttributeName as String)
        guard let font = attributedString.attribute(key, at: location, effectiveRange: nil) else {
            return 0
        }

        return CTFontGetMatrix(font as! CTFont).c
    }
}
