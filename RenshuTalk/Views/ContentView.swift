//
//  ContentView.swift
//  RenshuTalk
//
//  Created by Dalvlos on 2025/07/03.
//


import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = FraseViewModel()
    @State private var isMenuOpen = false // Estado para mostrar menu lateral (opcional)

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                InputBarView(viewModel: viewModel)
                FraseListView(viewModel: viewModel)
            }
            .navigationTitle("RenshuTalk")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        isMenuOpen.toggle()
                        // Aqui você pode abrir um menu lateral, sheet, ou qualquer ação desejada
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .imageScale(.large)
                    }
                }
            }
            .onAppear {
                viewModel.loadFrases()
            }
            // Exemplo de Sheet para menu (opcional)
            .sheet(isPresented: $isMenuOpen) {
                VStack {
                    Text("Menu")
                        .font(.headline)
                    // Adicione opções do menu aqui
                    Button("Fechar") {
                        isMenuOpen = false
                    }
                }
                .padding()
            }
        }
    }
}
