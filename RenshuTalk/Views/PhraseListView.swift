//
//  FraseListView.swift
//  RenshuTalk
//
//  Created by Dalvlos on 2025/07/12.
//


import SwiftUI

struct PhraseListView: View {
    @ObservedObject var viewModel: PhraseViewModel

    var body: some View {
        List {
            if let lista = viewModel.listaAtual {
                
                // 🚀 MUDANÇA IMPORTANTE:
                // Iteramos sobre os itens, não sobre os índices.
                // Isso requer que 'PhraseItem' seja Identifiable (o que já é, pois tem 'id: UUID')
                ForEach(lista.phrases) { phrase in
                    HStack {
                        // --- Botão de Play/Stop Atualizado ---
                        Button(action: {
                            togglePlayback(for: phrase)
                        }) {
                            // Verifica se ESTA frase está tocando
                            let isPlaying = viewModel.currentPlayingID == phrase.id
                            
                            Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                                .font(.title2)
                                .foregroundColor(isPlaying ? .red : .blue)
                        }
                        .buttonStyle(.plain) // Garante que o clique seja só no ícone

                        Text(phrase.text)
                            .font(.headline)

                        Spacer()
                    }
                }
                // 🚀 MUDANÇA IMPORTANTE:
                // Usamos o modificador .onDelete, que é mais seguro e padrão.
                // Isso nos dá um 'IndexSet' dos itens a serem excluídos.
                .onDelete(perform: deleteItems)
                
            } else {
                Text("Nenhuma lista selecionada")
                    .foregroundColor(.gray)
                    .italic()
            }
        }
    }
    
    /// Função auxiliar para lidar com a exclusão
    private func deleteItems(at offsets: IndexSet) {
        // Agora, precisamos de uma função no ViewModel que aceite 'IndexSet'
        viewModel.deleteFrases(at: offsets)
    }
    
    /// Função auxiliar para play/stop
    private func togglePlayback(for phrase: PhraseItem) {
        if viewModel.currentPlayingID == phrase.id {
            // Se já está tocando, para
            viewModel.stopPlayback()
        } else {
            // Se não, toca (passando o ID para o ViewModel rastrear)
            viewModel.playAudio(named: phrase.audioFileName, id: phrase.id)
        }
    }
}
