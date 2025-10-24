//
//  WelcomeView.swift
//  RenshuTalk
//
//  Created by Dalvlos on 2025/10/21.
//
import SwiftUI

struct WelcomeView: View {
    // mesmo storage usado no App para persistir a escolha
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome: Bool = true

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Logo / título — personalize como quiser (imagem, texto, etc)
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

            // Descrição curta
            Text("Digite uma frase e grave sua leitura. Pratique pronúncia e salve gravações.")
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            // Botões de ação
            VStack(spacing: 12) {
                Button(action: {
                    // marca como visto e automaticamente troca para ContentView
                    withAnimation {
                        hasSeenWelcome = true
                    }
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
                    // Opção para ver um tutorial, configurações, etc — por enquanto apenas pula
                    withAnimation {
                        hasSeenWelcome = true
                    }
                }) {
                    Text("")
                        .foregroundColor(.secondary)
                }
            }

            Spacer(minLength: 20)
        }
        .padding()
        .background(
            // Deixar aparência compatível com .preferredColorScheme(.dark)
            Color(.systemBackground)
                .edgesIgnoringSafeArea(.all)
        )
    }
}

// Preview opcional
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            .preferredColorScheme(.dark)
    }
}
