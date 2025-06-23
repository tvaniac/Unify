import SwiftUI

struct FocusDistractedButton: View {
    var title: String
    var colorName: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.vertical, 20)
                .padding(.horizontal, 90)
                .background(Color(colorName))
                .cornerRadius(45)
                .shadow(radius: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
