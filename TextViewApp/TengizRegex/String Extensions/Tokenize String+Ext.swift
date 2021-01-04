//
//  Tokenize String+Ext.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 25.12.2020.
//

import Foundation

public extension String {

    #warning("FIXME: FINISH THIS: move whitespace to lookup so it's not captured?")
    // MARK: - Regular Expression Patterns

    ///  (?m) - MULTILINE mode on
    static let groupPattern = #"(?m)^[А-Яа-я][^\n]*\n(^\d\d?\..*\n+)+ИТОГ:.*"#
    /// matching lines starting like "3. Электричество" or "12.Интернет"
    static let itemTitlePattern = #"^[1-9]\d?\.[^\d\n]+"#
    static let itemFullLineWithDigitsPattern = #"(?m)"# + itemTitlePattern + #"\d+.*"#
    /// matching lines like "4.Банковская комиссия 1.6% за эквайринг    " (mind whitespace)
    static let itemTitleWithPercentagePattern =  itemTitlePattern + #"\d+(\.\d+)?%[\D]*"#
    //static let itemTitleWithPercentagePattern =  #"^[1-9]\d?\.[\D]*\d+(\.\d+)?%[\D]*"#
    /// matching lines like "22. Хэдхантер (подбор пероснала)    " (mind whitespace)
    static let itemTitleWithParenthesesPattern = itemTitlePattern + #"\([^(]*\)[^\d\n]*"#
    static let itemWithPlusPattern = itemTitlePattern + numbersWithPlusPattern
    /// pattern to match "200.000 (за август) +400.000 (за сентябрь)" or "7.701+4.500"
    static let numbersWithPlusPattern = itemNumberPattern + #"(?:\s*\([^\)]+\)\s*)?\+"# + itemNumberPattern + #"(?:\s*\([^\)]+\)\s*)?"#
    static let groupHeaderFooterTitlePattern = #"^[А-Яа-я][А-Яа-я ]+(?=:)"#
    static let matchingPercentagePattern = #"\d+(\.\d+)*%"#

    // MARK: - Tokenize

    func tokenizeReportHeader() -> [Tokens.HeaderToken] {

        let headerItemCompanyPattern = #"(?<=Название объекта:\s).*"#
        let headerItemMonthPattern = #"[А-Яа-я]+\d{4}"#
        let headerItemPatterns = #"[А-Яа-я ]+:[А-Яа-я ]*\d+(\.\d{3})*"#
        let headerItemTitlePatterns = #"[А-Яа-я ]+:"#

        let company: Tokens.HeaderToken? = {
            guard let companyString = self.firstMatch(for: headerItemCompanyPattern) else { return nil }
            return .company(companyString)
        }()

        let month: Tokens.HeaderToken? = {
            guard let monthString = self.firstMatch(for: headerItemMonthPattern) else { return nil }
            return .month(monthString.trimmingCharacters(in: .whitespaces))
        }()

        let tail: String = self.replaceMatches(for: headerItemMonthPattern, withString: "")

        let headerItems: [Tokens.HeaderToken] = tail
            .listMatches(for: headerItemPatterns)
            .compactMap {
                guard let title = $0.firstMatch(for: headerItemTitlePatterns) else { return nil }
                let cleanTitle = (title.last == ":" ? String(title.dropLast()) : title)
                    .trimmingCharacters(in: .whitespaces)

                let tail = $0.replaceMatches(for: headerItemTitlePatterns,
                                             withString: "")
                guard let number = tail.extractNumber() else { return nil }
                return .headerItem(cleanTitle, number)
            }

        return [company, month].compactMap { $0 } + headerItems
    }

