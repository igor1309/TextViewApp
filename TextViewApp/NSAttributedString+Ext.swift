//
//  NSAttributedString+Ext.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 05.01.2021.
//

import UIKit

extension NSAttributedString {
    func highlightText(pattern: String) -> NSAttributedString {
        // swiftlint:disable:next force_cast
        let attributedTextCopy = self.mutableCopy() as! NSMutableAttributedString

        let attributedTextRange = NSRange(location: 0, length: attributedTextCopy.length)
        attributedTextCopy.removeAttribute(NSAttributedString.Key.backgroundColor, range: attributedTextRange)

        let range = NSRange(attributedTextCopy.string.startIndex..., in: attributedTextCopy.string)
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let matches = regex.matches(in: attributedTextCopy.string, options: [], range: range)
            let colors = [
                UIColor.systemYellow.withAlphaComponent(0.2),
                UIColor.systemTeal.withAlphaComponent(0.2)
            ]
            for index in 0..<matches.count {
                let matchRange = matches[index].range
                attributedTextCopy.addAttribute(
                    NSAttributedString.Key.backgroundColor,
                    value: colors[index % colors.count],
                    range: matchRange
                )
            }
            // swiftlint:disable:next force_cast
            return attributedTextCopy.copy() as! NSAttributedString
        } else {
            return self
        }
    }
}
