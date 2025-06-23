import SwiftUI

struct StartButton: View {
    var title: String
    var color: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(width: 250, height: 50)
                .background(color)
                .cornerRadius(25)
                .shadow(radius: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

