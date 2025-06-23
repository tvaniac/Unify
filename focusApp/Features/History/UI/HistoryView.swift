//import SwiftUI
//
//// The SessionSummary and HistorySection can be removed as we'll use the core models directly.
//struct HistorySection: Identifiable {
//    let id = UUID()
//    let date: String
//    let sessions: [CompletedSession] // Changed from SessionSummary to CompletedSession
//}
//
//
//struct HistoryView: View {
//    @EnvironmentObject var coordinator: AppCoordinator
//    @State private var historySections: [HistorySection] = []
//    @State private var isLoading = true
//    @State private var selectedSession: CompletedSession? // State to trigger the sheet
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            // MARK: - Header and Back Button
//            ZStack {
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
////
//                Text("History")
//                    .font(.title2.bold())
//                    .fontWeight(.semibold)
//                    .foregroundColor(Color("textApp"))
//            }
//
//
//            // MARK: - Main Content
//            if isLoading {
//                Spacer()
//                ProgressView("Loading History...")
//                    .frame(maxWidth: .infinity)
//                Spacer()
//            } else if historySections.isEmpty {
//                // MARK: - Empty State
//                Spacer()
//                VStack {
//                    Image(systemName: "doc.text.magnifyingglass")
//                        .font(.system(size: 40))
//                        .foregroundColor(.gray)
//                        .padding(.bottom, 5)
//                    Text("No History Found")
//                        .font(.headline)
//                    Text("Complete a session to see your history here.")
//                        .foregroundColor(.secondary)
//                }
//                .frame(maxWidth: .infinity)
//                Spacer()
//            } else {
//                // MARK: - History List
//                ScrollView {
//                    ForEach(Array(historySections.enumerated()), id: \.element.id) { index, section in
//                        VStack(alignment: .leading, spacing: 10) {
//                            Text(section.date)
//                                .font(.headline)
//                                .foregroundColor(Color("textApp"))
//                                .padding(.leading, 8)
//
//                            ForEach(section.sessions) { session in
//                                // Pass the full session object to the row view
//                                HistoryRowView(session: session)
//                                    .onTapGesture {
//                                        // Set the selected session to show the detail sheet
//                                        self.selectedSession = session
//                                    }
//                            }
//                        }
//                        .padding(.top, index == 0 ? 0 : 24)
//                    }
//                }
//            }
//        }
//        .padding(30)
//        .background(Color(.white))
//        .onAppear(perform: loadHistory)
//        // MARK: - Sheet Presentation
//        // This modifier presents the SessionDetailView when selectedSession is not nil
////        .sheet(item: $selectedSession) { session in
////            SessionDetailView(session: session)
//        .sheet(item: $selectedSession) { session in SessionDetailView(session: session)
//            // --- Pilihan Ukuran Pop-up Responsif ---
//            // Pilih salah satu atau kombinasi sesuai kebutuhan Anda:
//                // 1. Sheet mengisi hampir seluruh layar
//                .presentationDetents([.large])
//
//                // 2. Sheet mengisi setengah dan hampir penuh layar (pengguna bisa swipe)
////                 .presentationDetents([.medium, .large])
//
//                // 3. Sheet mengisi 90% dari tinggi layar
//                // .presentationDetents([.fraction(0.9)])
//
//                // 4. Sheet mengisi 75% dari tinggi layar
//                // .presentationDetents([.fraction(0.75)])
//
//                // Catatan: .presentationDetents memerlukan iOS 16 atau lebih baru.
//                // Jika Anda menargetkan versi iOS yang lebih lama, Anda mungkin perlu solusi berbeda (misal: .fullScreenCover)
//        }
//    }
//    
//    // --- The `formatDuration` helper here is part of `HistoryView` but seems unused directly by `HistoryRowView`.
//    // --- `HistoryRowView` has its own formatter. I'll modify `HistoryRowView` directly.
//    /*
//    private func formatDuration(_ duration: TimeInterval) -> String {
//        let formatter = DateComponentsFormatter()
//        formatter.allowedUnits = [.hour, .minute, .second]
//        formatter.unitsStyle = .abbreviated
//        return formatter.string(from: duration) ?? "0s"
//    }
//    */
//
//    /// Loads and processes session data from storage.
//    private func loadHistory() {
//        let sessions = HistoryStorage.shared.loadAllSessions()
//        self.historySections = groupSessionsByDate(sessions)
//        self.isLoading = false
//    }
//
//    /// Groups sessions into sections based on their date.
//    private func groupSessionsByDate(_ sessions: [CompletedSession]) -> [HistorySection] {
//        guard !sessions.isEmpty else { return [] }
//        
//        let formatter = DateFormatter()
//        let calendar = Calendar.current
//
//        let groupedByDateComponent = Dictionary(grouping: sessions) { session in
//            calendar.startOfDay(for: session.startTime)
//        }
//
//        let sortedDates = groupedByDateComponent.keys.sorted(by: >)
//
//        return sortedDates.map { date in
//            let dateString: String
//            if calendar.isDateInToday(date) {
//                dateString = "Today"
//            } else if calendar.isDateInYesterday(date) {
//                dateString = "Yesterday"
//            } else {
//                formatter.dateFormat = "MMMM d, yyyy"
//                dateString = formatter.string(from: date)
//            }
//            
//            // The dictionary now contains the full [CompletedSession] array
//            let sessionsForDate = groupedByDateComponent[date] ?? []
//            
//            return HistorySection(date: dateString, sessions: sessionsForDate)
//        }
//    }
//}
//
//
//// MARK: - History Row Subview (Updated)
//struct HistoryRowView: View {
//    // Now takes the full session object
//    let session: CompletedSession
//
//    // Formatter for the time string
//    private static let timeFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "h:mm a"
//        return formatter
//    }()
//    
//    // Formatter for the duration string - MODIFIED
//    private static let durationFormatter: DateComponentsFormatter = {
//        let formatter = DateComponentsFormatter()
//        formatter.allowedUnits = [.hour, .minute, .second] // Now includes seconds
//        formatter.unitsStyle = .full // Use full style (e.g., "1 hour 30 minutes 5 seconds")
//        formatter.zeroFormattingBehavior = .dropAll // Drop zero components like "0 hours"
//        return formatter
//    }()
//
//    // Helper function to handle special formatting for durations (e.g., "0 minutes" to "X seconds")
//    private func formattedDuration(from duration: TimeInterval) -> String {
//        if duration < 60 && duration > 0 {
//            // For durations less than 1 minute (but not zero), show only seconds
//            let secondsFormatter = DateComponentsFormatter()
//            secondsFormatter.allowedUnits = [.second]
//            secondsFormatter.unitsStyle = .full
//            secondsFormatter.zeroFormattingBehavior = .dropTrailing // Ensure "0 seconds" doesn't become empty if only seconds are allowed
//            return secondsFormatter.string(from: duration) ?? "\(Int(duration)) seconds" // Fallback to raw seconds
//        } else if duration == 0 {
//            return "0 seconds" // Explicitly show "0 seconds" for genuinely zero duration
//        } else {
//            // For 1 minute or more, use the standard durationFormatter
//            return Self.durationFormatter.string(from: duration) ?? "N/A"
//        }
//    }
//
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading, spacing: 4) {
//                HStack {
//                    Text("Session at \(Self.timeFormatter.string(from: session.startTime))")
//                        .fontWeight(.medium)
//                        .foregroundColor(Color("textApp"))
//                    
//                    Spacer()
//                    
//                    Text(formattedDuration(from: session.duration))
//                        .font(.subheadline)
//                        .foregroundColor(.white)
//                }
//
//                // Tambahan konten lain jika ada, misalnya tanggal atau deskripsi lainnya
//            }
//
//            Image(systemName: "chevron.right")
//                .foregroundColor(.white)
//        }
//        .padding()
//        .background(
//            LinearGradient(
//                colors: [Color("startHistoryMode"), Color("stopHistoryMode")],
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
//        )
//        .cornerRadius(10)
//        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
//    }
//}
//
//#Preview {
//    HistoryView()
//        .environmentObject(AppCoordinator())
//}
//


import SwiftUI

struct HistorySection: Identifiable {
    let id = UUID()
    let date: String
    let sessions: [CompletedSession]
}

struct HistoryView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var historySections: [HistorySection] = []
    @State private var isLoading = true
    @State private var selectedSession: CompletedSession?

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 16) {
                // MARK: - Header dan Tombol Kembali
                ZStack {
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
                        .buttonStyle(PlainButtonStyle()) // PlainButtonStyle bekerja baik di kedua platform
                        Spacer()
                    }
                    Text("History")
                        .font(.title2.bold())
                        .fontWeight(.semibold)
                        .foregroundColor(Color("textApp"))
                }
                .padding(.horizontal, 0)

                // MARK: - Konten Utama
                if isLoading {
                    Spacer()
                    ProgressView("Loading History...")
                        .frame(maxWidth: .infinity)
                    Spacer()
                } else if historySections.isEmpty {
                    // MARK: - Status Kosong
                    Spacer()
                    VStack {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                            .padding(.bottom, 5)
                        Text("No History Found")
                            .font(.headline)
                        Text("Complete a session to see your history here.")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    // MARK: - Daftar Riwayat
                    ScrollView {
                        ForEach(Array(historySections.enumerated()), id: \.element.id) { index, section in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(section.date)
                                    .font(.headline)
                                    .foregroundColor(Color("textApp"))
                                    .padding(.leading, 8)

                                ForEach(section.sessions) { session in
                                    HistoryRowView(session: session)
                                        .onTapGesture {
                                            self.selectedSession = session
                                        }
                                }
                            }
                            .padding(.top, index == 0 ? 0 : 24)
                            .padding(.horizontal, 20)
                        }
                    }
                }
            }
            .padding(30)
            .background(Color(.white))
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Memastikan view mengisi GeometryReader
        }
        .onAppear(perform: loadHistory)
        // MARK: - Sheet Presentation (Perhatikan Ini untuk macOS!)
        .sheet(item: $selectedSession) { session in
            SessionDetailView(session: session)
                // Menggunakan #if os(iOS) untuk modifier yang hanya berlaku di iOS
                #if os(iOS)
                .presentationDetents([.large]) // Hanya berfungsi di iOS 16+
                #endif
                // Untuk macOS, sheet akan menyesuaikan ukurannya dengan konten SessionDetailView.
                // Jika Anda ingin mengontrol ukuran sheet di macOS, Anda bisa menambahkan .frame() di sini:
                // .frame(width: 600, height: 800) // Contoh ukuran tetap untuk macOS
                // Atau:
                // .frame(minWidth: 400, idealWidth: 600, maxWidth: .infinity, minHeight: 500, idealHeight: 800, maxHeight: .infinity)
        }
    }

    /// Loads and processes session data from storage.
    private func loadHistory() {
        let sessions = HistoryStorage.shared.loadAllSessions()
        self.historySections = groupSessionsByDate(sessions)
        self.isLoading = false
    }

    /// Groups sessions into sections based on their date.
    private func groupSessionsByDate(_ sessions: [CompletedSession]) -> [HistorySection] {
        guard !sessions.isEmpty else { return [] }

        let formatter = DateFormatter()
        let calendar = Calendar.current

        let groupedByDateComponent = Dictionary(grouping: sessions) { session in
            calendar.startOfDay(for: session.startTime)
        }

        let sortedDates = groupedByDateComponent.keys.sorted(by: >)

        return sortedDates.map { date in
            let dateString: String
            if calendar.isDateInToday(date) {
                dateString = "Today"
            } else if calendar.isDateInYesterday(date) {
                dateString = "Yesterday"
            } else {
                formatter.dateFormat = "MMMM d, YYYY" // Pastikan format tahun yang benar
                dateString = formatter.string(from: date)
            }

            let sessionsForDate = groupedByDateComponent[date] ?? []

            return HistorySection(date: dateString, sessions: sessionsForDate)
        }
    }
}


// MARK: - History Row Subview
struct HistoryRowView: View {
    let session: CompletedSession

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    private static let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .full
        formatter.zeroFormattingBehavior = .dropAll
        return formatter
    }()

    private func formattedDuration(from duration: TimeInterval) -> String {
        if duration < 60 && duration > 0 {
            let secondsFormatter = DateComponentsFormatter()
            secondsFormatter.allowedUnits = [.second]
            secondsFormatter.unitsStyle = .full
            secondsFormatter.zeroFormattingBehavior = .dropTrailing
            return secondsFormatter.string(from: duration) ?? "\(Int(duration)) seconds"
        } else if duration == 0 {
            return "0 seconds"
        } else {
            return Self.durationFormatter.string(from: duration) ?? "N/A"
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Session at \(Self.timeFormatter.string(from: session.startTime))")
                        .fontWeight(.medium)
                        .foregroundColor(Color("textApp"))

                    Spacer()

                    Text(formattedDuration(from: session.duration))
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
            }

            Image(systemName: "chevron.right")
                .foregroundColor(.white)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color("startHistoryMode"), Color("stopHistoryMode")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}

#Preview {
    HistoryView()
        .environmentObject(AppCoordinator())
}
