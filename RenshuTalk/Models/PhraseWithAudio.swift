//
//  FraseComAudio.swift
//  RenshuTalk
//
//  Created by Dalvlos on 2025/07/03.
//

import Foundation

/*struct Recording: Identifiable, Codable {
    let id: UUID
    var text: String
    var audioFileName: String
    var dateCreated: Date
}

struct Playlist: Identifiable, Codable {
    let id: UUID
    var name: String
    var recordings: [Recording]
}

struct UserLibrary: Codable {
    var playlists: [Playlist]
}
*/

struct PhraseWithAudio: Identifiable, Codable {
    let id: UUID
    var texto: String
    var audioFileName: String
}

struct PhraseList: Identifiable, Codable {
    var id = UUID()
    var nome: String
    var frases: [PhraseWithAudio]
}
