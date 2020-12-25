//
//  Conversion String+Ext.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 25.12.2020.
//

import Foundation

extension String {

    static let rublesIKopeksPattern = #"\d+(\.\d+)*р( *\d+к)?"#
    static let itemNumberPattern = #"\d+(\.\d{3})*"#
    static let minusPattern = #"[М|м]инус"#

    // MARK: - helpers

    func getNumberAndRemains() -> (Double?, String) {
        var sign: Double = 1
        if self.firstMatch(for: #"[М|м]инус"#) != nil {
            sign = -1
        }

        if let numberString = self.firstMatch(for: String.rublesIKopeksPattern),
           let rubliIKopeiki = numberString.rubliIKopeikiToDouble(),
           let remains = self.replaceFirstMatch(for: String.rublesIKopeksPattern, withString: "") {
            return (sign * rubliIKopeiki, remains)
        } else if let numberString = self.firstMatch(for: String.itemNumberPattern),
                  let double = Double(numberString.replacingOccurrences(of: ".", with: "")),
                  let remains = self.replaceFirstMatch(for: String.itemNumberPattern, withString: "") {
            return (sign * double, remains)
        }

        return (nil, self)
    }

    func getNumberNoRemains() -> Double? {
        var sign: Double = 1
        if self.firstMatch(for: String.minusPattern) != nil {
            sign = -1
        }

        if let numberString = self.firstMatch(for: String.rublesIKopeksPattern),
           let rubliIKopeiki = numberString.rubliIKopeikiToDouble() {
            return sign * rubliIKopeiki
        } else if let numberString = self.firstMatch(for: String.itemNumberPattern),
                  let double = Double(numberString.replacingOccurrences(of: ".", with: "")) {
            return sign * double
        }

        return nil
    }

    // MARK: - Conversion

    func rubliIKopeikiToDouble() -> Double? {
        guard let spacedDelete = self.replaceMatches(for: " *", withString: ""),
              let dotDelete = spacedDelete.replaceMatches(for: #"\."#, withString: ""),
              let kopekDelete = dotDelete.replaceMatches(for: "к", withString: "") else { return nil }

        let components = kopekDelete.split(separator: "р")
        let integerPart = components.first ?? ""
        let integer = Double(integerPart) ?? 0

        let decimal: Double
        if components.count == 2 {
            let decimalPart = components[1]
            decimal = (Double(decimalPart) ?? 0) / 100
        } else {
            decimal = 0
        }

        return integer + decimal
    }

    func percentageStringToDouble() -> Double? {
        guard self.last == "%",
              let percentage = Double(self.dropLast()) else { return nil }
        return percentage / 100
    }

    func extractNumber() -> Double? {
        let itemNumberPattern = #"\d+(\.\d{3})*"#
        if let numberString = self.firstMatch(for: itemNumberPattern),
           let double = Double(numberString.replacingOccurrences(of: ".", with: "")) {
            return double
        }

        return nil
    }

}
