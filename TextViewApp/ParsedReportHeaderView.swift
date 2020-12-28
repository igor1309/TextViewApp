//
//  ParsedReportHeaderView.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 24.12.2020.
//

import SwiftUI

struct ParsedReportHeaderView: View {

    @ObservedObject var model: ParsedReportHeaderViewModel

    var body: some View {
        List {
            if model.hasError {
                Text(model.errorMessage)
                    .font(.headline)
                    .foregroundColor(Color(UIColor.systemRed))
            }

            Section(header: Text("Original Text")) {
                Text(model.headerString)
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }

            Section(header: Text("Parsed Header (\(model.items.count))")) {
                ParsedReportHeaderViewRows(model: model)
            }
        }
        .font(.subheadline)
        .listStyle(GroupedListStyle())
        .navigationTitle("Parsed Header")
    }

}

struct ParsedReportHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ParsedReportHeaderView(
            model: ParsedReportHeaderViewModel(
                headerString: """
                Название объекта: Саперави Аминьевка
                Месяц: сентябрь2020     Оборот:2.440.021    Средний показатель: 81.334

                Статья расхода:    Сумма расхода:    План %     Факт %
                """
            )
        )
    }
}
