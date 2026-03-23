import SwiftUI

struct OnlineChatView: View {
    @ObservedObject var viewModel: OnlineGameViewModel
    @Binding var path: [Route]
    @State private var currentMessage: String = ""
    
    var body: some View {
        VStack {
            VStack {
                if viewModel.isMyTurnToExplain {
                    Text("Объясни слово:")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text(viewModel.currentWordToExplain)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.blue)
                } else {
                    Text("Кто-то объясняет слово...")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(15)
            .padding(.horizontal)
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.displayMessages) { msg in
                            let isMyMessage = (msg.player.id == viewModel.myPlayerID)
                            let isWinningMessage = viewModel.winningMessageIDs.contains(msg.id)
                            
                            VStack(alignment: isMyMessage ? .trailing : .leading, spacing: 4) {
                                Text(viewModel.getPlayerName(by: msg.player.id))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 5)
                                
                                Text(msg.payload)
                                    .padding(10)
                                    .background(isWinningMessage ? Color.green.opacity(0.8) : (isMyMessage ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2)))
                                    .foregroundColor(.primary)
                                    .cornerRadius(10)
                            }
                            .frame(maxWidth: .infinity, alignment: isMyMessage ? .trailing : .leading)
                            .padding(.horizontal)
                            .id(msg.id)
                        }
                    }
                    .padding(.top)
                }
                .onChange(of: viewModel.displayMessages.count) { _ in
                    if let lastMessage = viewModel.displayMessages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            HStack {
                TextField(viewModel.isMyTurnToExplain ? "Объясните слово..." : "Ваш вариант...", text: $currentMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .submitLabel(.send)
                    .onSubmit { sendMessage() }
                
                Button(action: { sendMessage() }) {
                    Image(systemName: "paperplane.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding()
        }
        .navigationTitle("Чат")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onChange(of: viewModel.isTurnFinished) { isFinished in
            if isFinished {
                path.append(.onlineTurnResult)
            }
        }
    }
    
    private func sendMessage() {
        if !currentMessage.trimmingCharacters(in: .whitespaces).isEmpty {
            viewModel.sendChatMessage(currentMessage)
            currentMessage = ""
        }
    }
}

#Preview {
    let mock = OnlineGameViewModel()
    mock.isMyTurnToExplain = false
    mock.currentWordToExplain = "Ёлка"
    
    return NavigationStack {
        OnlineChatView(viewModel: mock, path: .constant([]))
    }
    .environment(\.locale, Locale(identifier: "ru"))
}
