//
//  TokenizedReportFooterViewRows.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 28.12.2020.
//

import SwiftUI

struct TokenizedReportFooterViewRows: View {

    @ObservedObject var model: TokenizedReportViewModel

    var body: some View {
        ForEach(model.footerModel.items, id: \.self, content: itemView)
    }

    @ViewBuilder
    private func itemView(item: Tokens.FooterToken) -> some View {
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

struct TokenizedReportFooterViewRows_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                Section {
                    TokenizedReportFooterViewRows(model: TokenizedReportViewModel.sample)
                }
            }
            .font(.subheadline)
            .listStyle(GroupedListStyle())
            .navigationBarTitleDisplayMode(.inline)
        }
        .environment(\.colorScheme, .dark)
    }
}
