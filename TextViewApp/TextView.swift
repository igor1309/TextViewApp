//
//  TextView.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 23.12.2020.
//

import SwiftUI

struct TextView: UIViewRepresentable {

    @Binding var text: NSMutableAttributedString
    @Binding var textStyle: UIFont.TextStyle

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()

        textView.font = UIFont.preferredFont(forTextStyle: textStyle)
        textView.autocapitalizationType = .sentences
        textView.isSelectable = true
        textView.isUserInteractionEnabled = true

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = text
        uiView.font = UIFont.preferredFont(forTextStyle: textStyle)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator($text)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<NSMutableAttributedString>

        init(_ text: Binding<NSMutableAttributedString>) {
            self.text = text
        }

        func textViewDidChange(_ textView: UITextView) {
            self.text.wrappedValue = NSMutableAttributedString(attributedString: textView.attributedText)
        }
    }
}
