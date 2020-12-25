//
//  ParsedReportGroupViewModel.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 25.12.2020.
//

import SwiftUI

final class ParsedReportGroupViewModel: ObservableObject {

    @Published var groupString: String
    @Published var groupHeaderString: String = ""
    @Published var groupHeader: Token = .empty
    @Published var listWithNumbers: [String]
    @Published var items: [Token] = []
    @Published var groupFooterString: String = ""
    @Published var groupFooter: Token = .empty

    init(groupString: String) {
        self.groupString = groupString

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
    private let rublesIKopeksPattern = #"\d+(\.\d+)*р( *\d+к)?"#
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

        guard let tail = groupFooterString.replaceFirstMatch(for: groupHeaderFooterTitlePattern,
                                                             withString: "") else {
            return Token.footer(cleanTitle, nil)
        }

        if let numberString = tail.firstMatch(for: rublesIKopeksPattern),
           let rubliIKopeiki = numberString.rubliIKopeikiToDouble() {
            return Token.footer(cleanTitle, rubliIKopeiki)
        }

        if let numberString = tail.firstMatch(for: itemNumberPattern),
           let double = Double(numberString.replacingOccurrences(of: ".", with: "")) {
            return Token.footer(cleanTitle, double)
        }

        return Token.footer(cleanTitle, nil)
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

        if let numberString = remains.firstMatch(for: rublesIKopeksPattern),
           let rubliIKopeiki = numberString.rubliIKopeikiToDouble() {
            number = rubliIKopeiki
            remains = remains.replaceFirstMatch(for: rublesIKopeksPattern, withString: "") ?? ""
        } else if let numberString = remains.firstMatch(for: itemNumberPattern),
                  let double = Double(numberString.replacingOccurrences(of: ".", with: "")) {
            number = double
            remains = remains.replaceFirstMatch(for: itemNumberPattern, withString: "") ?? ""
        }

        // special case when number after item title is not a number for item
        // for example in 1. Приход товара по накладным     946.056р (оплаты фактические: 475.228р 52к -переводы; 157.455р 85к-корпоративная карта; 0-наличные из кассы; Итого-632.684р 37к)
        let itemWithItogoPattern = #"(.*)?Итого"#
        if let afterItogo = remains.replaceFirstMatch(for: itemWithItogoPattern,
                                                      withString: "") {

            if let numberString = afterItogo.firstMatch(for: rublesIKopeksPattern),
               let rubliIKopeiki = numberString.rubliIKopeikiToDouble() {
                number = rubliIKopeiki
            } else if let numberString = afterItogo.firstMatch(for: itemNumberPattern),
                      let double = Double(numberString.replacingOccurrences(of: ".", with: "")) {
                number = double
            }

        }

        let comment: String? = remains.isEmpty ? nil : remains

        return Token.item(title, number, comment)
    }
}
