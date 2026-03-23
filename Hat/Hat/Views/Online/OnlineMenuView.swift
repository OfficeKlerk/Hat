import SwiftUI

struct OnlineMenuView: View {
    @ObservedObject var viewModel: OnlineGameViewModel
    @Binding var path: [Route]
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Сетевая игра")
                .font(.largeTitle).bold()
            
            TextField("Твое имя", text: $viewModel.myName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 15) {
                Button(action: {
                    Task {
                        let success = await viewModel.createGameAndHost()
                        if success { path.append(.onlineLobby) }
                    }
                }) {
                    FramedTextView(text: "СОЗДАТЬ ИГРУ", fontSize: 30)
                }
                .disabled(viewModel.myName.isEmpty || viewModel.isLoading)
                
                Text("ИЛИ").foregroundColor(.gray)
                
                TextField("Код игры", text: $viewModel.joinCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: {
                    Task {
                        let success = await viewModel.joinGameByCode()
                        if success { path.append(.onlineLobby) }
                    }
                }) {
                    Text("ВОЙТИ ПО КОДУ")
                        .frame(width: 280, height: 50)
                        .background((viewModel.myName.isEmpty || viewModel.joinCode.isEmpty) ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .font(.system(size: 30, weight: .bold))
                        .cornerRadius(10)
                }
                .disabled(viewModel.myName.isEmpty || viewModel.joinCode.isEmpty || viewModel.isLoading)
            }
            
            if viewModel.isLoading {
                ProgressView("Связь с сервером...")
                    .padding()
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Меню")
    }
}

#Preview {
    NavigationStack {
        OnlineMenuView(
            viewModel: OnlineGameViewModel(),
            path: .constant([])
        )
    }
}
