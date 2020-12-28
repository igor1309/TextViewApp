//
//  ReportStructureView.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 24.12.2020.
//

import SwiftUI

struct ReportStructureView: View {

    @ObservedObject var model: TextViewModel

    @StateObject private var headerModel: ParsedReportHeaderViewModel
    @StateObject private var footerModel: ParsedReportFooterViewModel

    init(model: TextViewModel) {
        self.model = model

        let reportContent = model.reportContent ?? TextViewModel.ReportContent.empty

        let headerModel = ParsedReportHeaderViewModel(headerString: reportContent.headerString)
        _headerModel = StateObject(wrappedValue: headerModel)

        let footerModel = ParsedReportFooterViewModel(footerString: reportContent.footerString)
        _footerModel = StateObject(wrappedValue: footerModel)
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
                Section(header: Text("Groups (\(reportContent.groups.count))")) {
                    reportGroupsView(reportContent.groups)
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
        NavigationLink(destination: ParsedReportHeaderView(model: headerModel)) {
            Text(header)
        }
    }

    private func reportGroupsView(_ groups: [String]) -> some View {
        ForEach(groups, id: \.self) { group in
            NavigationLink(destination: ParsedReportGroupView(groupString: group)) {
                Text(group)
            }
        }
    }

    private func reportFooterView(_ footer: String) -> some View {
        NavigationLink(destination: ParsedReportFooterView(model: footerModel)) {
            Text(footer)
        }
    }
}

struct ReportStructureView_Previews: PreviewProvider {
    static var previews: some View {
        ReportStructureView(model: TextViewModel())
    }
}
