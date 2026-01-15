import GoogleSignIn

@MainActor
public class GoogleSignInManager {
    public static let shared = GoogleSignInManager()

    public func logOut() {
        GIDSignIn.sharedInstance.signOut()
    }

    public func signOutAndRevokToken() {
        GIDSignIn.sharedInstance.disconnect { error in
            if let error = error {
                print("❌ Disconnect failed:", error.localizedDescription)
            } else {
                print("✅ User disconnected from Google.")
            }
        }
    }
    public func signIn(completion: @escaping (GIDSignInResult?, Error?) -> Void) {
        // Get the root view controller from the app
        topViewController { topVC in
            guard let topVC = topVC else { return }
            // https://console.cloud.google.com/apis/credentials?inv=1&invt=Ab4wnA&project=goidauthen
            // find oauth goplay vn
            //webClientID phải có thì mới trả về authenCode
            // if let infoDict = Bundle.main.infoDictionary,let clientID = infoDict["GIDClientID"] as? String {
            //     print("✅ GIDClientID tồn tại: \(clientID)")
            // } else {
            //     print("❌ GIDClientID không tồn tại hoặc không phải String")
            //     AlertDialog.instance.show(message:"GIDClientID is not exist in Info.plist")
            //     return
            // }
            if !self.validateGoogleSignInURLScheme() {
                return
            }

            //goIDaUTHEN project google
//            let iosClientID = "907722388702-23a71q66g43sb1drjsv63s1tst7tn3h5.apps.googleusercontent.com";
//            let iosClientID = "968111791801-pl6730rk2qetiidou6030tt3j4tedi1p.apps.googleusercontent.com"; //swiftobjCSample
            let iosClientID =
                Bundle.main.infoDictionary?["GIDClientID"] as? String
                ?? "968111791801-6f22l6stb4g3ru8ar7r82j8ddrq49r97.apps.googleusercontent.com"

            let webClientID =
                GoPlaySDK.instance.goPlayConfig?.googleClientId
                ?? "968111791801-up5hvsuofg6o1e3n9m4ue1uqa258on3k.apps.googleusercontent.com"
            //goIDaUTHEN web client
//            let webClientID =
//            "968111791801-up5hvsuofg6o1e3n9m4ue1uqa258on3k.apps.googleusercontent.com"
//            let webClientID = "907722388702-thmj3tj357778b93li18shsnh64l1rf7.apps.googleusercontent.com"

            let config = GIDConfiguration(clientID: iosClientID, serverClientID: webClientID)
            GIDSignIn.sharedInstance.configuration = config
            GIDSignIn.sharedInstance.signIn(
                withPresenting: topVC
            ) { user, error in
                completion(user, error)

            }
        }

    }


    private func validateGoogleSignInURLScheme() -> Bool {
        guard let clientID = Bundle.main.infoDictionary?["GIDClientID"] as? String else {
            AlertDialog.instance.show(message: "⚠️  GIDClientID not found in Info.plist")
            return false
        }

        // Lấy phần trước ".apps.googleusercontent.com"
        guard let idPart = clientID.components(separatedBy: ".apps.googleusercontent.com").first
        else {
            AlertDialog.instance.show(message: "⚠️ GIDClientID format í not correct")
            return false
        }

        // Scheme mong đợi
        let expectedScheme = "com.googleusercontent.apps." + idPart

        // Lấy danh sách scheme từ Info.plist
        let urlTypes =
            Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: Any]]
        let schemeExists =
            urlTypes?.contains(where: { dict in
                guard let schemes = dict["CFBundleURLSchemes"] as? [String] else { return false }
                return schemes.contains(expectedScheme)
            }) ?? false
        if !schemeExists {
            AlertDialog.instance.show(
                message: "⚠️ Please Config URL scheme: \(expectedScheme) in Info.plist")
        }
        return schemeExists
        // Báo lỗi nếu chưa cấu hình

    }

    private func topViewController(
        base: UIViewController? = nil, completion: ((UIViewController?) -> Void)? = nil
    ) {
        var baseVC: UIViewController?

        // Ensure we access UIApplication/WindowScene on the main thread
        DispatchQueue.main.async {
            // Safely check if there are any connected scenes and unwrap the first UIWindowScene
            guard
                let scene = UIApplication.shared.connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .first
            else {
                print("No connected UIWindowScene available.")
                completion?(nil)
                return
            }

            // Try to access the root view controller from the key window
//            baseVC = base ?? scene.keyWindow?.rootViewController. ios 15 only
            baseVC = base ?? scene.windows
                .first(where: { $0.isKeyWindow })?
                .rootViewController
            
            // If no base view controller is found, notify completion handler
            if baseVC == nil {
                completion?(nil)
                return
            }

            // Recursively find the top view controller
            if let nav = baseVC as? UINavigationController {
                self.topViewController(base: nav.visibleViewController, completion: completion)
            } else if let tab = baseVC as? UITabBarController,
                let selected = tab.selectedViewController
            {
                self.topViewController(base: selected, completion: completion)
            } else if let presented = baseVC?.presentedViewController {
                self.topViewController(base: presented, completion: completion)
            } else {
                // Call the completion handler with the final view controller
                completion?(baseVC)
            }
        }
    }

}
