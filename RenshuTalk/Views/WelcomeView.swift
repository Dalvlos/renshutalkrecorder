
import SwiftUI

struct WelcomeView: View {
    
    @Binding var hasSeenWelcome: Bool
    
    @EnvironmentObject var viewModel: PhraseViewModel

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 8) {
                Image(systemName: "waveform.path")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 96, height: 96)
                    .foregroundColor(.blue)

                Text("RenshuSpeak")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }

            Text("Type a sentence and record your reading. Practice pronunciation and save your recordings.")
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            VStack(spacing: 12) {
               
                Button(action: {
                    handleContinue()
                }) {
                    Text("Start Practice") // ✅ Texto mais claro
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 40)
                }
                
            }
            Spacer(minLength: 20)
        }
        .padding()
        .background(
            Color(.systemBackground)
                .edgesIgnoringSafeArea(.all)
        )
    }
    
    
    private func handleContinue() {
        withAnimation {
            hasSeenWelcome = true
            
            
            if viewModel.todasAsListas.isEmpty {
                viewModel.criarNovaLista(nome: "My Phrases")
            }
        }
    }
}
