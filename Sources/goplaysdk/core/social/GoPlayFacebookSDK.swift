//
////
////  GoPlayFacebookSDK.swift
////
//
//import Foundation
//import FBSDKCoreKit
//import UIKit
//
///**
// must declear in  partner project Info.plist
// <key>FacebookAutoLogAppEventsEnabled</key>
// <true/>
// <key>FacebookAdvertiserIDCollectionEnabled</key>
// <true/>
// */
//@MainActor
//public class GoPlayFacebookSDK {
//    public static let shared = GoPlayFacebookSDK()
//    private init() { }
//
//    private var fbAppID: String?
//
//
//    
//    
//    func application(_ app: UIApplication, open url: URL,
//                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//        return ApplicationDelegate.shared.application(app, open: url, options: options)
//    }
//    
//    func application(_ application: UIApplication,
//                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        
//        validateFacebookPlistKeys()
//        
//        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
//        
//        AppEvents.shared.activateApp() // <- Quan trọng!
//
//        return true
//    }
//    
//    func validateFacebookPlistKeys() {
//            let requiredKeys = [
//                "FacebookAppID",
//                "FacebookDisplayName",
//                "FacebookClientToken",
//                "FacebookAutoLogAppEventsEnabled",
//                "FacebookAdvertiserIDCollectionEnabled"
//            ]
//
//            for key in requiredKeys {
//                if Bundle.main.object(forInfoDictionaryKey: key) == nil {
//                    print("⚠️ [GoPlaySDK] Missing key in Info.plist: \(key)")
//                }
//            }
//        }
//
//    public func logEvent(name: String, parameters: [String: Any]? = nil) {
//        let convertedParams = parameters?.reduce(into: [AppEvents.ParameterName: Any]()) { result, item in
//            result[AppEvents.ParameterName(item.key)] = item.value
//        }
//        AppEvents.shared.logEvent(AppEvents.Name(name), parameters: convertedParams)
//    }
//
//    public func logLoginSuccess(userID: String) {
//        logEvent(name: "login_success", parameters: ["user_id": userID])
//    }
//
//    public func logLogout(userID: String) {
//        logEvent(name: "logout", parameters: ["user_id": userID])
//    }
//}
//
