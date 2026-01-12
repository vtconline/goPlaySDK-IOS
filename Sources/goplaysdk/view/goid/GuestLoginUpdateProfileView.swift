import SwiftUI

public struct GuestLoginUpdateProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss
    @Environment(\.hostingController) private var hostingController

    private let onBack: () -> Void

    @StateObject private var navigationManager = NavigationManager()

    @State private var userName = ""
    @State private var passWord = ""
    @State private var phoneNumber = ""
    @State private var email = ""

    @StateObject private var userNameValidator = UsernameValidator()
    @StateObject private var passwordValidator = PasswordValidator()
    @StateObject private var phoneNumberValidator = PhoneValidator()
    @StateObject private var emailValidator = EmailValidator()

    public init(onBack: @escaping () -> Void = {}) {
        self.onBack = onBack
    }
    var spaceOriented: CGFloat {
        // Dynamically set space based on the device orientation
        return DeviceOrientation.shared.isLandscape ? 10 : 10
    }

    public var body: some View {

        VStack(alignment: .center, spacing: spaceOriented) {
            Text(
                "Bạn đang dùng tài khoản chơi ngay. Bạn nên thay đổi tên đăng nhập để có thể sử dụng lần sau"
            )
            .font(.system(size: 16))
            .padding(.vertical, 12)

            GoTextField<UsernameValidator>(
                text: $userName,
                placeholder: "Nhập tài khoản",
                isPwd: false,
                validator: userNameValidator,
                leftIconName: "ic_user_focused",
                isSystemIcon: false
            )
            .keyboardType(.phonePad)
            .padding(.horizontal, 16)

            GoTextField<PasswordValidator>(
                text: $passWord,
                placeholder: "Nhập mật khẩu",
                isPwd: true,
                validator: passwordValidator,
                leftIconName: "ic_lock_focused",
                isSystemIcon: false
            )
            .keyboardType(.phonePad)
            .padding(.horizontal, 16)

            /*GoTextField<PhoneValidator>(text: $phoneNumber, placeholder: "Số ĐT", isPwd: false, validator: phoneNumberValidator, leftIconName: "ic_phone", isSystemIcon: false)
                .keyboardType(.phonePad)
                .padding(.horizontal, 16)
            
            GoTextField<EmailValidator>(text: $email, placeholder: "Email", isPwd: false, validator: emailValidator, leftIconName: "ic_email", isSystemIcon: false)
                .keyboardType(.phonePad)
                .padding(.horizontal, 16)
             */

            GoButton(text: "CẬP NHẬT", action: requestUpdate)

            Spacer()
        }
        .padding()
        .observeOrientation()  // Apply the modifier to detect orientation changes
        .navigateToDestination(navigationManager: navigationManager)  // Using the extension method
        //        .navigationBarHidden(true) // hide navigaotr bar at top
        .navigationTitle("Chơi ngay")
        //                .navigationBarBackButtonHidden(false) // Show back button (default)

        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    onBack()
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Quay lại")  // ← Custom back button text
                    }
                }
            }
        }

    }

    private func requestUpdate() {
        guard !userName.isEmpty, !passWord.isEmpty else {
            AlertDialog.instance.show(
                message: "Vui lòng nhập tài khoản và mật khẩu"
            )
            return
        }
        let userValidation = userNameValidator.validate(text: userName)
        let pwdValidation = passwordValidator.validate(text: passWord)

        if userValidation.isValid == false || pwdValidation.isValid == false {
            return
        }
        LoadingDialog.instance.show()

        // This would be a sample data payload to send in the POST request
        //ios
//    apple login swift sample dev    goId: Ma xac thuc cua ban la: 298604, MKC2 cua ban la: 124A2805. MKC2 chi co tac dung sau khi xac thuc.
        var bodyData: [String: Any] = [
//            "oldAccountName": KeychainHelper.loadCurrentSession()?.userName
//                ?? "",
//            "newAccountName": userName,
//            "password": passWord,
//            "passwordmd5": Utils.md5(passWord),
            "otp": passWord,
//            "jwt":KeychainHelper.loadCurrentSession()?.accessToken
        ]
        //test
        var params222 = GoApiService.shared.getuserParams(nil)
        bodyData = bodyData.merging(params222 ?? [:]) { current, _ in current }
        //test
        
        
        var bodyMerge = Utils.getPartnerParams()
        bodyData = bodyData.merging(bodyMerge ?? [:]) { current, _ in current }

        if !email.isEmpty {
            let emailValidation = emailValidator.validate(text: email)
            if emailValidation.isValid == false {
                return
            }
            bodyData["Email"] = email
        }

        print("oApi.userRename params \(bodyData)")
        Task {
            await ApiService.shared.post(
                path: GoApi.verifyPhone,//GoApi.verifyPhone GoApi.userRename
                body: bodyData,
                sign: false
            ) { result in

                LoadingDialog.instance.hide()

                switch result {
                case .success(let data):
                    // Handle successful response

                    // Parse the response if necessary
                    if let jsonResponse = try? JSONSerialization.jsonObject(
                        with: data,
                        options: []
                    ),
                        let responseDict = jsonResponse as? [String: Any]
                    {
                        print("requestUpdate Response: \(responseDict)")
                        onUpdateInfoResponse(response: responseDict)
                        
                    }

                case .failure(let error):
                    // Handle failure response
                    //                    print("Error: \(error.localizedDescription)")
                    AlertDialog.instance.show(
                        message: error.localizedDescription
                    )
                }
            }
        }
    }

    func onUpdateInfoResponse(response: [String: Any]) {
        do {
            let jsonData = try JSONSerialization.data(
                withJSONObject: response,
                options: []
            )
            let apiResponse = try JSONDecoder().decode(
                GoPlayApiResponse<TokenData>.self,
                from: jsonData
            )

            var message = "Lỗi đăng ký"

            if apiResponse.isSuccess() {

                print(
                    "onUpdateInfoResponse onRequestSuccess userName: \(apiResponse.data?.accessToken ?? "")"
                )
                guard apiResponse.data != nil else {
                    AlertDialog.instance.show(
                        message: "Không đọc được TokenData"
                    )
                    return
                }
                let tokenData: TokenData = apiResponse.data!
                if let session = GoPlaySession.deserialize(data: tokenData) {
                    KeychainHelper.save(
                        key: GoConstants.goPlaySession,
                        data: session
                    )
                    AuthManager.shared.postEventAccountLinking(
                        session: session,
                        error: nil
                    )
                    hostingController?.close()
                } else {
                    AlertDialog.instance.show(message: "Không đọc được Token")
                }

            } else {
                message = apiResponse.message
                AlertDialog.instance.show(message: apiResponse.message)
            }

        } catch {
            print("error linking \(error)")
            AlertDialog.instance.show(message: error.localizedDescription)
        }
    }

}
