import SwiftUI

struct TopBar: View {
    var onBack: () -> Void

    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
            .buttonStyle(PlainButtonStyle())
            Spacer()
        }
        .padding(.horizontal)
    }
}

