//
//  ParsedReportGroupViewModel.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 25.12.2020.
//

import SwiftUI

final class ParsedReportGroupViewModel: ObservableObject {

    @Published var groupHeaderString: String = ""
    @Published var groupHeader: Token = .empty
    @Published var listWithNumbers: [String]
    @Published var items: [Token] = []
    @Published var groupFooterString: String = ""
    @Published var groupFooter: Token = .empty

    let groupString: String

    var errorMessage: String {
        errorMessages.joined(separator: ", ")
    }
    var errorMessages: [String] {
        var messages = [String]()

        if groupHeaderString == "header error" {
            messages.append("header error")
        }
        if groupFooterString == "footer error" {
            messages.append("footer error")
        }
        if !isTotalsMatch {
            messages.append("totals don't match")
        }

        return messages
    }
    var hasError: Bool { !errorMessage.isEmpty }

    init(groupString: String) {
        self.groupString = groupString

        self.listWithNumbers = groupString.listMatches(for: String.itemFullLineWithDigitsPattern)
        self.items = listWithNumbers.compactMap { $0.transformLineToItem() }

        let components = groupString.components(separatedBy: "\n")
        self.groupHeaderString = components.first ?? "header error"
        self.groupFooterString = components.last ?? "footer error"

        self.groupHeader = groupHeaderString.getGroupHeader() ?? .empty
        self.groupFooter = groupFooterString.getGroupFooter() ?? .empty
    }

    enum Token: Hashable {
        case item(String, Double, String?)
        case header(String, Double?, Double?)
        case footer(String, Double?)
        case empty
    }

    var itemsTotal: Double {
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

    var isTotalsMatch: Bool {
        if case let .footer(_, number) = groupFooter {
            return itemsTotal == number
        }
        return false
    }

}
