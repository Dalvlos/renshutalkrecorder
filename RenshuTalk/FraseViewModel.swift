//
//  FraseViewModel.swift
//  RenshuTalk
//
//  Created by Dalvlos on 2025/07/12.
//


import Foundation
import AVFoundation

class FraseViewModel: ObservableObject {
    @Published var inputText = ""
    @Published var frases: [FraseComAudio] = []
    @Published var isRecording = false
    
    private var audioPlayer: AVAudioPlayer?
    @Published var recorder = AudioRecorder()
    
    func toggleRecording() {
        let filename = "\(UUID().uuidString).m4a"
        if isRecording {
            recorder.stopRecording()
            isRecording = false
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
    
    func playAudio(named filename: String) {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = path.appendingPathComponent(filename)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.play()
        } catch {
            print("Erro ao reproduzir áudio: \(error)")
        }
    }
    
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
