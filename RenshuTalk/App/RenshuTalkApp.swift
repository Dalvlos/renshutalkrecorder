
//
import SwiftUI

@main
struct RenshuTalkApp: App {
    // 1. Fonte de verdade para o estado de "primeira execução"
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome: Bool = false
    
    // 2. O ViewModel principal é criado UMA VEZ na raiz do app
    @StateObject private var viewModel = PhraseViewModel()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if hasSeenWelcome {
                    ContentView()
                } else {
                    // Passa o @AppStorage como @Binding
                    WelcomeView(hasSeenWelcome: $hasSeenWelcome)
                }
            }
            // 3. Injeta o ViewModel no ambiente para que todas as Views filhas
            //    possam acessá-lo via @EnvironmentObject.
            .environmentObject(viewModel)
            .preferredColorScheme(.dark)
        }
    }
}
