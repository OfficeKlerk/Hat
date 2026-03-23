import SwiftUI

struct ResultsView: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var path: [Route]
    
    var body: some View {
        VStack {
            Text(viewModel.wordsInHat.isEmpty ? "Конец игры!" : "Результаты игры")
                .font(.largeTitle)
                .bold()
                .padding(.top)
            
            if viewModel.wordsInHat.isEmpty {
                Text("Слова в шляпе закончились")
                    .foregroundColor(.gray)
                    .padding(.bottom)
            } else {
                Text("Игра завершена досрочно")
                    .foregroundColor(.gray)
                    .padding(.bottom)
            }
            
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
                }
            }
            
            Button(action: {
                path.removeAll()
            }) {
                Text("В главное меню")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    let mockViewModel = GameViewModel()
    return ResultsView(viewModel: mockViewModel, path: .constant([]))
}
