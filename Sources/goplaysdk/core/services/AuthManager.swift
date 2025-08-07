import Combine
import Foundation

@MainActor
@objc public class AuthManager: NSObject {
    @objc public static let shared = AuthManager()
    public override init() {
        super.init()
    }

    // Dùng với Swift Combine
    public let loginResultPublisher = PassthroughSubject<
        LoginResultObjC, Never
    >()
    public let logoutResultPublisher = PassthroughSubject<
        LogoutResultObjC, Never
    >()
    public let updateProfilePublisher = PassthroughSubject<
        UpdateProfileObjC, Never
    >()
    
    public let resResultPublisher = PassthroughSubject<
        ResResultObjC, Never
    >()

    // Swift-only hoặc ObjC gọi cũng được
    @objc public func postEventLogin(session: GoPlaySession?, errorStr: String?) {
        if let session = session {
            let result = LoginResultObjC(session: session)
            DispatchQueue.main.async {
                //run on main thread, prevent crash in objc project if use this lib
                self.loginResultPublisher.send(result)
            }

        } else {
            let err = NSError(
                domain: "LoginError",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: errorStr ?? "Invalid credentials"]
            )
            DispatchQueue.main.async {
                //run on main thread, prevent crash in objc project if use this lib
                self.loginResultPublisher.send(LoginResultObjC(error: err))
            }

        }
    }

    // Swift-only hoặc ObjC gọi cũng được
    @objc public func postEventLogout(error: String?) {
        //error null or empmty la logout success
        let err = NSError(
            domain: error == nil || error == ""
                ? "LogoutSuccess" : "LogoutError",
            code: error == nil || error == "" ? 0 : -1,
            userInfo: [NSLocalizedDescriptionKey: error]
        )
        let result = LogoutResultObjC(error: err)
        DispatchQueue.main.async {
            //run on main thread, prevent crash in objc project if use this lib
            self.logoutResultPublisher.send(result)
        }
    }
    
    @objc public func postEventResResult(resCode: Int,error: String?) {
        
        let result = ResResultObjC(code: resCode,errorMessage: error)
        DispatchQueue.main.async {
            //run on main thread, prevent crash in objc project if use this lib
            self.resResultPublisher.send(result)
        }
    }

    @objc public func postEventProfile(session: GoPlaySession?, error: String?)
    {
        DispatchQueue.main.async {
            //run on main thread, prevent crash in objc project if use this lib
            if let session = session {
                self.updateProfilePublisher.send(
                    UpdateProfileObjC(session: session)
                )
            } else {
                self.updateProfilePublisher.send(
                    UpdateProfileObjC(errorMessage: error ?? "Unknown error")
                )
            }
        }

    }
}

// MARK: - ObjC-compatible Enum Wrapper

@objc public class LoginResultObjC: NSObject {
    @objc public let session: GoPlaySession?
    @objc public let error: NSError?

    @objc public init(session: GoPlaySession) {
        self.session = session
        self.error = nil
    }

    @objc public init(error: NSError) {
        self.session = nil
        self.error = error
    }

    @objc public var isSuccess: Bool {
        return session != nil
    }
}

@objc public class UpdateProfileObjC: NSObject {
    @objc public let session: GoPlaySession?
    @objc public let errorMessage: String?

    @objc public init(session: GoPlaySession) {
        self.session = session
        self.errorMessage = nil
    }

    @objc public init(errorMessage: String) {
        self.session = nil
        self.errorMessage = errorMessage
    }

    @objc public var isSuccess: Bool {
        return session != nil
    }
}

@objc public class LogoutResultObjC: NSObject {
    @objc public let error: NSError?

    @objc public init(error: NSError?) {
        self.error = error
    }
    @objc public var isSuccess: Bool {
        return error != nil
    }
    //    @objc public let errorString: String?
    //
    //
    //    @objc public init(error: String?) {
    //        self.errorString = error
    //    }
    //    @objc public var isSuccess: Bool {
    //        return errorString != nil && errorString!.isEmpty == false
    //    }

}

@objc public class ResResultObjC: NSObject {
    @objc public let code: Int
    @objc public let errorMessage: String?

    @objc public init(code: Int, errorMessage: String?) {
        self.code = code
        self.errorMessage = errorMessage
    }


    @objc public var isSuccess: Bool {
        return code == GoErrorCode.Authen.ok.rawValue
    }
    
    @objc public var tokenExpired: Bool {
        return code == GoErrorCode.Authen.expired.rawValue
    }
}
