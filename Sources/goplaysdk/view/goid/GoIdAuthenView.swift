import SwiftUI

public struct GoIdAuthenView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.hostingController) private var hostingController

    @StateObject private var navigationManager = NavigationManager()

    @State private var username = ""  // Store the username
    @State private var password = ""  // Store the password

    @State private var usernameFocus = false
    @State private var passwordFocus = false

    @State private var rememberMe = true  // 🔐 Toggle for remembering credentials
    @State private var isShowingSafari = false

    @StateObject private var usernameValidator = UsernameValidator()
    @StateObject private var pwdValidator = PasswordValidator()

    let enalbeSocialLogin: Bool

    public init(enalbeSocialLogin: Bool = true) {
        self.enalbeSocialLogin = enalbeSocialLogin
    }

    var spaceOriented: CGFloat {
        // Dynamically set space based on the device orientation
        return DeviceOrientation.shared.isLandscape ? 5 : 10
    }

    public var body: some View {
        VStack(alignment: .center, spacing: spaceOriented) {

            GoTextField<UsernameValidator>(
                text: $username, placeholder: "Tên đăng nhập", isPwd: false,
                validator: usernameValidator, leftIconName: "ic_user_focused",  // This should be the name of your image in Resources/Images
                isSystemIcon: false,
                //                                           keyBoardFocused: $usernameFocus
            )
            .keyboardType(.asciiCapable)

            GoTextField<PasswordValidator>(
                text: $password,
                placeholder: "Enter Password",
                isPwd: true,
                validator: pwdValidator,
                leftIconName: "ic_lock_focused",  // This should be the name of your image in Resources/Images
                isSystemIcon: false,
                //                keyBoardFocused: $passwordFocus
            )
            .keyboardType(.default)
            //KeychainHelper.remove(key: "savedPassword")
            Toggle("Ghi nhớ đăng nhập", isOn: $rememberMe)
                .foregroundColor(Color.black)
                .frame(
                    maxWidth: min(
                        UIScreen.main.bounds.width - 2 * AppTheme.Paddings.horizontal,
                        300
                    ), alignment: .center
                )
                .onChange(of: rememberMe) { newValue in
                    //print("✅ rememberMe: \(newValue ? "On" : "Off")")
                    UserDefaults.standard.set(rememberMe, forKey: GoConstants.rememberMe)
                    if !newValue {
                        KeychainHelper.remove(key: GoConstants.savedPassword)
                    }
                }

            GoButton(text: "Đăng nhập", action: submitLoginGoId)

            // HStack for buttons in a row
            // HStack for buttons in a row, centered horizontally
            HStack(spacing: 10) {
                // Register Button using NavigationLink
                NavigationLink(destination: RegisterView()) {
                    Text("Đăng ký")
                        .foregroundColor(.blue)  // Text color for the text button
                        .padding(.horizontal, 10)  // Horizontal padding for the button
                }

                GoButton(
                    color: .white, padding: EdgeInsets(), useDefaultWidth: false,
                    action: {
                        isShowingSafari = true
                    }
                ) {
                    Text("Quên mật khẩu?")
                        .foregroundColor(.blue)
                        .padding(.horizontal, 10)
                }
                .sheet(isPresented: $isShowingSafari) {
                    SafariView(url: URL(string: GoConstants.urlForgotPassword)!)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)  // Center the buttons horizontally

            .padding(.top, spaceOriented)  // Space between login and buttons in row
            .padding(.bottom, spaceOriented)
            if enalbeSocialLogin == true {
                SocialLoginGroupView(haveGoIdLogin: false)
            }

        }
        .padding()
        .onAppear {
            let saveRememberMe = UserDefaults.standard.bool(forKey: GoConstants.rememberMe)
            rememberMe = saveRememberMe
            if saveRememberMe {
                if let savedUsername = UserDefaults.standard.string(
                    forKey: GoConstants.savedUserName)
                {
                    username = savedUsername
                }
                if let pwdData = KeychainHelper.load(key: GoConstants.savedPassword),
                    let pwd = String(data: pwdData, encoding: .utf8)
                {
                    password = pwd
                }
            }

        }
        //        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)  //topLeading
        .adaptiveVerticalAlignment()
        .background(Color.white)
        .observeOrientation()
        .navigateToDestination(navigationManager: navigationManager)  // Using the extension method
        .navigationTitle("Đăng nhập GoID")
        //        .hideNavigationTitleWhenLandscape()
        //.navigationBarBackButtonHidden(false) // Show back button (default)

        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()

                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Quay lại")  // ← Custom back button text
                    }
                }
            }
        }
        .dismissKeyboardOnInteraction()
    }

    private func submitLoginGoId() {
        let validation = usernameValidator.validate(text: username)
        let validationPwd = pwdValidator.validate(text: password)
        if validation.isValid == false || validationPwd.isValid == false {

            return
        }
        if rememberMe {
            UserDefaults.standard.set(username, forKey: GoConstants.savedUserName)
            if let pwdData = password.data(using: .utf8) {
                KeychainHelper.save(key: GoConstants.savedPassword, data: pwdData)
            }
        } else {
            KeychainHelper.remove(key: GoConstants.savedPassword)
        }
        //                guard !phoneNumber.isEmpty, !otp.isEmpty else {
        //                    alertMessage = "Vui lòng nhập SĐT và otp"
        //                    AlertDialog.instance.show(message: alertMessage)
        //                    return
        //                }

        LoadingDialog.instance.show()

        // This would be a sample data payload to send in the POST request
        let md5: String = Utils.generateHashMD5(input: password) ?? ""
        let bodyData: [String: Any] = [
            "username": username,
            "passwordmd5": md5,

        ]

        // Now, you can call the `post` method on ApiService
        Task {
            await ApiService.shared.post(path: GoApi.oauthLogin, body: bodyData) { result in

                LoadingDialog.instance.hide()

                switch result {
                case .success(let data):
                    // Handle successful response

                    // Parse the response if necessary
                    if let jsonResponse = try? JSONSerialization.jsonObject(
                        with: data, options: []),
                        let responseDict = jsonResponse as? [String: Any]
                    {
                        print("submitLoginGoId Response: \(responseDict)")
                        //                        AlertDialog.instance.show(message:"Đăng nhâp thành công")
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

                print(
                    "onLoginResponse onRequestSuccess userName: \(apiResponse.data?.accessToken ?? "")"
                )
                if apiResponse.data != nil {
                    let tokenData: TokenData = apiResponse.data!
                    if let session = GoPlaySession.deserialize(data: tokenData) {
                        KeychainHelper.save(key: GoConstants.goPlaySession, data: session)
                        AuthManager.shared.postEventLogin(session: session, errorStr: nil)
                        hostingController?.close()
                    } else {
                        AlertDialog.instance.show(message: "Không đọc được Token")
                    }
                }

            } else {
                message = apiResponse.message
                print("onLoginResponse fail onRequestSuccess userName: \(message)")
                AlertDialog.instance.show(message: apiResponse.message)
            }

        } catch {
            print(" errpr \(error)")
            AlertDialog.instance.show(message: error.localizedDescription)
        }
    }

}
