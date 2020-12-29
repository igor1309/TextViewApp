//
//  TokenizedReportViewModel.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 29.12.2020.
//

import SwiftUI

class TokenizedReportViewModel: ObservableObject {

    @Published var headerModel: TokenizedReportHeaderModel
    @Published var groupModels: [TokenizedReportGroupModel]
    @Published var footerModel: TokenizedReportFooterModel

    init(reportContent: TextViewModel.ReportContent) {
        headerModel = TokenizedReportHeaderModel(headerString: reportContent.headerString)

        groupModels = reportContent.groups
            .map {
                TokenizedReportGroupModel(groupString: $0)
            }
        footerModel = TokenizedReportFooterModel(footerString: reportContent.footerString)
    }
}
