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
    @StateObject private var viewModel = PhraseViewModel()
    @State private var isShowingListSelector = false
    // ❌ 'isMenuOpen' removido (não estava sendo usado)
    // ❌ 'listName' removido (não estava sendo inicializado e não é necessário aqui)
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                
                // --- Área 1: Tela 1:1 (Simplificada) ---
                // O GeometryReader e o ZStack complexos não são necessários.
                // Podemos atingir o mesmo resultado (um quadrado 1:1) assim:
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
                .background(Color.black)
                .cornerRadius(12)
                .shadow(radius: 5)
                .aspectRatio(1, contentMode: .fit) // 👈 Isso força o View a ser 1:1
                
                
                // --- Área 2: Menu acima da lista ---
                HStack(spacing: 20) {
                    // Botão de Gravação (igual, já estava correto)
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
                // Esta View (PhraseListView) também precisará ser atualizada
                // para ler de `viewModel.listaAtual?.phrases`
                PhraseListView(viewModel: viewModel)
            }
            .ignoresSafeArea(.keyboard)
            .navigationTitle("Write and Recorder") // 👈 Recomendo usar o nome da lista aqui
            // .navigationTitle(viewModel.listaAtual?.name ?? "Carregando...")
            .navigationBarTitleDisplayMode(.inline)
            // ❌ Bloco .onAppear REMOVIDO
            // O @StateObject já chama o init() do ViewModel,
            // que por sua vez já chama o loadAllData().
            .onTapGesture {
                UIApplication.shared.hideKeyboard()
            }
        }
    }
    
    // Função que ajusta o tamanho da fonte
    private func fontSize(for text: String) -> CGFloat {
        return 28
    }
    
    // Função que quebra cada linha (lógica mantida)
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
