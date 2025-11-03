
//
import SwiftUI

@main
struct RenshuTalkApp: App {
    
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome: Bool = false
    
    
    @StateObject private var viewModel = PhraseViewModel()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if hasSeenWelcome {
                    ContentView()
                } else {
                    
                    WelcomeView(hasSeenWelcome: $hasSeenWelcome)
                }
            }
            
            .environmentObject(viewModel)
            .preferredColorScheme(.dark)
        }
    }
}
