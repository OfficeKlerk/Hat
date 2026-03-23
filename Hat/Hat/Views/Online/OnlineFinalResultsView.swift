import SwiftUI

struct OnlineFinalResultsView: View {
    @ObservedObject var viewModel: OnlineGameViewModel
    @Binding var path: [Route]
    
    var body: some View {
        VStack {
            Text("Конец игры!")
                .font(.largeTitle).bold()
                .padding()
            
            List {
                ForEach(viewModel.finalScores, id: \.name) { player in
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
            
            Button(action: {
                viewModel.leaveGame()
                path.removeAll()
            }) {
                FramedTextView(text: "В ГЛАВНОЕ МЕНЮ")
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    OnlineFinalResultsView(viewModel: OnlineGameViewModel(), path: .constant([]))
}
