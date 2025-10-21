//
//  ContentView.swift
//  RenshuTalk
//
//  Created by Dalvlos on 2025/07/03.
//

//
//  ContentView.swift
//  RenshuTalk
//
//  Atualizado para suportar seleção/ criação de playlists.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = FraseViewModel()
    @State private var isMenuOpen = false
    @State private var showNewPlaylistSheet = false
    @State private var showManagePlaylists = false

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {

                // Top bar: seleção de lista + nova lista
                HStack(spacing: 12) {
                    Menu {
                        // mostra todas as playlists
                        ForEach(viewModel.library.playlists, id: \.id) { playlist in
                            Button(action: {
                                viewModel.selectPlaylist(id: playlist.id)
                            }) {
                                Text(playlist.name)
                            }
                        }
                        Divider()
                        Button(action: { showNewPlaylistSheet = true }) {
                            Label("Nova lista", systemImage: "plus")
                        }
                        Button(action: { showManagePlaylists = true }) {
                            Label("Gerenciar listas", systemImage: "square.stack")
                        }
                    } label: {
                        HStack {
                            Text(viewModel.activePlaylistName)
                                .fontWeight(.semibold)
                            Image(systemName: "chevron.down")
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                    }

                    Spacer()
                }
                .padding(.horizontal)

                // --- Área 1: Tela 1:1 estilo Instagram (mantive o seu layout) ---
                GeometryReader { geometry in
                    ZStack {
                        Rectangle()
                            .fill(Color.black.opacity(0.1))
                            .aspectRatio(1, contentMode: .fit)
                            .cornerRadius(16)
                            .shadow(radius: 3)

                        CenteredTextEditor(
                            text: $viewModel.inputText,
                            fontSize: fontSize(for: viewModel.inputText)
                        )
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.width,
                            alignment: .center
                        )
                        .background(Color.black)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                    }
                    .frame(height: geometry.size.width)
                }
                .frame(maxHeight: UIScreen.main.bounds.width)

                // --- Área 2: Menu acima da lista ---
                HStack(spacing: 20) {
                    // Botão de Gravação
                    Button(action: {
                        viewModel.toggleRecording()
                    }) {
                        Label(
                            viewModel.isRecording ? "Stop" : "REC",
                            systemImage: viewModel.isRecording ? "stop.circle.fill" : "mic.circle.fill"
                        )
                    }
                    .buttonStyle(.bordered)
                    .tint(viewModel.isRecording ? .red : .blue)

                    // Botão "Play All" (aplica à playlist ativa)
                    Button(action: {
                        // play all da playlist ativa — simples iteração
                        playAllActive()
                    }) {
                        Label("Play All", systemImage: "play.fill")
                    }
                    .buttonStyle(.bordered)
                    .tint(.green)

                    Spacer()
                }
                .padding(.horizontal)

                // --- Área 3: Lista de gravações da playlist ativa ---
                FraseListView(viewModel: viewModel)
            }
            .ignoresSafeArea(.keyboard)
            .navigationTitle("Write and Recorder")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.loadLibrary()
            }
            .onTapGesture {
                hideKeyboard()
            }
            }
            .sheet(isPresented: $showNewPlaylistSheet) {
                NewPlaylistView(viewModel: viewModel, isPresented: $showNewPlaylistSheet)
            }
            // (Opcional) sheet para gerenciar/renomear/excluir playlists
            .sheet(isPresented: $showManagePlaylists) {
                ManagePlaylistsView(viewModel: viewModel, isPresented: $showManagePlaylists)
            }
        }
    // Função que ajusta o tamanho da fonte
    private func fontSize(for text: String) -> CGFloat {
        return 28
    }

// ... dentro da struct ContentView { ... }

    private func playAllActive() {
        // agora viewModel está disponível porque esta função está dentro de ContentView
        let recordings = viewModel.activeRecordings
        guard !recordings.isEmpty else { return }

        var delay: TimeInterval = 0
        for rec in recordings {
            let file = rec.audioFileName
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                viewModel.playAudio(named: file)
            }
            delay += 3.5
        }
    }

    }

    


