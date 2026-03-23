import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var path: [Route]
    @State private var isTurnActive = false
    
    var body: some View {
        VStack {
            if !isTurnActive {
                Spacer()
                
                Text("Объясняет: ")
                    .font(.largeTitle).bold()
                    .padding()
                    .foregroundColor(.gray)
                Text("\(viewModel.activePlayer.name)")
                    .font(.largeTitle).bold()
                    .padding()
                
                Spacer()
                
                Text("Слов в шляпе: \(viewModel.wordsInHat.count)")
                    .foregroundColor(.gray)
                
                Button(action: {
                    isTurnActive = true
                    viewModel.startTurn()
                }) {
                    FramedTextView(text: "Начать ход")
                }
                .padding(.bottom, 20)
                
                Button(action: {
                    path.append(.currentResults)
                }) {
                    Text("Текущий счет")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding()
                }
                
                Spacer()
            } else {
                Spacer()
                FramedTextView(text: String(format: "00:%02d", viewModel.timeLeft))
                Spacer()
                
                if let currentWord = viewModel.wordsInHat.first {
                    Text(currentWord.text)
                        .font(.system(size: 60, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.1) 
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    Text("Слова закончились!")
                        .font(.title)
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    Button(action: { viewModel.wordSkipped() }) {
                        Image(systemName: "xmark.circle.fill").resizable().frame(width: 80, height: 80).foregroundColor(.red)
                    }
                    Spacer()
                    Button(action: { viewModel.wordGuessed() }) {
                        Image(systemName: "checkmark.circle.fill").resizable().frame(width: 80, height: 80).foregroundColor(.green)
                    }
                    Spacer()
                }
                Spacer()
                
                Button("Завершить ход досрочно") {
                    viewModel.endTurnEarly()
                    isTurnActive = false
                    path.append(.turnReview)
                }.foregroundColor(.red)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onChange(of: viewModel.timeLeft) { newValue in
            if newValue == 0 && isTurnActive {
                isTurnActive = false
                path.append(.turnReview)
            }
        }
        .onChange(of: viewModel.wordsInHat.isEmpty) { isEmpty in
            if isEmpty && isTurnActive {
                isTurnActive = false
                path.append(.turnReview)
            }
        }
    }
}

#Preview {
    GameView(viewModel: GameViewModel(), path: .constant([]))
}
