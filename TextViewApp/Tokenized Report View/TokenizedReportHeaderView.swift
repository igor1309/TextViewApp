//
//  TokenizedReportHeaderView.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 24.12.2020.
//

import SwiftUI

struct TokenizedReportHeaderView: View {

    @ObservedObject var model: TokenizedReportViewModel

    var body: some View {
        List {
            if model.headerModel.hasError {
                Text(model.headerModel.errorMessage)
                    .font(.headline)
                    .foregroundColor(Color(UIColor.systemRed))
            }

            Section(header: Text("Original Text")) {
                Text(model.headerModel.headerString)
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }

            Section(header: Text("Tokenized Header (\(model.headerModel.items.count))")) {
                TokenizedReportHeaderViewRows(model: model)
            }
        }
        .font(.subheadline)
        .listStyle(GroupedListStyle())
        .navigationTitle("Tokenized Header")
    }
}

struct TokenizedReportHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TokenizedReportHeaderView(model: TokenizedReportViewModel.sample)
                .font(.subheadline)
                .listStyle(GroupedListStyle())
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
