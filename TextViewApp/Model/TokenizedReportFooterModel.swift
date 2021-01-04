//
//  TokenizedReportFooterModel.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 29.12.2020.
//

import Foundation

struct TokenizedReportFooterModel {

    var items: [Tokens.FooterToken]

    let footerString: String

    #warning("FIXME: FINISH THIS:")
    var hasError: Bool {
        false
    }

    init(footerString: String) {
        self.footerString = footerString
        self.items = footerString.tokenizeReportFooter()
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

}
