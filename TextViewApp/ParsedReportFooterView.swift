//
//  ParsedReportFooterView.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 24.12.2020.
//

import SwiftUI

struct ParsedReportFooterView: View {

    @StateObject private var model: ParsedReportFooterViewModel

    init(footerString: String) {
        _model = StateObject(wrappedValue: ParsedReportFooterViewModel(footerString: footerString))
    }

    var body: some View {
        List {
            Section(header: Text("Original Text")) {
                Text(model.footerString)
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }
            #warning("add simple check in model: всего остаток входящий / исходящий")
            Section(header: Text("Parsed (\(model.items.count))")) {
                ForEach(model.items, id: \.self, content: itemView)
            }
        }
        .font(.subheadline)
        .listStyle(GroupedListStyle())
        .navigationTitle("Parsed Footer")
    }

    @ViewBuilder
    private func itemView(item: ParsedReportFooterViewModel.Token) -> some View {
        switch item {
            case let .total(title, number),
                 let .expensesTotal(title, number),
                 let .openingBalance(title, number):
                HStack(alignment: .firstTextBaseline) {
                    Text(title)
                    Spacer()
                    Text("\(number, specifier: "%.2f")")
                }

            case let .balance(title, number, percentage):
                HStack(alignment: .firstTextBaseline) {
                    Text(title)
                    Spacer()
                    Text("\(number, specifier: "%.2f")")
                    Text("\(percentage * 100, specifier: "%.2f%%")")
                }

            case let .tbd(line):
                Text("TBD: \(line)")

            case .error:
                Text("Error parcing line")
                    .foregroundColor(Color(UIColor.systemRed))
        }
    }
}

struct ParsedReportFooterView_Previews: PreviewProvider {
    static var previews: some View {
        ParsedReportFooterView(footerString: """
            ИТОГ всех расходов за месяц:    2.343.392р 37к
            Фактический остаток:    96.628р 63к    20%
                Минус с августа переходит 739.626р 06к
            ИТОГ:    Минус 642.997р 43к
            """
        )
    }
}
