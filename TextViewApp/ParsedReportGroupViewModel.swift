//
//  ParsedReportGroupViewModel.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 25.12.2020.
//

import SwiftUI

final class ParsedReportGroupViewModel: ObservableObject {

    @Published var group: String
    @Published var groupHeaderString: String = ""
    @Published var groupHeader: Token = .empty
    @Published var listWithNumbers: [String]
    @Published var items: [Token] = []
    @Published var groupFooterString: String = ""
    @Published var groupFooter: Token = .empty

    init(groupString: String) {
        self.group = groupString

        self.listWithNumbers = groupString.listMatches(for: self.itemFullLineWithDigitsPattern)
        self.items = listWithNumbers.compactMap(self.transformLineToItem)

        let components = groupString.components(separatedBy: "\n")
        self.groupHeaderString = components.first ?? "header error"
        self.groupFooterString = components.last ?? "footer error"

        self.groupHeader = getGroupHeader(from: groupHeaderString) ?? .empty
        self.groupFooter = getGroupFooter(from: groupFooterString) ?? .empty
    }

    enum Token: Hashable {
        case item(String, Double, String?)
        case header(String, Double?, Double?)
        case footer(String, Double?)
        case empty
    }

    var itemsTotal: Double {
        items
            .compactMap { token -> Double? in
                if case let .item(_, number, _) = token {
                    return number
                } else {
                    return nil
                }
            }
            .reduce(0, +)
    }

    var isTotalsMatch: Bool {
        if case let .footer(_, number) = groupFooter {
            return itemsTotal == number
        }
        return false
    }

    private let itemFullLineWithDigitsPattern = #"(?m)^[1-9][0-9]?\.[^\d\n]+\d+.*"#
    private let itemTitleWithPercentagePattern = #"^[1-9]\d?\.[\D]*\d+(\.\d+)?%[\D]*"#
    private let itemTitleWithParenthesesPattern = #"^[1-9][0-9]?\.[^\d\n]+\([^(]*\)[^\d\n]*"#
    private let itemTitlePattern = #"^[1-9][0-9]?\.[^\d\n]+"#
    private let rublesIKopeksPattern = #"^\d+(\.\d+)*р( *\d+к)?"#
    private let itemNumberPattern = #"\d+(\.\d{3})*"#
    private let groupHeaderFooterTitlePattern = #"^[А-Яа-я][А-Яа-я ]+:"#
    private let matchingPercentagePattern = #"\d+(\.\d+)*%"#

    private func getGroupHeader(from groupHeaderString: String) -> Token? {
        guard let title = groupHeaderString.firstMatch(for: groupHeaderFooterTitlePattern) else { return nil}
        let cleanTitle = title.last == ":" ? String(title.dropLast()) : title

        let firstTail = groupHeaderString.replaceFirstMatch(for: groupHeaderFooterTitlePattern,
                                                            withString: "")
        guard let firstPercentageString = firstTail?.firstMatch(for: matchingPercentagePattern),
              let firstPercentage = firstPercentageString.percentageStringToDouble() else {
            return Token.header(cleanTitle, nil, nil)
        }

        let secondtail = firstTail?.replaceFirstMatch(for: matchingPercentagePattern,
                                                      withString: "")
        guard let secondPercentageString = secondtail?.firstMatch(for: matchingPercentagePattern),
              let secondPercentage = secondPercentageString.percentageStringToDouble() else {
            return Token.header(cleanTitle, firstPercentage, nil)
        }

        return Token.header(cleanTitle, firstPercentage, secondPercentage)
    }

    private func getGroupFooter(from groupFooterString: String) -> Token? {
        guard let title = groupFooterString.firstMatch(for: groupHeaderFooterTitlePattern) else { return nil}
        let cleanTitle = title.last == ":" ? String(title.dropLast()) : title

        var tail = groupFooterString.replaceFirstMatch(for: groupHeaderFooterTitlePattern, withString: "")
        var total: Double?

        if let localTail = tail {
            localTail.getFirstMatchAndRemains(patterns: [rublesIKopeksPattern]) { (numberString, tailString) in
                guard let numberString = numberString,
                      // MARK: - ОТРЕЗАЮТСЯ КОПЕЙКИ!!!
                      let rubliIKopeiki = numberString.rubliIKopeikiToDouble(),
                      let tailString = tailString
                else {
                    guard let numberString = localTail.firstMatch(for: itemNumberPattern) else { return }

                    let cleanNumberString = numberString
                        .replacingOccurrences(of: ".", with: "")
                        .trimmingCharacters(in: .whitespaces)
                    guard let double = Double(cleanNumberString) else { return }
                    total = double

                    if let finalTail = localTail
                        .replaceMatches(for: itemNumberPattern, withString: "")?
                        .trimmingCharacters(in: .whitespaces) {
                        tail = finalTail
                    }

                    return
                }
                total = rubliIKopeiki
                tail = tailString
            }
        }

/*
        // MARK: - rubliIKopeiki!!!!
        // MARK: - SAME CODE USED IN transformLineToItem MAKE FUNC @ Strinf extension
        if let numberString = tail?.firstMatch(for: itemNumberPattern) {
            let cleanNumberString = numberString.replacingOccurrences(of: ".", with: "")
            let trimmedNumberString = cleanNumberString.trimmingCharacters(in: .whitespaces)
            total = Double(trimmedNumberString)
        } else {
            total = nil
        }
*/
        //  FIXME: FINISH THIS: 0????
        return Token.footer(cleanTitle, total)
    }

    private func transformLineToItem(line: String) -> Token? {
        var title: String = ""
        var remains: String = ""
        var number: Double = 0

        let itemTitlePatterns = [itemTitleWithPercentagePattern, itemTitleWithParenthesesPattern, itemTitlePattern]
        line.getFirstMatchAndRemains(patterns: itemTitlePatterns) { (match, remainsString) in
            guard let headString = match,
                  let tailString = remainsString else { return }
            title = headString
            remains = tailString
        }

        guard !title.isEmpty && !remains.isEmpty else { return nil }

        remains.getFirstMatchAndRemains(patterns: [rublesIKopeksPattern]) { (match, remainsString) in
            guard let numberString = match,
                  let rubliIKopeiki = numberString.rubliIKopeikiToDouble(),
                  let tailString = remainsString
            else {
                // MARK: - NOT 'RETURN' HERE!! TRY TO PARSE ANOTHER NUMBER PATTERN
                guard let numberString = remains.firstMatch(for: itemNumberPattern) else { return }
                let cleanNumberString = numberString.replacingOccurrences(of: ".", with: "")
                guard let double = Double(cleanNumberString) else { return }
                number = double

                if let finalTail = remains
                    .replaceMatches(for: itemNumberPattern, withString: "")?
                    .trimmingCharacters(in: .whitespaces) {
                    remains = finalTail
                }

                return
            }
            number = rubliIKopeiki
            remains = tailString
        }

        let comment: String? = remains.isEmpty ? nil : remains

        return Token.item(title, number, comment)
    }
}
