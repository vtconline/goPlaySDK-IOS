// The Swift Programming Language
// https://docs.swift.org/swift-book
// AppManager.swift

import Foundation
import UIKit
@MainActor
class GoPlaySDK {
    // Step 1: The static shared instance
    static let shared = GoPlaySDK()

    // Step 2: Private initializer to prevent multiple instances
    private init() {}
    
    // Step 3: Function that you want to call
    func getScreenWidth() -> CGFloat {
        return UIScreen.main.bounds.width
    }
}
