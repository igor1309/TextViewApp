//
//  ParsedReportGroupView.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 24.12.2020.
//

import SwiftUI

final class ParsedReportGroupViewModel: ObservableObject {
    @Published var group: String

    init(group: String) {
        self.group = group
    }

    var listWithNumbers: [String] {
        let itemFullLineWithDigitsPattern = #"(?m)^[1-9][0-9]?\.[^\d\n]+\d+.*"#
        return group.listMatches(for: itemFullLineWithDigitsPattern)
    }

    enum Token: Hashable {
        case item(String, Double, String?)
    }

    var items: [Token] {
        listWithNumbers.compactMap(transformLineToItem)
    }

    var total: Double {
        items
            .compactMap { token -> Double? in
                if case let .item(_, number, _) = token {
                    return number
                } else {
                    return nil
                }
            }
            .reduce(0, +)
    }

    let itemTitleWithPercentagePattern = #"^[1-9]\d?\.[\D]*\d+(\.\d+)?%[\D]*"#
    let itemTitleWithParenthesesPattern = #"^[1-9][0-9]?\.[^\d\n]+\([^(]*\)[^\d\n]*"#
    let itemTitlePattern = #"^[1-9][0-9]?\.[^\d\n]+"#
    let rublesIKopeksPattern = #"^\d+(\.\d+)*р( *\d+к)?"#
    let itemNumberPattern = #"\d+(\.\d{3})*"#


    private func transformLineToItem(line: String) -> Token? {
        var title: String = ""
        var tail: String = ""
        var number: Double = 0

        let itemTitlePatterns = [itemTitleWithPercentagePattern, itemTitleWithParenthesesPattern, itemTitlePattern]
        line.getHeadAndTail(patterns: itemTitlePatterns) { (headString, tailString) in
            guard let headString = headString,
                  let tailString = tailString else { return }
            title = headString
            tail = tailString
        }

        guard !title.isEmpty && !tail.isEmpty else { return nil }

        tail.getHeadAndTail(patterns: [rublesIKopeksPattern]) { (numberString, tailString) in
            guard let numberString = numberString,
                  let rubliIKopeiki = numberString.rubliIKopeikiToDouble(),
                  let tailString = tailString
            else {
                // MARK: - NOT 'RETURN' HERE!! TRY TO PARSE ANOTHER NUMBER PATTERN
                guard let numberString = tail.listMatches(for: itemNumberPattern).first else { return }
                let cleanNumberString = numberString.replacingOccurrences(of: ".", with: "")
                guard let double = Double(cleanNumberString) else { return }
                number = double

                if let finalTail = tail
                    .replaceMatches(for: itemNumberPattern, withString: "")?
                    .trimmingCharacters(in: .whitespaces) {
                    tail = finalTail
                }

                return
            }
            number = rubliIKopeiki
            tail = tailString
        }

        let comment: String? = tail.isEmpty ? nil : tail

        return Token.item(title, number, comment)
    }
}

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

            Section(
                header: Text("Parsed (\(model.items.count))"),
                footer: footer()
            ) {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(model.items, id: \.self) { token in
                    if case let .item(title, number, comment) = token {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
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
        }
        .font(.subheadline)
        .listStyle(GroupedListStyle())
        .navigationTitle("Parsed Group")
    }

    private func footer() -> some View {
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
        .previewLayout(.fixed(width: 350, height: 900))
    }
}
