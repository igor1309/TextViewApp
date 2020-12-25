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
                    NavigationLink(destination: ParsedReportHeaderView(headerString: reportContent.header)) {
                        Text(reportContent.header)
                    }
                }
                Section(header: Text("Groups (\(reportContent.groups.count))")) {
                    ForEach(reportContent.groups, id: \.self) { group in
                        NavigationLink(destination: ParsedReportGroupView(groupString: group)) {
                            Text(group)
                        }
                    }
                }
                Section(header: Text("footer")) {
                    NavigationLink(destination: ParsedReportFooterView(footerString: reportContent.footer)) {
                        Text(reportContent.footer)
                    }
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
}

struct ReportStructureView_Previews: PreviewProvider {
    static var previews: some View {
        ReportStructureView(model: TextViewModel())
    }
}
