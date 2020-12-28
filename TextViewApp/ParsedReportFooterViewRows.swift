//
//  ParsedReportFooterViewRows.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 28.12.2020.
//

import SwiftUI

struct ParsedReportFooterViewRows: View {
    @ObservedObject var model: ParsedReportFooterViewModel

    var body: some View {
        ForEach(model.items, id: \.self, content: itemView)
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

struct ParsedReportFooterViewRows_Previews: PreviewProvider {
    static let model = ParsedReportFooterViewModel(
        footerString: """
            ИТОГ всех расходов за месяц:    2.343.392р 37к
            Фактический остаток:    96.628р 63к    20%
                Минус с августа переходит 739.626р 06к
            ИТОГ:    Минус 642.997р 43к
            """
    )

    static var previews: some View {
        List {
            Section {
                ParsedReportFooterViewRows(model: model)
            }
        }
        .environment(\.colorScheme, .dark)
    }
}
