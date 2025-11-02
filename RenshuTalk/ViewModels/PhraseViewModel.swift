//
//  FraseViewModel.swift
//  RenshuTalk
//
//  Created by Dalvlos on 2025/07/12.
//

import Foundation
import AVFoundation

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
    
    // Constantes de persistência
    private let nomeArquivoAntigo = "frases.json"       // Formato antigo (legado)
    private let nomeArquivoNovo = "listasDeFrases.json" // Novo formato (lista única)
    
    
    // MARK: - Inicializador
    override init() {
        super.init()
        loadAllData() // Carrega os dados ou migra na inicialização
    }
    
    // MARK: - Gerenciamento de Listas
    
    /// Cria uma nova lista, a define como ativa e salva.
    func criarNovaLista(nome: String) {
        let novaLista = PhraseList(id: UUID(), name: nome, phrases: [])
        
        // 1. Adiciona à fonte única da verdade
        todasAsListas.append(novaLista)
        
        // 2. Define como a lista ativa
        listaAtual = novaLista
        
        // 3. Salva as mudanças
        salvarListas()
    }
    
    /// Define a lista selecionada como a lista de trabalho atual.
    func selecionarLista(_ lista: PhraseList) {
        listaAtual = lista
    }
    
    // MARK: - Gravação e Salvamento
    
    /// Alterna o estado de gravação (inicia ou para).
    func toggleRecording() {
        let filename = UUID().uuidString
        
        if isRecording {
            recorder.stopRecording()
            isRecording = false
            salvarFrase() // Tenta salvar a frase ao parar
        } else {
            recorder.startRecording(for: filename)
            isRecording = true
        }
    }
    
    /// Salva a frase gravada na lista_atual.
    func salvarFrase() {
        // 1. Verifica se há texto, um arquivo gravado e uma lista selecionada
        guard !inputText.isEmpty, let file = recorder.recordingURL else { return }
        guard let listaSelecionada = listaAtual else {
            print("⚠️ Nenhuma lista ativa encontrada para salvar a frase.")
            return
        }
        
        // 2. Cria a nova frase
        let novaFrase = PhraseItem(
            id: UUID(),
            text: inputText,
            audioFileName: file.lastPathComponent,
            dateCreated: Date()
        )
        
        // 3. Atualiza a lista correspondente em 'todasAsListas'
        if let index = todasAsListas.firstIndex(where: { $0.id == listaSelecionada.id }) {
            todasAsListas[index].phrases.append(novaFrase)
            
            // Atualiza a 'listaAtual' para refletir a nova adição
            listaAtual = todasAsListas[index]
            
            salvarListas()
        } else {
            print("⚠️ Erro: A lista atual não foi encontrada em todasAsListas.")
        }
        
        // 4. Limpa o estado
        inputText = ""
        recorder.recordingURL = nil
    }
    
    /// Exclui uma frase da lista atual e seu arquivo de áudio.
    func deleteFrase(at index: Int) {
        // 1. Garante que a lista e o índice são válidos
        guard let lista = listaAtual, index < lista.phrases.count else { return }
        
        let frase = lista.phrases[index]
        
        // 2. Deleta o arquivo de áudio
        let audioURL = getDocumentsDirectory().appendingPathComponent(frase.audioFileName)
        do {
            if FileManager.default.fileExists(atPath: audioURL.path) {
                try FileManager.default.removeItem(at: audioURL)
            }
        } catch {
            print("Erro ao deletar áudio:", error)
        }
        
        // 3. 🐞 CORREÇÃO DE BUG: Encontra o ÍNDICE da lista no array principal
        guard let listIndex = todasAsListas.firstIndex(where: { $0.id == lista.id }) else {
            print("⚠️ Erro: não foi possível encontrar a lista atual para deletar a frase.")
            return
        }
        
        // 4. Remove a frase DIRETAMENTE do array principal
        todasAsListas[listIndex].phrases.remove(at: index)
        
        // 5. Atualiza a 'listaAtual' com a versão modificada do array principal
        listaAtual = todasAsListas[listIndex]
        
        // 6. Salva o array principal modificado
        salvarListas()
    }
    
    // MARK: - Reprodução de Áudio
    
    /// Configura a sessão de áudio para reprodução.
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Erro ao configurar AVAudioSession: \(error)")
        }
    }
    
    /// Toca um único arquivo de áudio pelo nome.
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
            currentPlayIndex = nil // Isto não é uma sequência
            currentPlayingID = id
        } catch {
            print("Erro ao reproduzir áudio:", error)
        }
    }
    
    /// Toca todas as frases da lista atual em sequência.
    func playAll() {
        // A lógica de migração garante que 'listaAtual' sempre existe.
        guard let phrasesToPlay = listaAtual?.phrases, !phrasesToPlay.isEmpty else { return }
        
        configureAudioSession()
        playSequentially(index: 0, phrases: phrasesToPlay)
    }
    
    /// Função auxiliar recursiva para tocar a sequência.
    private func playSequentially(index: Int, phrases: [PhraseItem]) {
        guard index < phrases.count else {
            // 🔹 Todas as frases já foram tocadas
            stopPlayback() // Limpa o estado
            return
        }
        
        currentPlayIndex = index
        let phrase = phrases[index]
        
        let fileURL = getDocumentsDirectory().appendingPathComponent(phrase.audioFileName)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            // Pula para o próximo se o arquivo não existir
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
            // Se houver erro em uma, pula para a próxima
            playSequentially(index: index + 1, phrases: phrases)
        }
    }
    
    /// Para a reprodução atual e limpa o estado.
    func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        currentPlayIndex = nil
        currentPlayingID = nil
    }
    
    /// Delegate do AVAudioPlayer, chamado quando a reprodução termina.
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // Se estávamos em uma sequência, toca o próximo
        if let idx = currentPlayIndex, let phrases = listaAtual?.phrases {
            playSequentially(index: idx + 1, phrases: phrases)
        } else {
            // Se era um play único, apenas limpa o ID
            currentPlayingID = nil
        }
    }
    
    // MARK: - Persistência (Carregar e Salvar)
    
    /// Obtém o diretório de documentos do usuário.
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    /// Carrega todos os dados, migrando do formato antigo se necessário.
    func loadAllData() {
        let urlNovo = getDocumentsDirectory().appendingPathComponent(nomeArquivoNovo)
        
        // 1. Tenta carregar o novo formato (múltiplas listas)
        if let data = try? Data(contentsOf: urlNovo),
           let decoded = try? JSONDecoder().decode([PhraseList].self, from: data) {
            
            todasAsListas = decoded
            
        } else {
            // 2. Novo formato falhou. Tenta carregar o formato antigo para MIGRAÇÃO.
            if let frasesAntigas = loadFrasesAntigas(), !frasesAntigas.isEmpty {
                print("Migrando \(frasesAntigas.count) frases do formato antigo.")
                
                // Migra as frases antigas para o novo modelo de lista
                let lista = PhraseList(id: UUID(), name: "Minha Lista", phrases: frasesAntigas)
                todasAsListas = [lista]
                salvarListas() // Salva imediatamente no novo formato
                
                // Opcional: deletar o arquivo antigo após a migração
                deleteArquivoAntigo()
            }
        }
        
        // 3. GARANTIA DE ESTADO: Se (após tudo) não houver listas (ex: novo usuário)
        if todasAsListas.isEmpty {
            print("Nenhuma lista encontrada. Criando lista padrão.")
            let listaPadrao = PhraseList(id: UUID(), name: "Minha Lista", phrases: [])
            todasAsListas = [listaPadrao]
            salvarListas() // Salva a lista padrão
        }
        
        // 4. Define a lista atual. (Garantido que 'todasAsListas' não está vazia)
        listaAtual = todasAsListas.first
    }
    
    /// Salva o array 'todasAsListas' no 'nomeArquivoNovo'.
    private func salvarListas() {
        let url = getDocumentsDirectory().appendingPathComponent(nomeArquivoNovo)
        do {
            let data = try JSONEncoder().encode(todasAsListas)
            // .atomicWrite garante que o arquivo não seja corrompido se o app fechar
            try data.write(to: url, options: [.atomicWrite, .completeFileProtection])
        } catch {
            print("❌ Erro ao salvar listas: \(error.localizedDescription)")
        }
    }
    
    /// (Função de Migração) Tenta carregar frases do formato antigo.
    private func loadFrasesAntigas() -> [PhraseItem]? {
        let url = getDocumentsDirectory().appendingPathComponent(nomeArquivoAntigo)
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([PhraseItem].self, from: data)
        } catch {
            print("Nenhum arquivo antigo para migrar. \(error.localizedDescription)")
            return nil
        }
    }
    
    /// (Função de Migração) Deleta o arquivo antigo.
    func deleteFrases(at offsets: IndexSet) {
        // 1. Garante que a lista atual e seu índice no array principal são válidos
        guard let lista = listaAtual,
              let listIndex = todasAsListas.firstIndex(where: { $0.id == lista.id }) else {
            print("⚠️ Erro: não foi possível encontrar a lista atual para deletar.")
            return
        }

        // 2. Coleta as frases que serão deletadas ANTES de modificar o array
        let frasesParaDeletar = offsets.map { todasAsListas[listIndex].phrases[$0] }

        // 3. Deleta os arquivos de áudio
        for frase in frasesParaDeletar {
            let audioURL = getDocumentsDirectory().appendingPathComponent(frase.audioFileName)
            do {
                if FileManager.default.fileExists(atPath: audioURL.path) {
                    try FileManager.default.removeItem(at: audioURL)
                }
            } catch {
                print("Erro ao deletar áudio: \(error)")
            }
        }

        // 4. Remove as frases da lista DIRETAMENTE do array principal
        //    'remove(atOffsets:)' é seguro e lida com múltiplos índices
        todasAsListas[listIndex].phrases.remove(atOffsets: offsets)

        // 5. Atualiza a 'listaAtual' com a versão modificada
        listaAtual = todasAsListas[listIndex]

        // 6. Salva o estado modificado
        salvarListas()
    }
}
