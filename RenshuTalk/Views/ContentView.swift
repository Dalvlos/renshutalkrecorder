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
                            .fill(Color.gray.opacity(0.1))
                            .aspectRatio(1, contentMode: .fit)
                            .cornerRadius(16)
                            .shadow(radius: 3)
                        
                        // Texto digitado diretamente na tela 1:1
                        CenteredTextEditor(text: $viewModel.inputText,
                                                   fontSize: fontSize(for: viewModel.inputText))
                                    .frame(width: geometry.size.width,
                                           height: geometry.size.width,
                                           alignment: .center)
                                    .background(Color.clear)
                    }
                    
                    .frame(height: geometry.size.width) // altura = largura -> 1:1
                    
                }
                .frame(maxHeight: UIScreen.main.bounds.width) // limita a 1:1
                

                }

              
                .padding(.horizontal)
                
                // --- Área 3: Lista de frases ---
            
                FraseListView(viewModel: viewModel)
                PlayAndListView(viewModel: viewModel)
            }
            .ignoresSafeArea(.keyboard)
            .navigationTitle("RenshuTalk")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear
            {
                viewModel.loadFrases()
            }
            .onTapGesture {
                UIApplication.shared.hideKeyboard()
            }
        }
    
    }

    
    // Função que ajusta o tamanho da fonte com base no tamanho do texto
    private func fontSize(for text: String) -> CGFloat {
        switch text.count {
        case 0...50: return 32
        case 51...120: return 24
        case 121...200: return 18
        default: return 14
        }
        
    }



