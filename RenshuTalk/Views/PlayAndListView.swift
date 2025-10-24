//
//  PlayAndListView.swift
//  RenshuTalk
//
//  Created by Dalvlos on 2025/09/02.
//
import SwiftUI

struct PlayAndListView: View {
    @ObservedObject var viewModel: PhraseViewModel

    var body: some View {
        HStack(spacing: 20) {
            
            Button(action: {
                // Ação de "Play All"
                // viewModel.playAll()
            }) {
                Label("Play All", systemImage: "play.fill")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.15))
                    .foregroundColor(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Button(action: {
                // Ação de "Nova Lista"
                // viewModel.createNewPlaylist()
            }) {
                Label("New List", systemImage: "plus.circle")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green.opacity(0.15))
                    .foregroundColor(.green)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
    }
}
