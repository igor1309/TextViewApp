//
//  Parse String+Ext.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 25.12.2020.
//

import Foundation

extension String {
    #warning("move to seperate namespace enum?")
    //  (?m) - MULTILINE mode on
    static let groupPattern = #"(?m)^[А-Яа-я][^\n]*\n(^\d\d?\..*\n+)+ИТОГ:.*"#
    static let itemFullLineWithDigitsPattern = #"(?m)^[1-9][0-9]?\.[^\d\n]+\d+.*"#
    static let itemTitleWithPercentagePattern = #"^[1-9]\d?\.[\D]*\d+(\.\d+)?%[\D]*"#
    static let itemTitleWithParenthesesPattern = #"^[1-9][0-9]?\.[^\d\n]+\([^(]*\)[^\d\n]*"#
    static let itemTitlePattern = #"^[1-9][0-9]?\.[^\d\n]+"#
    static let groupHeaderFooterTitlePattern = #"^[А-Яа-я][А-Яа-я ]+:"#
    static let matchingPercentagePattern = #"\d+(\.\d+)*%"#

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

    func transformLineToItem() -> ParsedReportGroupViewModel.Token? {
        var title: String = ""
        var remains: String = ""
        var number: Double?

        let itemTitlePatterns = [String.itemTitleWithPercentagePattern, String.itemTitleWithParenthesesPattern, String.itemTitlePattern]
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

        let comment: String? = remains.isEmpty ? nil : remains

        return .item(title, number ?? 0, comment)
    }

    func getGroupHeader() -> ParsedReportGroupViewModel.Token? {
        guard let title = self.firstMatch(for: String.groupHeaderFooterTitlePattern) else { return nil}
        let cleanTitle = title.last == ":" ? String(title.dropLast()) : title

        let firstTail = self.replaceFirstMatch(for: String.groupHeaderFooterTitlePattern,
                                               withString: "")
        guard let firstPercentageString = firstTail?.firstMatch(for: String.matchingPercentagePattern),
              let firstPercentage = firstPercentageString.percentageStringToDouble() else {
            return .header(cleanTitle, nil, nil)
        }

        let secondtail = firstTail?.replaceFirstMatch(for: String.matchingPercentagePattern,
                                                      withString: "")
        guard let secondPercentageString = secondtail?.firstMatch(for: String.matchingPercentagePattern),
              let secondPercentage = secondPercentageString.percentageStringToDouble() else {
            return .header(cleanTitle, firstPercentage, nil)
        }

        return .header(cleanTitle, firstPercentage, secondPercentage)
    }

    func getGroupFooter() -> ParsedReportGroupViewModel.Token? {
        guard let title = self.firstMatch(for: String.groupHeaderFooterTitlePattern) else { return nil}
        let cleanTitle = title.last == ":" ? String(title.dropLast()) : title

        guard let tail = self.replaceFirstMatch(for: String.groupHeaderFooterTitlePattern, withString: ""),
              let number = tail.getNumberNoRemains() else { return .footer(cleanTitle, nil) }

        return .footer(cleanTitle, number)
    }

    func parseReportFooter() -> [ParsedReportFooterViewModel.Token] {
        let lines = self.components(separatedBy: "\n").filter { !$0.isEmpty }

        return lines.compactMap { line -> ParsedReportFooterViewModel.Token? in

            if line.firstMatch(for: #"ИТОГ:"#) != nil,
               let number = line.getNumberNoRemains() {
                return .total("ИТОГ:", number)
            }

            if line.firstMatch(for: #"ИТОГ всех расходов за месяц"#) != nil,
               let number = line.getNumberNoRemains() {
                return .expensesTotal("ИТОГ всех расходов за месяц", number)
            }

            if line.firstMatch(for: #"[П\п]ереходит"#) != nil,
               let number = line.getNumberNoRemains() {
                return .openingBalance(line.trimmingCharacters(in: .whitespaces), number)
            }

            if line.firstMatch(for: #"Фактический остаток:"#) != nil {
                // get percentage and remains (replace percentage with "")
                guard let percentageString = line.firstMatch(for: String.matchingPercentagePattern),
                      let percentage = percentageString.percentageStringToDouble(),
                      let remains = line.replaceMatches(for: String.matchingPercentagePattern, withString: "")
                else { return .error }

                // get number
                if let number = remains.getNumberNoRemains() {
                    return .balance("Фактический остаток", number, percentage)
                }
            }

            return .tbd(line)
        }
    }

}