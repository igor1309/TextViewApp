//
//  TokenizedReportView.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 28.12.2020.
//

import SwiftUI

struct TokenizedReportView: View {

    let reportContent: TextViewModel.ReportContent

    @StateObject private var model: TokenizedReportViewModel

    init(reportContent: TextViewModel.ReportContent) {
        self.reportContent = reportContent

        let model = TokenizedReportViewModel(reportContent: reportContent)
        _model = StateObject(wrappedValue: model)
    }

    // MARK: - this var has no idea about errors in groups
    private var hasErrors: Bool {
        model.headerModel.hasError || model.footerModel.hasError
    }

    var body: some View {
        List {
            if hasErrors {
                Text("TBD: show if errors")
                    .foregroundColor(Color(UIColor.systemRed))
            }

            Section(
                header: Text("Tokenized Header"),
                footer: NavigationLink(
                    destination: TokenizedReportHeaderView(model: model)
                ) {
                    Text("Compare to source")
                }
            ) {
                TokenizedReportHeaderViewRows(model: model)
            }

            ForEach(model.groupModels, id: \.self) { models in
                TokenizedReportGroupSectionView(model: models)
            }

            Section(
                header: Text("Tokenized Footer"),
                footer: NavigationLink(
                    destination: TokenizedReportFooterView(model: model)
                ) {
                    Text("Compare to source")
                }
            ) {
                TokenizedReportFooterViewRows(model: model)
            }
        }
        .font(.subheadline)
        .listStyle(GroupedListStyle())
        .navigationTitle("Tokenized Report")
    }
}

struct TokenizedReportView_Previews: PreviewProvider {
    static let reportContent = TextViewModel.ReportContent(
        headerString: TokenizedReportHeaderModel.sampleString,
        groups: [TokenizedReportGroupModel.sampleString,
                 TokenizedReportGroupModel.sampleString2],
        footerString: TokenizedReportFooterModel.sampleString
    )

    static var previews: some View {
        NavigationView {
            TokenizedReportView(reportContent: reportContent)
                .navigationBarTitleDisplayMode(.inline)
        }
        .previewLayout(.fixed(width: 370, height: 1200))
        //        .environment(\.colorScheme, .dark)
    }
}
