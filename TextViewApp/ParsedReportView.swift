//
//  ParsedReportView.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 28.12.2020.
//

import SwiftUI

struct ParsedReportView: View {

    let reportContent: TextViewModel.ReportContent

    @StateObject private var headerModel: ParsedReportHeaderViewModel
    @StateObject private var footerModel: ParsedReportFooterViewModel

    init(reportContent: TextViewModel.ReportContent) {
        self.reportContent = reportContent

        let headerModel = ParsedReportHeaderViewModel(headerString: reportContent.headerString)
        _headerModel = StateObject(wrappedValue: headerModel)

        let footerModel = ParsedReportFooterViewModel(footerString: reportContent.footerString)
        _footerModel = StateObject(wrappedValue: footerModel)
    }

    // MARK: - this var has no idea about errors in groups
    private var hasErrors: Bool {
        headerModel.hasError || footerModel.hasError
    }

    var body: some View {
        List {
            if hasErrors {
                Text("TBD: show if errors")
                    .font(.headline)
                    .foregroundColor(Color(UIColor.systemRed))
            }

            Section(
                header: Text("Parsed Header"),
                footer: NavigationLink(
                    destination: ParsedReportHeaderView(model: headerModel)
                ) {
                    Text("Compare to source")
                }
            ) {
                ParsedReportHeaderViewRows(model: headerModel)
            }

            ForEach(reportContent.groups, id: \.self) { groupString in
                ParsedReportGroupSectionView(groupString: groupString)
            }

            Section(
                header: Text("Parsed Footer"),
                footer: NavigationLink(
                    destination: ParsedReportFooterView(model: footerModel)
                ) {
                    Text("Compare to source")
                }
            ) {
                ParsedReportFooterViewRows(model: footerModel)
            }
        }
        .font(.subheadline)
        .listStyle(GroupedListStyle())
        .navigationTitle("Parsed Report")
    }
}

struct ParsedReportView_Previews: PreviewProvider {
    static let reportContent = TextViewModel.ReportContent(
        headerString: """
            Название объекта: Саперави Аминьевка
            Месяц: сентябрь2020     Оборот:2.440.021    Средний показатель: 81.334

            Статья расхода:    Сумма расхода:    План %     Факт %
            """,
        groups: [
            """
            Основные расходы:        25%
            1. Аренда торгового помещения    -----------------------------
            2. Эксплуатационные расходы    -----------------------------
            3. Электричество    -----------------------------
            4. Водоснабжение    -----------------------------
            5. Аренда головного офиса    11.500
            6. Аренда головного склада    -----------------------------
            7.Вывоз мусора    -----------------------------
            ИТОГ:    11.500
            """,
            """
            Прочие расходы:        15%    16.5%
            1.Налоговые платежи     26.964
            2.Банковское обслуживание    6.419
            4.Банковская комиссия 1.6% за эквайринг    26.581
            5.Тайный гость    -----------------------------
            9.Реклама и IT поддержка    65.000 (не iiko)
            ИТОГ:    402.520
            """
        ],
        footerString: """
            ИТОГ всех расходов за месяц:    2.343.392р 37к
            Фактический остаток:    96.628р 63к    20%
                Минус с августа переходит 739.626р 06к
            ИТОГ:    Минус 642.997р 43к
            """
    )

    static var previews: some View {
        NavigationView {
            ParsedReportView(reportContent: reportContent)
                .navigationBarTitleDisplayMode(.inline)
        }
        .previewLayout(.fixed(width: 370, height: 1100))
//        .environment(\.colorScheme, .dark)
    }
}
