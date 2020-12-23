//
//  TextViewModel.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 23.12.2020.
//

import SwiftUI

final class TextViewModel: ObservableObject {
    @Published var text = NSMutableAttributedString()
    @Published var textStyle = UIFont.TextStyle.body
    @Published var highlight = false

    func pasteClipboard() {
        Ory.withHapticsAndAnimation {
            guard let content = UIPasteboard.general.string else { return }
            self.text = NSMutableAttributedString(string: content)
        }
    }
}

