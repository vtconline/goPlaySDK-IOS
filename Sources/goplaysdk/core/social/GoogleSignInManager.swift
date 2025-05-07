

import GoogleSignIn

@MainActor
public class GoogleSignInManager {
    public static let shared = GoogleSignInManager()

    public func signIn(completion: @escaping (GIDSignInResult?, Error?) -> Void) {
        // Get the root view controller from the app
        topViewController { topVC in
            guard let topVC = topVC else { return }
            // Set up Google Sign-In with the correct client ID and presenting view controller
    //        GIDSignIn.sharedInstance.clientID =oogleusercontent.com"
            GIDSignIn.sharedInstance.signIn(
                withPresenting: topVC // "36318724422-hbqlqt43bcs4qb81i3f872l7dh2hphvv.apps.g Provide the presenting view controller here
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
