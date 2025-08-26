import SwiftUI

struct ContentView: View {
    @AppStorage("WelcomeScreenShown") private var welcomeScreenShown = false
    @State private var selectedTab = 0
    @State private var showNextPage = false // Step 1

    var body: some View {
        NavigationStack {
            if !welcomeScreenShown {
                WelcomeView(showNextPage: $showNextPage) // Step 2
            } else {
                MainView(selection: $selectedTab)
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
    @AppStorage("WelcomeScreenShown") private var welcomeScreenShown = false
    @Binding var showNextPage: Bool
    var body: some View {
        NavigationView {
            VStack() {
                VStack(){
                    Image(systemName: "house.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 180, alignment: .center)
                        .accessibility(hidden: true)
                        .foregroundColor(Color(UIColor.systemBlue))
                    Text("Welcome to")
                        .fontWeight(.black)
                        .font(.system(size: 36))

                    Text("Homy")
                        .fontWeight(.black)
                        .font(.system(size: 36))
                        .foregroundColor(Color(UIColor.systemBlue))
                }
                VStack(alignment: .leading) { 
                    InformationDetailView(title: "Control", subTitle: "Easily control all your smart home devices in one app.", imageName: "slider.horizontal.3")

                    InformationDetailView(title: "Automate", subTitle: "Create custom automations to make your home smarter.", imageName: "sparkles")

                    InformationDetailView(title: "Manage", subTitle: "Keep track of your devices and their status.", imageName: "list.bullet")
                }

                Spacer(minLength: 30)

                Button(action: {
                    welcomeScreenShown = true
                    showNextPage = true
                }) {
                    Text("Get Started")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        .background(RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .fill(Color(UIColor.systemBlue)))
                        .padding(.bottom)
                }
                NavigationLink(destination: NewPageView(), isActive: $showNextPage) {
                    EmptyView()
                }


            }
            .padding(.horizontal)
        }
    }
}

struct NewPageView: View {
    var body: some View {
        NavigationView {
            VStack() {
                VStack() {
                    Text("Add Your First")
                        .fontWeight(.black)
                        .font(.system(size: 36))

                    Text("Smart Device")
                        .fontWeight(.black)
                        .font(.system(size: 36))
                        .foregroundColor(Color(UIColor.systemBlue))
                }
            }
        }
    }
}


#Preview {
    ContentView()
}
