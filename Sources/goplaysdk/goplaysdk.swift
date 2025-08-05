// The Swift Programming Language
// https://docs.swift.org/swift-book
// AppManager.swift

import Foundation
import UIKit

@MainActor
@objc public class GoPlaySDK: NSObject {
    @objc public static let instance = GoPlaySDK()

    private override init() {
        super.init()
    }

    @objc public func initSDK(_ isSandBox: Bool, _ clientId: String, _ clientSecret: String) {
        ApiService.shared.initWithKey(isSandBox, clientId, clientSecret)
        //todo: add autologin if session not null
    }

    @objc public func application(_ app: UIApplication, open url: URL,
                                  options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GoPlayFacebookSDK.shared.application(app, open: url, options: options)
    }

    @objc public func application(_ application: UIApplication,
                                  didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GoPlayFirebaseSDK.shared.initialize()
        return GoPlayFacebookSDK.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    @objc public func logEventFB(eventName: String, parameters: [String: Any]? = nil) {
        GoPlayFacebookSDK.shared.logEvent(name: eventName, parameters: parameters)
    }

    @objc public func logEvent(eventName: String, parameters: [String: Any]? = nil) {
        GoPlayFirebaseSDK.shared.logEvent(name: eventName, parameters: parameters)
    }

    @objc public func recordError(_ error: NSError) {
        GoPlayFirebaseSDK.shared.recordError(error)
    }

    @objc public func getScreenWidth() -> CGFloat {
        return UIScreen.main.bounds.width
    }
}
