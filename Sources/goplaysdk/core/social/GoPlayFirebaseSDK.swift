////
////  GoPlayFirebaseSDK.swift
////  GoPlayFacebookSDK
////
////  Created by Pate Assistant on 05/08/2025.
////
//
//import FirebaseAnalytics
//import FirebaseCore
//import Foundation
//
//// import FirebaseCrashlytics
//
//@MainActor
//public final class GoPlayFirebaseSDK {
//    public static let shared = GoPlayFirebaseSDK()
//    private var isInitialized = false
//
//    private init() {}
//
//    public func initialize() {
//        guard !isInitialized else { return }
//        isInitialized = true
//
//        if FirebaseApp.app() == nil {
//            if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
//                let options = FirebaseOptions(contentsOfFile: path)
//            {
//                FirebaseApp.configure(options: options)
//                print("✅ [GoPlayFirebaseSDK] Firebase configured successfully.")
//            } else {
//                print("⚠️ [GoPlayFirebaseSDK] GoogleService-Info.plist not found in main bundle.")
//            }
//        }
//    }
//
//    public func logEvent(name: String, parameters: [String: Any]? = nil) {
//        Analytics.logEvent(name, parameters: parameters)
////        print("📊 [GoPlayFirebaseSDK] Logged event: \(name), parameters: \(parameters ?? [:])")
//    }
//
//    public func recordError(_ error: Error) {
//        // Crashlytics.crashlytics().record(error: error)
////        print("💥 [GoPlayFirebaseSDK] Error recorded: \(error.localizedDescription)")
//    }
//}
