//
//  AudioRecorder.swift
//  RenshuTalk
//
//  Created by Dalvlos on 2025/07/03.
//

import Foundation
import AVFoundation

class AudioRecorder: NSObject, ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    @Published var recordingURL: URL?

    func startRecording(for filename: String) {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        // Defina uma extensão de arquivo .m4a (ou .caf se preferir)
        let fileURL = path.appendingPathComponent(filename).appendingPathExtension("m4a")

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            // Configurar a sessão antes de gravar
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)

            recordingURL = fileURL
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()

            print("Gravando em: \(fileURL)")
        } catch {
            print("Erro ao iniciar gravação: \(error.localizedDescription)")
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil

        if let url = recordingURL {
            let exists = FileManager.default.fileExists(atPath: url.path)
            let size = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size]) as? Int ?? 0
            print("Arquivo salvo: \(exists) tamanho: \(size) bytes em \(url.path)")
        }
    }
}

