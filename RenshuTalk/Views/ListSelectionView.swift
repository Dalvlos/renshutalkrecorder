
import SwiftUI

struct ListSelectionView: View {
    
    @EnvironmentObject var viewModel: PhraseViewModel
    
    @Environment(\.dismiss) var dismiss
    
    
    @State private var newListName: String = ""

    var body: some View {
        NavigationView {
            List {
                
                Section(header: Text("Criar Nova Lista")) {
                    HStack {
                        TextField("Nome da Nova Lista", text: $newListName)
                        
                        Button("Criar") {
                            guard !newListName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                            
                            viewModel.criarNovaLista(nome: newListName)
                            newListName = ""
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(newListName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }

                
                Section(header: Text("Minhas Listas")) {
                    
                    ForEach(viewModel.todasAsListas) { list in
                        HStack {
                            Text(list.name)
                            Spacer()
                            
                            if list.id == viewModel.listaAtual?.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.selecionarLista(list)
                            dismiss()
                        }
                    }
                    .onDelete(perform: deleteLists)
                }
            }
            .navigationTitle("Gerenciar Listas")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func deleteLists(at offsets: IndexSet) {
        viewModel.deleteListas(at: offsets)
    }
}
