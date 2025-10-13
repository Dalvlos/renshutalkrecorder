//
//  FraseListView.swift
//  RenshuTalk
//
//  Created by Dalvlos on 2025/07/12.
//


import SwiftUI

struct FraseListView: View {
    @ObservedObject var viewModel: FraseViewModel

    var body: some View {
        List(viewModel.frases.indices, id: \.self) { index in
            VStack(alignment: .leading) {
                Text(viewModel.frases[index].texto)
                    .font(.headline)
                Button(action: {
                    viewModel.playAudio(named: viewModel.frases[index].audioFileName)
                }) {
                    Image(systemName: "play.fill") 
                        .font(.title2)
                        .foregroundColor(.blue)
                }

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
