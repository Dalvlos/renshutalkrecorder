//
//  ContentView.swift (REFATORADO E CORRIGIDO)
//  RenshuTalk
//
import SwiftUI


struct ContentView: View {
    
    @EnvironmentObject var viewModel: PhraseViewModel
    @State private var isShowingListSelector = false
    
    var body: some View {
        NavigationView {
            
            VStack(spacing: 16) {
                
                
                CenteredTextEditor(
                    text: $viewModel.inputText,
                    fontSize: fontSize(for: viewModel.inputText)
                )
                .onChange(of: viewModel.inputText) { oldValue, newValue in
                    let maxCharsPerLine = 25
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
                .aspectRatio(1, contentMode: .fit)
                
                
                Button(action: {
                    viewModel.toggleRecording()
                }) {
                    Image(systemName: viewModel.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(viewModel.isRecording ? .red : .blue)
                        .frame(width: 60, height: 60)
                }
               
                .disabled(viewModel.inputText.trimmingCharacters(in: .whitespaces).isEmpty && !viewModel.isRecording)
                
                
                PhraseListView()
            }
            
            .padding(.horizontal)
            .animation(.easeInOut(duration: 0.3), value: viewModel.inputText)
            .ignoresSafeArea(.keyboard)
            .navigationTitle(viewModel.listaAtual?.name ?? "Nova Lista")
            .navigationBarTitleDisplayMode(.inline)
            
           
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { isShowingListSelector = true }
                    label: { Image(systemName: "list.bullet.rectangle.fill") }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.playAll() }) {
                        Label("Tocar Tudo", systemImage: "speaker.wave.3.fill")
                    }
                    .disabled(viewModel.listaAtual?.phrases.isEmpty ?? true)
                }
            }
            .sheet(isPresented: $isShowingListSelector) {
                ListSelectionView()
            }
            .onTapGesture {
                
                hideKeyboard()
            }
            
        
            .onChange(of: viewModel.isRecording) { oldValue, isRecording in
                if isRecording {
                    hideKeyboard()
                }
            }
        }
    }
    
    

    // 1. Funções de Layout
    private func fontSize(for text: String) -> CGFloat {
        return 25
    }
    
    private func wrapLines(_ text: String, maxCharsPerLine: Int) -> String {
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        var wrappedLines: [String] = []
        
        for line in lines {
            var current = line
            while current.count > maxCharsPerLine {
                let splitIndex = current.index(current.startIndex, offsetBy: maxCharsPerLine)
                let chunk = String(current[..<splitIndex])
                wrappedLines.append(chunk)
                current = String(current[splitIndex...])
            }
            wrappedLines.append(current)
        }
        return wrappedLines.joined(separator: "\n")
    }
}

