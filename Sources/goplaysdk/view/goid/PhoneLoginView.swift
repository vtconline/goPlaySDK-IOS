import SwiftUI

//0394253555
public struct PhoneLoginView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    @Environment(\.hostingController) private var hostingController
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var navigationManager = NavigationManager()

    @State private var phoneNumber = ""  // Store the phone number
    @State private var otp = ""  // Store the OTP
    @State private var otpButtonText = "Get OTP"  // Text for OTP button
    @State private var isOtpSent = false  // Track OTP sent status
    @State private var alertMessage = ""  // Alert message
    @State private var isLoading = false  // Loading state for API calls

    @StateObject private var phoneNumberValidator = PhoneValidator()  // Validator for phone number
    @StateObject private var otpValidator = OTPValidator()  // Validator for OTP

    @State private var checkPhoneDone = false
    @State private var buttonOtpText = "Click Me"
    @State private var isButtonOtpDisabled = false

    public init() {}
    var spaceOriented: CGFloat {
        // Dynamically set space based on the device orientation
        return DeviceOrientation.shared.isLandscape ? 10 : 10
    }

    public var body: some View {

        VStack(alignment: .center, spacing: spaceOriented) {

            // Phone Number GoTextField
            GoTextField<PhoneValidator>(
                text: $phoneNumber, placeholder: "Nhập số điện thoại", isPwd: false,
                validator: phoneNumberValidator, leftIconName: "ic_phone", isSystemIcon: false,
                keyboardType: .numberPad
            )
            .keyboardType(.phonePad)
            .padding(.horizontal, 16)

            // OTP GoTextField with Get OTP Button
            if checkPhoneDone {
                HStack {
                    GoTextField<OTPValidator>(
                        text: $otp, placeholder: "Enter OTP", isPwd: false, validator: otpValidator,
                        leftIconName: "ic_lock_focused",
                        isSystemIcon: false
                    )
                    .keyboardType(.numberPad)
                    .padding(.trailing, 16)

                    Button(action: submitGetOtp) {
                        if isButtonOtpDisabled {
                            Text(buttonOtpText)
                                .foregroundColor(.blue)
                                .padding(10)  // Padding inside the border
                                .overlay(
                                    RoundedRectangle(cornerRadius: 2)  // Border color and thickness
                                        .stroke(AppTheme.Colors.primary, lineWidth: 2)
                                    //
                                )
                        } else {
                            Image(systemName: "paperplane.fill")  // You can use any icon for the OTP button
                                .foregroundColor(AppTheme.Colors.primary)
                                .padding()
                        }

                    }
                    .disabled(isButtonOtpDisabled)
                    //                    .background(isButtonOtpDisabled ? Color.gray : Color.blue)
                }
                .frame(width: min(UIScreen.main.bounds.width - 32, 300))
            }

            // Submit Button to verify phone and OTP
            GoButton(
                text: checkPhoneDone ? "ĐĂNG NHẬP SĐT" : "KIỂM TRA SĐT",
                action: checkPhoneDone ? submitLoginPhone : submitCheckPhone)

            HStack(alignment: .center) {
                Rectangle()
                    .fill(Color.gray)
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)

                Text("hoặc")
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)

                Rectangle()
                    .fill(Color.gray)
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 0)
            .padding(.horizontal, 32)

            SocialLoginGroupView(haveGoIdLogin: true)

            Spacer()
        }
        .padding()
        .observeOrientation()  // Apply the modifier to detect orientation changes
        //        .navigateToDestination(navigationManager: navigationManager)  // Using the extension method
        //        .resetNavigationWhenInActive(navigationManager: navigationManager, scenePhase: scenePhase)
        //        .navigationBarHidden(true) // hide navigaotr bar at top
        .navigationTitle("Đăng nhập với SĐT")
        //                .navigationBarBackButtonHidden(false) // Show back button (default)

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
        .background(Color.white)
        .dismissKeyboardOnInteraction()

    }

    private func submitGetOtp() {
        guard !phoneNumber.isEmpty else {
            alertMessage = "SĐT không được bỏ trống"
            AlertDialog.instance.show(message: alertMessage)
            return
        }
        LoadingDialog.instance.show()
        Task {
            let bodyData: [String: Any] = [
                "otpname": phoneNumber,
                "loginType": LoginType.phone.rawValue,
            ]
            await ApiService.shared.post(path: GoApi.oauthGetAuthenOtp, body: bodyData) { result in

                LoadingDialog.instance.hide()

                switch result {
                case .success(let data):
                    // Handle successful response

                    // Parse the response if necessary
                    if let jsonResponse = try? JSONSerialization.jsonObject(
                        with: data, options: []),
                        let responseDict = jsonResponse as? [String: Any]
                    {
                        print("submitGetOtp Response: \(responseDict)")
                        checkOtpResponse(response: responseDict)
                    }

                case .failure(let error):
                    // Handle failure response
                    print("submitGetOtp Error: \(error)")
                    AlertDialog.instance.show(message: error.localizedDescription)
                }
            }
        }
    }

    private func submitCheckPhone() {
        guard !phoneNumber.isEmpty else {
            alertMessage = "Vui lòng nhập SĐT"
            AlertDialog.instance.show(message: alertMessage)
            return
        }
        let validation = phoneNumberValidator.validate(text: phoneNumber)
        if validation.isValid == false {
            return
        }
        LoadingDialog.instance.show()

        let bodyData: [String: Any] = [
            "otpname": phoneNumber,
            "loginType": LoginType.phone.rawValue,
        ]

        // Now, you can call the `post` method on ApiService
        Task {
            await ApiService.shared.post(path: GoApi.oauthCheckAuthenOtp, body: bodyData) {
                result in

                LoadingDialog.instance.hide()

                switch result {
                case .success(let data):
                    // Handle successful response

                    // Parse the response if necessary
                    if let jsonResponse = try? JSONSerialization.jsonObject(
                        with: data, options: []),
                        let responseDict = jsonResponse as? [String: Any]
                    {
                        print("submitCheckPhone Response: \(responseDict)")
                        DispatchQueue.main.async {
                            checkPhoneNumberResponse(response: responseDict)
                        }

                    }

                case .failure(let error):
                    // Handle failure response
                    print("Error: \(error)")
                    DispatchQueue.main.async {
                        AlertDialog.instance.show(message: error.localizedDescription)
                    }

                }
            }
        }
    }

    private func submitLoginPhone() {
        guard !phoneNumber.isEmpty, !otp.isEmpty else {
            alertMessage = "Vui lòng nhập SĐT và otp"
            AlertDialog.instance.show(message: alertMessage)
            return
        }
        let validation = phoneNumberValidator.validate(text: phoneNumber)
        let otpValidation = otpValidator.validate(text: phoneNumber)
        if validation.isValid == false || otpValidation.isValid == false {
            return
        }
        LoadingDialog.instance.show()

        // This would be a sample data payload to send in the POST request
        let bodyData: [String: Any] = [
            "otpname": phoneNumber,
            "loginType": LoginType.phone.rawValue,
            "otppass": otp,
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
                        print("submitLoginPhone Response: \(responseDict)")
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

    func checkOtpResponse(response: [String: Any]) {
        do {

            let jsonData = try JSONSerialization.data(withJSONObject: response, options: [])
            let apiResponse = try JSONDecoder().decode(GoPlayApiResponse<Int>.self, from: jsonData)

            var message = "Lỗi OTP"
            var haveError = true

            if apiResponse.isSuccess() {
                //                print("checkOtpResponse onRequestSuccess data: \(apiResponse.data ?? 0)")

                let timeCountDown: Int = (apiResponse.data as? Int) ?? 0

                print("checkOtpResponse onRequestSuccess data: \(timeCountDown)")
                if timeCountDown > 0 {
                    haveError = false
                    isButtonOtpDisabled = true
                    DispatchQueue.main.async {
                        Utils.startCountdown(
                            totalSeconds: timeCountDown,
                            onTick: { secondsLeft in
                                let minutes = secondsLeft / 60
                                let seconds = secondsLeft % 60
                                print("checkOtpResponse tick data: \(minutes) \(seconds)")
                                buttonOtpText = String(format: "%02d:%02d", minutes, seconds)

                            },
                            onFinish: {
                                print("onFinish tick: ")
                                isButtonOtpDisabled = false
                                buttonOtpText = ""
                            }
                        )
                    }

                } else {
                    message =
                        apiResponse.message.isEmpty
                        ? "Có lỗi. Vui lòng lấy OTP mới" : apiResponse.message
                }

            } else {
                message = apiResponse.message
            }

            if haveError {
                AlertDialog.instance.show(message: message)

            }

        } catch {
            AlertDialog.instance.show(message: error.localizedDescription)
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
                        AuthManager.shared.handleLoginSuccess(session)
                        hostingController?.close() // close this view
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

    func checkPhoneNumberResponse(response: [String: Any]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: response, options: [])
            let apiResponse = try JSONDecoder().decode(CheckAuthenOtp.self, from: jsonData)

            print("apiResponse isSuccessed: \(apiResponse.isSuccessed)")

            var message = "Lỗi sđt"
            var haveError = true

            if apiResponse.isSuccessed {
                haveError = false
                let listUser = apiResponse.data

                if !listUser.isEmpty {

                    if listUser.count == 1 {
                        let userInfo = listUser[0]
                        print("userInfo.accountType = \(userInfo.accountType)")

                        if userInfo.accountType == AccountType.goId.rawValue {
                            var msg =
                                "SĐT \(userInfo.mobile) khai báo cho tài khoản \(userInfo.accountName). Hãy đăng nhập bằng tài khoản và mật khẩu goID!"
                            if userInfo.confirmCode == ConfirmCode.emailActive.rawValue
                                || userInfo.confirmCode == ConfirmCode.emailAndPhoneActive.rawValue
                            {
                                msg =
                                    "SĐT \(userInfo.mobile) đã kích hoạt cho tài khoản \(userInfo.accountName). Hãy đăng nhập bằng mật khẩu goID!"
                            }
                            AlertDialog.instance.show(
                                message: msg,
                                onOk: {
                                    //                                print("User navigateToGoIDView confirmed")
                                    navigationManager.navigate(
                                        to: NavigationDestination.goIdAuthenView)
                                })

                        } else {
                            //userInfo.accountType == AccountType.phone.rawValue
                            checkPhoneDone = true
                            //                            self.otpView.isHidden = false
                            //                            self.btnLoginPhone.isHidden = true
                        }
                    } else {
                        let msg =
                            "Bạn có \(apiResponse.userCount) tài khoản kích hoạt bằng SĐT \(listUser.first?.mobile ?? ""). Hãy đăng nhập bằng tài khoản và mật khẩu goID!"

                        AlertDialog.instance.show(message: msg)

                    }
                } else {
                    // Chưa có tài khoản nào gắn với số điện thoại
                    //                    self.otpView.isHidden = false
                    checkPhoneDone = true
                }
            } else {
                message = apiResponse.message
            }

            if haveError {
                AlertDialog.instance.show(message: message)
            }

        } catch {
            print("Parsing or network error: \(error)")
            AlertDialog.instance.show(message: error.localizedDescription)
        }
    }
}
