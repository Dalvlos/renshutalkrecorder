
import SwiftUI

struct ListSelectionView: View {
    
    @EnvironmentObject var viewModel: PhraseViewModel
    
    @Environment(\.dismiss) var dismiss
    
    
    @State private var newListName: String = ""

    var body: some View {
       
        NavigationView {
            List {
                
                Section(header: Text("Create New Play List")) {
                    HStack {
                        TextField("List Name", text: $newListName)
                        
                        Button("Create") {
                            guard !newListName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                            
                            viewModel.criarNovaLista(nome: newListName)
                            newListName = ""
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(newListName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }

                
                Section(header: Text("My play list")) {
                    
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
            .navigationTitle("Manager Contents")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
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
