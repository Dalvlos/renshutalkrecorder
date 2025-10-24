//
//  RenshuTalkApp.swift
//  RenshuTalk
//
//  Created by Dalvlos on 2025/07/03.
//
//
//  RenshuTalkApp.swift
//  RenshuTalk
//
//  Created by Dalvlos on 2025/07/03.
//

import SwiftUI

@main
struct RenshuTalkApp: App {
    
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome: Bool = false
        
    var body: some Scene {
        WindowGroup {
            Group {
                if hasSeenWelcome {
                    HomeView()
                } else {
                    WelcomeView()
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}
