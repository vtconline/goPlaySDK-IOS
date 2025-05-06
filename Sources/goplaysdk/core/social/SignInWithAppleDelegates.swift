//

import AuthenticationServices

@MainActor
class SignInWithAppleDelegates: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    static let shared = SignInWithAppleDelegates()
    
    var onSignInResult: ((Result<ASAuthorizationAppleIDCredential, Error>) -> Void)?

    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
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

    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                onSignInResult?(.success(appleIDCredential))
            }
        }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            onSignInResult?(.failure(error))
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
