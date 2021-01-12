//
//  sameAs+Ext.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 06.01.2021.
//

import Foundation

extension String {
    /// Compares two strings
    /// - Parameter other: String to compare to
    /// - Returns: true if two string are equal up to whitespaces
    func sameAs(_ other: String) -> Bool {
        self.replaceMatches(for: #"\s+"#, withString: " ") ==
            other.replaceMatches(for: #"\s+"#, withString: " ")
    }
}

extension Collection where Element == String {
    func sameAs<OtherCollection>(_ other: OtherCollection) -> Bool where OtherCollection: Collection, Self.Element == OtherCollection.Element {
        guard count == other.count else { return false }
        return zip(self, other).reduce(true, { $0 && $1.0.sameAs($1.1) })
    }
}

extension ReportContent {
    // equal up to whitespaces
    /// Compares two ReportContents
    /// - Parameter other: ReportContent
    /// - Returns: true if all components (properties) of ReportContents are "the same" (using sameAs(:) func)
    public func sameAs(_ other: ReportContent) -> Bool {
        return headerString.sameAs(other.headerString)
            && groups.sameAs(other.groups)
            && footerString.sameAs(other.footerString)
    }
}

