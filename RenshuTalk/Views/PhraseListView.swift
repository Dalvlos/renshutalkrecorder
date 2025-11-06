
import SwiftUI

struct PhraseListView: View {
    
    @EnvironmentObject var viewModel: PhraseViewModel 

    var body: some View {
        List {
            
            if let lista = viewModel.listaAtual {
                
                ForEach(lista.phrases) { phrase in
                    HStack {
                        
                        Button(action: {
                            togglePlayback(for: phrase)
                        }) {
                            let isPlaying = viewModel.currentPlayingID == phrase.id
                            
                            Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                                .font(.title2)
                                .foregroundColor(isPlaying ? .red : .blue)
                        }
                        .buttonStyle(.plain)

                        Text(phrase.text)
                            .font(.headline)

                        Spacer()
                    }
                }
                .onDelete(perform: deleteItems)
                
            } else {
                Text("Nothing Selected")
                    .foregroundColor(.gray)
                    .italic()
            }
        }
    }
    
    
    private func deleteItems(at offsets: IndexSet) {
        viewModel.deleteFrases(at: offsets)
    }
    
    
    private func togglePlayback(for phrase: PhraseItem) {
        print("Trying to Play:", phrase.audioFileName)
        if viewModel.currentPlayingID == phrase.id {
            viewModel.stopPlayback()
        } else {
            viewModel.playAudio(named: phrase.audioFileName, id: phrase.id)
        }
    }
}
