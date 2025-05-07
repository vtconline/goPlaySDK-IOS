//

import AuthenticationServices

@MainActor
public class SignInWithAppleDelegates: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    static let shared = SignInWithAppleDelegates()
    
    
    
    var onSignInResult: ((Result<ASAuthorizationAppleIDCredential, Error>) -> Void)?
    
    
    static var onLoginCallback: ((String) -> Void)?
    
    public static func registerLoginCallback(_ callback: @escaping (String) -> Void) {
        onLoginCallback = callback
    }

    
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        var window: UIWindow?

        DispatchQueue.main.sync {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                window = scene.windows.first(where: { $0.isKeyWindow })
            }
        }

        guard let keyWindow = window else {
            fatalError("No keyWindow found")
        }

        return keyWindow
    }

    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                onSignInResult?(.success(appleIDCredential))
                //option for cocos creator game app
                guard let callback = Self.onLoginCallback else {
                        print("⚠️ SignInWithAppleDelegates: loginCallback is nil, result not sent.")
                        return
                    }

                    if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
                        let userId = credential.user
                        let email = credential.email ?? ""
                        let fullName = credential.fullName.map {
                            "\($0.givenName ?? "") \($0.familyName ?? "")"
                        } ?? ""

                        var tokenString = ""
                        if let identityToken = credential.identityToken,
                           let str = String(data: identityToken, encoding: .utf8) {
                            tokenString = str
                        }

                        let resultDict: [String: Any] = [
                            "userId": userId,
                            "email": email,
                            "name": fullName,
                            "token": tokenString
                        ]

                        if let data = try? JSONSerialization.data(withJSONObject: resultDict, options: []),
                           let jsonString = String(data: data, encoding: .utf8) {
                            callback(jsonString)
                        }
                    }
            }
        }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            //call back from swift app  if have
            onSignInResult?(.failure(error))
        
            //call back from cocos creator game app if have
            let errorResult: [String: Any] = [
                    "error": error.localizedDescription
                ]
                if let data = try? JSONSerialization.data(withJSONObject: errorResult, options: []),
                   let jsonString = String(data: data, encoding: .utf8) {
                    Self.onLoginCallback?(jsonString)
                }
        }
    
    
    public func loginWithApple() {
            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()
            request.requestedScopes = [.fullName, .email]

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }

//    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
//        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
//            let userIdentifier = appleIDCredential.user
//            let fullName = appleIDCredential.fullName
//            let email = appleIDCredential.email
//            KeychainHelper.save(key: "appleAuthorizedUserIdKey", string: userIdentifier)
//            if(userIdentifier == nil || userIdentifier.isEmpty){
//                    if let loadedUserCredential: String = KeychainHelper.load(key: "appleAuthorizedUserIdKey", type: String.self) {
//                    
//                    }
//            }
//            if let identityToken = appleIDCredential.identityToken,
//                   let tokenString = String(data: identityToken, encoding: .utf8) {
//                    // Send `tokenString` to your backend for verification
//                    print("🛡️ Identity Token: \(tokenString)")
//                }
//
//            print("✅ Successfully signed in with Apple!")
////            User ID: 000858.95ac2a88398a48b3a7b7b672e66c750c.0319
////            Email: sbcmpjkxd5@privaterelay.appleid.com
////            Full Name: hiep Apple
//            print("User ID: \(userIdentifier)")
//            print("Email: \(email ?? "No Email")")
//            print("Full Name: \(fullName?.givenName ?? "") \(fullName?.familyName ?? "")")
//        }
//    }
//
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//        print("❌ Sign in with Apple failed: \(error.localizedDescription)")
//    }
}
