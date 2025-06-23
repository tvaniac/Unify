import SwiftUI
import AVFoundation

struct QuietModeView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var statsManager: StatsManager
    @StateObject private var cameraManager = CameraManager()

    var body: some View {
        VStack(spacing: 20) {
            // MARK: - Header
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

            // MARK: - Camera View
            CameraView()
                .environmentObject(cameraManager)
                .aspectRatio(CGSize(width: 1280, height: 720), contentMode: .fit)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .clipped()

            Spacer()
            
            // MARK: - Start Button (Corrected)
            Button(action: {
                print("Start Quiet Mode Clicked")
                
                // --- THIS IS THE CORRECT ORDER ---
                
                // 1. FIRST: Set up and start the recording session with the initial state.
                statsManager.startSession(initialState: cameraManager.drowsinessState)
                
                // 2. SECOND: Start the UI mode (which minimizes the app).
                coordinator.startMode(type: .quietMode)
                coordinator.closeLostOverlay()
                coordinator.closeDistractedOverlay()
                
            }) {
                Text("Start Quiet Mode")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 250, height: 50)
                    .background(Color("startQuietMode"))
                    .cornerRadius(25)
                    .shadow(radius: 5)
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        // MARK: - View Lifecycle
        .onAppear {
            cameraManager.setStatsManager(statsManager)
            cameraManager.setupSession()
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
            ToolbarItem(placement: .navigation) {
                EmptyView()
            }
        }
    }
}
