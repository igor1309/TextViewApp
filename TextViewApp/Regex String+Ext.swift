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
        return clean
    }

    /// Returns a new string containing matching regular expression replaced with provided string.
    /// - Parameters:
    ///   - pattern: string to create regular expression used for match
    ///   - replacementString: replacement string
    /// - Returns: string with replaced match or original string if no matches for match string were found
    func replaceMatches(for pattern: String, withString replacementString: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return self
        }
        return replaceMatches(for: regex, withString: replacementString)
    }

    /// Returns a new string containing matching regular expression replaced with provided string.
    /// - Parameters:
    ///   - regex: regular expression used for match
    ///   - replacementString: replacement string
    /// - Returns: string with replaced match or original string if no matches for match string were found
    func replaceMatches(for regex: NSRegularExpression, withString replacementString: String) -> String {
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

    /// Returns matching string or nil of no match
    /// - Parameter pattern: pattern to create NSRegularExpression
    /// - Returns: nil if no match
    func firstMatch(for pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return nil }
        return firstMatch(for: regex)
    }

    /// Returns matching string or nil of no match
    /// - Parameter regex: NSRegularExpression to match
    /// - Returns: nil if no match
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

    /// Returns a new string containing first matching regular expression replaced with provided string.
    /// - Parameters:
    ///   - pattern: string to create regular expression used for match
    ///   - replacementString: replacement string
    /// - Returns: string with replaced match or original string if no matches for match string were found
    func replaceFirstMatch(for pattern: String, withString replacementString: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return self }
        return replaceFirstMatch(for: regex, withString: replacementString)
    }

    /// Returns a new string containing first matching regular expression replaced with provided string.
    /// - Parameters:
    ///   - regex: search string as NSRegularExpression
    ///   - replacementString: replacement string
    /// - Returns: string with replaced match or original string if no matches for match string were found
    func replaceFirstMatch(for regex: NSRegularExpression, withString replacementString: String) -> String {
        let range = NSRange(self.startIndex..., in: self)
        let match = regex.firstMatch(in: self, options: [], range: range)

        if let match = match {
            let range = match.range
            return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replacementString)

        } else {
            return self
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
                  let headString = self.firstMatch(for: regex) else { continue }

            let tailString = self.replaceFirstMatch(for: regex, withString: "")
            match = headString.trimmingCharacters(in: .whitespaces)
            remains = tailString.trimmingCharacters(in: .whitespaces)
            break
        }

        completion(match, remains)
    }

}
