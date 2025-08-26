import SwiftUI

struct ContentView: View {
    @AppStorage("WelcomeScreenShown") private var welcomeScreenShown = false
    @State private var showWelcomeSheet = false
    @State private var selectedTab = 0

    var body: some View {
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
        .sheet(isPresented: $showWelcomeSheet) {
            WelcomeSheet(showWelcomeSheet: $showWelcomeSheet)
        }
        .onAppear {
            // Show the sheet only if it hasn't been shown before
            if !welcomeScreenShown {
                showWelcomeSheet = true
            }
        }
    }
}

struct WelcomeSheet: View {
    @Binding var showWelcomeSheet: Bool
    @AppStorage("WelcomeScreenShown") private var welcomeScreenShown = false

    var body: some View {
        NavigationView {
            VStack() {
                Spacer()
                VStack(){
                    Image("gradientsIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 180, alignment: .center)
                        .accessibility(hidden: true)
                    Text("Welcome to")
                        .fontWeight(.black)
                        .font(.system(size: 36))

                    Text("Homy")
                        .fontWeight(.black)
                        .font(.system(size: 36))
                        .foregroundColor(Color(UIColor.systemBlue))
                }
                InformationDetailView(title: "Match", subTitle: "Match the gradients by moving the Red, Green and Blue sliders for the left and right colors.", imageName: "slider.horizontal.below.rectangle")

                InformationDetailView(title: "Precise", subTitle: "More precision with the steppers to get that 100 score.", imageName: "minus.slash.plus")

                InformationDetailView(title: "Score", subTitle: "A detailed score and comparsion of your gradient and the target gradient.", imageName: "checkmark.square")
                
                Spacer(minLength: 30)

                Button(action: {
                    welcomeScreenShown = true
                    showWelcomeSheet = false
                }) {
                    Text("Get Started")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(UIColor.systemBlue))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }


            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    ContentView()
}
