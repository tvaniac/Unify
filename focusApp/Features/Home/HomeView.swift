//import SwiftUI
//
//struct HomeView: View {
//    @EnvironmentObject var coordinator: AppCoordinator
//
//    var body: some View {
//        GeometryReader { geometry in
//            VStack(spacing: 20) {
//                HStack {
//                    Spacer()
//                    Button(action: {
//                        print("Bantuan diklik")
//                    }) {
//                        Image(systemName: "questionmark.circle")
//                            .font(.title2)
//                            .foregroundColor(.gray)
//                    }
//                    .buttonStyle(PlainButtonStyle())
//                }
//                .padding(.horizontal)
//
//                Spacer()
//
//                VStack(spacing: 20) {
//                    HStack(spacing: 20) {
//                        alertModeButton
//                        quietModeButton
//                    }
//
//                    historyButton
//                }
//                .frame(maxWidth: 600) // Membatasi lebar di layar besar
//                .padding(.horizontal, 40)
//
//                Spacer()
//            }
//            .padding(30)
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .background(Color.white)
//        }
//        .toolbar {
//            ToolbarItem(placement: .navigation) {
//                EmptyView()
//            }
//            ToolbarItem(placement: .principal) {
//                EmptyView()
//            }
//        }
//    }
//
//    private var alertModeButton: some View {
//        Button {
//            coordinator.currentView = .alertMode
//        } label: {
//            VStack {
//                Image("bell")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(height: 70)
//                    .padding(.bottom, 5)
//                Text("Alert Mode")
//                    .font(.title)
//                    .fontWeight(.semibold)
//                    .foregroundColor(Color("textApp"))
//                Text("No focus? Big pop-up!")
//                    .fontWeight(.light)
//                    .foregroundColor(Color("textApp"))
//            }
//            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 250)
//            .background(
//                LinearGradient(
//                    colors: [Color("startAlertMode"), Color("stopAlertMode")],
//                    startPoint: .top,
//                    endPoint: .bottom
//                )
//            )
//            .cornerRadius(15)
//            .shadow(radius: 5)
//        }
//        .buttonStyle(PlainButtonStyle())
//    }
//
//    private var quietModeButton: some View {
//        Button {
//            coordinator.currentView = .quietMode
//        } label: {
//            VStack {
//                Image("moon")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(height: 70)
//                    .padding(.bottom, 5)
//                Text("Quiet Mode")
//                    .font(.title)
//                    .fontWeight(.semibold)
//                    .foregroundColor(Color("textApp"))
//                Text("Deep mode, no interruptions")
//                    .fontWeight(.light)
//                    .foregroundColor(Color("textApp"))
//            }
//            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 250)
//            .background(
//                LinearGradient(
//                    colors: [Color("startQuietMode"), Color("stopQuietMode")],
//                    startPoint: .top,
//                    endPoint: .bottom
//                )
//            )
//            .cornerRadius(15)
//            .shadow(radius: 5)
//        }
//        .buttonStyle(PlainButtonStyle())
//    }
//
//    private var historyButton: some View {
//        Button {
//            coordinator.currentView = .history
//        } label: {
//            Text("History")
//                .font(.title)
//                .fontWeight(.semibold)
//                .foregroundColor(Color("textApp"))
//                .frame(minWidth: 0, maxWidth: .infinity)
//                .frame(height: 70)
//                .background(
//                    LinearGradient(
//                        colors: [Color("startHistoryMode"), Color("stopHistoryMode")],
//                        startPoint: .topLeading,
//                        endPoint: .bottomTrailing
//                    )
//                )
//                .cornerRadius(15)
//                .shadow(radius: 5)
//        }
//        .buttonStyle(PlainButtonStyle())
//    }
//}
//
//#Preview {
//    HomeView()
//        .environmentObject(AppCoordinator())
//        .frame(width: 1200, height: 800) // Preview resolusi besar
//}


