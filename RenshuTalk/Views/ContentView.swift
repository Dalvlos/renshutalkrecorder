//
//  ContentView.swift
//  RenshuTalk
//
//  Created by Dalvlos on 2025/07/03.
//

import SwiftUI

extension UIApplication {
    func hideKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ContentView: View {
    @StateObject private var viewModel = FraseViewModel()
    @State private var isMenuOpen = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                
                // --- Área 1: Tela 1:1 estilo Instagram ---
                GeometryReader { geometry in
                    ZStack {
                        Rectangle()
                            .fill(Color.black.opacity(0.1))
                            .aspectRatio(1, contentMode: .fit)
                            .cornerRadius(16)
                            .shadow(radius: 3)
                        
                        CenteredTextEditor(
                            text: $viewModel.inputText,
                            fontSize: fontSize(for: viewModel.inputText)
                        )
                        .onChange(of: viewModel.inputText) { oldValue, newValue in
                            let maxCharsPerLine = 28
                            let formatted = wrapLines(newValue, maxCharsPerLine: maxCharsPerLine)
                            
                            
                            if formatted != newValue {
                                DispatchQueue.main.async {
                                    viewModel.inputText = formatted
                                }
                            }
                        }
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.width,
                            alignment: .center
                        )
                        .background(Color.black)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        
                    }
                    .frame(height: geometry.size.width)
                }
                .frame(maxHeight: UIScreen.main.bounds.width)
                
                // --- Área 2: Menu acima da lista ---
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
                
                // --- Área 3: Lista de frases ---
                FraseListView(viewModel: viewModel)
            }
            .ignoresSafeArea(.keyboard)
            .navigationTitle("Write and Recorder")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.loadFrases()
            }
            .onTapGesture {
                UIApplication.shared.hideKeyboard()
            }
        }
    }
    
    // Função que ajusta o tamanho da fonte
    private func fontSize(for text: String) -> CGFloat {
        return 28
    }
    
    // Função que quebra cada linha em pedaços de tamanho máximo
    private func wrapLines(_ text: String, maxCharsPerLine: Int) -> String {
        // Preserva linhas existentes
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        var wrappedLines: [String] = []
        
        for line in lines {
            var current = line
            // Quebra linhas maiores que maxCharsPerLine
            while current.count > maxCharsPerLine {
                let splitIndex = current.index(current.startIndex, offsetBy: maxCharsPerLine)
                let chunk = String(current[..<splitIndex])
                wrappedLines.append(chunk)
                current = String(current[splitIndex...])
            }
            // Adiciona o que restou da linha (pode ser vazio)
            wrappedLines.append(current)
        }
        
        return wrappedLines.joined(separator: "\n")
    }
}
