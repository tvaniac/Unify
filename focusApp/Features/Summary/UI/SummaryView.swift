//import SwiftUI
//
//struct SummaryView: View {
//    @EnvironmentObject var coordinator: AppCoordinator
//    let session: CompletedSession
//
//    @State private var categoryDurations: [StatCategory: TimeInterval] = [:]
//    @State private var totalConsideredDuration: TimeInterval = 0
//    @State private var focusPercentage: Int = 0 // New state to store calculated focus percentage
//
//    // Formatter for durations
//    private static let durationFormatter: DateComponentsFormatter = {
//        let formatter = DateComponentsFormatter()
//        formatter.allowedUnits = [.hour, .minute, .second]
//        formatter.unitsStyle = .full
//        formatter.zeroFormattingBehavior = .dropAll
//        return formatter
//    }()
//    
//    // Formatter for percentages
//    private static let percentageFormatter: NumberFormatter = {
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .percent
//        formatter.minimumFractionDigits = 0
//        formatter.maximumFractionDigits = 0
//        return formatter
//    }()
//
//    // MARK: - Properties
//    private let displayCategories: [StatCategory] = [.focus, .drowsy, .distracted, .onBreak]
//
//    // Computed property to determine the appropriate "Great Work" message
//    private var greatWorkMessage: (text: String, emoji: String) {
//        if focusPercentage >= 75 {
//            return ("You Nailed It", "🤩")
//        } else if focusPercentage >= 50 {
//            return ("Pretty Good", "😆")
//        } else if focusPercentage >= 25 {
//            return ("You Can Do Better", "😉")
//        } else {
//            return ("Focus is Off", "😵") // Default for lower focus or if no focus recorded
//        }
//    }
//
//    var body: some View {
//        ZStack(alignment: .topLeading) {
//            // Background gradient
//            LinearGradient(
//                gradient: Gradient(colors: [Color(hex: "#FAF4FD"), Color(hex: "#F1E5FF")]),
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
//            .ignoresSafeArea()
//
//            VStack(spacing: 20) {
//                // Back Button
//                HStack {
//                    Button(action: {
//                        coordinator.currentView = .home
//                    }) {
//                        Image(systemName: "chevron.left")
//                            .font(.caption2)
//                            .foregroundColor(Color("chevronLeft"))
//                            .frame(width: 20, height: 20)
//                            .background(Color("backChevronLeft"))
//                            .cornerRadius(12)
//                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
//                    }
//                    .buttonStyle(PlainButtonStyle())
//                    Spacer()
//                }
//                .padding(.horizontal)
//                .padding(.top, 20)
//                
//                Spacer()
//                
//                // Title and subtitle
//                VStack(spacing: 8) {
//                    Text("\(greatWorkMessage.text) \(greatWorkMessage.emoji)") // Dynamic message here
//                        .font(.system(size: 34, weight: .bold))
//                        .foregroundColor(.black)
//                    
//                    Text("You have worked for **\(SummaryView.durationFormatter.string(from: session.duration) ?? "N/A")**.")
//                        .font(.title3)
//                        .foregroundColor(.gray)
//                        .multilineTextAlignment(.center)
//                }
//                
//                // Summary cards - Dynamically generated
//                HStack(spacing: 20) {
//                    ForEach(displayCategories, id: \.self) { category in
//                        let duration = categoryDurations[category] ?? 0
//                        let percentage = totalConsideredDuration > 0 ? (duration / totalConsideredDuration) : 0
//                        
//                        // Display card if duration > 0 OR if the category is .focus (even if its duration is 0, to always show focus)
//                        if duration > 0 || category == .focus {
//                            SummaryCard(
//                                percentage: Int(percentage * 100),
//                                color: category.color,
//                                title: category.rawValue,
//                                duration: SummaryView.durationFormatter.string(from: duration) ?? "0 minutes"
//                            )
//                        }
//                    }
//                }
//                .padding(.top)
//                
//                Spacer()
//                
//                // Timeline bar
//                                TimelineBarView(session: session)
//                                    .frame(height: 170) // Use the full height of TimelineBarView
//                            }
//                            .padding(30)
////                HStack {
////                    VStack(alignment: .leading, spacing: 12) {
////                        Text("Timeline")
////                            .font(.headline)
////                            .foregroundColor(Color("textApp"))
////                        
////                        TimelineBarView(session: session)
////                            .frame(height: 40)
////                            .frame(maxWidth: .infinity)
////                            .clipShape(RoundedRectangle(cornerRadius: 20)) // Corner radius semua sisi
////                    }
////                    .padding()
////                    .background(Color.white) // Warna putih card
////                    .cornerRadius(25) // Radius semua sisi
////                    .shadow(color: Color.white.opacity(0.1), radius: 10, x: 0, y: 0) // Sama seperti card Focus, Drowsy, dll
////                }
////                .padding(.horizontal, -30) // Hilangkan padding dari parent agar benar-benar full
////            }
//
//        }
//        .navigationTitle("")
//        .navigationBarBackButtonHidden(true)
//        .toolbar {
//            ToolbarItem(placement: .navigation) { EmptyView() }
//        }
//        .onAppear {
//            // Calculate durations when the view appears
//            categoryDurations = session.calculateCategoryDurations()
//            
//            // Calculate total duration of relevant categories for percentage calculation
//            var calculatedTotalConsideredDuration: TimeInterval = 0
//            for category in displayCategories {
//                calculatedTotalConsideredDuration += categoryDurations[category] ?? 0
//            }
//            self.totalConsideredDuration = calculatedTotalConsideredDuration
//
//            // Calculate and set focus percentage
//            let focusDuration = categoryDurations[.focus] ?? 0
//            if totalConsideredDuration > 0 {
//                self.focusPercentage = Int((focusDuration / totalConsideredDuration) * 100)
//            } else {
//                self.focusPercentage = 0
//            }
//        }
//    }
//}
//

