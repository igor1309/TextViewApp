//
//  ContentView.swift
//  TextViewApp
//
//  Created by Igor Malyarov on 23.12.2020.
//

import SwiftUI

struct ContentView: View {

    @StateObject private var model = TextViewModel()

    var body: some View {
        ReportImportView(model: model)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
