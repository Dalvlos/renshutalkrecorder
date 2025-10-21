//
//  FraseListView.swift
//  RenshuTalk
//
//  Created by Dalvlos on 2025/07/12.
//

//
//  FraseListView.swift
//  RenshuTalk
//
//  Alterado para exibir Recording dentro da playlist ativa.
//

import SwiftUI

struct FraseListView: View {
    @ObservedObject var viewModel: FraseViewModel

    var body: some View {
        List {
            if viewModel.activeRecordings.isEmpty {
                Text("Nenhuma gravação nesta lista.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(viewModel.activeRecordings.indices, id: \.self) { index in
                    VStack(alignment: .leading) {
                        Text(viewModel.activeRecordings[index].text)
                            .font(.headline)
                        HStack {
                            Button(action: {
                                viewModel.playAudio(named: viewModel.activeRecordings[index].audioFileName)
                            }) {
                                Image(systemName: "play.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                            Spacer()
                            Text(viewModel.activeRecordings[index].dateCreated, style: .time)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete { offsets in
                    // Ajusta índices ao deletar usando o activeRecordings snapshot
                    if let first = offsets.first {
                        viewModel.deleteRecording(at: first)
                    }
                }
            }
        }
    }
}
