//
//  loadingDialog.swift
//  goplaysdk
//
//  Created by Ngô Đồng on 17/4/25.
//
import UIKit
@MainActor
class LoadingDialog {
    // Singleton instance
    static let instance = LoadingDialog()
    
    // Private overlay view
    private var overlayView: UIView?

    // Private init to prevent outside initialization
    private init() {}

    // Show loading overlay
    func show(on view: UIView? = nil) {
        guard overlayView == nil else { return } // Prevent showing multiple overlays

        // Get the main view (or fallback to key window)
//        let parentView = view ?? UIApplication.shared.windows.first { $0.isKeyWindow }
        let parentView: UIView = {
            if let view = view {
                return view
            } else {
                var keyWindow: UIWindow?
                DispatchQueue.main.sync {
                    keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
                }
                return keyWindow!
            }
        }()

        // Create semi-transparent overlay
        let overlay = UIView(frame: parentView?.bounds ?? .zero)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        //set touch on overlay -> prevent touch on below view
        overlay.isUserInteractionEnabled = true
        // Create and add spinner
//        let loadingBox = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
//        loadingBox.backgroundColor = UIColor.black.withAlphaComponent(0.8)
//        loadingBox.layer.cornerRadius = 10
//        loadingBox.center = overlay.center
 
          
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.center = CGPoint(x: 50, y: 50)
        spinner.color = UIColor(AppTheme.Colors.primary)
        spinner.center = overlay.center //remove if use loadingBox
        spinner.startAnimating()
        
//        loadingBox.addSubview(spinner)
//         overlay.addSubview(loadingBox)
        overlay.addSubview(spinner)

        // Add overlay to parent
        parentView?.addSubview(overlay)

        // Store reference to remove later
        overlayView = overlay
    }

    // Hide loading overlay
    func hide() {
        overlayView?.removeFromSuperview()
        overlayView = nil
    }
}

