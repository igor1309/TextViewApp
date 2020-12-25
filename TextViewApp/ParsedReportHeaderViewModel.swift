//
//  ParsedReportHeaderViewModel.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 25.12.2020.
//

import SwiftUI

final class ParsedReportHeaderViewModel: ObservableObject {

    @Published var headerString: String
    @Published var items: [Token]

    init(headerString: String) {
        self.headerString = headerString
        self.items = headerString.parseReportHeader()
    }

    enum Token: Hashable {
        case company(String)
        case month(String)
        case headerItem(String, Double)
    }

}
