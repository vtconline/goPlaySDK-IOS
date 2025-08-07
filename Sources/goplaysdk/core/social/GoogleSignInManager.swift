

import GoogleSignIn

@MainActor
public class GoogleSignInManager {
    public static let shared = GoogleSignInManager()

    public func logOut() {
        GIDSignIn.sharedInstance.signOut()
    }
    
    public func signOutAndRevokToken(){
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
            //webClientID phải có thì mới trả về authenCode
            
//            let iosClientID = "968111791801-6f22l6stb4g3ru8ar7r82j8ddrq49r97.apps.googleusercontent.com"
            let iosClientID = Bundle.main.infoDictionary?["GIDClientID"] as? String ?? "968111791801-6f22l6stb4g3ru8ar7r82j8ddrq49r97.apps.googleusercontent.com"

            let webClientID = GoPlaySDK.instance.goPlayConfig?.googleClientId ?? "968111791801-up5hvsuofg6o1e3n9m4ue1uqa258on3k.apps.googleusercontent.com" ;
                
            let config = GIDConfiguration(clientID: iosClientID, serverClientID: webClientID)
            GIDSignIn.sharedInstance.configuration = config
            GIDSignIn.sharedInstance.signIn(
                withPresenting: topVC
            ) { user, error in
                completion(user, error)
                
            }
        }

        
        
    }
    
    private func topViewController(base: UIViewController? = nil, completion: ((UIViewController?) -> Void)? = nil) {
        var baseVC: UIViewController?

        // Ensure we access UIApplication/WindowScene on the main thread
        DispatchQueue.main.async {
            // Safely check if there are any connected scenes and unwrap the first UIWindowScene
            guard let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first else {
                    print("No connected UIWindowScene available.")
                    completion?(nil)
                    return
            }

            // Try to access the root view controller from the key window
            baseVC = base ?? scene.keyWindow?.rootViewController
            
            // If no base view controller is found, notify completion handler
            if baseVC == nil {
                completion?(nil)
                return
            }

            // Recursively find the top view controller
            if let nav = baseVC as? UINavigationController {
                self.topViewController(base: nav.visibleViewController, completion: completion)
            } else if let tab = baseVC as? UITabBarController, let selected = tab.selectedViewController {
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
