
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

                Text("RenshuTalk")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }

            Text("Digite uma frase e grave sua leitura. Pratique pronúncia e salve gravações.")
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            VStack(spacing: 12) {
                Button(action: {
                    
                    handleContinue()
                }) {
                    Text("Começar")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 40)
                }

                Button(action: {
                    
                    handleContinue()
                }) {
                    Text("Pular")
                        .foregroundColor(.secondary)
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
                viewModel.criarNovaLista(nome: "Minhas Frases")
            }
        }
    }
}
