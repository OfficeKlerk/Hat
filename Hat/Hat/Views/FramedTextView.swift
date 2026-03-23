import SwiftUI

struct FramedTextView: View {
    var text: String
    var fontSize: CGFloat = 40
    
    var body: some View {
        Text(text)
            .frame(width: 280, height: 50)
            .background(.blue)
            .foregroundColor(.white)
            .font(.system(size: fontSize, weight: .bold, design: .default))
            .cornerRadius(10.0)
    }
}

#Preview {
    VStack(spacing: 20) {
        FramedTextView(text: "ОБЫЧНЫЙ")
        
        FramedTextView(text: "Длинный текст кнопки", fontSize: 22)
    }
}
