import SwiftUI

struct ContentView: View {
    @AppStorage("WelcomeScreenShown") private var WelcomeScreenShown = false
    @State private var selectedTab = 0
    var body: some View {
        if !WelcomeScreenShown {
            WelcomeView()
        } else {
            TabView(selection: $selectedTab) {
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
}

#Preview {
    ContentView()
}
