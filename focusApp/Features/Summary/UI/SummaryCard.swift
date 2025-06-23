import SwiftUI

struct SummaryCard: View {
    let percentage: Int
    let color: Color
    let title: String
    let duration: String

    var body: some View {
        VStack(spacing: 6) {
            Text("\(percentage)%")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(color)

            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.black)

            Text(duration)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(width: 140, height: 140)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .gray.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}
