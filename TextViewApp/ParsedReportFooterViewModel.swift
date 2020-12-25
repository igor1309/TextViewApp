//
//  ParsedReportFooterViewModel.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 26.12.2020.
//

import Foundation

final class ParsedReportFooterViewModel: ObservableObject {

    @Published var footerString: String
    @Published var items: [Token]

    init(footerString: String) {
        self.footerString = footerString
        self.items = footerString.parseReportFooter()
    }

    enum Token: Hashable {
        case total(String, Double)
        case expensesTotal(String, Double)
        case openingBalance(String, Double)
        case balance(String, Double, Double)
        case tbd(String)
        case error
    }
}
