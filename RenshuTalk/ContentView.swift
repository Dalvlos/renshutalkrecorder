//
//  ContentView.swift
//  RenshuTalk
//
//  Created by Dalvlos on 2025/07/03.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = FraseViewModel()

    var body: some View {
        VStack(spacing: 20) {
            InputBarView(viewModel: viewModel)
            FraseListView(viewModel: viewModel)
        }
        .onAppear {
            viewModel.loadFrases()
        }
    }
}
