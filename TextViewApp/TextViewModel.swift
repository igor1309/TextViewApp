//
//  TextViewModel.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 23.12.2020.
//

import SwiftUI
import Combine

final class TextViewModel: ObservableObject {

    @Published var attributedText = NSAttributedString()
    @Published var textStyle = UIFont.TextStyle.subheadline

    @Published var showingNextView: Bool = false
    @Published var reportContent: ReportContent?

    struct ReportContent {
        var headerString: String
        var groups: [String]
        var footerString: String

        static let empty = ReportContent(headerString: "", groups: [], footerString: "")
    }

    @Published var errorMessage = ""
    var hasError: Bool { !errorMessage.isEmpty }

    init() {
        // create subscription to update highlight if text was edited
        $attributedText
            .map { $0.string }
            .delay(for: 0.3, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                if let self = self {
                    self.highlightText(pattern: String.groupPattern)
                    self.splitReportContent()
                }
            }
            .store(in: &cancellableSet)
    }

    private var cancellableSet = Set<AnyCancellable>()

    deinit {
        for cancell in cancellableSet {
            cancell.cancel()
        }
    }

    func splitReportContent() {
        // using regex extract array of text for groups
        // replace extracted text with special delimiter
        // use delimiter to seperate header from footer

        let groups = attributedText.string
            .listMatches(for: String.groupPattern)

        let delimiter = "#####"
        var header = ""
        var footer = ""

        let copy = attributedText.string
            .replaceMatches(for: String.groupPattern, withString: delimiter)
        let components = copy
            .components(separatedBy: delimiter)
            .compactMap { $0 == "\n" ? nil : $0 }
            .compactMap { $0.isEmpty ? nil : $0 }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        header = components.first ?? "error getting header"
        footer = components.last ?? "error getting footer"

        switch components.count {
            case 2:      errorMessage = ""
            case 3...20: errorMessage = "Error: some group(s) not parsed"
            default:     errorMessage = "Error: unknown parsing error"
        }

        reportContent = ReportContent(headerString: header, groups: groups, footerString: footer)
    }

    func highlightText(pattern: String) {
        // swiftlint:disable:next force_cast
        let attributedTextCopy = attributedText.mutableCopy() as! NSMutableAttributedString
        let attributedTextRange = NSRange(location: 0, length: attributedTextCopy.length)
        attributedTextCopy.removeAttribute(NSAttributedString.Key.backgroundColor, range: attributedTextRange)

        let range = NSRange(attributedTextCopy.string.startIndex..., in: attributedTextCopy.string)
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let matches = regex.matches(in: attributedTextCopy.string, options: [], range: range)
            for match in matches {
                let matchRange = match.range
                attributedTextCopy.addAttribute(
                    NSAttributedString.Key.backgroundColor,
                    value: UIColor.yellow.withAlphaComponent(0.2),
                    range: matchRange
                )
            }
            // swiftlint:disable:next force_cast
            self.attributedText = attributedTextCopy.copy() as! NSAttributedString
        }
    }

    func pasteClipboard() {
        guard let content = UIPasteboard.general.string else { return }
        changeText(to: content)
    }

    func changeText(to content: String) {
        // make some file cleaning & fixes
        let cleanContent = content
            .clearWhitespacesAndNewlines()
            .replaceMatches(for: "\nФОТ Бренд, логистика, бухгалтерия",
                            withString: "\n2. ФОТ Бренд, логистика, бухгалтерия")

        self.attributedText = NSAttributedString(string: cleanContent)
        self.highlightText(pattern: String.groupPattern)
        self.splitReportContent()
        self.showingNextView = true
    }

    func handleFileImporter(result: Result<URL, Error>) {
        switch result {
            case let .success(url):
                if url.startAccessingSecurityScopedResource(),
                   let content = try? String(contentsOf: url) {
                    defer { url.stopAccessingSecurityScopedResource() }
                    changeText(to: content)
                } else {
                    changeText(to: "Error reading contents of \(url.absoluteString)")
                }
            case let .failure(error):
                changeText(to: error.localizedDescription)
        }
    }
}

extension TextViewModel {
    static let sample: TextViewModel = {
        let model = TextViewModel()
        model.changeText(to: TextViewModel.testText())
        return model
    }()

    // swiftlint:disable:next function_body_length
    static func testText() -> String {
        // swiftlint:disable line_length
        """
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
        // swiftlint:enable line_length
    }
}
