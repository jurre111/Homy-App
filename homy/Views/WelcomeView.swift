import SwiftUI

struct WelcomeView: View {
    @AppStorage("WelcomeScreenShown") private var WelcomeScreenShown = false
    var body: some View {
        VStack {
            Image(systemName: "globe")
            Text("Hello World!")
                .font(.title)
        }
        .padding()
        .navigationTitle("Welcome")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Continue") {
                    WelcomeScreenShown = true
                }
            }
        }
    }
}