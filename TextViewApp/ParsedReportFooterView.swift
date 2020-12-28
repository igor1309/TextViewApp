//
//  ParsedReportFooterView.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 24.12.2020.
//

import SwiftUI

struct ParsedReportFooterView: View {

    @ObservedObject var model: ParsedReportFooterViewModel

    var body: some View {
        List {
            Section(header: Text("Original Text")) {
                Text(model.footerString)
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }

            #warning("add simple check in model: всего остаток входящий / исходящий")
            Section(header: Text("Parsed Footer (\(model.items.count))")) {
                ParsedReportFooterViewRows(model: model)
                // ForEach(model.items, id: \.self, content: itemView)
            }
        }
        .font(.subheadline)
        .listStyle(GroupedListStyle())
        .navigationTitle("Parsed Footer")
    }
}

struct ParsedReportFooterView_Previews: PreviewProvider {
    static var previews: some View {
        ParsedReportFooterView(model: ParsedReportFooterViewModel(
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
