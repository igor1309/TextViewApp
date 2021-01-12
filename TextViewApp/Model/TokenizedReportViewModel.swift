//
//  TokenizedReportViewModel.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 29.12.2020.
//

import SwiftUI

final class TokenizedReportViewModel: ObservableObject {

    @Published var headerModel: TokenizedReportHeaderModel
    @Published var groupModels: [TokenizedReportBodyModel]
    @Published var footerModel: TokenizedReportFooterModel

    init(reportContent: ReportContent) {
        headerModel = TokenizedReportHeaderModel(headerString: reportContent.headerString)

        groupModels = reportContent.groups
            .map {
                TokenizedReportBodyModel(groupString: $0)
            }
        footerModel = TokenizedReportFooterModel(footerString: reportContent.footerString)
    }
}
