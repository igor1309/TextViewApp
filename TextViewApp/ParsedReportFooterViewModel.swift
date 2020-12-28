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

    var expensesTotal: Double {
        items
            .compactMap { token -> Double? in
                switch token {
                    case let .expensesTotal(_, number):
                        return number
                    default:
                        return nil
                }
            }
            .reduce(0, +)
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
