
import UIKit
import SwiftUI
//@MainActor
class LoadingDialog : @unchecked Sendable{
    // Singleton instance
    static let instance = LoadingDialog()
    
    // Private overlay view
    private var overlayView: UIView?

    // Private init to prevent outside initialization
    private init() {}

    // Show loading overlay
    func show(on view: UIView? = nil) {
        guard overlayView == nil else { return } // Prevent showing multiple overlays

        DispatchQueue.main.async {
            // Get the main view (or fallback to key window)
    //        let parentView = view ?? UIApplication.shared.windows.first { $0.isKeyWindow }
            let parentView: UIView? = view ?? UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }?.rootViewController?.view

            guard let parentView = parentView else {
                print("❌ parentView is nil. Can't create overlay.")
                return
            }
            // Create semi-transparent overlay
            let overlay = UIView(frame: parentView.bounds)
            overlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            //set touch on overlay -> prevent touch on below view
            overlay.isUserInteractionEnabled = true
            let containerSize: CGFloat = 120
            let container = UIView(frame: CGRect(
                x: 0, y: 0,
                width: containerSize,
                height: containerSize
            ))
            container.center = overlay.center
            container.backgroundColor = .clear

            // Image
            let imageSize: CGFloat = 24
            let imageView = UIImageView(frame: CGRect(
                x: 0, y: 0,
                width: imageSize,
                height: imageSize
            ))
            imageView.center = CGPoint(
                x: container.bounds.midX,
                y: container.bounds.midY
            )
            imageView.contentMode = .scaleAspectFit
            imageView.backgroundColor = .clear

            if let img = UIImage(named: "avatar-login", in: Bundle.goplaysdk, compatibleWith: nil) {
                imageView.image = img
            } else {
                print("❌ Image not found in bundle")
            }
            


            // Spinner
            let spinner = UIActivityIndicatorView(style: .large)
            spinner.frame = container.bounds
            spinner.center = CGPoint(
                x: container.bounds.midX,
                y: container.bounds.midY
            )
//            spinner.frame = container.bounds
//            spinner.center = CGPoint(x: containerSize / 2, y: containerSize / 2)

            let spinnerColor: UIColor
            if #available(iOS 14.0, *) {
                spinnerColor = UIColor(AppTheme.Colors.primary)
            } else {
                spinnerColor = AppTheme.Colors.primaryUIColor
            }
            spinner.color = spinnerColor
            spinner.startAnimating()

            // Add views
            container.addSubview(spinner)
//            container.addSubview(imageView)
            overlay.addSubview(container)

            parentView.addSubview(overlay)

            // Store reference to remove later
            self.overlayView = overlay
        }
        
    }

    // Hide loading overlay
    func hide() {
                        DispatchQueue.main.async {
                            self.overlayView?.removeFromSuperview()
                            self.overlayView = nil
                        }
    }
}

