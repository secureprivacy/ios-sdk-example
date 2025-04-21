import SwiftUI
import SPMobileConsent

struct ContentView: View {
    
    @State private var isLoading = true
    @State private var spConsentEngine: SPConsentEngine? = nil
    @State private var sdkStatusMsg: String = "Initialising..."
    
    var body: some View {
        VStack(
            spacing: 20,
            content: {
                HStack(
                    content: {
                        if isLoading {
                            ProgressView().progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(1.5)
                                .padding(.trailing, 8)
                            Text(sdkStatusMsg)
                        } else {
                            Text("SDK Status:").font(.system(size: 20,weight: .medium))
                            Text(sdkStatusMsg).font(.system(size: 20, weight: .light))
                        }
                    }
                )
                if let spConsentEngine = spConsentEngine {
                    MainContent(
                        spConsentEngine: spConsentEngine,
                        selectedAppId: Config.primaryAppId,
                        consentStatus: nil,
                        onClearSessionTap: clearSession
                    )
                }
                
                
            }
        )
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .onAppear{
            self.sdkStatusMsg = "Initialising..."
            initialiseSDK()
        }
    }
    
    private func initialiseSDK(){
        Task{
            self.isLoading = true
            let result = await SPConsentEngineFactory.initialise(
                key: SPAuthKey(
                    applicationId: Config.primaryAppId,
                    secondaryApplicationId: Config.secondaryAppId
                )
            )
            self.isLoading = false
            if let consentEngine = result.data {
                self.spConsentEngine = consentEngine
                self.sdkStatusMsg = "Initialised"
            }else {
                self.sdkStatusMsg = result.msg
            }
        }
    }
    
    private func clearSession(){
        if let spConsentEngine = self.spConsentEngine{
            self.isLoading = true
            self.spConsentEngine = nil
            self.sdkStatusMsg = "Re-Initialising..."
            spConsentEngine.clearSession()
            initialiseSDK()
        }
    }
}

private struct MainContent: View {
    
    @State var vc: UIViewController?
    
    let spConsentEngine: SPConsentEngine
    @State var selectedAppId: String
    @State var consentStatus: SPConsentStatus? = nil
    @State var packageId: String = ""
    @State var package: SPPackageConsent? = nil
    @State var showPackageStatusLabel = true
    let onClearSessionTap: ()->Void
    
    private static let CONSENT_REQUEST_CODE = 1008
    
    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 12,
            content:  {
                Spacer().frame(height: 0)
                Text("Application Type:").font(.system(size: 18, weight: .medium))
                VStack(alignment: .leading,
                       content: {
                    Spacer().frame(height: 8)
                    SPRadioButton(
                        title: "Primary",
                        subTitle: getClientId(applicationId: Config.primaryAppId),
                        isSelected: selectedAppId == Config.primaryAppId
                    ){
                        selectedAppId = Config.primaryAppId
                    }
                    Spacer().frame(height: 20)
                    SPRadioButton(
                        title: "Secondary app",
                        subTitle: getClientId(applicationId: Config.secondaryAppId),
                        isSelected: selectedAppId == Config.secondaryAppId
                    ){
                        selectedAppId = Config.secondaryAppId
                    }
                })
                Spacer().frame(height: 16)
                SPKeyValue(
                    key: "Consent Status:",
                    value: consentStatus?.rawValue ?? "Unknown"
                )
                SPButton(title: "CHECK CONSENT STATUS", action: checkConsentStatus)
                SPButton(title: "SHOW CONSENT BANNER", action: showConsentBanner)
                if let package = self.package {
                    SPKeyValue(
                        key: "Package status:",
                        value: package.enabled() ? "Enabled!" : "Disabled!"
                    )
                }else {
                    Text(showPackageStatusLabel ? "Please enter a package name": "Package info not found!").font(.system(size: 14, weight: .light)
                    )
                }
                TextField("com.google.ads.mediation:facebook", text: $packageId)
                    .textCase(.none)
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                Divider().padding(.bottom, 4)
                SPButton(title: "CHECK PACKAGE STATUS", action: checkPackageStatus)
                SPButton(title: "CLEAR SESSION", action: clearSession)
            }
        )
        .onAppear{
            spConsentEngine.addObserver(code: MainContent.CONSENT_REQUEST_CODE, observer: self){event in checkConsentStatus()}
        }.onDisappear{
            spConsentEngine.removeObserver(forCode: MainContent.CONSENT_REQUEST_CODE)
        }
        .background(
            ViewControllerAccessor { vc in self.vc = vc }
        )
    }
    
    private func getClientId(applicationId: String) -> String? {
        return spConsentEngine.getClientId(applicationId: applicationId).data ?? nil
    }
    
    private func checkConsentStatus(){
        let result = spConsentEngine.getConsentStatus(applicationId: selectedAppId)
        if(result.code == 200 && result.data != nil){
            self.consentStatus = result.data
        }else{
            print("Error: \(result.msg) ", result.error ?? "")
        }
    }
    
    private func showConsentBanner(){
        if let vc = self.vc {
            let result = spConsentEngine.showConsentBanner(in: vc)
            if result.code != 200 {
                print("Error: \(result.msg) ", result.error ?? "")
            }
        }
    }
    
    private func checkPackageStatus(){
        let result = spConsentEngine.getPackage(
            applicationId: selectedAppId,
            packageId: packageId
        )
        package = result.data ?? nil
        showPackageStatusLabel = false
    }
    
    private func clearSession(){
        self.consentStatus = nil
        self.packageId = ""
        self.package = nil
        self.showPackageStatusLabel = true
        self.onClearSessionTap()
    }
}

private struct SPKeyValue : View {
    let key: String
    let value: String
    var body: some View {
        HStack(content: {
            Text(key).font(.system(size: 16, weight: .regular))
            Text(value).font(.system(size: 16, weight: .light))
        })
    }
}

private struct SPButton: View {
    let title: String
    let action: ()->Void
    var body: some View {
        Button(action: action, label: {
            Text(title)
                .font(.system(size: 14))
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                .padding(.vertical,12)
                .background(Color.gray.tertiary)
                .accentColor(.black)
        }).cornerRadius(4)
    }
}
private struct SPRadioButton: View {
    
    let title: String
    let subTitle: String?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action){
            HStack{
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .foregroundColor(isSelected ? .green: .gray)
                    .scaleEffect(1.2)
                VStack(
                    alignment: .leading,
                    content:{
                        Text(title).font(.system(size:14))
                        if let subTitle = self.subTitle {
                            Text(subTitle).font(.system(size: 14, weight: .light)).padding(.top, -2)
                        }
                    }
                )
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ViewControllerAccessor: UIViewControllerRepresentable{
    var callback: (UIViewController) -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        DispatchQueue.main.async{
            self.callback(vc)
        }
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
}

#Preview {
    ContentView()
}


