//
//  ParsedReportHeaderView.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 24.12.2020.
//

import SwiftUI

struct ParsedReportHeaderView: View {

    @StateObject private var model: ParsedReportHeaderViewModel

    init(headerString: String) {
        _model = StateObject(wrappedValue: ParsedReportHeaderViewModel(headerString: headerString))
    }

    var body: some View {
        List {
            Section(header: Text("Original Text")) {
                Text(model.headerString)
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }

            Section(header: Text("Parsed Header")) {
                ForEach(model.items, id: \.self) { item in
                    switch item {
                        case let .company(company):
                            HStack(alignment: .firstTextBaseline) {
                                Text("Company")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(company)
                            }
                        case let .month(month):
                            HStack(alignment: .firstTextBaseline) {
                                Text("Month")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(month)
                            }
                        case let .headerItem(title, number):
                            HStack(alignment: .firstTextBaseline) {
                                Text(title)
                                Spacer()
                                Text("\(number, specifier: "%.2f")")
                            }
                    }
                }
            }
        }
        .font(.subheadline)
        .listStyle(GroupedListStyle())
        .navigationTitle("Parsed Header")
    }
}

struct ParsedReportHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ParsedReportHeaderView(headerString: """
            Название объекта: Саперави Аминьевка
            Месяц: сентябрь2020     Оборот:2.440.021    Средний показатель: 81.334

            Статья расхода:    Сумма расхода:    План %     Факт %
            """
        )
    }
}
