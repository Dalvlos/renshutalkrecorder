
import Foundation

// MARK: - PhraseItem


struct PhraseItem: Identifiable, Codable, Equatable {
    let id: UUID
    var text: String
    var audioFileName: String
    let dateCreated: Date

    init(id: UUID = UUID(), text: String, audioFileName: String, dateCreated: Date = Date()) {
        self.id = id
        self.text = text
        self.audioFileName = audioFileName
        self.dateCreated = dateCreated
    }
}

// MARK: - PhraseList

struct PhraseList: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var phrases: [PhraseItem]

    init(id: UUID = UUID(), name: String, phrases: [PhraseItem] = []) {
        self.id = id
        self.name = name
        self.phrases = phrases
    }
    
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.phrases = []
    }
}
