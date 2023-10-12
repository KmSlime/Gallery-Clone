//
//  StringExtension.swift
//  GlueTeam
//
//  Created by LIEMNH on 11/10/2023.
//

import UIKit

//MARK: Validate String
extension String {
    func isUrlLink() -> Bool {
        guard self.starts(with: "https") || self.starts(with: "http") else { return false }
        let urlPattern = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let result = self.matches(pattern: urlPattern)
        return result
    }

    private func matches(pattern: String) -> Bool { //regex
        let regex = try? NSRegularExpression(
            pattern: pattern,
            options: [.caseInsensitive])
        return regex?.firstMatch(
            in: self,
            options: [],
            range: NSRange(location: 0, length: utf16.count)) != nil
    }

    
    var isEmail: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) != nil
        } catch {
            return false
        }
    }
    
    var isAlphanumeric: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
    
    var isNumeric: Bool {
        return !isEmpty && range(of: "[^0-9]", options: .regularExpression) == nil
    }
    
    func isEmptyAfterTrimmedText(characterSet: CharacterSet = .whitespacesAndNewlines) -> Bool {
        return self.trimmingCharacters(in: characterSet).isEmpty
    }
    
    func isNotContainSpecialCharacter() -> Bool {
        range(of: ".*[^A-Za-z0-9].*", options: .regularExpression) != nil
    }
    
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
    }
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
    
    var isSimpleEmoji: Bool {
        guard let firstScalar = unicodeScalars.first else { return false }
        return firstScalar.properties.isEmoji && firstScalar.value > 0x238C
    }
    
    var containsEmoji: Bool { contains { $0.isEmoji } }
    
    var containsOnlyEmoji: Bool { !isEmpty && !contains { !$0.isEmoji } }
    
    var emojiString: String { emojis.map { String($0) }.reduce("", +) }
    
    var emojis: [Character] { filter { $0.isEmoji } }
    
    var emojiScalars: [UnicodeScalar] { filter { $0.isEmoji }.flatMap { $0.unicodeScalars } }
}

//MARK: Calculator String
extension String {
    public func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.uppercased().boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font : font], context: nil)
        return ceil(boundingBox.height)
    }
    
    public func width(withConstrainedHeight height: CGFloat, font: UIFont, minimumTextWrapWidth:CGFloat) -> CGFloat {
        var textWidth: CGFloat = minimumTextWrapWidth
        let incrementWidth: CGFloat = minimumTextWrapWidth * 0.1
        var textHeight: CGFloat = self.height(withConstrainedWidth: textWidth, font: font)
        //Increase width by 10% of minimumTextWrapWidth until minimum width found that makes the text fit within the specified height
        while textHeight > height {
            textWidth += incrementWidth
            textHeight = self.height(withConstrainedWidth: textWidth, font: font)
        }
        return ceil(textWidth)
    }
}

//MARK: String Format
extension String {
    func replace(string: String, replacement:String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(string: " ", replacement: "")
    }
    
    func removeCharactersWhitespacesAndNewlines() -> String {
        return String(self.filter { !" \n\t\r".contains($0) })
    }
    
    func addHttpPrefix() -> String {
        return self.lowercased().range(of: "http") != nil ? self : String(format: "http://%@", self)
    }

}

//MARK: String Utilities
extension String {
    var length: Int {
        return self.count
    }
}

//MARK: String convert
extension String {
    func toInt() -> Int? {
        return Int(self)
    }
    
    func toUInt() -> UInt? {
        return UInt(self)
    }
    
    func toDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" 
        /* find out and place date format from http://userguide.icu-project.org/formatparse/datetime */
        return dateFormatter.date(from: self)
    }

    func toDate(dateformat: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateformat
        return dateFormatter.date(from: self)
    }
    
    internal func convertBase64ToImage() -> UIImage? {
        guard let imageData = Data(base64Encoded: self,
                                   options: Data.Base64DecodingOptions.ignoreUnknownCharacters) else { return nil }
        return UIImage(data: imageData)
    }
    
    internal func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    internal mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

