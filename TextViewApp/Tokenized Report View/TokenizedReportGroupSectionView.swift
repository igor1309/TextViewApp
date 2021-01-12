//
//  TokenizedReportGroupSectionView.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 28.12.2020.
//

import SwiftUI

#warning("lots of partially repeating code below, see TokenizedReportGroupView")
struct TokenizedReportGroupSectionView: View {

    //    @StateObject private var model: TokenizedReportGroupViewModel
    //
    //    init(groupString: String) {
    //        _model = StateObject(wrappedValue: TokenizedReportGroupViewModel(groupString: groupString))
    //    }

    let model: TokenizedReportBodyModel

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
                groupTotalView()
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Group Total".uppercased())
                        Spacer()
                        Text("\(model.itemsTotal, specifier: "%.2f")")
                            .foregroundColor(Color(UIColor.systemRed))
                    }

                    groupTotalView()

                    if let difference = model.difference {
                        HStack(alignment: .firstTextBaseline) {
                            Text("Difference")
                            Spacer()
                            Text("\(difference, specifier: "%.2f")")
                        }
                        .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 3)
            }
        }
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

    @ViewBuilder
    private func groupTotalView() -> some View {
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
            destination: TokenizedReportGroupView(model: model)
        ) {
            Text("Compare to source")
        }
    }
}

struct TokenizedReportGroupSectionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                List {
                    TokenizedReportGroupSectionView(model: TokenizedReportBodyModel.sample)
                }
                .font(.subheadline)
                .listStyle(GroupedListStyle())
                .navigationBarTitleDisplayMode(.inline)
            }
            .previewLayout(.fixed(width: 370, height: 720))

            NavigationView {
                List {
                    TokenizedReportGroupSectionView(model: TokenizedReportBodyModel.sample2)
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
