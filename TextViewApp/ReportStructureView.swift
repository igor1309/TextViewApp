//
//  ReportStructureView.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 24.12.2020.
//

import SwiftUI

struct ReportStructureView: View {

    @ObservedObject var model: TextViewModel

    var body: some View {
        if let reportContent = model.reportContent {
            List {
                if model.hasError {
                    Text(model.errorMessage)
                        .font(.headline)
                        .foregroundColor(Color(UIColor.systemRed))
                }

                Section(header: Text("header")) {
                    reportHeader(reportContent.header)
                }
                Section(header: Text("Groups (\(reportContent.groups.count))")) {
                    reportGroups(reportContent.groups)
                }
                Section(header: Text("footer")) {
                    reportFooter(reportContent.footer)
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

    private func reportHeader(_ header: String) -> some View {
        NavigationLink(destination: ParsedReportHeaderView(headerString: header)) {
            Text(header)
        }
    }

    private func reportGroups(_ groups: [String]) -> some View {
        ForEach(groups, id: \.self) { group in
            NavigationLink(destination: ParsedReportGroupView(groupString: group)) {
                Text(group)
            }
        }
    }

    private func reportFooter(_ footer: String) -> some View {
        NavigationLink(destination: ParsedReportFooterView(footerString: footer)) {
            Text(footer)
        }
    }
}

struct ReportStructureView_Previews: PreviewProvider {
    static var previews: some View {
        ReportStructureView(model: TextViewModel())
    }
}
