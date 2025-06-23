import SwiftUI

struct CameraSection: View {
    @ObservedObject var cameraManager: CameraManager

    var body: some View {
        CameraFeedView(cameraManager: cameraManager)
            .frame(maxWidth: .infinity, minHeight: 300)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
}

