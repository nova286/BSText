import UIKit

extension NSString {
    func rangeOfWord(at location: Int) -> NSRange? {
        guard location >= 0 && location <= length else {
            return nil
        }
        
        var start = location
        var end = location
        
        while start > 0 && character(at: start - 1).isWordCharacter {
            start -= 1
        }
        
        while end < length && character(at: end).isWordCharacter {
            end += 1
        }
        
        return NSRange(location: start, length: end - start)
    }
}

extension unichar {
    var isWordCharacter: Bool {
        let character = Character(UnicodeScalar(self) ?? "\0")
        return character.isLetter || character.isNumber || self == 0x27 // apostrophe
    }
}

extension UIFont {
    private static let syntheticItalicShear: CGFloat = 0.35

    var isBold: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitBold)
    }
    
    var isItalic: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitItalic)
    }
    
    var bolded: UIFont {
        var traits = fontDescriptor.symbolicTraits
        traits.insert(.traitBold)
        if let descriptor = fontDescriptor.withSymbolicTraits(traits) {
            return UIFont(descriptor: descriptor, size: pointSize)
        }
        // Fallback: use system bold font
        return UIFont.boldSystemFont(ofSize: pointSize)
    }
    
    var unbolded: UIFont {
        var traits = fontDescriptor.symbolicTraits
        traits.remove(.traitBold)
        if let descriptor = fontDescriptor.withSymbolicTraits(traits) {
            return UIFont(descriptor: descriptor, size: pointSize)
        }
        // Fallback: use system regular font
        return UIFont.systemFont(ofSize: pointSize)
    }
    
    var italicized: UIFont {
        var traits = fontDescriptor.symbolicTraits
        traits.insert(.traitItalic)

        let baseDescriptor = fontDescriptor.withSymbolicTraits(traits) ?? fontDescriptor
        let italicDescriptor = baseDescriptor.addingAttributes([
            .matrix: CGAffineTransform(a: 1, b: 0, c: UIFont.syntheticItalicShear, d: 1, tx: 0, ty: 0)
        ])
        return UIFont(descriptor: italicDescriptor, size: pointSize)
    }

    var syntheticItalicized: UIFont {
        let descriptor = fontDescriptor.addingAttributes([
            .matrix: CGAffineTransform(a: 1, b: 0, c: UIFont.syntheticItalicShear, d: 1, tx: 0, ty: 0)
        ])
        return UIFont(descriptor: descriptor, size: pointSize)
    }

    var syntheticUnitalicized: UIFont {
        let descriptor = fontDescriptor.addingAttributes([
            .matrix: CGAffineTransform.identity
        ])
        return UIFont(descriptor: descriptor, size: pointSize)
    }

    var hasSyntheticItalic: Bool {
        let matrix = fontDescriptor.object(forKey: .matrix)

        if let value = matrix as? NSValue {
            return abs(value.cgAffineTransformValue.c) > 0.001
        }

        if let transform = matrix as? CGAffineTransform {
            return abs(transform.c) > 0.001
        }

        return false
    }

    var visuallyItalicized: UIFont {
        let italicFont = italicized
        if italicFont.isItalic || italicFont.hasSyntheticItalic {
            return italicFont
        }

        // Fallback: use system italic font
        return UIFont.italicSystemFont(ofSize: pointSize).syntheticItalicized
    }

    var visuallyUnitalicized: UIFont {
        return unitalicized.syntheticUnitalicized
    }
    
    var unitalicized: UIFont {
        var traits = fontDescriptor.symbolicTraits
        traits.remove(.traitItalic)
        if let descriptor = fontDescriptor.withSymbolicTraits(traits) {
            return UIFont(descriptor: descriptor, size: pointSize)
        }
        // Fallback: use system regular font
        return UIFont.systemFont(ofSize: pointSize)
    }
}
