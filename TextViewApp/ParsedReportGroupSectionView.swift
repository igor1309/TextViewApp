//
//  ParsedReportGroupSectionView.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 28.12.2020.
//

import SwiftUI

#warning("lots of partially repeating code below, see ParsedReportGroupView")
struct ParsedReportGroupSectionView: View {

    @StateObject private var model: ParsedReportGroupViewModel

    init(groupString: String) {
        _model = StateObject(wrappedValue: ParsedReportGroupViewModel(groupString: groupString))
    }

    var body: some View {
        Section(
            header: sectionHeaderView(),
            footer: sectionFooterView()
        ) {
            if model.hasError {
                Text(model.errorMessage)
                    .font(.headline)
                    .foregroundColor(Color(UIColor.systemRed))
            }

            ForEach(model.items, id: \.self, content: tokenView)

            if model.isTotalsMatch {
                groupTotal()
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Group Total".uppercased())
                        Spacer()
                        Text("\(model.itemsTotal, specifier: "%.2f")")
                            .foregroundColor(Color(UIColor.systemRed))
                    }

                    groupTotal()
                }
                .padding(.vertical, 3)
            }
        }
    }

    @ViewBuilder
    private func tokenView(token: ParsedReportGroupViewModel.Token) -> some View {
        if case let .item(title, number, comment) = token {
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
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

    @ViewBuilder
    private func groupTotal() -> some View {
        if case let .footer(title, total) = model.groupFooter {
            HStack(alignment: .firstTextBaseline) {
                Text(title)

                Spacer()

                if let total = total {
                    Text("\(total, specifier: "%.2f")")
                } else {
                    Text("no total")
                        .foregroundColor(Color(UIColor.systemRed))
                }
            }
        }
    }

    private func sectionHeaderView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if case let .header(title, plan, fact) = model.groupHeader {
                HStack(alignment: .firstTextBaseline) {
                    Text(title)

                    Spacer()

                    if let plan = plan {
                        Text("\(plan * 100, specifier: "%.2f%%")")
                    } else {
                        Text("no plan")
                            .foregroundColor(Color(UIColor.systemRed))
                    }

                    if let fact = fact {
                        Text("\(fact * 100, specifier: "%.2f%%")")
                    } else {
                        Text("no fact")
                            .foregroundColor(Color(UIColor.systemRed))
                    }
                }
            }
        }
        .padding(.vertical, 3)
    }

    private func sectionFooterView() -> some View {
        NavigationLink(
            destination: ParsedReportGroupView(groupString: model.groupString)
        ) {
            Text("Compare to source")
        }
    }
}

struct ParsedReportGroupSectionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                List {
                    ParsedReportGroupSectionView(groupString: """
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
            """)
                }
                .font(.subheadline)
                .listStyle(GroupedListStyle())
                .navigationBarTitleDisplayMode(.inline)
            }
            .previewLayout(.fixed(width: 370, height: 650))

            NavigationView {
                List {
                    ParsedReportGroupSectionView(groupString: """
            Прочие расходы:        15%    16.5%
            1.Налоговые платежи     26.964
            2.Банковское обслуживание    6.419
            3.Юридическое сопровождение    40.000
            ИТОГ:    73.383
            """)
                }
                .font(.subheadline)
                .listStyle(GroupedListStyle())
                .navigationBarTitleDisplayMode(.inline)
            }
            .previewLayout(.fixed(width: 370, height: 400))
        }
        .environment(\.colorScheme, .dark)
    }
}
