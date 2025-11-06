//
//  ContentView.swift (REFATORADO E CORRIGIDO)
//  RenshuTalk
//
import SwiftUI


struct ContentView: View {
    @EnvironmentObject var viewModel: PhraseViewModel
    @State private var isShowingListSelector = false
    @FocusState private var isTextFieldFocused: Bool

    private var isPlaybackActive: Bool {
        // Verifica se currentPlayingID está definido, indicando que o player está ativo
        return viewModel.currentPlayingID != nil
    }
    


    var body: some View {
       
        NavigationView {
            
            VStack(spacing: 20) {
                
               
                    ZStack(){
                        CenteredTextEditor(
                            text: $viewModel.inputText,
                            fontSize: fontSize(for: viewModel.inputText)
                        )
                        .transaction { transaction in
                            transaction.animation = nil
                        }
                        .focused($isTextFieldFocused)
                        .onChange(of: viewModel.inputText) { oldValue, newValue in
                            let maxCharsPerLine = 30
                            guard newValue.count >= oldValue.count else { return }
                            let formatted = wrapLines(newValue, maxCharsPerLine: maxCharsPerLine)
                            
                            if formatted != newValue {
                                if oldValue != formatted {
                                    viewModel.inputText = formatted
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 375, maxHeight: 375)
                        .background(Color.black)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.5), lineWidth: 2)
                        )
                        .shadow(radius: 5)
                        .clipped()
                    }
                
                
                
                Button(action: {
                    
                    viewModel.toggleRecording()
                    
                }) {
                    Image(systemName: viewModel.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(viewModel.isRecording ? .red : .blue)
                        .frame(width: 55, height: 55)
                        .scaleEffect(viewModel.isRecording ? 1.2 : 1.0)
                }
                
                
                .disabled(viewModel.inputText.trimmingCharacters(in: .whitespaces).isEmpty && !viewModel.isRecording)
                
                
                PhraseListView()
                    .environmentObject(viewModel)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal)
            .ignoresSafeArea(.keyboard)
            .navigationTitle(viewModel.listaAtual?.name ?? "New List")
            .navigationBarTitleDisplayMode(.inline)
            
            
            .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button { isShowingListSelector = true }
                            label: { Image(systemName: "list.bullet.rectangle.fill") }
                        }
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                            
                            // 2. MODIFICAR O BOTÃO DE PLAY/STOP
                            Button(action: {
                                if isPlaybackActive {
                                    viewModel.stopPlayback()
                                } else {
                                    viewModel.playAll()
                                }
                            }) {
                                Label(isPlaybackActive ? "Stop" : "Tocar Tudo", systemImage: isPlaybackActive ? "stop.fill" : "play.fill")
                            }
                            // Desabilita se a lista estiver vazia E o playback não estiver ativo
                            .disabled((viewModel.listaAtual?.phrases.isEmpty ?? true) && !isPlaybackActive)
                        }
                    }
            .sheet(isPresented: $isShowingListSelector) {
                ListSelectionView()
                    .environmentObject(viewModel)   
            }
            .onTapGesture {
                hideKeyboard()
                isTextFieldFocused = false
            }
            
        }
        
       
        
        .onChange(of: viewModel.isRecording) { oldValue, isRecording in
            if isRecording {
                hideKeyboard()
            }
        }
    }
}
    // 1. Funções de Layout
// 1. Funções de Layout
private func fontSize(for text: String) -> CGFloat {
    let baseSize: CGFloat = 25
    let length = text.count
    
    switch length {
    case 0...50: return baseSize
    case 51...100: return baseSize * 0.9
    case 101...200: return baseSize * 0.8
    default: return baseSize * 0.7
    }
} 

private func wrapLines(_ text: String, maxCharsPerLine: Int) -> String {
    let lines = text.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
    var wrappedLines: [String] = []
    
    for line in lines {
        var current = line
        
        while current.count > maxCharsPerLine {
            // Procura o último espaço antes do limite
            let endIndex = current.index(current.startIndex, offsetBy: maxCharsPerLine)
            var breakIndex = current[..<endIndex].lastIndex(of: " ") ?? endIndex
            
            // Se não encontrar espaço, força a quebra (para não travar loop)
            if breakIndex == current.startIndex {
                breakIndex = endIndex
            }
            
            let chunk = String(current[..<breakIndex]).trimmingCharacters(in: .whitespaces)
            wrappedLines.append(chunk)
            
            // Pula o espaço e continua
            let nextIndex = current.index(after: breakIndex)
            current = String(current[nextIndex...]).trimmingCharacters(in: .whitespaces)
        }
        
        wrappedLines.append(current)
    }
    
    return wrappedLines.joined(separator: "\n")
}


private func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    
}
