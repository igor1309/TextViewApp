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

    func listMatches(for pattern: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return [] }

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

    /// Get first match from string and cut match from string to give tail
    /// Handle head (match) and tail in closure
    /// - Parameters:
    ///   - patterns: array of regular expression patterns to apple to string (order matters!)
    ///   - completion: closure to work with non empty head and tail
    func getHeadAndTail(patterns: [String], completion: (_ head: String?, _ tail: String?) -> Void) {
    var head: String?
    var tail: String?

    for pattern in patterns {
    guard let regex = try? NSRegularExpression(pattern: pattern, options: []),
    let headString = self.listMatches(for: regex).first,
    let tailString = self.replaceMatches(for: regex, withString: "") else { continue }

    head = headString.trimmingCharacters(in: .whitespaces)
    tail = tailString.trimmingCharacters(in: .whitespaces)
    break
    }

    completion(head, tail)
    }

    func rubliIKopeikiToDouble() -> Double? {
    guard let spacedDelete = self.replaceMatches(for: " *", withString: ""),
    let dotDelete = spacedDelete.replaceMatches(for: #"\."#, withString: ""),
    let kopekDelete = dotDelete.replaceMatches(for: "к", withString: "") else { return nil }

    let components = kopekDelete.split(separator: "р")
    let integerPart = components.first ?? ""
    let integer = Double(integerPart) ?? 0

    let decimal: Double
    if components.count == 2 {
    let decimalPart = components[1]
    decimal = (Double(decimalPart) ?? 0) / 100
    } else {
    decimal = 0
    }

    return integer + decimal
    }

}
