import SwiftUI

struct DictionaryPreviewView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let dictionary: WordDictionary
    
    var body: some View {
        NavigationView {
            List {
                ForEach(dictionary.words, id: \.id) { word in
                    Text(word.text)
                        .font(.body)
                        .padding(.vertical, 4)
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle(dictionary.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Закрыть")
                            .fontWeight(.bold)
                    }
                }
            }
        }
    }
}
