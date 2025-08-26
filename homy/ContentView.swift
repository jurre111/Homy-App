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
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    showingWelcome = true
                }
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
                    withAnimation(.easeInOut) { 
                        welcomeTab = 1 
                    }
                }
                .transition(.moveAndFade)
            } else if welcomeTab == 1 {
                SecondPage { 
                    withAnimation(.easeInOut) {
                        welcomeTab = 2
                    }
                }
                .transition(.moveAndFade)
            } else if welcomeTab == 2 {
                ThirdPage {
                    withAnimation(.easeInOut) {
                        UserDefaults.standard.set(true, forKey: "WelcomeScreenShown")
                        showingWelcome = false
                    } 
                }
                .transition(.moveAndFade)
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
            SettingsView(selection: $selection)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(1)
        }
    }
}

struct SettingsView: View {
    @Binding var selection: Int

    var body: some View {
        TabView(selection: $selection) {
            VStack {
                Image(systemName: "gear")
                Text("Settings")
                    .font(.title)
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag(0)
            SettingsView(selection: $selection)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(1)
        }
    }
}

struct FirstPage: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            VStack() {
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
                onContinue()
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
        }
        .padding(.horizontal)
    }
}

struct SecondPage: View {
    let onContinue: () -> Void
    @State private var step = 1
    @State private var deviceIP: String = ""

    var body: some View {
        VStack(alignment: .center) {
            Spacer()

            VStack {
                Image(systemName: "homepod.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 180)
                    .foregroundColor(Color(UIColor.systemBlue))

                Text("Add Your First")
                    .fontWeight(.black)
                    .font(.system(size: 36))
                Text("Smart Device")
                    .fontWeight(.black)
                    .font(.system(size: 36))
                    .foregroundColor(Color(UIColor.systemBlue))
            }

            // 👇 Show form only after step advances
            if step == 2 {
                Form {
                    Section("Device's IP Address or Hostname") {
                        TextField("192.168.x.x or mydevice.local", text: $deviceIP)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .keyboardType(.URL)
                    }
                }
                .frame(maxHeight: 200)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .animation(.easeInOut, value: step)
            }

            Spacer()

            VStack(spacing: 12) {
                Button(action: {
                    withAnimation {
                        if step == 1 {
                            step = 2  // reveal the form
                        } else {
                            onContinue() // finish onboarding
                        }
                    }
                }) {
                    Text(step == 1 ? "Continue" : "Finish")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 15)
                            .fill(Color(UIColor.systemBlue)))
                }
                .padding(.bottom)

                if step == 1 {
                    Button("Skip") {
                        onContinue()
                    }
                    .foregroundColor(.gray)
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


struct ThirdPage: View {
    let onContinue: () -> Void
    @State private var deviceIP: String = ""

    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            VStack() {
                Image(systemName: "homepod.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 180, alignment: .center)
                    .accessibility(hidden: true)
                    .foregroundColor(Color(UIColor.systemBlue))
                Text("Add Your First")
                    .fontWeight(.black)
                    .font(.system(size: 36))
                Text("Smart Device")
                    .fontWeight(.black)
                    .font(.system(size: 36))
                    .foregroundColor(Color(UIColor.systemBlue))
            }
            Form {
                Section("Device's IP Adress or Hostname") {
                    TextField("192.168.x.x or mydevice.local", text: $deviceIP)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .keyboardType(.URL)
                }
            }
            .scrollDisabled(true)
            .frame(maxHeight: 200)
            
            Spacer()
            Button(action: {
                onContinue()
            }) {
                Text("Continue")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    .background(RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(Color(UIColor.systemBlue)))
            }
            .padding(.horizontal)
            Button(action: {
                onContinue()
            }) {
                Text("Skip")
                    .foregroundColor(.gray)
                    .font(.headline)
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

extension AnyTransition {
    static var moveAndFade: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing),
            removal: .move(edge: .leading)
        )
    }
}

#Preview {
    ContentView()
}