    func transformLineToItem() -> Tokens.GroupToken? {
        var title: String = ""
        var remains: String = ""
        var number: Double?

        /// tokenize lines like "1. Аренда торгового помещения     200.000 (за август) +400.000 (за сентябрь)        " or "12.Интернет    7.701+4.500"
        if let _ = self.firstMatch(for: String.itemWithPlusPattern),
           let titleString = self.firstMatch(for: String.itemTitlePattern),
           let remains = self.firstMatch(for: String.numbersWithPlusPattern) {
            let sum = remains
                .listMatches(for: String.itemNumberPattern)
                .compactMap { $0.getNumberNoRemains() }
                .reduce(0, +)

            return .item(titleString.clearWhitespacesAndNewlines(),
                         sum,
                         remains.clearWhitespacesAndNewlines())
        }

        let itemTitlePatterns = [String.itemTitleWithPercentagePattern,
                                 String.itemTitleWithParenthesesPattern,
                                 String.itemTitlePattern]

        self.getFirstMatchAndRemains(patterns: itemTitlePatterns) { (match, remainsString) in
            guard let headString = match,
                  let tailString = remainsString else { return }
            title = headString
            remains = tailString
        }

        guard !title.isEmpty && !remains.isEmpty else { return nil }

        (number, remains) = remains.getNumberAndRemains()

        // special case when number after item title is not a number for item
        // for example in 1. Приход товара по накладным     946.056р (оплаты фактические: 475.228р 52к -переводы; 157.455р 85к-корпоративная карта; 0-наличные из кассы; Итого-632.684р 37к)
        let itemWithItogoPattern = #"(.*)?Итого"#
        if let afterItogo = remains.replaceFirstMatch(for: itemWithItogoPattern, withString: "") {
            number = afterItogo.getNumberNoRemains()
        }

        let dirtyComment = remains.clearWhitespacesAndNewlines()
        let comment: String? = dirtyComment.isEmpty ? nil : dirtyComment

        return .item(title, number ?? 0, comment)
    }
    
    func getGroupHeader() -> Tokens.GroupToken? {
        guard let title = self.firstMatch(for: String.groupHeaderFooterTitlePattern) else { return nil }

        guard let firstTail = self.replaceFirstMatch(for: String.groupHeaderFooterTitlePattern, withString: ""),
              let firstPercentageString = firstTail.firstMatch(for: String.matchingPercentagePattern),
              let firstPercentage = firstPercentageString.percentageStringToDouble() else {
            return .header(title, nil, nil)
        }

        let secondtail = firstTail.replaceFirstMatch(for: String.matchingPercentagePattern,
                                                      withString: "")
        guard let secondPercentageString = secondtail?.firstMatch(for: String.matchingPercentagePattern),
              let secondPercentage = secondPercentageString.percentageStringToDouble() else {
            return .header(title, firstPercentage, nil)
        }

        return .header(title, firstPercentage, secondPercentage)
    }

    func getGroupFooter() -> Tokens.GroupToken? {
        guard let title = self.firstMatch(for: String.groupHeaderFooterTitlePattern) else { return nil }

        guard let tail = self.replaceFirstMatch(for: String.groupHeaderFooterTitlePattern, withString: ""),
              let number = tail.getNumberNoRemains()
        else { return .footer(title, nil) }

        return .footer(title, number)
    }

    func tokenizeReportFooter() -> [Tokens.FooterToken] {
        let lines = self.components(separatedBy: "\n").filter { !$0.isEmpty }

        return lines.compactMap { line -> Tokens.FooterToken? in

            if line.firstMatch(for: #"ИТОГ:"#) != nil,
               let number = line.getNumberNoRemains() {
                return .total("ИТОГ:", number)
            }

            if line.firstMatch(for: #"ИТОГ всех расходов за месяц"#) != nil,
               let number = line.getNumberNoRemains() {
                return .expensesTotal("ИТОГ всех расходов за месяц", number)
            }

            if line.firstMatch(for: #"[П\п]ереход"#) != nil,
               let number = line.getNumberNoRemains() {
                return .openingBalance(line.trimmingCharacters(in: .whitespaces), number)
            }

            if line.firstMatch(for: #"Фактический остаток:"#) != nil {
                // get percentage and remains (replace percentage with "")
                guard let percentageString = line.firstMatch(for: String.matchingPercentagePattern),
                      let percentage = percentageString.percentageStringToDouble()
                else { return .error }

                let remains = line.replaceMatches(for: String.matchingPercentagePattern, withString: "")
                // get number
                if let number = remains.getNumberNoRemains() {
                    return .balance("Фактический остаток", number, percentage)
                }
            }

            return .tbd(line)
        }
    }

}
