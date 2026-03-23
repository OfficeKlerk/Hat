import SwiftUI

struct OnlineLobbyView: View {
    @ObservedObject var viewModel: OnlineGameViewModel
    @ObservedObject var localViewModel: GameViewModel
    @Binding var path: [Route]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Комната ожидания")
                .font(.largeTitle).bold()
            
            VStack {
                Text("Код для приглашения:")
                    .foregroundColor(.gray)
                
                HStack {
                    Text(viewModel.joinCode)
                        .font(.system(size: 50, weight: .black))
                        .foregroundColor(.blue)
                    
                    Button(action: {
                        UIPasteboard.general.string = viewModel.joinCode
                    }) {
                        Image(systemName: "doc.on.doc")
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            
            Text("Игроки в комнате:")
                .font(.headline)
            
            List(viewModel.playersInLobby) { player in
                HStack {
                    Image(systemName: "person.fill").foregroundColor(.green)
                    Text(player.userName)
                        .font(.title3)
                }
            }
            
            Spacer()
            
            if viewModel.isHost {
                Button(action: {
                    localViewModel.prepareGame()
                    let wordsAsStrings = localViewModel.wordsInHat.map { $0.text }
                    viewModel.startOnlineGame(with: wordsAsStrings)
                    path.append(.onlineChat)
                }) {
                    FramedTextView(text: "НАЧАТЬ ИГРУ", fontSize: 24)
                }
                .disabled(viewModel.playersInLobby.count < 2)
                .opacity(viewModel.playersInLobby.count < 2 ? 0.5 : 1.0)
                .padding()
            } else {
                Text("Ожидаем, пока хост начнет игру...")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Выйти") {
                    viewModel.leaveGame()
                    path.removeLast()
                }
            }
        }
        .onChange(of: viewModel.isGameStarted) { started in
            if started && path.last != .onlineChat {
                path.append(.onlineChat)
            }
        }
    }
}
