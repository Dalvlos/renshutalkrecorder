//
//  HomeView.swift
//  RenshuTalk
//
//  Created by Dalvlos on 2025/10/22.
//
import SwiftUI

struct HomeView: View {
    enum Destination: Hashable {
        case newList
        case contentView(listName: String)
    }

    @State private var path: [Destination] = []

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 40) {
                Spacer()

                Text("Minhas Gravações")
                    .font(.largeTitle.bold())
                    .padding(.bottom, 20)

                Button("➕ Criar nova lista") {
                    path.append(.newList)
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(12)

                Button("📁 Acessar lista existente") {
                    // Por enquanto, podemos deixar isso para depois
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(12)

                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .newList:
                    // Passa o binding do path para poder navegar de dentro da NewListView
                    NewListView(path: $path)

                case .contentView(let listName):
                    // Abre a tela principal já com a lista criada
                    ContentView(listName: listName)
                }
            }
        }
    }
}
