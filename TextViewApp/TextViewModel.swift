//
//  TextViewModel.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 23.12.2020.
//

import SwiftUI

final class TextViewModel: ObservableObject {
    @Published var text = NSMutableAttributedString()
    @Published var textStyle = UIFont.TextStyle.subheadline
    @Published var highlight = false

    func pasteClipboard() {
        Ory.withHapticsAndAnimation {
            guard let content = UIPasteboard.general.string else { return }
            self.text = NSMutableAttributedString(string: content)
        }
    }


    func toggleHighlight() {
        highlight = true
        let groupPattern = #"(?m)^[А-Яа-я][^\n]*\n(^\d\d?\..*\n+)+ИТОГ:.*"#
        let regex = try! NSRegularExpression(pattern: groupPattern, options: [])
        highlightText(regex: regex)
    }

    func highlightText(regex: NSRegularExpression/*_ searchText: String, inTextView textView: UITextView*/) {
        let attributedText = text.mutableCopy() as! NSMutableAttributedString
        let attributedTextRange = NSMakeRange(5, attributedText.length)
        //attributedText.removeAttribute(NSAttributedString.Key.backgroundColor, range: attributedTextRange)

//        if let searchOptions = self.searchOptions, let regex = try? NSRegularExpression(options: searchOptions) {
        let range = NSRange(text.startIndex..., in: text.string)
            if let matches = regex?.matches(in: textView.text, options: [], range: range) {
                for match in matches {
                    let matchRange = match.range
                    attributedText.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.yellow, range: attributedTextRange)
                }
            }
//        }

        self.text = (attributedText.copy() as! NSMutableAttributedString)
    }
}
