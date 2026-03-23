import SwiftUI

enum Route: Hashable {
    case setup, dictionary, localLobby, game, turnReview, currentResults, results
    case onlineMenu, onlineLobby, onlineChat, onlineTurnResult, onlineFinalResults
}

struct ContentView: View {
    @ObservedObject var viewModel: GameViewModel
    @StateObject var onlineViewModel = OnlineGameViewModel()
    @State private var path = [Route]()
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 30) {
                Text("ШЛЯПА")
                    .font(.system(size: 60, weight: .black))
                
                NavigationLink(value: Route.setup) { FramedTextView(text: "Настройки", fontSize: 40) }
                NavigationLink(value: Route.dictionary) { FramedTextView(text: "Словари", fontSize: 40) }
                
                Spacer().frame(height: 50)
                
                Button(action: {
                    viewModel.prepareGame()
                    path.append(.localLobby)
                }) {
                    Text("ЛОКАЛЬНАЯ ИГРА")
                        .frame(width: 280, height: 50)
                        .background(viewModel.players.count < 2 ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .cornerRadius(10.0)
                }
                .disabled(viewModel.players.count < 2)
                
                Button(action: {
                    path.append(.onlineMenu)
                }) {
                    Text("ИГРА ОНЛАЙН")
                        .frame(width: 280, height: 50)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .cornerRadius(10.0)
                }
            }
            .padding()
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .setup: SetupPlayersView(viewModel: viewModel)
                case .dictionary: DictionarySelectionView(viewModel: viewModel)
                case .localLobby: LocalLobbyView(viewModel: viewModel, path: $path)
                case .game: GameView(viewModel: viewModel, path: $path)
                case .turnReview: TurnReviewView(viewModel: viewModel, path: $path)
                case .currentResults: CurrentResultsView(viewModel: viewModel, path: $path)
                case .results: ResultsView(viewModel: viewModel, path: $path)
                
                case .onlineMenu: OnlineMenuView(viewModel: onlineViewModel, path: $path)
                
                case .onlineLobby: OnlineLobbyView(viewModel: onlineViewModel, localViewModel: viewModel, path: $path)
                    
                case .onlineChat: OnlineChatView(viewModel: onlineViewModel, path: $path)
                case .onlineTurnResult: OnlineTurnResultView(viewModel: onlineViewModel, path: $path)
                case .onlineFinalResults: OnlineFinalResultsView(viewModel: onlineViewModel, path: $path)
                }
            }
        }
    }
}
