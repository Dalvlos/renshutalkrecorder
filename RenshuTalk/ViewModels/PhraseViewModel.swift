//
//  FraseViewModel.swift
//  RenshuTalk
//
//  Created by Dalvlos on 2025/07/12.
//

import Foundation
import AVFoundation

class PhraseViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    // MARK: - Dados
    @Published var inputText = ""
    @Published var frases: [PhraseWithAudio] = []          // ← compatibilidade antiga
    @Published var todasAsListas: [PhraseList] = []   // 🔹 NOVO: múltiplas listas
    @Published var listaAtual: PhraseList? = nil      // 🔹 NOVO: lista ativa no momento
    
    @Published var isRecording = false
    @Published var currentPlayingID: UUID?
    
    private var audioPlayer: AVAudioPlayer?
    private var currentPlayIndex: Int?
    
    @Published var recorder = AudioRecorder()
    
    
    private let nomeArquivoAntigo = "frases.json"
    private let nomeArquivoNovo = "listasDeFrases.json"
    
    // MARK: - Gravação
    func toggleRecording() {
        let filename = UUID().uuidString
        
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
        
        let novaFrase = PhraseWithAudio(
            id: UUID(),
            texto: inputText,
            audioFileName: file.lastPathComponent
        )
        
        // 🔹 Salva na lista atual, se existir
        if var lista = listaAtual {
            lista.frases.append(novaFrase)
            listaAtual = lista
            salvarListas()
        } else {
            // compatibilidade antiga
            frases.append(novaFrase)
            saveFrases()
        }
        
        inputText = ""
        recorder.recordingURL = nil
    }
    
    // MARK: - Reprodução
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Erro ao configurar AVAudioSession: \(error)")
        }
    }
    
    func playAudio(named filename: String, id: UUID? = nil) {
        stopPlayback()
        configureAudioSession()
        
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = path.appendingPathComponent(filename)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("Arquivo não encontrado:", fileURL.path)
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            currentPlayIndex = nil
            currentPlayingID = id
        } catch {
            print("Erro ao reproduzir áudio:", error)
        }
    }
    
    func playAll() {
        guard !(listaAtual?.frases.isEmpty ?? frases.isEmpty) else { return }
        configureAudioSession()
        playSequentially(index: 0)
    }
    
    private func playSequentially(index: Int) {
        let frasesParaReproduzir = listaAtual?.frases ?? frases
        guard index < frasesParaReproduzir.count else {
            currentPlayIndex = nil
            currentPlayingID = nil
            return
        }
        
        currentPlayIndex = index
        let frase = frasesParaReproduzir[index]
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = path.appendingPathComponent(frase.audioFileName)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            playSequentially(index: index + 1)
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            currentPlayingID = frase.id
        } catch {
            playSequentially(index: index + 1)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if let idx = currentPlayIndex {
            playSequentially(index: idx + 1)
        } else {
            currentPlayingID = nil
        }
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        currentPlayIndex = nil
        currentPlayingID = nil
    }
    
    // MARK: - Exclusão e gerenciamento
    func deleteFrase(at index: Int) {
        let frasesParaEditar = listaAtual?.frases ?? frases
        let frase = frasesParaEditar[index]
        
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioURL = path.appendingPathComponent(frase.audioFileName)
        
        do {
            if FileManager.default.fileExists(atPath: audioURL.path) {
                try FileManager.default.removeItem(at: audioURL)
            }
        } catch {
            print("Erro ao deletar áudio:", error)
        }
        
        if var lista = listaAtual {
            lista.frases.remove(at: index)
            listaAtual = lista
            salvarListas()
        } else {
            frases.remove(at: index)
            saveFrases()
        }
    }
    
    // 🔹 NOVO — Criação de lista
    func criarNovaLista(nome: String) {
        let nova = PhraseList(nome: nome, frases: [])
        todasAsListas.append(nova)
        listaAtual = nova
        salvarListas()
    }
    
    func selecionarLista(_ lista: PhraseList) {
        listaAtual = lista
    }
    
    // MARK: - Persistência
    
    func loadAllData() {
        // tenta carregar o novo formato (múltiplas listas)
        let urlNovo = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(nomeArquivoNovo)
        
        if let data = try? Data(contentsOf: urlNovo),
           let decoded = try? JSONDecoder().decode([PhraseList].self, from: data) {
            todasAsListas = decoded
            listaAtual = decoded.first
            return
        }
        
        // fallback para o formato antigo
        loadFrases()
        if !frases.isEmpty {
            let lista = PhraseList(nome: "Lista Principal", frases: frases)
            todasAsListas = [lista]
            listaAtual = lista
            salvarListas() // migra automaticamente
        }
    }
    
    private func saveFrases() {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(nomeArquivoAntigo)
        do {
            let data = try JSONEncoder().encode(frases)
            try data.write(to: url)
        } catch {
            print("Erro ao salvar frases:", error)
        }
    }
    
    private func salvarListas() {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(nomeArquivoNovo)
        do {
            let data = try JSONEncoder().encode(todasAsListas)
            try data.write(to: url)
        } catch {
            print("Erro ao salvar listas:", error)
        }
    }
    func loadFrases() {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("frases.json")
        do {
            let data = try Data(contentsOf: url)
            frases = try JSONDecoder().decode([PhraseWithAudio].self, from: data)
        } catch {
            print("Erro ao carregar frases:", error)
        }
    }
}

