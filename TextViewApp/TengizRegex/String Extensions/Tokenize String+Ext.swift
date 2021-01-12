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
    // static let groupPattern = #"(?m)^[А-Яа-я][^\n]*\n(^\d\d?\..*\n+)+ИТОГ:.*"#
    static let groupHeaderPattern = #"^[А-Яа-я][^\n]*\n"#
    #warning("compare to itemFullLineWithDigitsPattern and other!!")
    static let itemLine = #"(^\d\d?\..*\n+)"#
    /// matching lines like `"-10.000 за перерасход питание персонала в июле"`
    static let itemCorrectionLine = #"^-\d{1,3}(?:\.\d{3})*.*"#
    static let groupPattern = #"(?m)"# + groupHeaderPattern + #"("# + itemLine + #"|("# + itemCorrectionLine + #"\n))+ИТОГ:.*"#
    /// matching lines starting like "3. Электричество" or "12.Интернет"
    static let itemTitlePattern = #"^[1-9]\d?\.[^\d\n]+"#
    static let itemFullLineWithDigitsPattern = #"(?m)"# + itemTitlePattern + #"\d+.*"#
    /// matching lines like `"4.Банковская комиссия 1.6% за эквайринг    "` (mind whitespace)
    static let itemTitleWithPercentagePattern =  itemTitlePattern + percentagePattern + #"[\D]*"#
    // static let itemTitleWithPercentagePattern =  #"^[1-9]\d?\.[\D]*\d+(\.\d+)?%[\D]*"#
    /// matching lines like `"22. Хэдхантер (подбор пероснала)    "` (mind whitespace)
    static let itemTitleWithParenthesesPattern = itemTitlePattern + #"\([^(]*\)[^\d\n]*"#
    static let itemWithPlusPattern = itemTitlePattern + numbersWithPlusPattern
    /// pattern to match `"200.000 (за август) +400.000 (за сентябрь)"` or `"7.701+4.500"`
    static let numbersWithPlusPattern = itemNumberPattern + #"(?:\s*\([^\)]+\)\s*)?\+"# + itemNumberPattern + #"(?:\s*\([^\)]+\)\s*)?"#
    static let groupHeaderFooterTitlePattern = #"^[А-Яа-я][А-Яа-я ]+(?=:)"#
    static let percentagePattern = #"\d+(\.\d+)?%"#

    // MARK: - Tokenize Report Header

    func tokenizeReportHeader() -> [Tokens.HeaderToken] {

        let headerCompanyPattern = #"(?<=Название объекта:\s).*"#
        let headerMonthPattern = #"[А-Яа-я]+\d{4}"#
        let headerItemTitlePattern = #"[А-Яа-я ]+(?=:)"#
        let headerItemPattern = headerItemTitlePattern + #":[А-Яа-я ]*\d+(\.\d{3})*"#

        let company: Tokens.HeaderToken? = {
            guard let companyString = self.firstMatch(for: headerCompanyPattern) else { return nil }
            return .company(companyString)
        }()

        let month: Tokens.HeaderToken? = {
            guard let monthString = self.firstMatch(for: headerMonthPattern) else { return nil }
            return .month(monthString.trimmingCharacters(in: .whitespaces))
        }()

        let tail: String = self.replaceMatches(for: headerMonthPattern, withString: "")

        let headerItems: [Tokens.HeaderToken] = tail
            .listMatches(for: headerItemPattern)
            .compactMap {
                guard let title = $0.firstMatch(for: headerItemTitlePattern) else { return nil }
                let cleanTitle = title.trimmingCharacters(in: .whitespaces)
                guard let number = $0.extractNumber() else { return nil }
                return .headerItem(cleanTitle, number)
            }

        return [company, month].compactMap { $0 } + headerItems
    }

    // MARK: - Tokenize Report Group

    // swiftlint:disable:next function_body_length
    func transformLineToGroupItem() -> Tokens.GroupToken? {
        var title: String = ""
        var remains: String = ""
        var number: Double?

        /// tokenize lines like `"-10.000 за перерасход питание персонала в июле"`
        if self.firstMatch(for: String.itemCorrectionLine) != nil,
           let number = self.getNumberNoRemains() {
            return .item("Correction", number, self)
        }

        /// tokenize lines like `"12.Интернет    7.701+4.500"` or `"1. Аренда торгового помещения     200.000 (за август) +400.000 (за сентябрь)        "`
        if self.firstMatch(for: String.itemWithPlusPattern) != nil,
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

        let itemWithItogoPattern = #".*?Итого"#
        if self.firstMatch(for: itemWithItogoPattern) != nil {

            let prihodPattern = #"1. Приход товара по накладным"#
            if let titleString = self.firstMatch(for: prihodPattern),
               let afterItogo = self.replaceFirstMatch(for: itemWithItogoPattern, withString: ""),
               let number = afterItogo.getNumberNoRemains(),
               let comment = self.replaceFirstMatch(for: prihodPattern, withString: "") {
                return .item(titleString, number, comment.clearWhitespacesAndNewlines())
            }

            let prepayPattern = #"2. Предоплаченный товар, но не отраженный в приходе"#
            if let titleString = self.firstMatch(for: prepayPattern),
               let afterItogo = self.replaceFirstMatch(for: itemWithItogoPattern, withString: ""),
               let number = afterItogo.getNumberNoRemains(),
               let comment = self.replaceFirstMatch(for: prepayPattern, withString: "") {
                return .item(titleString, number, comment.clearWhitespacesAndNewlines())
            }

        }

        /// tokenize line like `"2. Предоплаченный товар, но не отраженный в приходе    Студиопак-12.500 (влажные салфетки);"`
        let anotherPrepayPattern = #"2. Предоплаченный товар, но не отраженный в приходе(?=\s+[А-Яа-я])"#
        if let titleString = self.firstMatch(for: anotherPrepayPattern) {
            let comment = self.replaceMatches(for: anotherPrepayPattern, withString: "")
            if let number = comment.extractNumber() {
                return .item(titleString, number, comment.clearWhitespacesAndNewlines())
            }
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

        /// special case when number after item title is not a number for item
        /// for example in `"1. Приход товара по накладным     946.056р (оплаты фактические: 475.228р 52к -переводы; 157.455р 85к-корпоративная карта; 0-наличные из кассы; Итого-632.684р 37к)"`
        if let afterItogo = remains.replaceFirstMatch(for: itemWithItogoPattern, withString: "") {
            number = afterItogo.getNumberNoRemains()
        }

        /// another special case when number after item title is not a number for item
        /// for example in `"1. Приход товара по накладным    451.198р41к (из них у нас оплачено фактический 21.346р15к)"`
        let factPattern = #".*?фактический"#
        if let afterFact = remains.replaceFirstMatch(for: factPattern, withString: "") {
            number = afterFact.getNumberNoRemains()
            remains = self.replaceFirstMatch(for: String.itemTitlePattern + #""#, withString: "") ?? self
        }

        let dirtyComment = remains.clearWhitespacesAndNewlines()
        let comment: String? = dirtyComment.isEmpty ? nil : dirtyComment

        return .item(title, number ?? 0, comment)
    }

    func getGroupHeader() -> Tokens.GroupToken? {
        guard let title = self.firstMatch(for: String.groupHeaderFooterTitlePattern) else { return nil }

        guard let firstTail = self.replaceFirstMatch(for: String.groupHeaderFooterTitlePattern, withString: ""),
              let firstPercentageString = firstTail.firstMatch(for: String.percentagePattern),
              let firstPercentage = firstPercentageString.percentageStringToDouble() else {
            return .header(title, nil, nil)
        }

        let secondtail = firstTail.replaceFirstMatch(for: String.percentagePattern,
                                                     withString: "")
        guard let secondPercentageString = secondtail?.firstMatch(for: String.percentagePattern),
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

    // MARK: - Tokenize Report Footer

    func tokenizeReportFooter() -> [Tokens.FooterToken] {
        let lines = self.components(separatedBy: "\n").filter { !$0.isEmpty }

        return lines.compactMap { line -> Tokens.FooterToken? in

            if line.firstMatch(for: #"ИТОГ:"#) != nil,
               let number = line.getNumberNoRemains() {
                return .total("ИТОГ", number)
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
                guard let percentageString = line.firstMatch(for: String.percentagePattern),
                      let percentage = percentageString.percentageStringToDouble()
                else { return .error }

                let remains = line.replaceMatches(for: String.percentagePattern, withString: "")
                // get number
                if let number = remains.getNumberNoRemains() {
                    return .balance("Фактический остаток", number, percentage)
                }
            }

            return .tbd(line)
        }
    }

}
