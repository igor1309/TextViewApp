//
//  ReportImportView.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 23.12.2020.
//

import SwiftUI

struct ReportImportView: View {

    @Environment(\.colorScheme) private var colorScheme

    @StateObject private var model = TextViewModel()

    @State private var showingFileImporter = true

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {

                NavigationLink(
                    "Report Structure",
                    destination: destination(),
                    isActive: $model.showingNextView
                )
                .hidden()

                TextView(attributedText: $model.attributedText, textStyle: $model.textStyle, colorScheme: colorScheme)

                 if model.hasError {
                    Text(model.errorMessage)
                        .font(.footnote)
                        .foregroundColor(Color(UIColor.systemRed))
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color(UIColor.secondarySystemBackground))
                                .shadow(radius: 6)
                        )
                 }
            }
            .padding()
            .navigationTitle("Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: toolbar)
            // .onAppear(perform: testText)
            .fileImporter(isPresented: $showingFileImporter, allowedContentTypes: [.plainText], onCompletion: handleFileImporter)

        }
    }

    @ViewBuilder
    private func destination() -> some View {
        if let reportContent = model.reportContent {
            ParsedReportView(reportContent: reportContent)
        } else {
            ReportStructureView(model: model)
        }
    }

    private func handleFileImporter(result: Result<URL, Error>) {
        switch result {
            case let .success(url):
                if url.startAccessingSecurityScopedResource(),
                   let content = try? String(contentsOf: url) {
                    defer { url.stopAccessingSecurityScopedResource() }
                    model.changeText(to: content)
                } else {
                    model.changeText(to: "Error reading contents of \(url.absoluteString)")
                }
            case let .failure(error):
                model.changeText(to: error.localizedDescription)
        }
    }

    @ToolbarContentBuilder
    private func toolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            HStack(spacing: 0) {
                Button {
                    showingFileImporter = true
                } label: {
                    Image(systemName: "arrow.down.doc")
                        .frame(width: 44, height: 44, alignment: .leading)
                }

                Button {
                    Ory.withHapticsAndAnimation(action: model.pasteClipboard)
                } label: {
                    Image(systemName: "doc.on.clipboard")
                        .frame(width: 44, height: 44, alignment: .leading)
                }

                Button {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                } label: {
                    Image(systemName: "keyboard.chevron.compact.down")
                        .frame(width: 44, height: 44, alignment: .leading)
                }
            }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            Button("Next") {
                // Ory.withHapticsAndAnimation(action: model.splitReportContent)
                Ory.withHapticsAndAnimation {
                    model.showingNextView = true
                }
            }
        }
    }

    // swiftlint:disable function_body_length
    // swiftlint:disable line_length
    private func testText() {
        let test = """
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

        UIPasteboard.general.string = test
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: model.pasteClipboard)

        // model.attributedText = NSAttributedString(string: test)
    }
}

struct ReportImportView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ReportImportView()
                .previewLayout(.fixed(width: 350, height: 400))
                .environment(\.colorScheme, .light)

            ReportImportView()
                .previewLayout(.fixed(width: 350, height: 400))
                .environment(\.colorScheme, .dark)
        }
    }
}
