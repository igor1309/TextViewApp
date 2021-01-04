//
//  TokenizedReportGroupModel.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 29.12.2020.
//

import Foundation
import TengizRegex

struct TokenizedReportGroupModel: Hashable {

    var groupHeaderString: String = ""
    var groupHeader: Tokens.GroupToken = .empty
    var listWithNumbers: [String]
    var items: [Tokens.GroupToken] = []
    var groupFooterString: String = ""
    var groupFooter: Tokens.GroupToken = .empty

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
        return difference == 0
//        if case let .footer(_, number) = groupFooter {
//            return itemsTotal == number
//        }
//        return false
    }

    var difference: Double? {
        if case let .footer(_, number) = groupFooter,
           let numberValue = number {
            return itemsTotal - numberValue
        }
        return nil
    }
}
