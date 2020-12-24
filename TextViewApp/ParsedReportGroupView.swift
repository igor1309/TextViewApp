//
//  ParsedReportGroupView.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 24.12.2020.
//

import SwiftUI

struct ParsedReportGroupView: View {
    let group: String

    var body: some View {
        List {
            Text(group)
                .foregroundColor(.secondary)
                .font(.footnote)

            Section(header: Text("Parsed (\("TBD"))")) {
                Text("TBD")
            }
        }
        .font(.subheadline)
        .listStyle(GroupedListStyle())
        .navigationTitle("Parsed Group")
    }
}

struct ParsedReportGroupView_Previews: PreviewProvider {
    static var previews: some View {
        ParsedReportGroupView(group: """
            Расходы на доставку:
            1. Курьеры    -----------------------------
            2. Агрегаторы    18.132
            ИТОГ:    18.132
            """
        )
    }
}
