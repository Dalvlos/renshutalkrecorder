//
//  ContentView.swift
//  RenshuTalk
//
//  Created by Dalvlos on 2025/07/03.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var inputText: String = ""
    @State private var frases: [FraseComAudio] = []
    @StateObject private var recorder = AudioRecorder()
    @State private var isRecording = false
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Digite uma frase...", text: $inputText)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            HStack(spacing: 20) {
                Button(action: {
                    let filename = "\(UUID().uuidString).m4a"
                    if isRecording {
                        recorder.stopRecording()
                        isRecording = false
                    } else {
                        recorder.startRecording(for: filename)
                        isRecording = true
                    }
                }) {
                    Label(
                        isRecording ? "Parar gravação" : "Gravar áudio",
                        systemImage: isRecording ? "stop.circle.fill" : "mic.circle.fill"
                    )
                    .font(.headline)
                }
                .buttonStyle(.bordered)
                .tint(isRecording ? .red : .blue)
                
                Button(action: {
                    guard !inputText.isEmpty, let file = recorder.recordingURL else { return }
                    let item = FraseComAudio(id: UUID(), texto: inputText, audioFileName: file.lastPathComponent)
                    frases.append(item)
                    saveFrases()
                    inputText = ""
                    recorder.recordingURL = nil
                }) {
                    Label("Salvar frase", systemImage: "square.and.arrow.down")
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
            .padding(.horizontal)

            
            List(frases.indices, id: \.self) { index in
                VStack(alignment: .leading) {
                    Text(frases[index].texto)
                        .font(.headline)
                    Button("Ouvir áudio") {
                        playAudio(named: frases[index].audioFileName)
                    }
                }
                .swipeActions {
                    Button(role: .destructive) {
                        deleteFrase(at: index)
                    } label: {
                        Label("Deletar", systemImage: "trash")
                    }
                }
            }
        }
        .onAppear(perform: loadFrases)
    }
    
    // MARK: - Funções auxiliares
    
    private func playAudio(named filename: String) {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = path.appendingPathComponent(filename)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.play()
        } catch {
            print("Erro ao reproduzir áudio: \(error)")
        }
    }
    
    private func saveFrases() {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("frases.json")
        do {
            let data = try JSONEncoder().encode(frases)
            try data.write(to: url)
        } catch {
            print("Erro ao salvar frases: \(error)")
        }
    }
    
    private func loadFrases() {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("frases.json")
        do {
            let data = try Data(contentsOf: url)
            frases = try JSONDecoder().decode([FraseComAudio].self, from: data)
        } catch {
            print("Nenhuma frase salva ou erro ao carregar.")
        }
    }
    
    private func deleteFrase(at index: Int) {
        let fraseParaDeletar = frases[index]
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioURL = path.appendingPathComponent(fraseParaDeletar.audioFileName)
        
        do {
            if FileManager.default.fileExists(atPath: audioURL.path) {
                try FileManager.default.removeItem(at: audioURL)
                print("Áudio deletado: \(fraseParaDeletar.audioFileName)")
            }
        } catch {
            print("Erro ao deletar o áudio: \(error)")
        }
        
        frases.remove(at: index)
        saveFrases()
    }
}