//import SwiftUI
//
//struct HomeView: View {
//    @EnvironmentObject var coordinator: AppCoordinator
//
//    var body: some View {
//        GeometryReader { geometry in
//            VStack(spacing: 40) {
//                HStack {
//                    Spacer()
//                    Button(action: {
//                        print("Bantuan diklik")
//                    }) {
//                        Image(systemName: "questionmark.circle")
//                            .font(.title2)
//                            .foregroundColor(.gray)
//                    }
//                    .buttonStyle(PlainButtonStyle())
//                }
//                .padding(.horizontal)
//
//                Spacer()
//
//                HStack(spacing: 40) {
//                    alertModeButton
//                    quietModeButton
//                }
//                .frame(height: 250) // Tinggi tombol atas
//
//                historyButton
//                    .frame(height: 90)
//
//                Spacer()
//            }
//            .padding(.horizontal, 60)
//            .padding(.vertical, 40)
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .background(Color.white)
//        }
//    }
//
//    private var alertModeButton: some View {
//        Button {
//            coordinator.currentView = .alertMode
//        } label: {
//            VStack {
//                Spacer()
//                Image("bell")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(height: 100) // Icon besar
//                Text("Alert Mode")
//                    .font(.title)
//                    .fontWeight(.semibold)
//                    .foregroundColor(Color("textApp"))
//                Text("No focus? Big pop-up!")
//                    .fontWeight(.light)
//                    .foregroundColor(Color("textApp"))
//                Spacer()
//            }
//            .padding()
//            .frame(maxWidth: .infinity)
//            .background(
//                LinearGradient(
//                    colors: [Color("startAlertMode"), Color("stopAlertMode")],
//                    startPoint: .top,
//                    endPoint: .bottom
//                )
//            )
//            .cornerRadius(20)
//            .shadow(radius: 5)
//        }
//        .buttonStyle(PlainButtonStyle())
//    }
//
//    private var quietModeButton: some View {
//        Button {
//            coordinator.currentView = .quietMode
//        } label: {
//            VStack {
//                Spacer()
//                Image("moon")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(height: 100)
//                Text("Quiet Mode")
//                    .font(.title)
//                    .fontWeight(.semibold)
//                    .foregroundColor(Color("textApp"))
//                Text("Deep mode, no interruptions")
//                    .fontWeight(.light)
//                    .foregroundColor(Color("textApp"))
//                Spacer()
//            }
//            .padding()
//            .frame(maxWidth: .infinity)
//            .background(
//                LinearGradient(
//                    colors: [Color("startQuietMode"), Color("stopQuietMode")],
//                    startPoint: .top,
//                    endPoint: .bottom
//                )
//            )
//            .cornerRadius(20)
//            .shadow(radius: 5)
//        }
//        .buttonStyle(PlainButtonStyle())
//    }
//
////    private var historyButton: some View {
////        Button {
////            coordinator.currentView = .history
////        } label: {
////            Text("History")
////                .font(.title2)
////                .fontWeight(.semibold)
////                .foregroundColor(Color("textApp"))
////                .frame(maxWidth: .infinity)
////                .background(
////                    LinearGradient(
////                        colors: [Color("startHistoryMode"), Color("stopHistoryMode")],
////                        startPoint: .topLeading,
////                        endPoint: .bottomTrailing
////                    )
////                )
////                .cornerRadius(20)
////                .shadow(radius: 5)
////        }
////        .buttonStyle(PlainButtonStyle())
////    }
//    private var historyButton: some View {
//        Button {
//            coordinator.currentView = .history
//        } label: {
//            ZStack {
//                RoundedRectangle(cornerRadius: 15)
//                    .fill(
//                        LinearGradient(
//                            colors: [Color("startHistoryMode"), Color("stopHistoryMode")],
//                            startPoint: .topLeading,
//                            endPoint: .bottomTrailing
//                        )
//                    )
//                    .frame(height: 100) // ✅ Inilah tinggi sebenarnya
//                
//                Text("History")
//                    .font(.title)
//                    .fontWeight(.semibold)
//                    .foregroundColor(Color("textApp"))
//            }
//            .shadow(radius: 5)
//        }
//        .buttonStyle(PlainButtonStyle())
//    }
//
//}
//
//#Preview {
//    HomeView()
//        .environmentObject(AppCoordinator())
//        .frame(width: 1300, height: 800) // Besar seperti screenshot kamu
//}

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: geometry.size.height * 0.05) { // spacing juga responsif
//                HStack {
//                    Spacer()
//                    Button(action: {
//                        print("Bantuan diklik")
//                    }) {
//                        Image(systemName: "questionmark.circle")
//                            .font(.title2)
//                            .foregroundColor(.gray)
//                    }
//                    .buttonStyle(PlainButtonStyle())
//                }
//                .padding(.horizontal)
//
//                Spacer(minLength: geometry.size.height * 0.05)
                Spacer()
                Spacer() 
                // Tombol-tombol utama
                HStack(spacing: geometry.size.width * 0.03) {
                    alertModeButton(height: geometry.size.height * 0.3)
                    quietModeButton(height: geometry.size.height * 0.3)
                }

                historyButton(height: geometry.size.height * 0.12)

                Spacer(minLength: geometry.size.height * 0.05)
            }
            .padding(.horizontal, geometry.size.width * 0.05)
            .padding(.vertical, geometry.size.height * 0.05)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
        }
    }


    private func alertModeButton(height: CGFloat) -> some View {
        Button {
            coordinator.currentView = .alertMode
        } label: {
            VStack {
                Spacer()
                Image("bell")
                    .resizable()
                    .scaledToFit()
                    .frame(height: height * 0.45) // icon ~45% tinggi tombol
                Text("Alert Mode")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("textApp"))
                Text("No focus? Big pop-up!")
                    .fontWeight(.light)
                    .foregroundColor(Color("textApp"))
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: height)
            .background(LinearGradient(
                colors: [Color("startAlertMode"), Color("stopAlertMode")],
                startPoint: .top,
                endPoint: .bottom))
            .cornerRadius(20)
            .shadow(radius: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }


    private func quietModeButton(height: CGFloat) -> some View {
        Button {
            coordinator.currentView = .quietMode
        } label: {
            VStack {
                Spacer()
                Image("moon")
                    .resizable()
                    .scaledToFit()
                    .frame(height: height * 0.45)
                Text("Quiet Mode")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("textApp"))
                Text("Deep mode, no interruptions")
                    .fontWeight(.light)
                    .foregroundColor(Color("textApp"))
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: height)
            .background(LinearGradient(
                colors: [Color("startQuietMode"), Color("stopQuietMode")],
                startPoint: .top,
                endPoint: .bottom))
            .cornerRadius(20)
            .shadow(radius: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func historyButton(height: CGFloat) -> some View {
        Button {
            coordinator.currentView = .history
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        LinearGradient(
                            colors: [Color("startHistoryMode"), Color("stopHistoryMode")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: height)

                Text("History")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("textApp"))
            }
            .shadow(radius: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }

}

#Preview {
    HomeView()
        .environmentObject(AppCoordinator())
        .frame(width: 1300, height: 800) // Besar seperti screenshot kamu
}
