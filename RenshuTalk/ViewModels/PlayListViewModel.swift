//
//  PlayListViewModel.swift
//  RenshuTalk
//
//  Created by Dalvlos on 2025/08/12.
//
import SwiftUI

class LibraryViewModel: ObservableObject {
    @Published var library: UserLibrary = UserLibrary(playlists: [])

    func addPlaylist(name: String) {
        let playlist = Playlist(id: UUID(), name: name, recordings: [])
        library.playlists.append(playlist)
        saveLibrary()
    }

    func addRecording(to playlistID: UUID, text: String, audioFileName: String) {
        guard let index = library.playlists.firstIndex(where: { $0.id == playlistID }) else { return }
        let recording = Recording(id: UUID(), text: text, audioFileName: audioFileName, dateCreated: Date())
        library.playlists[index].recordings.append(recording)
        saveLibrary()
    }

    func saveLibrary() {
        // salvar no JSON local
    }
}
