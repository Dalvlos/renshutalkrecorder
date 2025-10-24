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
        List(viewModel.frases.indices, id: \.self) { index in
            HStack {
                
                Button(action: {
                    viewModel.playAudio(named: viewModel.frases[index].audioFileName)
                }) {
                    Image(systemName: "play.fill") 
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                Text(viewModel.frases[index].texto)
                    .font(.headline)
                    
                
                Spacer()

            }

            .swipeActions {
                Button(role: .destructive) {
                    viewModel.deleteFrase(at: index)
                } label: {
                    Label("Deletar", systemImage: "trash")
                }
            }
        }
    }
}
