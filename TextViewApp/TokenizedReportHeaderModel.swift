//
//  TokenizedReportHeaderModel.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 29.12.2020.
//

import Foundation

struct TokenizedReportHeaderModel {

    var items: [Tokens.HeaderToken]

    let headerString: String

    let errorMessage = "Error parsing header"
    var hasError: Bool { items.count != 4 }

    init(headerString: String) {
        self.headerString = headerString
        self.items = headerString.tokenizeReportHeader()
    }
}
