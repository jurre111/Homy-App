import SwiftUI

struct ContentView: View {
    @AppStorage("WelcomeScreenShown") private var welcomeScreenShown = false
    @State private var selectedTab = 0
    @State private var showingWelcome = false

    var body: some View {
        ZStack {
            MainView(selection: $selectedTab)
        }
        .onAppear {
            if !welcomeScreenShown {
                showingWelcome = true
            }
        }
        .fullScreenCover(isPresented: $showingWelcome) {
            WelcomeView(showingWelcome: $showingWelcome)
        }
    }
}

struct WelcomeView: View {
    @Binding var showingWelcome: Bool
    @State private var welcomeTab = 0

    var body: some View {
        VStack {
            if welcomeTab == 0 {
                FirstPage {
                    withAnimation {
                        welcomeTab = 1
                    }
                }
            } else if welcomeTab == 1 {
                SecondPage {
                    withAnimation {
                        welcomeTab = 2
                    }
                }
            } else if welcomeTab == 2 {
                ThirdPage {
                    // Mark onboarding as complete
                    UserDefaults.standard.set(true, forKey: "WelcomeScreenShown")
                    showingWelcome = false
                }
            }
        }
    }
}

struct MainView: View {
    @Binding var selection: Int

    var body: some View {
        TabView(selection: $selection) {
            VStack {
                Image(systemName: "globe")
                Text("Hello World!")
                    .font(.title)
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag(0)
        }
    }
}

struct FirstPage: View {
    let onContinue: () -> Void

    var body: some View {
        VStack {
            Text("Welcome to Homy")
                .font(.largeTitle)
            Button("Get Started") {
                onContinue()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}

struct SecondPage: View {
    let onContinue: () -> Void

    var body: some View {
        VStack {
            Text("Add Your First Device")
                .font(.title)
            Button("Continue") {
                onContinue()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}

struct ThirdPage: View {
    let onContinue: () -> Void

    var body: some View {
        VStack {
            Text("All Set!")
                .font(.title)
            Button("Finish") {
                onContinue()
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}

#Preview {
    ContentView()
}
