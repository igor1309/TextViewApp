//
//  String+Ext.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 24.12.2020.
//

import Foundation

extension String {
    func replaceMatches(for regex: NSRegularExpression, withString replacementString: String) -> String? {
        let range = NSRange(self.startIndex..., in: self)
        return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replacementString)
    }

    func replaceMatches(for pattern: String, withString replacementString: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return self
        }

        let range = NSRange(self.startIndex..., in: self)
        return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replacementString)
    }

    func listMatches(for regex: NSRegularExpression) -> [String] {
        let range = NSRange(self.startIndex..., in: self)
        let matches = regex.matches(in: self, options: [], range: range)

        return matches.map {
            let range = Range($0.range, in: self)!
            return String(self[range])
        }
    }


    /// clean whitespaces and empty lines
    func clearWhitespacesAndNewlines() -> String {
        let cleanContent = self
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: "\n")

        let clean = cleanContent.replaceMatches(for: "\n\n", withString: "\n")
        return clean ?? cleanContent
    }

}

