//
//  ParsedReportGroupView.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 24.12.2020.
//

import SwiftUI
import Combine

struct ParsedReportGroupView: View {
    @StateObject private var model: ParsedReportGroupViewModel

    init(group: String) {
        _model = StateObject(wrappedValue: ParsedReportGroupViewModel(group: group))
    }

    var body: some View {
        List {
            Section(header: Text("Original Text")) {
                Text(model.group)
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }

            Section(header: Text("Rows with numbers (\(model.listWithNumbers.count))")) {
                VStack(alignment: .leading, spacing: 3) {
                    ForEach(model.listWithNumbers, id: \.self) { row in
                        Text(row)
                            .foregroundColor(.secondary)
                            .font(.footnote)
                    }
                }
            }

            Section(header: Text("Parsed header")) {
                Text("TBD")
            }

            Section(
                header: Text("Parsed rows (\(model.items.count))"),
                footer: itemsSectionFooter()
            ) {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(model.items, id: \.self) { token in
                        if case let .item(title, number, comment) = token {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(alignment: .firstTextBaseline) {
                                    Text(title)
                                    Spacer()
                                    Text("\(number, specifier: "%.2f")")
                                }

                                if let comment = comment,
                                   !comment.isEmpty {
                                    Text(comment)
                                        .foregroundColor(.secondary)
                                        .font(.footnote)
                                }
                            }
                        }
                    }
                }
            }

            Section(header: Text("Parsed footer")) {
                Text("TBD")
            }

        }
        .font(.subheadline)
        .listStyle(GroupedListStyle())
        .navigationTitle("Parsed Group")
    }

    private func itemsSectionFooter() -> some View {
        HStack {
            Text("Group Total".uppercased())
                .font(.subheadline)
            Spacer()
            Text("\(model.total, specifier: "%.2f")")
                .font(.subheadline)
        }
        .foregroundColor(.primary)
    }
}

struct ParsedReportGroupView_Previews: PreviewProvider {
    static var previews: some View {
        ParsedReportGroupView(group: """
Прочие расходы:        15%    16.5%
1.Налоговые платежи     26.964
2.Банковское обслуживание    6.419
3.Юридическое сопровождение    40.000
4.Банковская комиссия 1.6% за эквайринг    26.581
5.Тайный гость    -----------------------------
9.Реклама и IT поддержка    65.000 (не iiko)
10.Обслуживание пожарной охраны    -----------------------------
11.Вневедомственная охрана помещения    -----------------------------
12.Интернет    9.000
13.Дезобработка помещения    -----------------------------
14. ----------------------------------    ----------------------------
15.Аренда зарядных устройств и раций    ----------------------------
27. Сервис Гуру (система аттестации, за 1 год)    12.655
ИТОГ:    402.520
"""
        )
        .previewLayout(.fixed(width: 350, height: 1000))
    }
}
