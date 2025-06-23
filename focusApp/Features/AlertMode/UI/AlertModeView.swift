import SwiftUI
import AVFoundation

struct AlertModeView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var statsManager: StatsManager
    @StateObject private var cameraManager = CameraManager()

    var body: some View {
        ZStack {
            // ==== LAYOUT UTAMA ====
            VStack(spacing: 20) {
                HStack {
                    Button(action: {
                        coordinator.currentView = .home
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.caption2)
                            .foregroundColor(Color("chevronLeft"))
                            .frame(width: 20, height: 20)
                            .background(Color("backChevronLeft"))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(PlainButtonStyle())
                    Spacer()
                }
                .padding(.horizontal)

                Spacer()

                
                // Replace the existing CameraView block with this one
                CameraView()
                    // Injects the cameraManager from the parent view
                    .environmentObject(cameraManager)
//                    .frame(minWidth: 640, minHeight: 360)
                    
                    // This is the key change:
                    // It forces the view into a 16:9 aspect ratio.
                    // The contentMode .fit ensures it scales down to fit the parent view's bounds
                    // while maintaining the aspect ratio perfectly.
                    .aspectRatio(CGSize(width: 1280, height: 720), contentMode: .fit)
                    
                    // By removing the separate .frame() modifier, the view's size is now
                    // governed purely by the aspectRatio and its parent container,
                    // making it "follow" the ratio strictly.
                    
                    // Standard styling
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .clipped()

                Spacer()

                Button(action: {
                    print("Start Alert Mode Clicked")
                    
                    // --- THIS IS THE MODIFIED LINE ---
                    // Pass the camera's current state directly to startSession.
                    statsManager.startSession(initialState: cameraManager.drowsinessState)
                    
                    coordinator.startMode(type: .alertMode)
                    // The two closeOverlay calls are good for resetting state
                    coordinator.closeLostOverlay()
                    coordinator.closeDistractedOverlay()
                }) {
                    Text("Start Alert Mode")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 250, height: 50)
                        .background(Color("startAlertMode"))
                        .cornerRadius(25)
                        .shadow(radius: 5)
                }
                .buttonStyle(PlainButtonStyle())

                Spacer()
            }
            .padding(30)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)

//            // ==== DEBUG FLOATING TOOLS ====
//            #if DEBUG
//            VStack {
//                Spacer()
//                HStack {
//                    Spacer()
//                    VStack(alignment: .trailing, spacing: 8) {
//                        Button("🔴 Trigger Lost") {
//                            coordinator.showLostOverlay()
//                        }
//                        Button("🟠 Trigger Distracted") {
//                            coordinator.showDistractedOverlay()
//                        }
//                    }
//                    .padding()
//                    .background(.ultraThinMaterial)
//                    .cornerRadius(12)
//                    .shadow(radius: 4)
//                    .padding()
//                }
//            }
//            #endif
        }
        .onAppear {
            cameraManager.setStatsManager(statsManager)
            cameraManager.setupSession()
            cameraManager.setCoordinator(coordinator)
            coordinator.statsManager = statsManager
        }
        .onDisappear {
            cameraManager.stopSession()
            statsManager.endSession()
            coordinator.closeLostOverlay()
            coordinator.closeDistractedOverlay()
        }
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigation) { EmptyView() }
            ToolbarItem(placement: .principal) { EmptyView() }
        }
    }
}

//#Preview {
//    AlertModeView()
//}
