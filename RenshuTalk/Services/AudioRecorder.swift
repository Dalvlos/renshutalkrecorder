
import Foundation
import AVFoundation

class AudioRecorder: NSObject, ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    @Published var recordingURL: URL?

    func startRecording(for filename: String) {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = path.appendingPathComponent(filename).appendingPathExtension("m4a")

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 24000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        let session = AVAudioSession.sharedInstance()

        
        session.requestRecordPermission { [weak self] granted in
            guard granted else {
                print("Permissão de gravação negada.")
                // TODO: Informar o usuário na UI que a permissão é necessária
                return
            }
            
            
            
            DispatchQueue.main.async {
                do {
                    
                    try session.setCategory(.playAndRecord, mode: .default, options: [.allowBluetooth, .allowBluetoothA2DP])
                    try session.setActive(true)

                    self?.recordingURL = fileURL
                    self?.audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
                    self?.audioRecorder?.prepareToRecord()
                    self?.audioRecorder?.record()

                    print("Gravando em: \(fileURL)")
                } catch {
                    print("Erro ao iniciar gravação: \(error.localizedDescription)")
                }
            }
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil

        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            print("Sessão de áudio desativada (Gravação concluída).")
        } catch {
            print("Erro ao desativar AVAudioSession após gravação: \(error)")
        }
        
        if let url = recordingURL {
            let exists = FileManager.default.fileExists(atPath: url.path)
            let size = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size]) as? Int ?? 0
            print("Arquivo salvo: \(exists) tamanho: \(size) bytes em \(url.path)")
        }
    }
}

