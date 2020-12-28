//
//  TokenizedReportFooterView.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 24.12.2020.
//

import SwiftUI

struct TokenizedReportFooterView: View {

    @ObservedObject var model: TokenizedReportFooterViewModel

    var body: some View {
        List {
            Section(header: Text("Original Text")) {
                Text(model.footerString)
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }

            #warning("add simple check in model: всего остаток входящий / исходящий")
            Section(header: Text("Tokenized Footer (\(model.items.count))")) {
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
        TokenizedReportFooterView(model: TokenizedReportFooterViewModel(
            footerString: """
            ИТОГ всех расходов за месяц:    2.343.392р 37к
            Фактический остаток:    96.628р 63к    20%
                Минус с августа переходит 739.626р 06к
            ИТОГ:    Минус 642.997р 43к
            """
        )
        )
    }
}
