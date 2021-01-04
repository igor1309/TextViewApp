//
//  TokenizedReportGroupView.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 24.12.2020.
//

import SwiftUI
import Combine

struct TokenizedReportGroupView: View {

    let model: TokenizedReportGroupModel

    var body: some View {
        List {
            #warning("add errors or calc issues here")
            if model.hasError {
                Text(model.errorMessage)
                    .font(.headline)
                    .foregroundColor(Color(UIColor.systemRed))
            }

            Section(header: Text("Original Text")) {
                Text(model.groupString)
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }

            Section(header: Text("Group header")) {
                headerView()
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
                header: Text("Tokenized rows (\(model.items.count))"),
                footer: itemsSectionFooterView()
            ) {
                // VStack(alignment: .leading, spacing: 8) {
                ForEach(model.items, id: \.self, content: tokenView)
                // }
                // .padding(.vertical, 3)
            }

            Section(header: Text("Group footer")) {
                footerView()
            }
        }
        .font(.subheadline)
        .listStyle(GroupedListStyle())
        .navigationTitle("Tokenized Group")
    }

    private func headerView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(model.groupHeaderString)
                .foregroundColor(.secondary)
                .font(.footnote)

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

    @ViewBuilder
    private func tokenView(token: Tokens.GroupToken) -> some View {
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

    private func footerView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(model.groupFooterString)
                .foregroundColor(.secondary)
                .font(.footnote)

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
        .padding(.vertical, 3)
    }

    private func itemsSectionFooterView() -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Group Total".uppercased())
                .font(.subheadline)
            Spacer()
            Text("\(model.itemsTotal, specifier: "%.2f")")
                .font(.subheadline)
                .if(!model.isTotalsMatch) {
                    $0.foregroundColor(Color(UIColor.systemRed))
                }
        }
        .foregroundColor(.primary)
    }
}
struct TokenizedReportGroupView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                TokenizedReportGroupView(model: TokenizedReportGroupModel.sample)
            }
            .previewLayout(.fixed(width: 350, height: 1500))

            NavigationView {
                TokenizedReportGroupView(model: TokenizedReportGroupModel.sample2)
            }
            .previewLayout(.fixed(width: 350, height: 850))
        }
        .font(.subheadline)
        .listStyle(GroupedListStyle())
        .navigationBarTitleDisplayMode(.inline)
    }
}
