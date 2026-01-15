import AuthenticationServices
import SwiftUI


public struct SocialLoginGroupView: View {
    @State private var authorizationController: ASAuthorizationController?
    //hostingController được truyền xuyên suốt cây view từ rootView(goplaysdk.getGoPlayView) -> các subview => access every where in sub child/view
    @Environment(\.hostingController) private var hostingController

    private var haveGoIdLogin: Bool = false
    public init(haveGoIdLogin: Bool) {
        self.haveGoIdLogin = haveGoIdLogin
    }
    var spaceOriented: CGFloat {
        // Dynamically set space based on the device orientation
        return DeviceOrientation.shared.isLandscape ? 10 : 10
    }

    public var body: some View {
        //        socialViewPortraid()
        ResponsiveView(portraitView: socialViewPortraid(), landscapeView: socialViewLandscape())
    }

    func socialViewPortraid() -> some View {
        VStack(spacing: spaceOriented) {
            if haveGoIdLogin {
                GoNavigationLink(
                    text: "ĐĂNG NHẬP GOID",
                    destination: GoIdAuthenView(),
                    assetImageName: "logo_goplay",

                    imageSize: CGSize(width: 28, height: 28),
                    font: .system(size: 16, weight: .semibold),
                    textColor: .white,
                    backgroundColor: AppTheme.Colors.secondary
                )
            }
            GoButton(
                text: "Login with Google",
                color: .white,
                borderColor: .gray.opacity(0.75),
                textColor: .black,

                iconName: "google_icon",
                isSystemIcon: false,
                iconSize: 24,
                action: loginWithGmail
            )

            GoButton(
                text: "Login with Apple",
                color: AppTheme.Colors.apple,
                textColor: .white,
                iconSysColor: .white,
                iconName: "apple.logo",
                iconPadding: EdgeInsets(top: 0, leading: 0, bottom: 6, trailing: 0),
                action: loginWithApple
            )

            GoButton(
                text: "Login nhanh",
                color: .white,
                borderColor: .gray,
                textColor: .black,
                iconSysColor: .black,

                iconName: "person",
                action: loginGuest
            )

        }
        .padding(.vertical, 0)
        .padding(.horizontal, 0)

    }

