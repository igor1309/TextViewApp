//
//  ParsedReportHeaderView.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 24.12.2020.
//

import SwiftUI

struct ParsedReportHeaderView: View {
    let header: String

    var body: some View {
        List {
            Text(header)
                .foregroundColor(.secondary)
                .font(.footnote)

            Section(header: Text("Parsed (\("TBD"))")) {
                Text("TBD")
            }
        }
        .font(.subheadline)
        .listStyle(GroupedListStyle())
        .navigationTitle("Parsed Header")
    }
}

struct ParsedReportHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ParsedReportHeaderView(header: """
            Название объекта: Саперави Аминьевка
            Месяц: сентябрь2020     Оборот:2.440.021    Средний показатель: 81.334

            Статья расхода:    Сумма расхода:    План %     Факт %
            Основные расходы:        20%    8.95%
            """
        )
    }
}
