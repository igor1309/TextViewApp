//
//  String+Ext.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 24.12.2020.
//

import Foundation

extension String {

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

    func percentageStringToDouble() -> Double? {
        guard self.last == "%",
              let percentage = Double(self.dropLast()) else { return nil }
        return percentage / 100
    }

    func extractNumber() -> Double? {
        let itemNumberPattern = #"\d+(\.\d{3})*"#
        if let numberString = self.firstMatch(for: itemNumberPattern),
           let double = Double(numberString.replacingOccurrences(of: ".", with: "")) {
            return double
        }

        return nil
    }

    func parseReportHeader() -> [ParsedReportHeaderViewModel.Token] {

        let headerItemPatterns = #"[А-Яа-я ]+:[А-Яа-я ]*\d+(\.\d{3})*"#
        let headerItemTitlePatterns = #"[А-Яа-я ]+:"#
        let headerItemCompanyPattern = #"Название объекта: (.*)"#
        let headerItemMonthPattern = #"(.*)?\d{4}"#

        let company: ParsedReportHeaderViewModel.Token? = {
            guard let companyString = self.firstMatch(for: headerItemCompanyPattern),
                  let company = companyString
                    .replaceMatches(for: #"Название объекта:"#, withString: "")?
                    .trimmingCharacters(in: .whitespaces)
            else { return nil }

            return .company(company)
        }()

        let headerItems: [ParsedReportHeaderViewModel.Token] = self
            .listMatches(for: headerItemPatterns)
            .compactMap {
                guard let title = $0.firstMatch(for: headerItemTitlePatterns),
                      let tail = $0.replaceMatches(for: headerItemTitlePatterns,
                                                   withString: "")
                else { return nil }

                let cleanTitle = (title.last == ":" ? String(title.dropLast()) : title).trimmingCharacters(in: .whitespaces)

                if let month = tail.firstMatch(for: headerItemMonthPattern) {
                    return .month(month.trimmingCharacters(in: .whitespaces))
                }

                guard let number = tail.extractNumber() else { return nil }
                return .headerItem(cleanTitle, number)
            }

        if let company = company {
            return [company] + headerItems
        } else {
            return headerItems
        }
    }
}
