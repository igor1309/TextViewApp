//
//  ReportImportView.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 23.12.2020.
//

import SwiftUI

struct ReportImportView: View {

    @Environment(\.colorScheme) private var colorScheme

    @ObservedObject var model: TextViewModel

    @State private var showingFileImporter = true

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {

                NavigationLink(
                    "Report Structure",
                    destination: destinationView(),
                    isActive: $model.showingNextView
                )
                .hidden()

                TextView(attributedText: $model.attributedText, textStyle: $model.textStyle, colorScheme: colorScheme)

                errorMessageView()
            }
            .padding()
            .navigationTitle("Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: toolbar)
            .fileImporter(isPresented: $showingFileImporter, allowedContentTypes: [.plainText], onCompletion: model.handleFileImporter)
        }
    }

    @ViewBuilder
    private func errorMessageView() -> some View {
        if let reportContent = model.reportContent,
           reportContent.hasError {
            Text(reportContent.errorMessage)
                .font(.footnote)
                .foregroundColor(Color(UIColor.systemRed))
                .padding(.horizontal)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color(UIColor.secondarySystemBackground))
                        .shadow(radius: 6)
                )
        }
    }

    @ViewBuilder
    private func destinationView() -> some View {
        if let reportContent = model.reportContent {
            TokenizedReportView(reportContent: reportContent, tokenizationErrorMessage: reportContent.errorMessage)
        } else {
            ReportStructureView(model: model)
        }
    }

    @ToolbarContentBuilder
    private func toolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            HStack(spacing: 0) {
                Button {
                    showingFileImporter = true
                } label: {
                    Image(systemName: "arrow.down.doc")
                        .frame(width: 44, height: 44, alignment: .leading)
                }

                Button {
                    Ory.withHapticsAndAnimation(action: model.pasteClipboard)
                } label: {
                    Image(systemName: "doc.on.clipboard")
                        .frame(width: 44, height: 44, alignment: .leading)
                }

                Button {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                } label: {
                    Image(systemName: "keyboard.chevron.compact.down")
                        .frame(width: 44, height: 44, alignment: .leading)
                }
            }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            Button("Next") {
                Ory.withHapticsAndAnimation {
                    model.showingNextView = true
                }
            }
        }
    }
}

struct ReportImportView_Previews: PreviewProvider {
    static let model = TextViewModel.sample

    static var previews: some View {
        ReportImportView(model: model)
            .previewLayout(.fixed(width: 350, height: 400))
            .environment(\.colorScheme, .light)

        ReportImportView(model: model)
            .previewLayout(.fixed(width: 350, height: 400))
            .environment(\.colorScheme, .dark)
    }
}