import SwiftUI

struct SummaryView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    let session: CompletedSession

    // MARK: - Static Formatters
    private static let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .full
        formatter.zeroFormattingBehavior = .dropAll
        return formatter
    }()
    
    private static let percentageFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    // MARK: - Properties
    private let displayCategories: [StatCategory] = [.focus, .drowsy, .distracted, .onBreak]

//    private var categoryDurations: [StatCategory: TimeInterval] {
//        session.calculateCategoryDurations()
//    }
//
//    private var totalConsideredDuration: TimeInterval {
//        displayCategories.reduce(0) { $0 + (categoryDurations[$1] ?? 0) }
//    }
    private var categoryDurations: [StatCategory: TimeInterval] {
            var durations = session.calculateCategoryDurations()
            let phoneDuration = durations[.phoneDistracted] ?? 0
            
            if phoneDuration > 0 {
                durations[.distracted, default: 0] += phoneDuration
            }
            
            durations[.phoneDistracted] = nil
            
            return durations
        }

        private var totalConsideredDuration: TimeInterval {
            return StatCategory.allCases.reduce(0) { $0 + (session.calculateCategoryDurations()[$1] ?? 0) }
        }


    private var focusPercentage: Int {
        let focusDuration = categoryDurations[.focus] ?? 0
        guard totalConsideredDuration > 0 else { return 0 }
        return Int((focusDuration / totalConsideredDuration) * 100)
    }

    private var greatWorkMessage: String {
        if focusPercentage >= 75 {
            return ("You Nailed It")
        } else if focusPercentage >= 50 {
            return ("Pretty Good")
        } else if focusPercentage >= 25 {
            return ("You Can Do Better")
        } else {
            return ("Focus is Off")
        }
    }

    // MARK: - View Body
    var body: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#FAF4FD"), Color(hex: "#F1E5FF")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

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
                .padding(.top, 20)
                
                // NEW: Trophy Image (conditional)
                // This image will only appear for the best performance.
                if focusPercentage >= 75 {
                    Image("1happy")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 180)
                        .padding(.bottom, 0) // Adds some space between the image and the text
                } else if focusPercentage >= 50 {
                    Image("2happyaja")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 180)
                        .padding(.bottom, 0) // Adds some space between the image and the text
                } else if focusPercentage >= 25 {
                    Image("3normal")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 180)
                        .padding(.bottom, 0) // Adds some space between the image and the text
                } else {
                    Image("4sad")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 180)
                        .padding(.bottom, 0) // Adds some space between the image and the text
                }
                
                // MARK: - Title and Subtitle (from SummaryView)
                VStack(spacing: 10) {
                    Text(greatWorkMessage)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.black)

                    Text("You have worked for **\(Self.durationFormatter.string(from: session.duration) ?? "N/A")**.")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }

                // MARK: - Summary Cards (from SummaryView)
                HStack(spacing: 20) {
                    ForEach(displayCategories, id: \.self) { category in
                        let duration = categoryDurations[category] ?? 0
                        let percentage = totalConsideredDuration > 0 ? (duration / totalConsideredDuration) : 0

                        if duration > 0 || category == .focus {
                            SummaryCard(
                                percentage: Int(percentage * 100),
                                color: category.color,
                                title: category.rawValue,
                                duration: Self.durationFormatter.string(from: duration) ?? "0 minute"
                            )
                        }
                    }
                }
                .padding(.top)

//                Spacer()

                TimelineBarView(session: session)
                    .frame(height: 160)
                    .cornerRadius(25)
            }
            .padding(30)
        }
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigation) { EmptyView() }
        }
    }
}
