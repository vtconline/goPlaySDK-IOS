import UIKit
import SwiftUI

//@MainActor
public class AlertDialog: @unchecked Sendable {
    public static let instance = AlertDialog()
    private init() {}

    /// Show alert dialog
    ///
    /// - Parameters:
    ///   - title: optional title string
    ///   - message: required message
    ///   - okTitle: optional text for OK button (default: "OK")
    ///   - cancelTitle: optional text for Cancel button
    ///   - onOk: optional callback when OK is tapped
    ///   - onCancel: optional callback when Cancel is tapped
    @MainActor
    public func show(
        title: String? = nil,
        message: String,
        okTitle: String = "OK",
        cancelTitle: String? = nil,
        onOk: (() -> Void)? = nil,
        onCancel: (() -> Void)? = nil,
        navigatorView: (any View)? = nil // Custom SwiftUI view to be navigator when press ok
    ) {
        topViewController { topVC in
            guard let topVC = topVC else { return }
            
            // Proceed with topVC
//            print("Top View Controller: \(topVC)")
            
            DispatchQueue.main.async {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

                
                if cancelTitle != nil || onCancel != nil {
                    let title = cancelTitle ?? "Hủy"
                    alert.addAction(
                        UIAlertAction(title: title, style: .cancel) { _ in
                            onCancel?()
                        }
                    )
                }

                alert.addAction(UIAlertAction(title: okTitle, style: .default) { _ in
                    onOk?()
                    
                    
                    // Check if a navigator view is provided and present it
                                if let view = navigatorView {
                                    let hostingController = UIHostingController(rootView: AnyView(view))
                                    topVC.present(hostingController, animated: true)
                                }
                })
                topVC.present(alert, animated: true, completion: nil)
            }
        }

        
        
    }

    /// Get the top most view controller to present from
    @MainActor
    private func topViewController(base: UIViewController? = nil, completion: ((UIViewController?) -> Void)? = nil) {
        var baseVC: UIViewController?

        // Ensure we access UIApplication/WindowScene on the main thread
        DispatchQueue.main.async {
            // Get the first UIWindowScene (connected scene)
            guard let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first else {
                    completion?(nil)  // If no scene is available, return nil via completion
                    return
            }
            
            // Get the root view controller from the key window
//            baseVC = base ?? scene.keyWindow?.rootViewController ios15 only
            baseVC = base ?? scene.windows
                .first(where: { $0.isKeyWindow })?
                .rootViewController

            // Recursively find the top view controller
            if let nav = baseVC as? UINavigationController {
                self.topViewController(base: nav.visibleViewController, completion: completion)
            } else if let tab = baseVC as? UITabBarController, let selected = tab.selectedViewController {
                self.topViewController(base: selected, completion: completion)
            } else if let presented = baseVC?.presentedViewController {
                self.topViewController(base: presented, completion: completion)
            } else {
                // If a completion handler is provided, call it with the result
                completion?(baseVC)
            }
        }
    }



}
