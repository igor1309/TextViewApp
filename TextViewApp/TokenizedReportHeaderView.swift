//
//  TokenizedReportHeaderView.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 24.12.2020.
//

import SwiftUI

struct TokenizedReportHeaderView: View {

    @ObservedObject var model: TokenizedReportHeaderViewModel

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

            Section(header: Text("Tokenized Header (\(model.items.count))")) {
                TokenizedReportHeaderViewRows(model: model)
            }
        }
        .font(.subheadline)
        .listStyle(GroupedListStyle())
        .navigationTitle("Tokenized Header")
    }

}

struct TokenizedReportHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        TokenizedReportHeaderView(
            model: TokenizedReportHeaderViewModel(
                headerString: """
                Название объекта: Саперави Аминьевка
                Месяц: сентябрь2020     Оборот:2.440.021    Средний показатель: 81.334

                Статья расхода:    Сумма расхода:    План %     Факт %
                """
            )
        )
    }
}
