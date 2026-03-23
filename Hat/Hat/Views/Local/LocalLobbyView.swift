import SwiftUI

struct LocalLobbyView: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var path: [Route]
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 10) {
                Text("Слов в шляпе: \(viewModel.wordsInHat.count)")
                    .font(.title2)
                    .foregroundColor(.gray)
                Text("Всего игроков: \(viewModel.players.count)")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
            .padding()
            
            List(viewModel.players) { player in
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.blue)
                    Text(player.name)
                        .font(.headline)
                }
            }
            
            Spacer()
            
            Button(action: {
                path.append(.game)
            }) {
                FramedTextView(text: "Начать")
            }
            .padding(.bottom, 40)
        }
        .navigationTitle("Лобби")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let mock = GameViewModel()
    mock.prepareGame()
    return LocalLobbyView(viewModel: mock, path: .constant([]))
}
