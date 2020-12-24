//
//  TextView.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 23.12.2020.
//

import SwiftUI

struct TextView: UIViewRepresentable {

    @Binding var attributedText: NSAttributedString
    @Binding var textStyle: UIFont.TextStyle

    let colorScheme: ColorScheme

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()

        textView.font = UIFont.preferredFont(forTextStyle: textStyle)
        textView.autocapitalizationType = .sentences
        textView.isSelectable = true
        textView.isEditable = true
        textView.isUserInteractionEnabled = true

        textView.delegate = context.coordinator

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = attributedText

        uiView.font = UIFont.preferredFont(forTextStyle: textStyle)

        switch colorScheme {
            case .dark:
                uiView.textColor = .white
                uiView.backgroundColor = .clear

            default: break
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator($attributedText)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<NSAttributedString>

        init(_ text: Binding<NSAttributedString>) {
            self.text = text
        }

        func textViewDidChange(_ textView: UITextView) {
            self.text.wrappedValue = NSAttributedString(attributedString: textView.attributedText)
        }
    }
}
