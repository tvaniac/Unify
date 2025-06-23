import SwiftUI

struct BreakOptionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var statsManager: StatsManager // <<< Add this
    @State private var navigateToBreakCountdown = false
    @State private var selectedBreakDuration: TimeInterval = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Color("yellow-lost")
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Spacer()

                    Text("⏰ Pick your break time")
                        .font(.system(size: 55, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text("Choose how long, then get back with a clear mind")
                        .font(.system(size: 28, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    HStack(spacing: 20) {
                        ForEach([5, 10, 15], id: \.self) { minute in
                            Button(action: {
                                print("\(minute) Menit Break dipilih")
                                selectedBreakDuration = TimeInterval(60)
                                
                                // <<< CALL START BREAK HERE, when a duration is chosen and the timer is about to begin
                                statsManager.startBreak()

                                navigateToBreakCountdown = true
                            }) {
                                Text("\(minute) Minutes")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 30)
                                    .padding(.horizontal, 60)
                                    .background(Color("brownButtonA"))
                                    .cornerRadius(15)
                                    .shadow(radius: 5)
                                    .padding(.top, 60)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.bottom, 20)

                    Button(action: {
                        print("Tombol Cancel diklik di BreakOptionView")
                        dismiss()
                        // If cancelling here means returning to a non-break state immediately
                        // and not starting a break, no statsManager.endBreak() is needed.
                        // However, if a break was *already started* (e.g., if this view is presented mid-break),
                        // you might need to handle that. Based on your flow, the break starts *after* selection.
                    }) {
                        Text("Back to focus")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 25)
                            .background(Color("brownButtonC"))
                            .cornerRadius(25)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Spacer()
                }
                .padding(30)
            }
            .navigationDestination(isPresented: $navigateToBreakCountdown) {
                BreakCountdownView(duration: selectedBreakDuration)
                    .environmentObject(coordinator)
                    .environmentObject(statsManager) // <<< Ensure statsManager is passed here
                    .onDisappear {
                        navigateToBreakCountdown = false
                    }
            }
            .navigationTitle("")
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigation) { EmptyView() }
                ToolbarItem(placement: .principal) { EmptyView() }
            }
        }
    }
}
