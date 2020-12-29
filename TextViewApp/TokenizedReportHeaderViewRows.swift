//
//  TokenizedReportHeaderViewRows.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 28.12.2020.
//

import SwiftUI

struct TokenizedReportHeaderViewRows: View {
    @ObservedObject var model: TokenizedReportHeaderViewModel

    var body: some View {
        ForEach(model.items, id: \.self, content: itemView)
    }

    @ViewBuilder
    private func itemView(item: Tokens.HeaderToken) -> some View {
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
    }}

struct TokenizedReportHeaderViewRows_Previews: PreviewProvider {
    static let model = TokenizedReportHeaderViewModel(
        headerString: """
            Название объекта: Саперави Аминьевка
            Месяц: сентябрь2020     Оборот:2.440.021    Средний показатель: 81.334

            Статья расхода:    Сумма расхода:    План %     Факт %
            """
    )

    static var previews: some View {
        List {
            Section {
                TokenizedReportHeaderViewRows(model: model)
            }
        }
        .environment(\.colorScheme, .dark)
    }
}
