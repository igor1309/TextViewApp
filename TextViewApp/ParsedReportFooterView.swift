//
//  ParsedReportFooterView.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 24.12.2020.
//

import SwiftUI

struct ParsedReportFooterView: View {
    let footer: String

    var body: some View {
        List {
            Text(footer)
                .foregroundColor(.secondary)
                .font(.footnote)

            Section(header: Text("Parsed (\("TBD"))")) {
                Text("TBD")
            }
        }
        .font(.subheadline)
        .listStyle(GroupedListStyle())
        .navigationTitle("Parsed Footer")
    }
}

struct ParsedReportFooterView_Previews: PreviewProvider {
    static var previews: some View {
        ParsedReportFooterView(footer: """
            ИТОГ всех расходов за месяц:    2.343.392р 37к
            Фактический остаток:    96.628р 63к    20%
                Минус с августа переходит 739.626р 06к
            ИТОГ:    Минус 642.997р 43к
            """
        )
    }
}
