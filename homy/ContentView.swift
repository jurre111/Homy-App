import SwiftUI

struct ContentView: View {
    @AppStorage("WelcomeScreenShown") private var welcomeScreenShown = false
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            if !welcomeScreenShown {
                WelcomeView()
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
    @State private var welcomeTab = 0
    @AppStorage("WelcomeScreenShown") private var welcomeScreenShown = false

    var body: some View {
        TabView(selection: $welcomeTab) {
            FirstPage(onNext: {
                welcomeTab = 1
            })
            .tag(0)

            SecondPage(onContinue: {
                welcomeScreenShown = true
            })
            .tag(1)
        }
    }
}

struct FirstPage: View {
    let onNext: () -> Void

    var body: some View {
        NavigationView {
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
                    onNext()
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
}

struct SecondPage: View {
    let onContinue: () -> Void

    var body: some View {
        NavigationView {
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
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
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
            }
            ToolbarItem(placement: .principal) {
                Button(action: {
                    onContinue()
                }) {
                    Text("Skip")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }
}

//struct SecondPage: View {
//    let onContinue: () -> Void
//    @State private var deviceIP = ""
//    
//    var body: some View {
//        NavigationView {
//            VStack(alignment: .center) {
//                Spacer()
//                VStack() {
//                    Image(systemName: "homepod.fill")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 180, alignment: .center)
//                        .accessibility(hidden: true)
//                        .foregroundColor(Color(UIColor.systemBlue))
//                    Text("Add Your First")
//                        .fontWeight(.black)
//                        .font(.system(size: 36))
//
//                    Text("Smart Device")
//                        .fontWeight(.black)
//                        .font(.system(size: 36))
//                        .foregroundColor(Color(UIColor.systemBlue))
//                }
//                Form {
//                    Section("Device's IP Adress or Hostname") {
//                        TextField("192.168.x.x or mydevice.local", text: $deviceIP)
//                            .textInputAutocapitalization(.never)
//                            .disableAutocorrection(true)
//                            .keyboardType(.URL)
//                    }
//                }
//                .scrollDisabled(true)
//                .frame(maxHeight: 200)
//                
//                Spacer()
//
//                VStack(spacing: 12) {
//                    Button(action: {
//                        onContinue()
//                    }) {
//                        Text("Continue")
//                            .foregroundColor(.white)
//                            .font(.headline)
//                            .padding()
//                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
//                            .background(RoundedRectangle(cornerRadius: 15, style: .continuous)
//                                .fill(Color(UIColor.systemBlue)))
//                    }
//                    Button(action: {
//                        onContinue()
//                    }) {
//                        Text("Skip")
//                            .foregroundColor(.gray)
//                            .font(.headline)
//                            .padding()
//                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
//                            .padding(.bottom)
//                    }
//                }
//                .padding(.horizontal)
//                .padding(.bottom, 0)
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//        }
//    }
//}



#Preview {
    ContentView()
}
