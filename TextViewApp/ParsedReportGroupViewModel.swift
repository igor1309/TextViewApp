//
//  ParsedReportGroupViewModel.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 25.12.2020.
//

import SwiftUI
import Combine

final class ParsedReportGroupViewModel: ObservableObject {

    @Published var group: String
    @Published var listWithNumbers: [String]
    @Published var items: [Token]

    private let itemFullLineWithDigitsPattern = #"(?m)^[1-9][0-9]?\.[^\d\n]+\d+.*"#

    init(group: String) {
        self.group = group
        self.listWithNumbers = []
        self.items = []

        // subscribe to group change
        $group
            .removeDuplicates()
            .map {
                $0.listMatches(for: self.itemFullLineWithDigitsPattern)
            }
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.listWithNumbers = $0
            }
            .store(in: &cancellableSet)

        $listWithNumbers
            .removeDuplicates()
            .map {
                $0.compactMap(self.transformLineToItem)
            }
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.items = $0
            }
            .store(in: &cancellableSet)
    }

    private var cancellableSet = Set<AnyCancellable>()

    deinit {
        for cancell in cancellableSet {
            cancell.cancel()
        }
    }

    //    var listWithNumbers: [String] {
    //        let itemFullLineWithDigitsPattern = #"(?m)^[1-9][0-9]?\.[^\d\n]+\d+.*"#
    //        return group.listMatches(for: itemFullLineWithDigitsPattern)
    //    }

    enum Token: Hashable {
        case item(String, Double, String?)
    }

    //    var items: [Token] {
    //        listWithNumbers.compactMap(transformLineToItem)
    //    }

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


