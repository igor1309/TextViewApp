//
//  ReportContent.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 05.01.2021.
//

import Foundation

public struct ReportContent {
    public var headerString: String
    public var groups: [String]
    public var footerString: String

    public var errorMessage = ""
    public var hasError: Bool { !errorMessage.isEmpty }

    public init(headerString: String, groups: [String], footerString: String, errorMessage: String = "") {
        self.headerString = headerString
        self.groups = groups
        self.footerString = footerString
        self.errorMessage = errorMessage
    }

    public static let empty = ReportContent(headerString: "",
                                     groups: [],
                                     footerString: "")
}
