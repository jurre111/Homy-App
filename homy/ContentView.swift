import SwiftUI

struct ContentView: View {
    @AppStorage("WelcomeScreenShown") private var WelcomeScreenShown = false
    var body: some View {
        if !WelcomeScreenShown {
            WelcomeView()
        } else {
            MainView() {
                VStack {
                    Image(systemName: "globe")
                    Text("Hello World!")
                        .font(.title)
                }
                .padding()
            }
        }
    }
}

#Preview {
    ContentView()
}
