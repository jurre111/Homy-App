import SwiftUI
import Foundation

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
    @State private var deviceIP: String = ""
    @State private var deviceName: String = ""

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
                            step = .done
                        }
                    },
                    step: $secondPageStep,
                    deviceIP: $deviceIP,
                    deviceName: $deviceName
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
                            step = .done
                        }
                    },
                    deviceIP: $deviceIP,
                    deviceName: $deviceName
                )
                .transition(.goForth)

            case .fourth:
                FourthPage(
                    onContinue: {
                        withAnimation(.easeInOut) {
                            goingBack = false
                            step = .done
                        }
                    },
                    deviceName: $deviceName
                )
                .transition(.goForth)

            case .done:
                Done {
                    withAnimation(.easeInOut) {
                        UserDefaults.standard.set(true, forKey: "WelcomeScreenShown")
                        showingWelcome = false
                    }
                }
                .transition(.goForth)
            }
        }
    }
}

struct TileView: View {
    let title: String
    let image: String
    @Binding var showingEntity: Bool
    @Binding var entityName: String
    @Binding var entityIcon: String

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Image(systemName: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 27, height: 27)
                    .foregroundColor(.white)
                Spacer()
                Button(action: {
                    entityIcon = image
                    entityName = title
                    showingEntity = true
                }) {
                    ZStack() {
                        Circle()
                            .fill(.white)
                            .opacity(0.2)
                            .frame(width: 28, height: 28)
                        Image(systemName: "ellipsis")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(12)
            Spacer()
            Text(title)
                .foregroundColor(.white)
                .fontWeight(.medium)
                .font(.system(size: 18))
                .padding(10)
        }
        .aspectRatio(10/7, contentMode: .fill)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: 0x5083c7), Color(hex: 0x406aa3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
}

struct MainView: View {
    @Binding var selection: Int
    var body: some View {
        TabView(selection: $selection) {
            NavigationStack {
                NavigationLink("Entities") {
                    EntitiesView()
                }
            }
            .navigationTitle("Home")
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


struct EntitiesView: View {
    @State private var showingEntity = false
    @State private var entityName: String = ""
    @State private var entityIcon: String = ""
    @State private var data: [[String]] = [[]]
    @State private var pageLoaded = false

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                if pageLoaded {
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(data, id: \.self) { entity in
                            TileView(title: entity[0], image: entity[2], showingEntity: $showingEntity, entityName: $entityName, entityIcon: $entityIcon)
                        }
                    }
                    .padding(.horizontal)
                } else {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(alignment: .center) {
                        Button(action: {
                            
                        }) {
                            Text("Select")
                        }
                        Button(action: {
                            
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .onAppear {
                do {
                    let baseURL = getURL(urlEnd: "")
                    if let devices = listFiles(in: baseURL) {
                        for device in devices {
                            if let subURL = getURL(urlEnd: "\(device)/entities/") {
                                let entities = listFiles(in: subURL)
                                for entity in entities {
                                    if let entityURL = getURL(urlEnd: "\(device)/entities/\(entity)") {
                                        let data = try Data(contentsOf: entityURL)
                                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
                                        let name = json["name"] as! String
                                        let unit = json["unit"] as! String
                                        let icon = json["icon"] as! String
                                        data[data.count] = [name, unit, icon]
                                    }
                                }
                            }
                        }
                    }
                    pageLoaded = true
                } catch {
                    print("collecting etntities failed!?")
                }
            }
        }
        .fullScreenCover(isPresented: $showingEntity) {
            EntityView(showingEntity: $showingEntity, entityName: $entityName, entityIcon: $entityIcon)
        }
    }
}

struct InputView: View {
    @Binding var entityIcon: String
    @State private var text: String = ""

    var body: some View {
        HStack() {
            Image(systemName: entityIcon)
                .font(.system(size: 12, weight: .bold))
                .padding(6)
                .background(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(
                        Color.blue.opacity(0.2)
                        )
                        .aspectRatio(1 / 1, contentMode: .fit)
                )
                .foregroundColor(.blue)
                .padding(10)
            TextField("Entity Name", text: $text)
                .font(.system(size: 12))
                .foregroundColor(.blue)
                .fixedSize(horizontal: true, vertical: false)
                .padding(6)
                .background(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(
                        Color.blue.opacity(0.2)
                    )
                )
                .padding(10)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    Color(UIColor.secondarySystemBackground)
                )
        )                         
    }
}

struct EntityView: View {
    @Binding var showingEntity: Bool
    @Binding var entityName: String
    @Binding var entityIcon: String

    var body: some View {
        NavigationStack {
            ScrollView() {
                VStack {
                    InputView(entityIcon: $entityIcon)
                }
                .padding(.horizontal)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(alignment: .center) {
                        Image(systemName: entityIcon)
                            .font(.system(size: 12, weight: .bold))
                            .background(
                                RoundedRectangle(cornerRadius: 7, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: 0x5083c7), Color(hex: 0x406aa3)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 26, height: 26)
                            )
                        Button(action: {
                            // do nothing
                        }) {
                            Text(entityName)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                            ZStack(alignment: .center) {
                                Circle()
                                    .fill(.white)
                                    .opacity(0.2)
                                    .frame(width: 17, height: 17)
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(.white)
                                    .opacity(0.6)
                                    .padding(.top, 2)
                            }
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingEntity = false
                    }) {
                        Text("Done")
                            .font(.system(size: 18, weight: .bold))
                    }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: {
                        showingEntity = false
                    }) {
                        Image(systemName: "xmark.circle")
                    }
                    Spacer()
                    Button(action: {
                        showingEntity = false
                    }) {
                        Image(systemName: "trash.circle")
                    }
                    Spacer()
                    Button(action: {
                        showingEntity = false
                    }) {
                        Image(systemName: "checkmark.circle")
                    }
                }
            }
            .toolbarBackground(
                Color.white.opacity(0.1), 
                for: .bottomBar
            )
            .toolbarBackground(.visible, for: .bottomBar)
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
                InformationDetailView(title: "Control", subTitle: "Easily control all your smart home devices in one app.", imageName: "apps.ipad.landscape")
                InformationDetailView(title: "Automate", subTitle: "Create custom automations to make your home smarter.", imageName: "memorychip")
                InformationDetailView(title: "Manage", subTitle: "Keep track of your devices and their status.", imageName: "mail.stack")
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
    @Binding var deviceIP: String
    @Binding var deviceName: String

    var body: some View {
        ZStack(alignment: .center) {
            
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
                        Section("Device Name") {
                            TextField("My Smart Device", text: $deviceName)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                                .keyboardType(.default)
                        }
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
                Spacer(minLength: 30)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            VStack() {
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
            .ignoresSafeArea(.keyboard)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
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
    @State private var entitiesFound = false
    @State private var entityAmount: Int = 0
    @Binding var deviceIP: String
    @Binding var deviceName: String
    let devicesJsonUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("devices.json")

    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            VStack {
                Image(systemName: "homepod.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 140)
                    .foregroundColor(Color(UIColor.systemBlue))
                    .symbolEffect(
                        .pulse,
                        value: [1, 2, 3].contains(connectionStatus) ? animationIsActive : true
                    )
                Text("Configuring Your")
                    .fontWeight(.black)
                    .font(.system(size: 36))
                }
                Text("Smart Device")
                    .fontWeight(.black)
                    .font(.system(size: 36))
                    .foregroundColor(Color(UIColor.systemBlue))
            VStack(alignment: .leading) { 
                InformationDetailView(
                    title: connectionStatus == 1 ? "Connecting..." : connectionStatus == 4 ? "Connection Failed" : "Connected", 
                    subTitle: connectionStatus == 1 ? "Trying to connect to your device" : connectionStatus == 4 ? "Connecting to your device failed. Please refer to our documentation for more information" : "Connecting to your device succeeded", 
                    imageName: connectionStatus == 1 ? "wifi" : connectionStatus == 4 ? "wifi.slash" : "checkmark.circle.fill")
                InformationDetailView(
                    title: [1, 2, 4].contains(connectionStatus) ? "Verifying Data Format..." : connectionStatus == 5 ? "Incorrect Data Format" : "Correct Data Format", 
                    subTitle: [1, 2, 4].contains(connectionStatus) ? "Verifying that the data is formatted correctly." : connectionStatus == 5 ? "The data from your device is not formatted correctly. Please refer to our documentation for more information." : "The data from your device is formatted correctly.", 
                    imageName: [1, 2, 4].contains(connectionStatus) ? "doc.text.magnifyingglass" : connectionStatus == 5 ? "doc.text.magnifyingglass" : "checkmark.circle.fill", 
                    stepOpacity: [1, 4].contains(connectionStatus) ? 0.1 : 1.0)
                InformationDetailView(
                    title: [1, 2, 3, 4, 5].contains(connectionStatus) ? "Getting Entities..." : connectionStatus == 6 ? "No Entities Found" : "Entities Found", 
                    subTitle: connectionStatus < 4 ? "Getting entities from your device." : connectionStatus == 6 ? "No entities were found in your device. Please refer to our documentation for more information." : "\(entityAmount) entities were found in your device.", 
                    imageName: [1, 2, 3, 4, 5].contains(connectionStatus) ? "lightbulb" : connectionStatus == 6 ? "text.badge.xmark" : "checkmark.circle.fill", 
                    stepOpacity: [1, 2, 4, 5].contains(connectionStatus) ? 0.1 : 1.0)
            }
            Spacer(minLength: 30)
            if connectionStatus == 7 {
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
                .animation(.easeInOut, value: connectionStatus)
            } else if [4, 5, 6].contains(connectionStatus) {
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
                .animation(.easeInOut, value: connectionStatus)
            }
        }
        .padding(.horizontal)
        .onAppear {
            timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                animationIsActive.toggle()
            }
            Task {
                let reachable = await canConnect(to: deviceIP)

                withAnimation(.easeInOut) {
                    connectionStatus = reachable ? 2 : 4
                }

                guard reachable else { return }

                let jsonFormat = await isJSONFormat(urlString: deviceIP)

                withAnimation(.easeInOut) {
                    connectionStatus = jsonFormat ? 3 : 5
                }

                guard jsonFormat else { return }

                if let entities = await parseEntities(from: deviceIP) {
                    for entity in entities {
                        let url = getURL(urlEnd: "\(deviceName)/entities/\(entity).json")
                        let entity = [
                            "name": "",
                            "unit": "",
                            "icon": ""
                        ]
                        let data = try JSONSerialization.data(withJSONObject: entity, options: [.prettyPrinted])
                        try data.write(to: url)
                    }
                    entitiesFound = true
                    entityAmount = entities.count
                }

                withAnimation(.easeInOut) {
                    connectionStatus = entitiesFound ? 7 : 6
                }
            } 
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct FourthPage: View {
    let onContinue: () -> Void
    @Binding var deviceName: String
    @State var entityNames: [String] = []
    @State var entityList: [
        String:[String:String]
    ] = [:]
    @State var devices: [String: [String: Any]] = [:]
    var devicesJsonUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("devices.json")

    var body: some View {
        VStack(alignment: .center) {
            VStack {
                Image(systemName: "mail.stack")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 180)
                    .foregroundColor(Color(UIColor.systemBlue))

                Text("Configure Your")
                    .fontWeight(.black)
                    .font(.system(size: 36))
                Text("Entities")
                    .fontWeight(.black)
                    .font(.system(size: 36))
                    .foregroundColor(Color(UIColor.systemBlue))
            }
            Spacer()
            Form {
                ForEach(entityNames, id: \.self) { entity in
                    Section(entity) {
                        TextField("Name", text: Binding(
                            get: { entityList[entity]?["name"] ?? "" },
                            set: { entityList[entity, default: [:]]["name"] = $0 }
                        ))
                            .keyboardType(.default)

                        TextField("Unit", text: Binding(
                            get: { entityList[entity]?["unit"] ?? "" },
                            set: { entityList[entity, default: [:]]["unit"] = $0 }
                        ))
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .keyboardType(.default)  

                        TextField("Icon", text: Binding(
                            get: { entityList[entity]?["icon"] ?? "" },
                            set: { entityList[entity, default: [:]]["icon"] = $0 }
                        ))
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .keyboardType(.default) 
                    }
                }
            }
            Spacer()
            Button(action: {
                do {
                    for (key, value) in Array(entityList) {
                        let url = getURL(urlEnd: "\(deviceName)/entities/\(key).json")
                        let data = try JSONSerialization.data(withJSONObject: value, options: [.prettyPrinted])
                        try data.write(to: url)
                        onContinue()
                    }
                } catch {
                    print("❌ Failed to save devices.json: \(error)")
                }
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
            .ignoresSafeArea(.keyboard, edges: .bottom)            
        }
        .onAppear {
            do {
                let url = getURL(urlEnd: "\(deviceName)/entities/")
                let entityNames = listFiles(in: url, includeExtension: false)
//                let loadedData = try Data(contentsOf: devicesJsonUrl)
//                if let loadedDevices = try JSONSerialization.jsonObject(with: loadedData) as? [String: [String: [String]]],
//                let entities = loadedDevices[deviceName]?["entities"] as? [String] {
//                    entityNames = entities
//                    devices = loadedDevices
//                }
            } catch {
                print("❌ Failed to load devices.json: \(error)")
            }
        }
    }
}

struct Done: View {
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

func getURL(urlEnd: String) -> URL? {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(urlEnd)
}

func listFiles(in url: URL, includeExtension: Bool = true) -> [String] {
    let fileManager = FileManager.default
    do {
        let urls = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
        return includeExtension ? urls.map { $0.lastPathComponent } : urls.map { $0.deletingPathExtension().lastPathComponent }// just the file names
    } catch {
        print("⚠️ Error reading folder \(url): \(error)")
        return []
    }
}



/// Tries to connect to a URL/IP and returns true if reachable, false otherwise
func canConnect(to urlString: String) async -> Bool {
    // Make sure the string is a valid URL
    guard let url = URL(string: urlString.hasPrefix("http") ? urlString : "http://\(urlString)") else {
        return false
    }
    
    var request = URLRequest(url: url)
    request.timeoutInterval = 7 // seconds
    
    do {
        let (_, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, 200..<400 ~= httpResponse.statusCode {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            return true
        }
    } catch {
        // Could not connect
        return false
    }
    
    return false
}

func isJSONFormat(urlString: String) async -> Bool {
    // Ensure the string is a valid URL (prepend http:// if missing)
    guard let url = URL(string: urlString.hasPrefix("http") ? urlString : "http://\(urlString)") else {
        return false
    }

    var request = URLRequest(url: url)
    request.timeoutInterval = 7 // seconds

    do {
        let (data, response) = try await URLSession.shared.data(for: request)

        // Must be an HTTP response with success status
        guard let httpResponse = response as? HTTPURLResponse,
              200..<400 ~= httpResponse.statusCode else {
            return false
        }

        // Try to parse JSON
        do {
            _ = try JSONSerialization.jsonObject(with: data, options: [])
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            return true
        } catch {
            return false
        }

    } catch {
        // Request failed
        return false
    }
}

func parseEntities(from urlString: String) async -> [String]? {
    guard let url = URL(string: urlString.hasPrefix("http") ? urlString : "http://\(urlString)") else { return nil }

    do {
        let (data, _) = try await URLSession.shared.data(from: url)

        // Try decoding JSON into a [String: Any]
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])

        guard let dict = jsonObject as? [String: Any] else {
            return nil
        }

        // Extract entity keys
        let entities = Array(dict.keys)
        try? await Task.sleep(nanoseconds: 2_000_000_000)

        return entities
    } catch {
        print("❌ Failed to parse JSON: \(error)")
        return nil
    }
}

extension Color {
    init(hex: Int, opacity: Double = 1.0) {
        let red = Double((hex & 0xff0000) >> 16) / 255.0
        let green = Double((hex & 0xff00) >> 8) / 255.0
        let blue = Double((hex & 0xff) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}





#Preview {
    ContentView()
}