//MARK: AttributeString
extension String {
    func detectUrl(blackOrWhite: Bool) -> NSMutableAttributedString {
        let attributeLabel = NSMutableAttributedString(string: self, attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)
        ])
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
        
        for match in matches {
            guard let range = Range(match.range, in: self) else { continue }
            let urlString = String(self[range])
            if urlString.hasPrefix("https://") || urlString.hasPrefix("http://") {
                attributeLabel.addAttribute(.link, value: URL(string: String(urlString))!, range: match.range)
            } else {
                let correctedURL = "http://\(urlString)"
                attributeLabel.addAttribute(.link, value: URL(string: String(correctedURL))!, range: match.range)
            }
            attributeLabel.addAttribute(.underlineStyle, value: NSUnderlineStyle.thick.rawValue, range: match.range)
            attributeLabel.addAttribute(.underlineColor, value: blackOrWhite ? UIColor.black : UIColor.white, range: match.range)
        }
        return attributeLabel
    }
}

extension NSMutableAttributedString {
    var fontSize: CGFloat { return 14 }
    var boldFont: UIFont { return UIFont(name: "AvenirNext-Bold", size: fontSize) ?? UIFont.boldSystemFont(ofSize: fontSize) }
    var normalFont: UIFont { return UIFont(name: "AvenirNext-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize) }

    func bold(_ value: String) -> NSMutableAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: boldFont
        ]

        self.append(NSAttributedString(string: value, attributes: attributes))
        return self
    }

    func normal(_ value: String) -> NSMutableAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: normalFont
        ]

        self.append(NSAttributedString(string: value, attributes: attributes))
        return self
    }

    /* Other styling methods */
    func orangeHighlight(_ value: String) -> NSMutableAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: normalFont,
            .foregroundColor: UIColor.white,
            .backgroundColor: UIColor.orange
        ]

        self.append(NSAttributedString(string: value, attributes: attributes))
        return self
    }

    func blackHighlight(_ value: String) -> NSMutableAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: normalFont,
            .foregroundColor: UIColor.white,
            .backgroundColor: UIColor.black
        ]

        self.append(NSAttributedString(string: value, attributes: attributes))
        return self
    }

    func underlined(_ value: String) -> NSMutableAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: normalFont,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]

        self.append(NSAttributedString(string: value, attributes: attributes))
        return self
    }
    
    func addText(text: String) -> NSMutableAttributedString {
        addAttributes(for: text, attribute: nil)
    }
    
    func addLineBreak(times: UInt = 1) -> NSMutableAttributedString {
        var numberLine = ""
        (0..<times).forEach({ (_) in
            numberLine.append("\n")
        })
        return addAttributes(for: numberLine, attribute: nil)
    }
    
    func addFont(text: String, font: UIFont) -> NSMutableAttributedString {
        addAttributes(for: text, attribute: [NSAttributedString.Key.font: font])
    }
    
    func textColor(text: String, color: UIColor) -> NSMutableAttributedString {
        addAttributes(for: text, attribute: [NSAttributedString.Key.foregroundColor : color])
    }
    
    func addAttributes(for text: String, attribute: [NSAttributedString.Key : Any]?) -> NSMutableAttributedString {
        self.append(NSAttributedString(string: text, attributes: attribute))
        return self
    }
    
    func addAtributes(for text: String, attribute: [NSAttributedString.Key : Any]?) -> NSMutableAttributedString {
        self.append(NSAttributedString(string: text, attributes: attribute))
        return self
    }
    
    func insertAttribute(for text: String, attribute: [NSAttributedString.Key : Any]?, at index: Int) -> NSMutableAttributedString {
        self.insert(NSAttributedString(string: text, attributes: attribute), at: index)
        return self
    }
}


extension Character {
    /// A simple emoji is one scalar and presented to the user as an Emoji
    var isSimpleEmoji: Bool {
        guard let firstScalar = unicodeScalars.first else { return false }
        return firstScalar.properties.isEmoji && firstScalar.value > 0x238C
    }
    
    /// Checks if the scalars will be merged into an emoji
    var isCombinedIntoEmoji: Bool { unicodeScalars.count > 1 && unicodeScalars.first?.properties.isEmoji ?? false }
    
    var isEmoji: Bool { isSimpleEmoji || isCombinedIntoEmoji }
}
