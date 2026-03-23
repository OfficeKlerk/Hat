import SwiftUI
import UniformTypeIdentifiers

struct DictionarySelectionView: View {
    @ObservedObject var viewModel: GameViewModel
    
    @State private var showFileImporter = false
    @State private var showNameAlert = false
    @State private var newDictionaryName = ""
    @State private var temporarilyLoadedWords: [Word] = []
    @State private var dictionaryToPreview: WordDictionary? = nil
    
    var body: some View {
        VStack {
            Button(action: {
                showFileImporter = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Загрузить свой словарь")
                }
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            }
            .padding()
            
            List {
                Section(header: Text("Настройки игры")) {
                    Stepper("Слов в шляпе: \(viewModel.totalWordsInGame)", value: $viewModel.totalWordsInGame, in: 10...200, step: 5)
                }
                
                Section(header: Text("Доступные словари")) {
                    ForEach(viewModel.availableDictionaries) { dict in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(dict.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("\(dict.words.count) слов")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            if viewModel.selectedDictionaryID == dict.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                                    .bold()
                            }
                            
                            Button(action: {
                                dictionaryToPreview = dict
                            }) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                                    .padding(.leading, 10)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.selectedDictionaryID = dict.id
                        }
                    }
                }
            }
        }
        .navigationTitle("Словари")
        
        .sheet(item: $dictionaryToPreview) { dict in
            DictionaryPreviewView(dictionary: dict)
        }
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.plainText],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let selectedUrl = urls.first {
                    if selectedUrl.startAccessingSecurityScopedResource() {
                        if let words = viewModel.parseWordsFromFile(url: selectedUrl) {
                            temporarilyLoadedWords = words
                            showNameAlert = true
                        }
                        selectedUrl.stopAccessingSecurityScopedResource()
                    }
                }
            case .failure(let error):
                print("Ошибка выбора файла: \(error.localizedDescription)")
            }
        }
        .alert("Название словаря", isPresented: $showNameAlert) {
            TextField("Введите название", text: $newDictionaryName)
            
            Button("Сохранить") {
                let name = newDictionaryName.trimmingCharacters(in: .whitespaces).isEmpty ? "Мой словарь" : newDictionaryName
                viewModel.addNewCustomDictionary(name: name, words: temporarilyLoadedWords)
                newDictionaryName = ""
                temporarilyLoadedWords = []
            }
            
            Button("Отмена", role: .cancel) {
                newDictionaryName = ""
                temporarilyLoadedWords = []
            }
        } message: {
            Text("Успешно загружено слов: \(temporarilyLoadedWords.count)")
        }
    }
}

#Preview {
    NavigationStack {
        DictionarySelectionView(viewModel: GameViewModel())
    }
}
