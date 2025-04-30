
import Combine


@MainActor
public class AuthManager {
    public static let shared = AuthManager()
    private init() {}

    public let loginResultPublisher = PassthroughSubject<LoginResult, Never>()
    public let updateProfilePublisher = PassthroughSubject<UpdateProfile, Never>()

    public func postEventLogin(sesion: GoPlaySession?) {
        if sesion != nil {
            self.loginResultPublisher.send(.success(sesion!))
        } else {
            self.loginResultPublisher.send(.failure(LoginError.invalidCredentials))
        }
    }
    
    public func postEventProfile(sesion: GoPlaySession?, error: String?) {
        if error != nil {
            self.updateProfilePublisher.send(.success(sesion!))
        } else {
            self.updateProfilePublisher.send(.failure(error!))
        }
    }
}
public enum LoginResult {
    case success(GoPlaySession)
    case failure(Error)
}

public enum LoginError: Error {
    case invalidCredentials
}


public enum UpdateProfile {
//    case openView(GoPlaySession)
    case success(GoPlaySession)
    case failure(String)
}
