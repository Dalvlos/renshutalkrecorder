//
//  PhraseViewModel.swift
//  RenshuTalk
//
//  Created by Dalvlos on 2025/07/12.
//
import Foundation
import AVFoundation
import SwiftUI

class PhraseViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    // MARK: - Estado Principal
    @Published var inputText = ""
    @Published var todasAsListas: [PhraseList] = []
    @Published var listaAtual: PhraseList? = nil
    @Published var recorder = AudioRecorder()
    @Published var isRecording = false
    @Published var currentPlayingID: UUID? = nil
    
    // MARK: - Propriedades Privadas
    private var audioPlayer: AVAudioPlayer?
    private var currentPlayIndex: Int? = nil
    
    
    private let nomeArquivoAntigo = "frases.json"
    private let nomeArquivoNovo = "listasDeFrases.json"
    
    
    // MARK: - Inicializador
    override init() {
        super.init()
        loadAllData()
    }
    
    // MARK: - Gerenciamento de Listas
    
    func criarNovaLista(nome: String) {
        let novaLista = PhraseList(name: nome)
        todasAsListas.append(novaLista)
        listaAtual = novaLista
        salvarListas()
    }
    
    func selecionarLista(_ lista: PhraseList) {
        listaAtual = lista
    }
    
    // MARK: - Gravação e Salvamento
    
    
    func toggleRecording() {
        let filename = UUID().uuidString
        
        if isRecording {
            
            recorder.stopRecording()
            isRecording = false
            
           
            if !inputText.isEmpty, let fileURL = recorder.recordingURL {
                
                salvarFrase(audioFileURL: fileURL)
            } else if let fileURL = recorder.recordingURL {
                
                print("Arquivo órfão detectado (sem texto). Deletando: \(fileURL.lastPathComponent)")
                try? FileManager.default.removeItem(at: fileURL)
            }
            
            
            recorder.recordingURL = nil
            inputText = ""
            
        } else {
            
            stopPlayback()
            recorder.startRecording(for: filename)
            isRecording = true
        }
    }
    
    
    private func salvarFrase(audioFileURL file: URL) {
        
        
        guard FileManager.default.fileExists(atPath: file.path) else {
            print("⚠️ Erro: Tentativa de salvar frase, mas o arquivo de áudio não existe em \(file.path)")
            return
        }
        
        
        guard let listaSelecionada = listaAtual else {
            print("⚠️ Nenhuma lista ativa encontrada. Deletando áudio órfão.")
            try? FileManager.default.removeItem(at: file)
            return
        }
        
        let novaFrase = PhraseItem(
            text: inputText,
            audioFileName: file.lastPathComponent,
            dateCreated: Date()
        )
        
        
        if let index = todasAsListas.firstIndex(where: { $0.id == listaSelecionada.id }) {
            todasAsListas[index].phrases.append(novaFrase)
            
            
            listaAtual = todasAsListas[index]
            
            salvarListas()
        } else {
            print("⚠️ Erro: A lista atual não foi encontrada em todasAsListas. Deletando áudio.")
            try? FileManager.default.removeItem(at: file)
        }
        
        
    }
    
    
    func deleteFrases(at offsets: IndexSet) {
        guard let lista = listaAtual,
              let listIndex = todasAsListas.firstIndex(where: { $0.id == lista.id }) else {
            print("⚠️ Erro: não foi possível encontrar a lista atual para deletar.")
            return
        }

        let frasesParaDeletar = offsets.map { todasAsListas[listIndex].phrases[$0] }

        
        for frase in frasesParaDeletar {
            let audioURL = getDocumentsDirectory().appendingPathComponent(frase.audioFileName)
            try? FileManager.default.removeItem(at: audioURL)
        }

        
        todasAsListas[listIndex].phrases.remove(atOffsets: offsets)
        listaAtual = todasAsListas[listIndex]
        salvarListas()
    }
    
    // MARK: - Reprodução de Áudio
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playAndRecord,
                mode: .default,
                options: [.allowBluetooth, .allowBluetoothA2DP]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Erro ao configurar AVAudioSession para PlayAndRecord: \(error)")
        }
    }
    func playAudio(named filename: String, id: UUID? = nil) {
        stopPlayback()
        configureAudioSession()
        
        let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
        
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
            stopPlayback()
        }
    }
    
    func playAll() {
        guard let phrasesToPlay = listaAtual?.phrases, !phrasesToPlay.isEmpty else { return }
        
        configureAudioSession()
        playSequentially(index: 0, phrases: phrasesToPlay)
    }
    
    private func playSequentially(index: Int, phrases: [PhraseItem]) {
        guard index < phrases.count else {
            stopPlayback()
            return
        }
        
        currentPlayIndex = index
        let phrase = phrases[index]
        let fileURL = getDocumentsDirectory().appendingPathComponent(phrase.audioFileName)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            
            playSequentially(index: index + 1, phrases: phrases)
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            currentPlayingID = phrase.id
        } catch {
            
            playSequentially(index: index + 1, phrases: phrases)
        }
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        currentPlayIndex = nil
        currentPlayingID = nil
        
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            print("Sessão de áudio desativada (Playback concluído).")
        } catch {
            print("Erro ao desativar AVAudioSession: \(error)")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if let idx = currentPlayIndex, let phrases = listaAtual?.phrases {
            
            playSequentially(index: idx + 1, phrases: phrases)
        } else {
            
            stopPlayback()
        }
    }
    
    // MARK: - Persistência (Carregar e Salvar)
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func loadAllData() {
        let urlNovo = getDocumentsDirectory().appendingPathComponent(nomeArquivoNovo)
        
        
        if let data = try? Data(contentsOf: urlNovo),
           let decoded = try? JSONDecoder().decode([PhraseList].self, from: data) {
            
            todasAsListas = decoded
            
        } else {
            
            if let frasesAntigas = loadFrasesAntigas(), !frasesAntigas.isEmpty {
                print("Migrando \(frasesAntigas.count) frases do formato antigo.")
                let lista = PhraseList(id: UUID(), name: "Minha Lista", phrases: frasesAntigas)
                todasAsListas = [lista]
                salvarListas()
                deleteArquivoAntigo()
            }
        }
        
        
        if todasAsListas.isEmpty {
            print("Nenhuma lista encontrada. Criando lista padrão.")
            let listaPadrao = PhraseList(name: "Minha Lista")
            todasAsListas = [listaPadrao]
            salvarListas()
        }
        
        
        listaAtual = todasAsListas.first
    }
    
    func deleteListas(at offsets: IndexSet) {
        let newFirstListIndex = offsets.first
        
        
        offsets.forEach { index in
            let lista = todasAsListas[index]
            lista.phrases.forEach { phrase in
                let audioURL = getDocumentsDirectory().appendingPathComponent(phrase.audioFileName)
                try? FileManager.default.removeItem(at: audioURL)
            }
        }
        
        
        todasAsListas.remove(atOffsets: offsets)
        
        
        if todasAsListas.isEmpty {
            let listaPadrao = PhraseList(name: "Minha Lista")
            todasAsListas = [listaPadrao]
        }
        
        
        if listaAtual == nil || !todasAsListas.contains(where: { $0.id == listaAtual?.id }) {
            if let index = newFirstListIndex, index < todasAsListas.count {
                 listaAtual = todasAsListas[index]
            } else {
                 listaAtual = todasAsListas.first
            }
        }
        
       
        salvarListas()
    }
    
    private func salvarListas() {
        let url = getDocumentsDirectory().appendingPathComponent(nomeArquivoNovo)
        do {
            let data = try JSONEncoder().encode(todasAsListas)
            try data.write(to: url, options: [.atomicWrite, .completeFileProtection])
        } catch {
            print("❌ Erro ao salvar listas: \(error.localizedDescription)")
        }
    }
    
    
    private func loadFrasesAntigas() -> [PhraseItem]? {
        let url = getDocumentsDirectory().appendingPathComponent(nomeArquivoAntigo)
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([PhraseItem].self, from: data)
        } catch {
            print("Nenhum arquivo antigo para migrar.")
            return nil
        }
    }
    
    private func deleteArquivoAntigo() {
        let url = getDocumentsDirectory().appendingPathComponent(nomeArquivoAntigo)
        try? FileManager.default.removeItem(at: url)
        print("Arquivo de frases antigo deletado.")
    }
}
