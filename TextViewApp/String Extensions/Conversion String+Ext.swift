//
//  Conversion String+Ext.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 25.12.2020.
//

import Foundation

extension String {

    static let rubliKopeikiPattern = #"\d{1,3}(\.\d{3})*р( \d\d?к)?"#
    static let itemNumberPattern =   #"\d{1,3}(\.\d{3})*"#
    static let kopeikiPatterm = #"((?<=р )\d\d?(?=к))"#
    static let minusPattern = #"(?:[М|м]инус\D*)|-"#

    // MARK: - helpers

    func getNumberAndRemains() -> (Double?, String) {
        var sign: Double = 1
        if self.firstMatch(for: String.minusPattern) != nil {
            sign = -1
        }

        if let numberString = self.firstMatch(for: String.rubliKopeikiPattern) {
            let rubliIKopeiki = numberString.rubliIKopeikiToDouble()
            if let remains = self.replaceFirstMatch(for: String.rubliKopeikiPattern, withString: "") {
                return (sign * rubliIKopeiki, remains)
            }
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

        if let numberString = self.firstMatch(for: String.rubliKopeikiPattern) {
            let rubliIKopeiki = numberString.rubliIKopeikiToDouble()
            return sign * rubliIKopeiki
        } else if let numberString = self.firstMatch(for: String.itemNumberPattern),
                  let double = Double(numberString.replacingOccurrences(of: ".", with: "")) {
            return sign * double
        }

        return nil
    }

    // MARK: - Conversion

    private func rubliIKopeikiToDouble() -> Double {
        guard let integerString = self.firstMatch(for: String.itemNumberPattern),
              let integer = Double(integerString.replaceMatches(for: #"\."#, withString: ""))
        else { return 0 }

        guard let decimalString = self.firstMatch(for: String.kopeikiPatterm),
              let decimal = Double(decimalString)
        else { return integer }

        return integer + decimal / 100
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
