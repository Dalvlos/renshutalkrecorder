//
//  FraseViewModel.swift
//  RenshuTalk
//
//  Created by Dalvlos on 2025/07/12.
//

//
//  FraseViewModel.swift
//  RenshuTalk
//
//  Atualizado para suportar playlists (listas independentes).
//

import Foundation
import AVFoundation

class FraseViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate {
    // texto em edição
    @Published var inputText = ""
    // biblioteca com playlists
    @Published var library: UserLibrary = UserLibrary(playlists: [])
    // id da playlist ativa
    @Published var activePlaylistID: UUID?

    @Published var isRecording = false

    private var audioPlayer: AVAudioPlayer?
    @Published var recorder = AudioRecorder()

    // MARK: - Inicialização
    override init() {
        super.init()
        loadLibrary()
        // se não houver playlists, cria uma padrão
        if library.playlists.isEmpty {
            createPlaylist(name: "Default")
        }
        // garante que existe uma playlist ativa
        if activePlaylistID == nil {
            activePlaylistID = library.playlists.first?.id
        }
    }

    // MARK: - Acesso à playlist ativa
    var activePlaylistIndex: Int? {
        guard let id = activePlaylistID else { return nil }
        return library.playlists.firstIndex { $0.id == id }
    }

    var activePlaylistName: String {
        if let idx = activePlaylistIndex {
            return library.playlists[idx].name
        } else {
            return "Nenhuma lista"
        }
    }

    var activeRecordings: [Recording] {
        guard let idx = activePlaylistIndex else { return [] }
        return library.playlists[idx].recordings
    }

    // MARK: - Playlists
    func createPlaylist(name: String) {
        let playlist = Playlist(id: UUID(), name: name, recordings: [])
        library.playlists.append(playlist)
        // torna a nova playlist ativa
        activePlaylistID = playlist.id
        saveLibrary()
    }

    func selectPlaylist(id: UUID) {
        guard library.playlists.contains(where: { $0.id == id }) else { return }
        activePlaylistID = id
    }

    func renamePlaylist(id: UUID, newName: String) {
        guard let idx = library.playlists.firstIndex(where: { $0.id == id }) else { return }
        library.playlists[idx].name = newName
        saveLibrary()
    }

    func deletePlaylist(at index: Int) {
        guard library.playlists.indices.contains(index) else { return }
        let removingID = library.playlists[index].id
        library.playlists.remove(at: index)
        // se removida a playlist ativa, atualiza a ativa
        if activePlaylistID == removingID {
            activePlaylistID = library.playlists.first?.id
        }
        saveLibrary()
    }

    // MARK: - Gravação
    func toggleRecording() {
        let filename = "\(UUID().uuidString).m4a"
        if isRecording {
            recorder.stopRecording()
            isRecording = false
            salvarGravacaoNaPlaylist()
        } else {
            recorder.startRecording(for: filename)
            isRecording = true
        }
    }

    private func salvarGravacaoNaPlaylist() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let file = recorder.recordingURL,
              let idx = activePlaylistIndex else {
            // limpa URL se necessário
            recorder.recordingURL = nil
            return
        }

        let nova = Recording(id: UUID(), text: inputText, audioFileName: file.lastPathComponent, dateCreated: Date())
        library.playlists[idx].recordings.append(nova)
        saveLibrary()
        // limpa campo e URL atual de gravação
        inputText = ""
        recorder.recordingURL = nil
    }

    // MARK: - Reprodução
    func playAudio(named filename: String) {
        stopPlayback()
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = path.appendingPathComponent(filename)

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Erro ao reproduzir áudio: \(error)")
        }
    }

    func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
    }

    func deleteRecording(at index: Int) {
        guard let idx = activePlaylistIndex,
              library.playlists[idx].recordings.indices.contains(index) else { return }
        let fileName = library.playlists[idx].recordings[index].audioFileName
        // tenta remover arquivo físico
        let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = doc.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: fileURL)
        // remove da lista
        library.playlists[idx].recordings.remove(at: index)
        saveLibrary()
    }

    // MARK: - salvar/carregar biblioteca
    private func libraryURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("library.json")
    }

    func loadLibrary() {
        let url = libraryURL()
        do {
            let data = try Data(contentsOf: url)
            library = try JSONDecoder().decode(UserLibrary.self, from: data)
        } catch {
            // sem arquivo -> começa vazio (já tratado no init)
            print("Nenhuma library existente: \(error.localizedDescription)")
        }
    }

    func saveLibrary() {
        let url = libraryURL()
        do {
            let data = try JSONEncoder().encode(library)
            try data.write(to: url)
        } catch {
            print("Erro ao salvar library: \(error)")
        }
    }
}
