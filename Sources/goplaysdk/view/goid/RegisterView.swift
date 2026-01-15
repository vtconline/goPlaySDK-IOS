import SwiftUI

public struct RegisterView: View {
    //    @Environment(\.presentationMode) var presentationMode
  
    @Environment(\.hostingController) private var hostingController
    @StateObjectCompat private var navigationManager = NavigationManager()

    @State private var userName = ""
    @State private var passWord = ""
    @State private var phoneNumber = ""
    @State private var email = ""

    @StateObjectCompat private var userNameValidator = UsernameValidator()
    @StateObjectCompat private var passwordValidator = PasswordValidator()
    @StateObjectCompat private var phoneNumberValidator = PhoneValidator()
    @StateObjectCompat private var emailValidator = EmailValidator()

    public init() {}
    var spaceOriented: CGFloat {
        // Dynamically set space based on the device orientation
        return DeviceOrientation.shared.isLandscape ? 10 : 10
    }

    public var body: some View {

        VStack(alignment: .center, spacing: spaceOriented) {

            GoTextField<UsernameValidator>(
                text: $userName, placeholder: "Nhập tài khoản", isPwd: false,
                validator: userNameValidator, leftIconName: "ic_user_focused",
                isSystemIcon: false
            )
            .keyboardType(.default)
            .padding(.horizontal, 16)

            GoTextField<PasswordValidator>(
                text: $passWord, placeholder: "Nhập mật khẩu", isPwd: true,
                validator: passwordValidator, leftIconName: "ic_lock_focused",
                isSystemIcon: false
            )
            .keyboardType(.default)
            .padding(.horizontal, 16)

            GoTextField<PhoneValidator>(
                text: $phoneNumber, placeholder: "Số ĐT", isPwd: false,
                validator: phoneNumberValidator, leftIconName: "ic_phone",
                isSystemIcon: false, keyboardType: .numberPad
            )
            .padding(.horizontal, 16)

            GoTextField<EmailValidator>(
                text: $email, placeholder: "Email", isPwd: false, validator: emailValidator,
                leftIconName: "ic_email", isSystemIcon: false, keyboardType: .emailAddress
            )

            .padding(.horizontal, 16)

            GoButton(text: "ĐĂNG KÝ", action: {
                Task { @MainActor in
                        await submitLoginPhone()
                    }
            })

            Spacer()
        }
        .padding()
        .observeOrientation()  // Apply the modifier to detect orientation changes
        //        .navigateToDestination(navigationManager: navigationManager)  // Using the extension method
        
        //        .navigationBarHidden(true) // hide navigaotr bar at top
        .compatNavigationTitle("Đăng ký GOID")
        //                .navigationBarBackButtonHidden(false) // Show back button (default)

        .navigationBarBackButtonHidden(true)
        .compatToolbar {
            GoPlayDismissButton()
        }

    }

    private func submitLoginPhone() async {
        guard !userName.isEmpty, !passWord.isEmpty else {
            AlertDialog.instance.show(message: "Vui lòng nhập tài khoản và mật khẩu")
            return
        }
        let userValidation = userNameValidator.validate(text: userName)
        let pwdValidation = passwordValidator.validate(text: passWord)

        if userValidation.isValid == false || pwdValidation.isValid == false {
            return
        }
        LoadingDialog.instance.show()

        // This would be a sample data payload to send in the POST request
        var bodyData: [String: Any] = [
            "username": userName,
            "password": passWord,
        ]
        if !phoneNumber.isEmpty {
            let phoneValidation = phoneNumberValidator.validate(text: phoneNumber)
            if phoneValidation.isValid == false {

                return
            }
            bodyData["mobile"] = phoneNumber
        }
        if !email.isEmpty {
            let emailValidation = emailValidator.validate(text: email)
            if emailValidation.isValid == false {
                return
            }
            bodyData["email"] = email
        }

        // Now, you can call the `post` method on ApiService
        
             await ApiService.shared.post(path: GoApi.oauthRegister, body: bodyData) { result in
                 Task{@MainActor in
                     LoadingDialog.instance.hide()

                     switch result {
                     case .success(let data):
                         // Handle successful response

                         // Parse the response if necessary
                         if let jsonResponse = try? JSONSerialization.jsonObject(
                             with: data, options: []),
                             let responseDict = jsonResponse as? [String: Any]
                         {
                             // print("onRegisterResponse Response: \(responseDict)")
                             onRegisterResponse(response: responseDict)
                             
                         }

                     case .failure(let error):
                         // Handle failure response
                         //                    print("Error: \(error.localizedDescription)")
                         AlertDialog.instance.show(message: error.localizedDescription)
                     }
                 }
               
           }
        
       
             
        
    }

    func onRegisterResponse(response: [String: Any]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: response, options: [])
            let apiResponse = try JSONDecoder().decode(
                GoPlayApiResponse<TokenData>.self, from: jsonData)

            var message = "Lỗi đăng ký"

            if apiResponse.isSuccess() {

                print(
                    "onRegisterResponse onRequestSuccess userName: \(apiResponse.data?.accessToken ?? "")"
                )
                guard apiResponse.data != nil else {
                    AlertDialog.instance.show(message: "Không đọc được TokenData")
                    return
                }
                let tokenData: TokenData = apiResponse.data!
                if let session = GoPlaySession.deserialize(data: tokenData) {
                    UserDefaults.standard.set(session.userName, forKey: GoConstants.savedUserName)
                    AuthManager.shared.handleLoginSuccess(session)
                    hostingController?.close()
                } else {
                    AlertDialog.instance.show(message: "Không đọc được Token")
                }

            } else {
                message = apiResponse.message
                AlertDialog.instance.show(message: apiResponse.message)
            }

        } catch {
            print("error register \(error)")
            AlertDialog.instance.show(message: error.localizedDescription)
        }
    }

}
