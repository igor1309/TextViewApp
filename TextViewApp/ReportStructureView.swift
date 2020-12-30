//
//  ReportStructureView.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 24.12.2020.
//

import SwiftUI

struct ReportStructureView: View {

    @ObservedObject var model: TextViewModel

    @StateObject private var tokenizedReportViewModel: TokenizedReportViewModel

    init(model: TextViewModel) {
        self.model = model

        let reportContent = model.reportContent ?? TextViewModel.ReportContent.empty

        let tokenizedReportViewModel = TokenizedReportViewModel(reportContent: reportContent)
        _tokenizedReportViewModel = StateObject(wrappedValue: tokenizedReportViewModel)
    }

    var body: some View {
        if let reportContent = model.reportContent {
            List {
                if model.hasError {
                    Text(model.errorMessage)
                        .font(.headline)
                        .foregroundColor(Color(UIColor.systemRed))
                }

                Section(header: Text("header")) {
                    reportHeaderView(reportContent.headerString)
                }

                Section(header: Text("Groups (\(tokenizedReportViewModel.groupModels.count))")) {
                    reportGroupsView()
                }

                Section(header: Text("footer")) {
                    reportFooterView(reportContent.footerString)
                }
            }
            .font(.subheadline)
            .listStyle(GroupedListStyle())
            .navigationTitle("Report Structure")
        } else {
            Text("Error: no Report Structure")
                .foregroundColor(.red)
        }
    }

    private func reportHeaderView(_ header: String) -> some View {
        NavigationLink(destination: TokenizedReportHeaderView(model: tokenizedReportViewModel)) {
            Text(header)
        }
    }

    private func reportGroupsView() -> some View {
        ForEach(tokenizedReportViewModel.groupModels, id: \.self) { model in
            NavigationLink(destination: TokenizedReportGroupView(model: model)) {
                Text(model.groupString)
            }
        }
    }

    private func reportFooterView(_ footer: String) -> some View {
        NavigationLink(destination: TokenizedReportFooterView(model: tokenizedReportViewModel)) {
            Text(footer)
        }
    }
}

struct ReportStructureView_Previews: PreviewProvider {
    static let model = TextViewModel()

    static var previews: some View {
        ReportStructureView(model: TextViewModel())
            .previewLayout(.fixed(width: 370, height: 200))

        ReportStructureView(model: TextViewModel.sample)
    }
}
