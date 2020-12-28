//
//  ReportStructureView.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 24.12.2020.
//

import SwiftUI

struct ReportStructureView: View {

    @ObservedObject var model: TextViewModel

    @StateObject private var headerModel: ParsedReportHeaderViewModel
    @StateObject private var footerModel: ParsedReportFooterViewModel

    init(model: TextViewModel) {
        self.model = model

        let reportContent = model.reportContent ?? TextViewModel.ReportContent.empty

        let headerModel = ParsedReportHeaderViewModel(headerString: reportContent.headerString)
        _headerModel = StateObject(wrappedValue: headerModel)

        let footerModel = ParsedReportFooterViewModel(footerString: reportContent.footerString)
        _footerModel = StateObject(wrappedValue: footerModel)
    }

    var body: some View {
        if let reportContent = model.reportContent {
            List {
                if model.hasError {
                    Text(model.errorMessage)
                        .font(.headline)
                        .foregroundColor(Color(UIColor.systemRed))
                }

                Section(header: Text("header")) {
                    reportHeaderView(reportContent.headerString)
                }
                Section(header: Text("Groups (\(reportContent.groups.count))")) {
                    reportGroupsView(reportContent.groups)
                }
                Section(header: Text("footer")) {
                    reportFooterView(reportContent.footerString)
                }
            }
            .font(.subheadline)
            .listStyle(GroupedListStyle())
            .navigationTitle("Report Structure")
        } else {
            Text("Error: no Report Structure")
                .foregroundColor(.red)
        }
    }

    private func reportHeaderView(_ header: String) -> some View {
        NavigationLink(destination: ParsedReportHeaderView(model: headerModel)) {
            Text(header)
        }
    }

    private func reportGroupsView(_ groups: [String]) -> some View {
        ForEach(groups, id: \.self) { group in
            NavigationLink(destination: ParsedReportGroupView(groupString: group)) {
                Text(group)
            }
        }
    }

    private func reportFooterView(_ footer: String) -> some View {
        NavigationLink(destination: ParsedReportFooterView(model: footerModel)) {
            Text(footer)
        }
    }
}

struct ReportStructureView_Previews: PreviewProvider {
    static let model = TextViewModel()
    static let testText = """
Название объекта: Саперави Аминьевка
Месяц: сентябрь2020     Оборот:2.440.021    Средний показатель: 81.334

Статья расхода:    Сумма расхода:    План %     Факт %
Основные расходы:        20%    8.95%
1. Аренда торгового помещения     200.000 (за август)
2. Эксплуатационные расходы    -----------------------------
3. Электричество    -----------------------------
4. Водоснабжение    -----------------------------
5. Аренда головного офиса    11.500
6. Аренда головного склада    7.000
7. Вывоз мусора    -----------------------------
ИТОГ:    218.500
Зарплата:        20%    43.4%
1.ФОТ     960.056( за вторую часть августа и первую  часть сентября)
ФОТ Бренд, логистика, бухгалтерия    99.000

ИТОГ:    1.059.056
Фактический приход товара и оплата товара:    946.056р    25%
1. Приход товара по накладным     946.056р (оплаты фактические: 475.228р   52к -переводы; 157.455р 85к-корпоративная карта; 0-наличные из кассы; Итого-632.684р 37к)
2. Предоплаченный товар, но не отраженный в приходе    Студиопак-12.500 (влажные салфетки);
ИТОГ:    645.184р37к
Прочие расходы:        15%    16.5%
1.Налоговые платежи     26.964
2.Банковское обслуживание    6.419
3.Юридическое сопровождение    40.000
4.Банковская комиссия 1.6% за эквайринг    26.581
5.Тайный гость    -----------------------------
6.Обслуживание кассовой программы Айко    16.336
7.Обслуживание хостинга    ----------------------------
8.Обслуживание мобильного приложения    9.200
9.Реклама и IT поддержка    65.000
10.Обслуживание пожарной охраны    -----------------------------
11.Вневедомственная охрана помещения    -----------------------------
12.Интернет    9.000
13.Дезобработка помещения    -----------------------------
14. ----------------------------------    ----------------------------
15.Аренда зарядных устройств и раций    ----------------------------
16. Текущие мелкие расходы     1.600
17. Обслуживание Жироуловителей    -----------------------------
18. Аренда оборудования д/питьевой воды    -----------------------------
19. Ремонт оборудования    -----------------------------
20. Чистка вентиляции    26.250
21. Обслуживание банкетов    15.250
22. Хэдхантер (подбор пероснала)    9.720
23. Аудит кантора (Бухуслуги)    60.000
24. Стол Тенгиз    17.905
25. Стол Игорь    47.090
26. Стол Андрей    9.550
27. Сервис Гуру (система аттестации, за 1 год)    12.655
ИТОГ:    402.520
Расходы на доставку:
1. Курьеры    -----------------------------
2. Агрегаторы    18.132
ИТОГ:    18.132
ИТОГ всех расходов за месяц:    2.343.392р 37к

Фактический остаток:    96.628р 63к    20%
    Минус с августа переходит 739.626р 06к

ИТОГ:    Минус 642.997р 43к

"""

    static var previews: some View {
        model.changeText(to: testText)

        return Group {
            ReportStructureView(model: TextViewModel())
                .previewLayout(.fixed(width: 370, height: 200))
            ReportStructureView(model: model)
        }
    }
}
