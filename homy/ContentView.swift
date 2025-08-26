import SwiftUI

enum AppScreen {
    case welcome
    case onboarding
    case main
}


struct ContentView: View {
    @AppStorage("WelcomeScreenShown") private var welcomeScreenShown = false
    @State private var selectedTab = 0
    @State private var currentScreen: AppScreen = .welcome

    var body: some View {
        Group {
            switch currentScreen {
            case .welcome:
                WelcomeView(onNext: {
                    welcomeScreenShown = true
                    currentScreen = .onboarding
                })
            case .onboarding:
                SecondPage(onContinue: {
                    currentScreen = .main
                })
            case .main:
                MainView(selection: $selectedTab)
            }
        }
        .onAppear {
            if welcomeScreenShown {
                currentScreen = .main
            }
        }
    }
}



struct MainView: View {
    @Binding var selection: Int
    var body: some View {
        TabView(selection: $selection) {
        NavigationView {
            VStack {
                Image(systemName: "globe")
                Text("Hello World!")
                    .font(.title)
            }
            .padding()
        }
        .tabItem {
            Image(systemName: "house.fill")
            Text("Home")
        }
        .tag(0)
        }
    }
}

struct WelcomeView: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            Text("Welcome to Homy")
                .font(.largeTitle)
                .bold()

            // Your InformationDetailView list here...

            Button("Get Started") {
                onNext()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(15)
        }
        .padding()
    }
}

struct SecondPage: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            Text("Add Your First Smart Device")
                .font(.largeTitle)
                .bold()

            Button("Continue to App") {
                onContinue()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(15)
        }
        .padding()
    }
}



#Preview {
    ContentView()
}
