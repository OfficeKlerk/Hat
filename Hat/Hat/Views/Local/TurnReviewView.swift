import SwiftUI

struct TurnReviewView: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var path: [Route]
    
    var body: some View {
        VStack {
            Text("Проверка слов")
                .font(.largeTitle)
                .padding()
            Text("Объяснил или нет?")
                .foregroundColor(.gray)
            
            List {
                ForEach(viewModel.currentTurnWords.indices, id: \.self) { index in
                    Toggle(isOn: $viewModel.currentTurnWords[index].isGuessed) {
                        Text(viewModel.currentTurnWords[index].word.text)
                            .font(.title2)
                    }
                    .tint(.green)
                }
            }
            
            Button(action: {
                viewModel.finalizeTurn()
                if viewModel.wordsInHat.isEmpty {
                    path.append(.results)
                } else {
                    path.removeLast() 
                }
            }) {
                FramedTextView(text: "Передать телефон", fontSize: 28)
            }
            .padding()
            
            Button("Завершить игру досрочно") {
                viewModel.finalizeTurn()
                path.append(.results)
            }.foregroundColor(.red).padding(.bottom)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    TurnReviewView(viewModel: GameViewModel(), path: .constant([]))
}
