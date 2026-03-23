import SwiftUI

struct CurrentResultsView: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var path: [Route]
    
    var body: some View {
        VStack {
            Text("Текущий счет")
                .font(.largeTitle)
                .bold()
                .padding(.top)
            
            List {
                ForEach(viewModel.players.sorted(by: { $0.score > $1.score })) { player in
                    HStack {
                        Text(player.name)
                            .font(.headline)
                        Spacer()
                        Text("\(player.score) очков")
                            .bold()
                            .foregroundColor(.blue)
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .navigationTitle("Счет")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    CurrentResultsView(viewModel: GameViewModel(), path: .constant([]))
}
