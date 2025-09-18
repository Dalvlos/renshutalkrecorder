//
//  FraseViewModel.swift
//  RenshuTalk
//
//  Created by Dalvlos on 2025/07/12.
//

import Foundation
import AVFoundation

class FraseViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var inputText = ""
    @Published var frases: [FraseComAudio] = []
    @Published var isRecording = false

    private var audioPlayer: AVAudioPlayer?
    @Published var recorder = AudioRecorder()

    // controla qual índice está sendo reproduzido no modo "playAll"
    private var currentPlayIndex: Int?

    // MARK: - Gravação
    func toggleRecording() {
        let filename = "\(UUID().uuidString).m4a"
        if isRecording {
            recorder.stopRecording()
            isRecording = false
            salvarFrase()
        } else {
            recorder.startRecording(for: filename)
            isRecording = true
        }
    }

    func salvarFrase() {
        guard !inputText.isEmpty, let file = recorder.recordingURL else { return }
        let novaFrase = FraseComAudio(id: UUID(), texto: inputText, audioFileName: file.lastPathComponent)
        frases.append(novaFrase)
        saveFrases()
        inputText = ""
        recorder.recordingURL = nil
    }

    // MARK: - Reprodução simples
    func playAudio(named filename: String) {
        stopPlayback()
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = path.appendingPathComponent(filename)

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            currentPlayIndex = nil // reprodução isolada
        } catch {
            print("Erro ao reproduzir áudio: \(error)")
        }
    }

    // MARK: - Play All (sequencial)
    func playAll() {
        guard !frases.isEmpty else { return }
        playSequentially(index: 0)
    }

    private func playSequentially(index: Int) {
        guard index < frases.count else {
            // terminou todas
            currentPlayIndex = nil
            return
        }

        currentPlayIndex = index
        let frase = frases[index]
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = path.appendingPathComponent(frase.audioFileName)

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Erro ao reproduzir áudio sequencialmente: \(error)")
            // tenta próximo se falhar
            playSequentially(index: index + 1)
        }
    }

    // AVAudioPlayerDelegate — chamado quando um áudio termina
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if let idx = currentPlayIndex {
            playSequentially(index: idx + 1)
        }
    }

    // Para parar qualquer reprodução em andamento
    func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        currentPlayIndex = nil
    }

    // MARK: - Gerenciamento
    func deleteFrase(at index: Int) {
        let frase = frases[index]
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioURL = path.appendingPathComponent(frase.audioFileName)

        do {
            if FileManager.default.fileExists(atPath: audioURL.path) {
                try FileManager.default.removeItem(at: audioURL)
            }
        } catch {
            print("Erro ao deletar áudio: \(error)")
        }

        frases.remove(at: index)
        saveFrases()
    }

    func createNewPlaylist() {
        frases.removeAll()
        saveFrases()
    }

    // MARK: - Persistência
    func loadFrases() {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("frases.json")
        do {
            let data = try Data(contentsOf: url)
            frases = try JSONDecoder().decode([FraseComAudio].self, from: data)
        } catch {
            print("Erro ao carregar frases.")
        }
    }

    private func saveFrases() {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("frases.json")
        do {
            let data = try JSONEncoder().encode(frases)
            try data.write(to: url)
        } catch {
            print("Erro ao salvar frases.")
        }
    }
}
