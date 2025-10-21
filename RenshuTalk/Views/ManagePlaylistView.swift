//
//  ManagePlaylistView.swift
//  RenshuTalk
//
//  Created by Dalvlos on 2025/10/21.
//

//
//  ManagePlaylistsView.swift
//  RenshuTalk
//
//  Uma tela simples para renomear/excluir playlists.
//

import SwiftUI

struct ManagePlaylistsView: View {
    @ObservedObject var viewModel: FraseViewModel
    @Binding var isPresented: Bool
    @State private var newName: String = ""
    @State private var selectedIndex: Int? = nil

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.library.playlists.indices, id: \.self) { idx in
                    HStack {
                        Text(viewModel.library.playlists[idx].name)
                        Spacer()
                        if viewModel.library.playlists[idx].id == viewModel.activePlaylistID {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.selectPlaylist(id: viewModel.library.playlists[idx].id)
                    }
                }
                .onDelete { offsets in
                    if let first = offsets.first {
                        viewModel.deletePlaylist(at: first)
                    }
                }
            }
            .navigationTitle("Gerenciar Listas")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fechar") { isPresented = false }
                }
            }
        }
    }
}
