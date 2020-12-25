//
//  String+Ext.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 24.12.2020.
//

import Foundation

extension String {

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

    func replaceMatches(for pattern: String, withString replacementString: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return self
        }
        return replaceMatches(for: regex, withString: replacementString)
    }

    func replaceMatches(for regex: NSRegularExpression, withString replacementString: String) -> String? {
        let range = NSRange(self.startIndex..., in: self)
        return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replacementString)
    }

    func listMatches(for pattern: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return [] }
        return listMatches(for: regex)
    }

    func listMatches(for regex: NSRegularExpression) -> [String] {
        let range = NSRange(self.startIndex..., in: self)
        let matches = regex.matches(in: self, options: [], range: range)

        return matches.map {
            let range = Range($0.range, in: self)!
            return String(self[range])
        }
    }

    func firstMatch(for pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return nil }
        return firstMatch(for: regex)
    }

    func firstMatch(for regex: NSRegularExpression) -> String? {
        let range = NSRange(self.startIndex..., in: self)
        let match = regex.firstMatch(in: self, options: [], range: range)

        if let match = match {
            let range = Range(match.range, in: self)!
            return String(self[range])
        } else {
            return nil
        }
    }

    func replaceFirstMatch(for pattern: String, withString replacementString: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return nil }
        return replaceFirstMatch(for: regex, withString: replacementString)
    }

    func replaceFirstMatch(for regex: NSRegularExpression, withString replacementString: String) -> String? {
        let range = NSRange(self.startIndex..., in: self)
        let match = regex.firstMatch(in: self, options: [], range: range)

        if let match = match {
            let range = match.range
            return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replacementString)

        } else {
            return nil
        }
    }

    /// Get first match from string and cut match from string to give remains
    /// Handle head (match) and tail in closure
    /// - Parameters:
    ///   - patterns: array of regular expression patterns to apple to string (order matters!)
    ///   - completion: closure to work with non empty head and tail
    func getFirstMatchAndRemains(patterns: [String], completion: (String?, String?) -> Void) {
        var match: String?
        var remains: String?

        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: []),
                  let headString = self.firstMatch(for: regex),
                  let tailString = self.replaceFirstMatch(for: regex, withString: "") else { continue }

            match = headString.trimmingCharacters(in: .whitespaces)
            remains = tailString.trimmingCharacters(in: .whitespaces)
            break
        }

        completion(match, remains)
    }

}
