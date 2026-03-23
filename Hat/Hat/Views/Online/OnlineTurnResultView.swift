import SwiftUI

struct OnlineTurnResultView: View {
    @ObservedObject var viewModel: OnlineGameViewModel
    @Binding var path: [Route]
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Слово угадано!")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.green)
            
            Text(viewModel.lastGuessedWord)
                .font(.system(size: 50, weight: .black))
            
            Text("Победитель раунда:\n\(viewModel.lastWinnerName)")
                .font(.title2)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
            
            Spacer().frame(height: 50)
            
            if viewModel.isHost {
                Button(action: {
                    if viewModel.isGameOver {
                        path.append(.onlineFinalResults)
                    } else {
                        viewModel.startNextTurn()
                        if !path.isEmpty {
                            path.removeLast()
                        }
                    }
                }) {
                    FramedTextView(text: viewModel.isGameOver ? "ИТОГИ ИГРЫ" : "СЛЕДУЮЩИЙ ХОД")
                }
                
                if !viewModel.isGameOver {
                    Button(action: {
                        viewModel.endGameEarly()
                        path.append(.onlineFinalResults)
                    }) {
                        Text("ЗАВЕРШИТЬ ИГРУ")
                            .font(.headline)
                            .foregroundColor(.red)
                            .padding(.top, 10)
                    }
                }
                
            } else {
                Text("Ждем когда хост начнет следующий ход...")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Выйти") {
                    viewModel.leaveGame()
                    path.removeAll()
                }
            }
        }
        .onChange(of: viewModel.isTurnFinished) { isFinished in
            if !isFinished && !path.isEmpty {
                path.removeLast()
            }
        }
        .onChange(of: viewModel.isGameOver) { isOver in
            if isOver && path.last != .onlineFinalResults {
                path.append(.onlineFinalResults)
            }
        }
    }
}
