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

enum WelcomeTab {
    case first
    case second
    case third
    case fourth
    case done
}


struct WelcomeView: View {
    @Binding var showingWelcome: Bool
    @State private var step: WelcomeTab = .first
    @State private var secondPageStep = 1
    @State private var goingBack = false // track if we are going back

    var body: some View {
        VStack {
            switch step {
            case .first:
                FirstPage {
                    withAnimation(.easeInOut) {
                        goingBack = false
                        step = .second
                    }
                }
                .transition(.goForth)

            case .second:
                SecondPage(
                    onContinue: {
                        withAnimation(.easeInOut) {
                            goingBack = false
                            step = .third
                        }
                    },
                    onSkip: {
                        withAnimation(.easeInOut) {
                            goingBack = false
                            step = .fourth
                        }
                    },
                    step: $secondPageStep
                )
                .transition(.goForth)

            case .third:
                ThirdPage(
                    onContinue: {
                        withAnimation(.easeInOut) {
                            goingBack = false
                            step = .fourth
                        }
                    },
                    onBack: {
                        withAnimation(.easeInOut) {
                            goingBack = true
                            step = .second
                            secondPageStep = 2
                        }
                    },
                    onSkip: {
                        withAnimation(.easeInOut) {
                            goingBack = false
                            step = .fourth
                        }
                    }
                )
                .transition(.goForth)

            case .fourth:
                FourthPage {
                    withAnimation(.easeInOut) {
                        UserDefaults.standard.set(true, forKey: "WelcomeScreenShown")
                        showingWelcome = false
                    }
                }
                .transition(.goForth)

            case .done:
                EmptyView()
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
            .padding(.horizontal)
        } 
    }
}

struct SecondPage: View {
    let onContinue: () -> Void
    let onSkip: () -> Void
    @Binding var step: Int
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
                .scrollDisabled(true)
                .frame(maxHeight: 200)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .animation(.easeInOut, value: step)
                .background(Color(UIColor.systemBackground))
            }

            Spacer()

            VStack() {
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
                            .fill(isValidIP(deviceIP) ? Color(UIColor.systemGray2) : Color(UIColor.systemBlue)))
                            .animation(.easeInOut(duration: 0.3), value: isValidIP(deviceIP))
                }
                .disabled(isValidIP(deviceIP))
                Button("Skip") {
                    onSkip()
                }
                .foregroundColor(.gray)
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    private func isValidIP(_ ip: String) -> Bool {
        if step != 2 { return false }
        if ip.count > 6 {
            if ip.contains(".local") {
                return false
            } else if ip.filter({ $0 == "." }).count == 3 {
                let parts = ip.components(separatedBy: ".")
                for part in parts {
                    if part.count > 0 {
                        continue
                    } else {
                        return true
                    }
                }
                return false
            }
        }
        return true
    }
}


struct ThirdPage: View {
    let onContinue: () -> Void
    let onBack: () -> Void
    let onSkip: () -> Void
    @State private var animationIsActive = false
    @State private var connectionStatus = 1
    @State private var timer: Timer? = nil

    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            VStack {
                Image(systemName: "wifi")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 180)
                    .foregroundColor(connectionStatus == 1 ? Color(UIColor.systemBlue) : connectionStatus == 2 ? Color(UIColor.systemGreen) : Color(UIColor.systemRed))
                    .symbolEffect(
                        .bounce.byLayer,
                        value: animationIsActive
                    )

                Text(
                    connectionStatus == 1 ? "Connecting to": "Connection")
                    .fontWeight(.black)
                    .font(.system(size: 36))
                Text(
                    connectionStatus == 1 ? "Smart Device":
                    connectionStatus == 2 ? "Successful": 
                    "Failed"
                )
                    .fontWeight(.black)
                    .font(.system(size: 36))
                    .foregroundColor(connectionStatus == 1 ? Color(UIColor.systemBlue) : connectionStatus == 2 ? Color(UIColor.systemGreen) : Color(UIColor.systemRed))
            }
            Spacer(minLength: 30)
            if connectionStatus == 2 {
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
                        .padding(.bottom)
                }
                .padding(.horizontal)
                .animation(.easeInOut, value: connectionStatus)
            } else if connectionStatus == 3 {
                VStack() {
                    Button(action: {
                        onBack()
                    }) {
                        Text("Retry")
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                            .background(RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .fill(Color(UIColor.systemBlue)))
                    }
                    Button("Skip") {
                        onSkip()
                    }
                    .foregroundColor(.gray)
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                .animation(.easeInOut, value: connectionStatus)
            }
        }
        .onAppear {
            timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                animationIsActive.toggle()
            }
            Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { _ in
                if connectionStatus == 1 {
                    timer?.invalidate()
                    timer = nil
                    connectionStatus = 3
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct FourthPage: View {
    let onContinue: () -> Void
    

    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            VStack() {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, alignment: .center)
                    .accessibility(hidden: true)
                    .foregroundColor(Color(UIColor.systemBlue))
                    .padding(.bottom)
                Text("All")
                    .fontWeight(.black)
                    .font(.system(size: 36)) +
                Text(" Done")
                    .fontWeight(.black)
                    .font(.system(size: 36))
                    .foregroundColor(Color(UIColor.systemBlue))
            }
            Spacer()
            Button(action: {
                onContinue()
            }) {
                Text("Finish")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    .background(RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(Color(UIColor.systemBlue)))
                    .padding(.bottom)
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

extension AnyTransition {
    static var goForth: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing),
            removal: .move(edge: .leading)
        )
    }
}

#Preview {
    ContentView()
}
