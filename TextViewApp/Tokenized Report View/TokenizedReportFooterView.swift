//
//  TokenizedReportFooterView.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 24.12.2020.
//

import SwiftUI
import TengizRegex

struct TokenizedReportFooterView: View {

    @ObservedObject var model: TokenizedReportViewModel

    var body: some View {
        List {
            Section(header: Text("Original Text")) {
                Text(model.footerModel.footerString)
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }

            #warning("add simple check in model: всего остаток входящий / исходящий")
            Section(header: Text("Tokenized Footer (\(model.footerModel.items.count))")) {
                TokenizedReportFooterViewRows(model: model)
                // ForEach(model.items, id: \.self, content: itemView)
            }
        }
        .font(.subheadline)
        .listStyle(GroupedListStyle())
        .navigationTitle("Tokenized Footer")
    }
}

struct TokenizedReportFooterView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TokenizedReportFooterView(model: TokenizedReportViewModel.sample)
                .font(.subheadline)
                .listStyle(GroupedListStyle())
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
