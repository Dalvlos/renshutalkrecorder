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
            TextField("Digite uma frase...", text: $viewModel.inputText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            HStack(spacing: 20) {
                Button(action: {
                    viewModel.toggleRecording()
                }) {
                    Label(
                        viewModel.isRecording ? "Parar gravação" : "Gravar áudio",
                        systemImage: viewModel.isRecording ? "stop.circle.fill" : "mic.circle.fill"
                    )
                }
                .buttonStyle(.bordered)
                .tint(viewModel.isRecording ? .red : .blue)

                Button(action: {
                    viewModel.salvarFrase()
                }) {
                    Label("Salvar frase", systemImage: "square.and.arrow.down")
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
            .padding(.horizontal)
        }
    }
}
