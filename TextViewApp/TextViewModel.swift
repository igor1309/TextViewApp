//
//  TextViewModel.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 23.12.2020.
//

import SwiftUI
import Combine

final class TextViewModel: ObservableObject {
    @Published var attributedText = NSAttributedString()
    @Published var textStyle = UIFont.TextStyle.subheadline
    @Published var showingReportStructure: Bool?
    @Published var reportContent: ReportContent?

    struct ReportContent {
        var header: String
        var groups: [String]
        var footer: String
    }

    @Published var errorMessage = ""
    var hasError: Bool { !errorMessage.isEmpty }

    init() {
        // create subscription to update highlight if text was edited
        $attributedText
            .map { $0.string }
            .delay(for: 0.3, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                if let self = self {
                    self.highlightText(pattern: String.groupPattern)
                }
            }
            .store(in: &cancellableSet)
    }

    private var cancellableSet = Set<AnyCancellable>()

    deinit {
        for cancell in cancellableSet {
            cancell.cancel()
        }
    }

    func splitReportContent() {
        // using regex extract array of text for groups
        // replace extracted text with special delimiter
        // use delimiter to seperate header from footer

        let groups = attributedText.string.listMatches(for: String.groupPattern)

        let delimiter = "#####"
        var header = ""
        var footer = ""

        if let copy = attributedText.string.replaceMatches(for: String.groupPattern, withString: delimiter) {
            let components = copy
                .components(separatedBy: delimiter)
                .compactMap { $0 == "\n" ? nil : $0 }
                .compactMap { $0.isEmpty ? nil : $0 }
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

            header = components.first ?? "error getting header"
            footer = components.last ?? "error getting footer"

            switch components.count {
                case 2:      errorMessage = ""
                case 3...20: errorMessage = "Error: some group(s) not parsed"
                default:     errorMessage = "Error: unknown parsing error"
            }
        }

        reportContent = ReportContent(header: header, groups: groups, footer: footer)
        showingReportStructure = true
    }

    func highlightText(pattern: String) {
        // swiftlint:disable:next force_cast
        let attributedTextCopy = attributedText.mutableCopy() as! NSMutableAttributedString
        let attributedTextRange = NSRange(location: 0, length: attributedTextCopy.length)
        attributedTextCopy.removeAttribute(NSAttributedString.Key.backgroundColor, range: attributedTextRange)

        let range = NSRange(attributedTextCopy.string.startIndex..., in: attributedTextCopy.string)
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let matches = regex.matches(in: attributedTextCopy.string, options: [], range: range)
            for match in matches {
                let matchRange = match.range
                attributedTextCopy.addAttribute(
                    NSAttributedString.Key.backgroundColor,
                    value: UIColor.yellow.withAlphaComponent(0.2),
                    range: matchRange
                )
            }
            // swiftlint:disable:next force_cast
            self.attributedText = attributedTextCopy.copy() as! NSAttributedString
        }
    }

    func pasteClipboard() {
        Ory.withHapticsAndAnimation {
            guard let content = UIPasteboard.general.string else { return }

            // clean whitespaces and empty lines
            let cleanContent = content.clearWhitespacesAndNewlines()

            self.attributedText = NSAttributedString(string: cleanContent)
            self.highlightText(pattern: String.groupPattern)
        }
    }
}
