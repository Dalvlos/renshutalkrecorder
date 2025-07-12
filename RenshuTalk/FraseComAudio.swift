//
//  FraseComAudio.swift
//  RenshuTalk
//
//  Created by Dalvlos on 2025/07/03.
//

import Foundation

struct FraseComAudio: Identifiable, Codable {
    let id: UUID
    let texto: String
    let audioFileName: String
}
