//
//  NewListView.swift
//  RenshuTalk
//
//  Created by Dalvlos on 2025/10/22.
//

import SwiftUI

struct NewListView: View {
    @State private var listName: String = ""
    @Binding var path: [HomeView.Destination]

    var body: some View {
        VStack(spacing: 20) {
            Text("Nova Lista")
                .font(.title.bold())

            TextField("Nome da lista", text: $listName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Criar lista") {
                if !listName.isEmpty {
                    // Empilha a próxima tela (ContentView)
                    path.append(.contentView(listName: listName))
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(listName.isEmpty ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .disabled(listName.isEmpty)

            Spacer()
        }
        .padding()
        .navigationTitle("Nova Lista")
    }
}
