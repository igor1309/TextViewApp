//
//  ReportImportView.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 23.12.2020.
//

import SwiftUI

struct ReportImportView: View {
    @StateObject private var model = TextViewModel()

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                TextView(text: $model.text, textStyle: $model.textStyle)

                Text(model.text.string)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .navigationTitle("Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: toolbar)
        }
    }

    @ToolbarContentBuilder
    private func toolbar() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                model.pasteClipboard()
            } label: {
                Image(systemName: "doc.on.clipboard")
                    .frame(width: 44, height: 44, alignment: .trailing)
            }
        }

        ToolbarItem(placement: .primaryAction) {
            Button {
                Ory.withHapticsAndAnimation {
                    model.highlight.toggle()
                }
            } label: {
                Image(systemName: model.highlight ? "lightbulb.fill" : "lightbulb")
                    .frame(width: 44, height: 44, alignment: .trailing)
            }
        }
    }
}

struct ReportImportView_Previews: PreviewProvider {
    static var previews: some View {
        ReportImportView()
    }
}
