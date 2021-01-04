//
//  TokenizedReportHeaderViewRows.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 28.12.2020.
//

import SwiftUI

struct TokenizedReportHeaderViewRows: View {
    @ObservedObject var model: TokenizedReportViewModel

    var body: some View {
        ForEach(model.headerModel.items, id: \.self, content: itemView)
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
    }
}

struct TokenizedReportHeaderViewRows_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                Section {
                    TokenizedReportHeaderViewRows(model: TokenizedReportViewModel.sample)
                }
            }
            .font(.subheadline)
            .listStyle(GroupedListStyle())
            .navigationBarTitleDisplayMode(.inline)
        }
        .environment(\.colorScheme, .dark)
    }
}
