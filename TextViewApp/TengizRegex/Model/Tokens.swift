//
//  Tokens.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 29.12.2020.
//

import Foundation

public enum Tokens {

    public enum HeaderToken: Hashable {
        case company(String)
        case month(String)
        case headerItem(String, Double)
    }

    public enum GroupToken: Hashable {
        case item(String, Double, String?)
        case header(String, Double?, Double?)
        case footer(String, Double?)
        case empty
    }

    public enum FooterToken: Hashable {
        case total(String, Double)
        case expensesTotal(String, Double)
        case openingBalance(String, Double)
        case balance(String, Double, Double)
        case tbd(String)
        case error
    }

}
