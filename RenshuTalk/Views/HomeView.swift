//
//  HomeView.swift
//  RenshuTalk
//
//  Created by Dalvlos on 2025/10/22.
//
import SwiftUI

struct HomeView: View {
    // 💡 Usa o ViewModel para carregar os dados
    @StateObject private var viewModel = PhraseViewModel()
    
    // Estado para apresentar o menu de seleção
    @State private var isShowingListSelector = false

    var body: some View {
        // Usa o NavigationView para o título, sem a complexidade do NavigationStack
        NavigationView {
            VStack(spacing: 40) {
                Spacer()

                Text("Minhas Gravações")
                    .font(.largeTitle.bold())
                    .padding(.bottom, 20)
                
                // 1. Botão "Criar" chama a folha de seleção
                Button("➕ Gerenciar / Criar Lista") {
                    isShowingListSelector = true
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(12)
                
                // 2. Botão "Acessar" leva à tela principal se uma lista estiver carregada
                // Se o viewModel carregar a lista corretamente no init, este botão pode
                // levar o usuário direto.
                NavigationLink(destination: ContentView()) {
                    Text("▶️ Abrir Última Lista: \(viewModel.listaAtual?.name ?? "Carregando...")")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(viewModel.listaAtual == nil) // Desabilita se não há lista

                Spacer()
            }
            .padding()
            // 💡 Apresenta o menu de listas quando solicitado
            .sheet(isPresented: $isShowingListSelector) {
                // É CRUCIAL passar o mesmo objeto viewModel
                ListSelectionView(viewModel: viewModel)
            }
            // 💡 Remove a barra de navegação principal, mas adiciona o título
            .navigationTitle("Início")
        }
        // CRUCIAL: Passa o ViewModel para a ContentView quando navegamos
        .environmentObject(viewModel)
    }
}
