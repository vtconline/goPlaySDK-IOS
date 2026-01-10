// The Swift Programming Language
// https://docs.swift.org/swift-book
// AppManager.swift

import Foundation
import SwiftUI
import UIKit

@MainActor
@objc public class GoPlaySDK: NSObject {
    @objc public static let instance = GoPlaySDK()

    private override init() {
        super.init()
    }

    public var goPlayConfig: GoPlayConfig? = nil

    private var _isGetConfig: Bool = false
    private var isManualClick: Bool = false

    private var _autoLogin: Bool = true

    @objc public var autoLogin: Bool {
        get { return _autoLogin }
        set { _autoLogin = newValue }
    }

    @objc(initSDK:clientId:clientSecret:)
    public func initSDK(
        _ isSandBox: Bool,
        _ clientId: String,
        _ clientSecret: String
    ) {
        ApiService.shared.initWithKey(isSandBox, clientId, clientSecret)
        self.getRemoteConfig()
    }

    @objc(getGoPlayLoginView:)
    public func getGoPlayLoginView(type: Int)
        -> UIViewController
    {
        let view: AnyView
        switch type {
        case GoSwiftViewType.selectView:
            view = AnyView(GoPlayMainView())
        case GoSwiftViewType.phone:
            view = AnyView(GoPlayPhoneLoginViewObjC())
        case GoSwiftViewType.goid:
            view = AnyView(GoPlayGoIdLoginViewObjC())
        case GoSwiftViewType.updateProfile:
            view = AnyView(GuestLoginUpdateProfileViewObjC())
        default:
            view = AnyView(GoPlayPhoneLoginViewObjC())
        }

        let controller = GoPlayHostingController(rootView: view)  // UIHostingController(rootView: view)
        //ensure fullscreen
        controller.modalPresentationStyle = .pageSheet

        controller.rootView = AnyView(
            view.environment(\.hostingController, controller))
        return controller
    }
    @objc(application:openURL:options:)
    public func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        return GoPlayFacebookSDK.shared.application(
            app,
            open: url,
            options: options
        )
    }
    @objc(application:didFinishLaunchingWithOptions:)
    public func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication
            .LaunchOptionsKey: Any]?
    ) -> Bool {
        GoPlayFirebaseSDK.shared.initialize()
        return GoPlayFacebookSDK.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
    }
    @objc(logEventFB:parameters:)
    public func logEventFB(
        eventName: String,
        parameters: [String: Any]? = nil
    ) {
        GoPlayFacebookSDK.shared.logEvent(
            name: eventName,
            parameters: parameters
        )
    }
    @objc(logEvent:parameters:)
    public func logEvent(
        _ eventName: String,
        _ parameters: [String: Any]? = nil
    ) {
        GoPlayFirebaseSDK.shared.logEvent(
            name: eventName,
            parameters: parameters
        )
    }
    @objc(recordError:)
    public func recordError(_ error: NSError) {
        GoPlayFirebaseSDK.shared.recordError(error)
    }

    @objc public func getScreenWidth() -> CGFloat {
        return UIScreen.main.bounds.width
    }
    @objc(getRemoteConfig)
    public func getRemoteConfig() {
        GoApiService.shared.getRemoteConfig(
            success: { (configDict: [String: Any]) in
                //                print("Config received:", configDict)
                self._isGetConfig = true
                do {
                    // Convert Dictionary -> JSON Data
                    let jsonData = try JSONSerialization.data(
                        withJSONObject: configDict,
                        options: []
                    )

                    // Decode JSON Data -> GoPlayConfig
                    self.goPlayConfig = try JSONDecoder().decode(
                        GoPlayConfig.self,
                        from: jsonData
                    )

                    //print("✅ Config decoded:", self.goPlayConfig)
                    print(
                        "✅ Config decoded googleClientId:",
                        self.goPlayConfig?.googleClientId
                    )
                    if self.goPlayConfig != nil
                        && !self.goPlayConfig!.googleClientId.isEmpty
                    {
                        //TODO :: update google client id
                    }

                } catch {
                    print("❌ Failed to decode GoPlayConfig:", error)
                }

                if self.autoLogin || self.isManualClick {
                    self.savedUserServer()
                }

            },
            failure: { (error: Error) in
                print("❌ Remote Config Failed:", error.localizedDescription)
                self._isGetConfig = true
                if self.autoLogin || self.isManualClick {
                    self.savedUserServer()
                }
            }
        )
    }

    @objc func savedUserServer() {
        GoApiService.shared.checkDevice(
            success: { (configDict: [String: Any]) in
                print("checkDevice done :", configDict)

                do {
                    // Convert Dictionary -> JSON Data
                    let jsonData = try JSONSerialization.data(
                        withJSONObject: configDict,
                        options: []
                    )

                    let apiResponse = try JSONDecoder().decode(
                        GoPlayApiResponse<TokenData>.self,
                        from: jsonData
                    )

                    var message = "Lỗi đăng nhập"

                    print("checkDevice apiResponse", apiResponse)
                    if apiResponse.isSuccess() {
                        print("checkDevice isSuccess true")
                        self.logEvent("login_success", ["SUCCESS": "SUCCESS"])
                        if apiResponse.data != nil {
                            let tokenData: TokenData = apiResponse.data!
                            if let session = GoPlaySession.deserialize(
                                data: tokenData
                            ) {
                                //                                print("checkDevice get session =",session)
                                KeychainHelper.save(
                                    key: GoConstants.goPlaySession,
                                    data: session
                                )
                                AuthManager.shared.postEventLogin(
                                    session: session,
                                    errorStr: nil
                                )
                                return
                            } else {
                                //AlertDialog.instance.show(message:"Không đọc được Token")
                            }
                        }

                    } else {
                        AuthManager.shared.postEventResResult(
                            resCode: apiResponse.code,
                            error: apiResponse.message
                        )
                    }

                } catch {
                    print("❌ Failed to decode data in checkDevice:", error)
                }

                self.showLoginForm()

            },
            failure: { (error: Error) in
                print(
                    "❌ checkDevice request Failed:",
                    error.localizedDescription
                )
                self._isGetConfig = true

            }
        )
    }
    @objc(showLoginForm)
    func showLoginForm() {
        //        KeychainHelper.clearSavedData()
        //        AuthManager.shared.postEventLogin(session: nil)
    }

    @objc public func logOut() {
        //logout google,apple,fb,goId
        GoogleSignInManager.shared.logOut()
        SignInWithAppleDelegates.shared.logOut()
        GoApiService.shared.logOut(
            success: { (configDict: [String: Any]) in
                print("logOut done :", configDict)

                do {
                    let jsonData = try JSONSerialization.data(
                        withJSONObject: configDict,
                        options: []
                    )

                    let apiResponse = try JSONDecoder().decode(
                        GoPlayApiResponse<TokenData>.self,
                        from: jsonData
                    )

                    var message = "Lỗi đăng xuất"

                    print("logOut apiResponse", apiResponse)
                    if apiResponse.isSuccess() {
                        self.logEvent("logout_success", ["SUCCESS": "SUCCESS"])
                        KeychainHelper.clearDatalogOut()
                        AuthManager.shared.postEventLogout(
                            error: nil
                        )

                    } else {
                        AlertDialog.instance.show(
                            message: apiResponse.message ?? "Đăng xuất thất bại")
                        // AuthManager.shared.postEventLogout(
                        //     error: apiResponse.message
                        // )
                    }

                } catch {
                    print("❌ Failed to logout, parse data error:", error)
                    AuthManager.shared.postEventLogout(
                        error: "error: Failed to logout, parse data  \(error.localizedDescription)"
                    )
                }

            },
            failure: { (error: Error) in
                print(
                    "❌ fail to reqeust api logout",
                    error.localizedDescription
                )
                AuthManager.shared.postEventLogout(
                    error: error.localizedDescription
                )
            }
        )
    }

    @objc(startObservingLoginResultForTarget:target:selector:)
    public func startObservingLoginResultForTarget(
        goPlayAction: NSString,
        target: NSObject,
        selector: Selector
    ) {
        GenericObserver.shared.startObservingLoginResultForTarget(
            goPlayAction: goPlayAction,
            target: target,
            selector: selector
        )
    }

    @objc(cancelObserver:)
    public func cancelObserver(goPlayAction: NSString) {
        GenericObserver.shared.cancelObserver(goPlayAction: goPlayAction)
    }

    @objc(cancelAllObservers)
    public func cancelAllObservers() {
        GenericObserver.shared.cancelAll()
    }

}
