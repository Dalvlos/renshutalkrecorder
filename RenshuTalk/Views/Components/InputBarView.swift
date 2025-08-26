//
//  InputBarView.swift
//  RenshuTalk
//
//  Created by Dalvlos on 2025/07/12.
//


import SwiftUI

struct InputBarView: View {
    @ObservedObject var viewModel: FraseViewModel

    var body: some View {
        VStack {
            TextField("Write a phrase...", text: $viewModel.inputText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            HStack(spacing: 20) {
                // Botão de Gravação
                Button(action: {
                    viewModel.toggleRecording()
                }) {
                    Label(
                        viewModel.isRecording ? "Stop" : "REC",
                        systemImage: viewModel.isRecording ? "stop.circle.fill" : "mic.circle.fill"
                    )
                }
                .buttonStyle(.bordered)
                .tint(viewModel.isRecording ? .red : .blue)
                .disabled(viewModel.inputText.trimmingCharacters(in: .whitespaces).isEmpty)

            }
            .padding(.horizontal)
        }
    }
}
