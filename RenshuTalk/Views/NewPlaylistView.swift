//
//  NewPlaylistView.swift
//  RenshuTalk
//
//  Created by Dalvlos on 2025/10/21.
//

//
//  NewPlaylistView.swift
//  RenshuTalk
//
//  Tela simples para criar nova playlist.
//

import SwiftUI

struct NewPlaylistView: View {
    @ObservedObject var viewModel: FraseViewModel
    @Binding var isPresented: Bool
    @State private var playlistName: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Nome da nova lista")) {
                    TextField("Ex: Lista 1", text: $playlistName)
                }

                Section {
                    Button(action: {
                        let name = playlistName.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !name.isEmpty else { return }
                        viewModel.createPlaylist(name: name)
                        isPresented = false
                    }) {
                        Text("Criar")
                    }
                    .disabled(playlistName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle("Nova Lista")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { isPresented = false }
                }
            }
        }
    }
}
