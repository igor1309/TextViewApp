//
//  TokenizedReportHeaderViewModel.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 25.12.2020.
//

import SwiftUI

final class TokenizedReportHeaderViewModel: ObservableObject {

    @Published var items: [Token]

    let headerString: String

    let errorMessage = "Error parsing header"
    var hasError: Bool { items.count != 4 }

    init(headerString: String) {
        self.headerString = headerString
        self.items = headerString.tokenizeReportHeader()
    }

    enum Token: Hashable {
        case company(String)
        case month(String)
        case headerItem(String, Double)
    }

}