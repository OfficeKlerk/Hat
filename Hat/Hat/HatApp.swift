import SwiftUI

@main
struct HatApp: App {
    @StateObject var gameViewModel = GameViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: gameViewModel)
        }
    }
}
