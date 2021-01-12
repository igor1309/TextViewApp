//
//  String+Ext.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 05.01.2021.
//

import Foundation

public extension String {

    func cleanReport() -> String {
        // make some cleaning & fixes
        self.clearWhitespacesAndNewlines()
            // fix one special line
            .replaceMatches(for: "\nФОТ Бренд, логистика, бухгалтерия",
                            withString: "\n2. ФОТ Бренд, логистика, бухгалтерия")
            .replaceMatches(for: "Итого-",
                            withString: "Итого ")
            // remove optionality from rubli-kopeiki making rubliKopeikiPattern and kopeikiPatterm simpler
            .replaceMatches(for: #"(\d{1,3}(?:\.\d{3})*) *р *(?:(\d\d?) *к\.?)"#,
                            withString: #"$1р $2к"#)
            // rubli without kopeiki -> just number
            .replaceMatches(for: #"(\d{1,3}(?:\.\d{3})*) *р(?= [^\dк)])"#,
                            withString: #"$1"#)
            // fix no space after dot after line number
            .replaceMatches(for: #"(?m)(^\d+.)([А-Я])"#, withString: #"$1 $2"#)
    }

    func splitReportContent() -> ReportContent {

        let headerPattern = #"(?m)(^(.*)\n)+?(?=Статья расхода:)"#
        let footerPattern = #"(?m)^ИТОГ всех расходов за месяц.*\n(^.*\n)*"#
        let columnTitleRowPattern = #"(?m)^Статья расхода:\s*Сумма расхода:\s*План %\s*Факт %\s*\n"#
        let groupPattern = #"(?m)(?:^[А-Яа-я ]+:.*$)(?:\n.*$)+?\nИТОГ:.*"#

        let headerString = self.firstMatch(for: headerPattern) ?? "error getting header"

        let groups = self
            // cut header
            .replaceMatches(for: headerPattern, withString: "")
            // cut footer
            .replaceMatches(for: footerPattern, withString: "")
            // delete column title row
            .replaceMatches(for: columnTitleRowPattern, withString: "")
            .listMatches(for: groupPattern)

        let footerString = self.firstMatch(for: footerPattern) ?? "error getting footer"
        let errorMessage = ""

        return ReportContent(headerString: headerString,
                             groups: groups,
                             footerString: footerString,
                             errorMessage: errorMessage)
    }
}