    func socialViewLandscape() -> some View {
        HStack {
            Spacer()
            if haveGoIdLogin {
                GoNavigationLink(
                    text: "",
                    destination: GoIdAuthenView(),
                    assetImageName: "logo_goplay",
                    width: 60,
                    imageSize: CGSize(width: 18, height: 18),
                    font: .system(size: 16, weight: .semibold),
                    textColor: .white,
                    backgroundColor: AppTheme.Colors.secondary
                )
            }
            GoButton(
                text: "",
                color: .white,
                borderColor: .black,
                textColor: .black,
                width: 60,
                iconName: "google_icon",
                isSystemIcon: false,
                iconSize: 24,
                action: loginWithGmail
            )

//            CustomAppleSignInButton(
//                title: "",
//                width: 60,
//                action: loginWithApple
//            )
            
            GoButton(
                text: "",
                color: AppTheme.Colors.apple,
                textColor: .white,
                iconSysColor: .white,
                width: 60,
                iconName: "apple.logo",
                iconPadding: EdgeInsets(top: 0, leading: 0, bottom: 6, trailing: 0),
                
                action: loginWithApple
            )
            
            GoButton(
                color: .white,
                borderColor: .black,
                width: 60,
                action: loginGuest

            ) {
                ZStack {
                    Image(systemName: "person")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.black)

                    VStack {
                        Spacer()
                        Text("Guest")
                            .font(.caption)
                            .foregroundColor(.black)
                            //                            .bold()
                            .shadow(radius: 1)
                            .padding(.top, 22)
                    }
                    .frame(width: 40, height: 24)
                }

            }
            Spacer()
        }

    }
    private func loginGuest() {
        LoadingDialog.instance.show()

        // This would be a sample data payload to send in the POST request
        let bodyData: [String: Any] = [
            "email": GoPlayUUID.shared.userUUID
        ]

        // Now, you can call the `post` method on ApiService
        Task {
            await ApiService.shared.post(path: GoApi.oauthGuest, body: bodyData) { result in

                LoadingDialog.instance.hide()

                switch result {
                case .success(let data):
                    // Handle successful response

                    // Parse the response if necessary
                    if let jsonResponse = try? JSONSerialization.jsonObject(
                        with: data, options: []),
                        let responseDict = jsonResponse as? [String: Any]
                    {
                        print("loginGuest Response: \(responseDict)")
                        onLoginResponse(response: responseDict)
                    }

                case .failure(let error):
                    // Handle failure response
                    //                    print("Error: \(error.localizedDescription)")
                    AlertDialog.instance.show(message: error.localizedDescription)
                }
            }
        }
    }

    // Function for Gmail login (dummy)
    private func loginWithGmail() {
        GoogleSignInManager.shared.signIn { user, error in
            if let error = error {
                print("loginWithGmail error: \(error)")
                AlertDialog.instance.show(message: error.localizedDescription)
            } else if let user = user {
                //userName = user.profile.name
                print("loginWithGmail user.serverAuthCode \(user.serverAuthCode)")
                if let profile = user.user.profile, profile != nil {
                    let idToken = user.user.idToken?.tokenString ?? ""

                    requestLoginWithGoogle(
                        gId: user.user.userID ?? "", gMail: profile.email,
                        authenCode: user.serverAuthCode ?? "", name: profile.name)
                }

            }
        }
    }

    private func requestLoginWithGoogle(
        gId: String, gMail: String, authenCode: String, name: String
    ) {
        LoadingDialog.instance.show()

        // This would be a sample data payload to send in the POST request
        var bodyData: [String: Any] = [
            "ggId": gId,
            "ggEmail": gMail,
            "code": authenCode,  //old sdk
                //            "token": token,//new sdk
        ]
        if name != nil {
            bodyData["ggName"] = name
        }
        print("requestLoginWithGoogle bodyData: \(bodyData)")

        Task {
            await ApiService.shared.post(path: GoApi.oauthGoogle, body: bodyData) { result in

                LoadingDialog.instance.hide()
                switch result {
                case .success(let data):
                    // Handle successful response

                    // Parse the response if necessary
                    if let jsonResponse = try? JSONSerialization.jsonObject(
                        with: data, options: []),
                        let responseDict = jsonResponse as? [String: Any]
                    {
                        print("requestLoginWithGoogle done Response: \(responseDict)")
                        //nếu đã login gg -> update tk sang goId vi du sdkgoogle01/pwd..
                        //sau đó login lại = gg thì sẽ báo Tài khoản đã được unlink
                        //tức ko cho phép login tiếp = tk gg đã được sử dụng trước đó
                        onLoginResponse(response: responseDict)

                    }

                case .failure(let error):
                    print("requestLoginWithGoogle error Response:")
                    AlertDialog.instance.show(message: error.localizedDescription)
                }

            }
        }
    }

    private func loginWithApple() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        let delegate = SignInWithAppleDelegates.shared
        controller.delegate = delegate
        controller.presentationContextProvider = delegate
        self.authorizationController = controller  // retain

        delegate.onSignInResult = { result in
            switch result {
            case .success(let credential):
                let userIdentifier = credential.user
                let fullName = credential.fullName  //1st return only
                let email = credential.email  //1st return only

                var finalEmail: String
                var finalName: String

                if let emailUnwrapped = email, !emailUnwrapped.isEmpty {
                    // Save the email for future logins
                    KeychainHelper.save(key: "appleEmail\(userIdentifier)", string: emailUnwrapped)
                    finalEmail = emailUnwrapped
                } else {
                    // Try to retrieve the saved email
                    finalEmail =
                        KeychainHelper.load(key: "appleEmail\(userIdentifier)", type: String.self)
                        ?? ""
                }

                if let nameUnwrapped = fullName, nameUnwrapped != nil {
                    // Save the name for future logins
                    finalName = "\(nameUnwrapped.givenName ?? "") \(nameUnwrapped.familyName ?? "")"
                    KeychainHelper.save(key: "appleName\(userIdentifier)", string: finalName)

                } else {
                    // Try to retrieve the saved email
                    finalName =
                        KeychainHelper.load(key: "appleName\(userIdentifier)", type: String.self)
                        ?? ""
                }
                if let identityToken = credential.identityToken,
                    let tokenString = String(data: identityToken, encoding: .utf8)
                {
                    // Send `tokenString` to your backend for verification
                    //                    print("🛡️ Identity Token: \(tokenString)")

                    requestLoginWithApple(
                        appleId: userIdentifier, appleMail: finalEmail, token: tokenString,
                        name: finalName.trimmingCharacters(in: .whitespaces))

                } else {
                    print("✅ Successfully signed in with Apple! but identityToken is nil or empty")
                }
            case .failure(let error):
                print("❌ Apple Sign-In Failed: \(error.localizedDescription)")
                AuthManager.shared.logout( error.localizedDescription)
            }
        }

        controller.performRequests()
    }

    private func requestLoginWithApple(
        appleId: String, appleMail: String, token: String, name: String?
    ) {
        LoadingDialog.instance.show()

        let endIndex =
            token.index(token.startIndex, offsetBy: 10, limitedBy: token.endIndex) ?? token.endIndex
        let substring = token[token.startIndex..<endIndex]
        // This would be a sample data payload to send in the POST request
        var bodyData: [String: Any] = [
            "apId": appleId.isEmpty ? substring : appleId,
            "apEmail": appleMail.isEmpty ? "noemail@icloud.com" : appleMail,
            "token": token,
        ]
        if name != nil {
            bodyData["apName"] = name
        }
        Task {
            await ApiService.shared.post(path: GoApi.oauthApple, body: bodyData) { result in
                LoadingDialog.instance.hide()

                switch result {
                case .success(let data):
                    // Handle successful response

                    // Parse the response if necessary
                    if let jsonResponse = try? JSONSerialization.jsonObject(
                        with: data, options: []),
                        let responseDict = jsonResponse as? [String: Any]
                    {
                        print("requestLoginWithApple Response: \(responseDict)")
                        onLoginResponse(response: responseDict)
                    }

                case .failure(let error):
                    // Handle failure response
                    //                    print("Error: \(error.localizedDescription)")
                    AlertDialog.instance.show(message: error.localizedDescription)
                }

            }
        }
    }

    func onLoginResponse(response: [String: Any]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: response, options: [])
            let apiResponse = try JSONDecoder().decode(
                GoPlayApiResponse<TokenData>.self, from: jsonData)

            var message = "Lỗi đăng nhập"

            if apiResponse.isSuccess() {

                //                print("onLoginResponse onRequestSuccess userName: \(apiResponse.data?.accessToken ?? "")")
                if apiResponse.data != nil {
                    let tokenData: TokenData = apiResponse.data!
                    if let session = GoPlaySession.deserialize(data: tokenData) {
                        KeychainHelper.save(key: GoConstants.goPlaySession, data: session)
                        AuthManager.shared.handleLoginSuccess(session)
                        hostingController?.close() // close rootview(which add hostingController in gopalysdk.getGoPlayView)
                    } else {
                        AlertDialog.instance.show(message: "Không đọc được Token")
                    }
                }

            } else {
                message = apiResponse.message
                AlertDialog.instance.show(message: apiResponse.message)
            }

        } catch {
            AlertDialog.instance.show(message: error.localizedDescription)
        }
    }
}
