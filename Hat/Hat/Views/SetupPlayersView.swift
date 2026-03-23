import SwiftUI

struct SetupPlayersView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        Form {
            Section(header: Text("Правила игры")) {
                Stepper("Время на ход: \(viewModel.roundDuration) сек", value: $viewModel.roundDuration, in: 10...120, step: 10)
            }
            
            Section(header: Text("Игроки")) {
                ForEach($viewModel.players) { $player in
                    TextField("Имя", text: $player.name)
                        .disableAutocorrection(true)
                }
                .onDelete(perform: viewModel.removePlayer)
                .onMove(perform: viewModel.movePlayer)
                
                Button(action: {
                    viewModel.addPlayer()
                }) {
                    HStack {
                        Image(systemName: "person.crop.circle.badge.plus")
                        Text("Добавить игрока")
                    }
                }
            }
        }
        .navigationTitle("Настройки")
        .toolbar { EditButton() }
    }
}

#Preview {
    NavigationStack {
        SetupPlayersView(viewModel: GameViewModel())
    }
}
