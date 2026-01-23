import SwiftUI
///
///https://dev-api.goplay.vn/core/v1/authen-service/oauth/getotp?Mobile=0979221902
///thay sdt login để lấy otp sau khi đã nhấn Gửi OTP trong view này
///
public struct PhoneLoginOtpView: View {
    @Environment(\.presentationMode) var presentationMode

    @Environment(\.hostingController) private var hostingController

    @StateObjectCompat private var navigationManager = NavigationManager()

    @State private var step = 0
    @State private var otpNumber = ""
    @State private var phoneNumber = ""

    @State private var isSentOtp = false

    @State private var otpRemainTxt = ""
    @State private var otpTimeTotal = 0

    //tao mat khau
    @State private var passWord = ""
    @State private var rePassWord = ""
    @StateObjectCompat private var passwordValidator = PasswordValidator()
    @StateObjectCompat private var rePasswordValidator = PasswordValidator()

    @StateObjectCompat private var otpValidator = OTPValidator()

    private let onBack: (() -> Void)?
    private let onPhoneActiveCallback: ((_ mustActive: Bool) -> Void)?

    public init(
        phone: String = "",
        onBack: (() -> Void)? = nil,
        onPhoneActive: ((_ mustActive: Bool) -> Void)? = nil
    ) {
        self.onBack = onBack
        self.onPhoneActiveCallback = onPhoneActive
        if phone.isEmpty == false {
            //_step = State(initialValue: 1)
            //            _isDisablePhoneTxt = State(initialValue: true)
        }
        _phoneNumber = .init(initialValue: phone)
    }
    var spaceOriented: CGFloat {
        // Dynamically set space based on the device orientation
        return DeviceOrientation.shared.isLandscape ? 10 : 4
    }

    public var body: some View {
        VStack(alignment: .center, spacing: spaceOriented) {
            if step == 0 {
                verifyOTPview()
                OTPNoteView()
                    .frame(
                        maxWidth: DeviceOrientation.shared.isLandscape
                            ? .infinity : 300,
                        alignment: .leading
                    )
            } else {
                createPassWordView()
                Text("Mật khẩu bao gồm:\n- Mật khẩu gồm ít nhất 1 chữ thường, 1 số, 1 viết hoa\n- Ít nhất 8 ký tự")
        //                .fontWeight(.semibold)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .padding(.vertical, 10)
                    .frame(maxWidth: AppTheme.Buttons.defaultWidth, alignment: .leading)
            }
            
        }
        .observeOrientation()  // Apply the modifier to detect orientation changes
        .navigateToDestination(navigationManager: navigationManager)  // Using the extension method
        //        .navigationBarHidden(true) // hide navigaotr bar at top
        .compatNavigationTitle("Xác thực SĐT")

        .navigationBarBackButtonHidden(true)
        .compatToolbar {
            GoPlayDismissButton()
        }

    }
    @ViewBuilder
    private func createPassWordView() -> some View {

        Text(
            "Nhập mật khẩu mới:"
        )
        .fontWeight(.semibold)
        .font(.system(size: 16))
        .foregroundColor(.black)
        .padding(.vertical, 10)
        .frame(maxWidth: AppTheme.Buttons.defaultWidth, alignment: .center)

        Text("Mật khẩu")
            .fontWeight(.semibold)
            .font(.system(size: 16))
            .foregroundColor(.black)
            .padding(.vertical, 10)
            .frame(maxWidth: AppTheme.Buttons.defaultWidth, alignment: .leading)

        GoTextField<PasswordValidator>(
            text: $passWord,
            placeholder: "Nhập mật khẩu",
            isPwd: true,
            validator: passwordValidator,
            leftIconName: "ic_lock_focused",
            isSystemIcon: false
        )
        .keyboardType(.default)
        .padding(.horizontal, 16)
        Text("Nhập lại mật khẩu")
            .fontWeight(.semibold)
            .font(.system(size: 16))
            .foregroundColor(.black)
            .padding(.vertical, 10)
            .frame(maxWidth: AppTheme.Buttons.defaultWidth, alignment: .leading)
        GoTextField<PasswordValidator>(
            text: $rePassWord,
            placeholder: "Nhập lại mật khẩu",
            isPwd: true,
            validator: rePasswordValidator,
            leftIconName: "ic_lock_focused",
            isSystemIcon: false
        )
        .keyboardType(.default)
        .padding(.horizontal, 16)

                    GoButton(color: .black,  action: requestCreatePassword){
                        Text("Xác nhận")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }

        

    }

    @ViewBuilder
    private func verifyOTPview() -> some View {
        Text("Mã OTP được gửi tới số điện thoại \(phoneNumber)")
            .foregroundColor(.black)
            .fontWeight(.semibold)
            .font(.system(size: 16))

        OTPInputView(otp: $otpNumber)
            .frame(maxWidth: .infinity, alignment: .center)

        Text("\(otpRemainTxt)")
            .foregroundColor(.red)
        Text(
            "OTP chỉ có giá trị trong vòng \(String(format: "%02d:%02d",otpTimeTotal/60,otpTimeTotal%60)) phút"
        )
        .foregroundColor(.black)

        GoButton(
            color: .black,
            action: isSentOtp ? requestLoginWithOtp : submitGetOtp
        ) {
            Text(isSentOtp ? "Xác nhận" : "Gửi OTP")
                .font(.system(size: 16))
                .foregroundColor(.white)
        }
        Spacer()

    }

    private func submitGetOtp() {

        LoadingDialog.instance.show()
        Task {
            let bodyData: [String: Any] = [
                "username": "",
                "otpname": phoneNumber,
                "loginType": LoginType.phone.rawValue,
            ]
            await ApiService.shared.post(
                path: GoApi.oauthGetAuthenOtp,
                bodyJwtSign: bodyData
            ) { result in

                LoadingDialog.instance.hide()

                switch result {
                case .success(let data):

                    if let jsonResponse = try? JSONSerialization.jsonObject(
                        with: data,
                        options: []
                    ),
                        let responseDict = jsonResponse as? [String: Any]
                    {
                        //                        print("submitGetOtp Response: \(responseDict)")
                        checkOtpResponse(response: responseDict)
                    }

                case .failure(let error):
                    // Handle failure response
                    print("submitGetOtp Error: \(error)")
                    AlertDialog.instance.show(
                        message: error.localizedDescription
                    )
                }
            }
        }
    }

    func checkOtpResponse(response: [String: Any]) {
        do {

            let jsonData = try JSONSerialization.data(
                withJSONObject: response,
                options: []
            )
            let apiResponse: GoPlayApiResponse<Int>

            //            if(GoPlaySDK.instance.isSandBox){
            //                apiResponse = GoPlayApiResponse<Int>.createTest(
            //                    data: 300
            //                )
            //            }else{
            //                apiResponse = try JSONDecoder().decode(
            //                    GoPlayApiResponse<Int>.self,
            //                    from: jsonData
            //                )
            //            }
            apiResponse = try JSONDecoder().decode(
                GoPlayApiResponse<Int>.self,
                from: jsonData
            )

            var message = "Lỗi OTP"
            var haveError = true

            if apiResponse.isSuccess() {
                //print("checkOtpResponse onRequestSuccess data: \(apiResponse.data ?? 0)")
                isSentOtp = true

                let timeCountDown: Int = (apiResponse.data as? Int) ?? 0
                otpTimeTotal = timeCountDown
                print(
                    "checkOtpResponse onRequestSuccess data: \(timeCountDown)"
                )
                if timeCountDown > 0 {
                    haveError = false

                    DispatchQueue.main.async {
                        Utils.startCountdown(
                            totalSeconds: timeCountDown,
                            onTick: { secondsLeft in
                                let minutes = secondsLeft / 60
                                let seconds = secondsLeft % 60
                                otpRemainTxt = String(
                                    format: "%02d:%02d",
                                    minutes,
                                    seconds
                                )

                            },
                            onFinish: {
                                //                                print("onFinish tick: ")
                                //                                step = 0
                                otpRemainTxt = ""
                                isSentOtp = false
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

    private func requestLoginWithOtp() {
        guard !phoneNumber.isEmpty, !otpNumber.isEmpty else {
            AlertDialog.instance.show(message: "Vui lòng nhập SĐT và otp")
            return
        }
        //        let validation = phoneNumberValidator.validate(text: phoneNumber)
        //        let otpValidation = otpValidator.validate(text: phoneNumber)
        //        if validation.isValid == false || otpValidation.isValid == false {
        //            return
        //        }
        LoadingDialog.instance.show()

        // This would be a sample data payload to send in the POST request
        let bodyData: [String: Any] = [
            "username": "",
            "passwordmd5": "",
            "salt": "",
            "otpname": phoneNumber,
            "loginType": LoginType.phone.rawValue,
            "otppass": otpNumber,
        ]

        Task {
            await ApiService.shared.post(
                path: GoApi.oauthLogin,
                bodyJwtSign: bodyData
            ) { result in

                LoadingDialog.instance.hide()

                switch result {
                case .success(let data):
                    

                    // Parse the response if necessary
//                    if let jsonResponse = try? JSONSerialization.jsonObject(
//                        with: data,
//                        options: []
//                    ),
//                        let responseDict = jsonResponse as? [String: Any]
//                    {
//                        print("requestLoginWithOtp Response: \(responseDict)")
//                        onLoginResponse(jsonData: data)
//                    }
                    onLoginResponse(jsonData: data)
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

    func onLoginResponse(jsonData: Data) {
        do {
//            let jsonData = try JSONSerialization.data(
//                withJSONObject: response,
//                options: []
//            )
            let apiResponse = try JSONDecoder().decode(
                GoPlayApiResponse<TokenData>.self,
                from: jsonData
            )

            var message = "Lỗi đăng nhập"

            if apiResponse.isSuccess() {

                //                print(
                //                    "onLoginResponse onRequestSuccess mustActive \(apiResponse.isMustActive()) token: \(apiResponse.data?.accessToken ?? "")"
                //                )
                if apiResponse.data != nil {
                    let tokenData: TokenData = apiResponse.data!
                    if let session = GoPlaySession.deserialize(data: tokenData)
                    {

                        
                        if apiResponse.nextStep
                            == GoNextStep.mustUpdatePwd.rawValue
                        {
                            AuthManager.shared.saveSession(session) //create pwd need sesion
                            step = 1
                            return
                        }
                        //login done
                        self.onPhoneActiveCallback?(true)
                        
                        AccountManager.saveAndSetCurrent(
                            Account(
                                userId: Int(session.userId ?? 0),
                                username: session.userName ?? "",
                                credential: passWord
                            )
                        )
                        
                        AuthManager.shared.handleLoginSuccess(
                            session, true
                        )

                        hostingController?.close()

                    } else {
                        AlertDialog.instance.show(
                            message: "Không đọc được Token"
                        )
                    }
                }

            } else {
                message = apiResponse.message
                print(
                    "onLoginResponse fail onRequestSuccess userName: \(message)"
                )
                AlertDialog.instance.show(message: apiResponse.message)
            }

        } catch {
            print(" errpr \(error)")
            AlertDialog.instance.show(message: error.localizedDescription)
        }
    }
    
    private func requestCreatePassword() {
        guard !passWord.isEmpty, !rePassWord.isEmpty else {
            AlertDialog.instance.show(message: "Vui lòng nhập đủ 2 mật khẩu")
            return
        }
        guard passWord == rePassWord else {
            AlertDialog.instance.show(message: "2 mật khẩu không khớp nhau")
            return
        }
                let validation = passwordValidator.validate(text: passWord)
                let rePwdValidate = rePasswordValidator.validate(text: rePassWord)
                if validation.isValid == false  {
                    AlertDialog.instance.show(message: validation.errorMessage)
                    return
                }
        if rePwdValidate.isValid == false  {
            AlertDialog.instance.show(message: rePwdValidate.errorMessage)
            return
        }
        LoadingDialog.instance.show()

        // This would be a sample data payload to send in the POST request
        let bodyData: [String: Any] = [
            "oldAccountName": phoneNumber,
            "newAccountName": phoneNumber,
            "passwordmd5": Utils.md5(passWord),
            "password": passWord,
            "client_secret": ApiService.shared.clientSecret,
//            "jwt": , post api sẽ tự gán jwt từ sesion nếu ko có
            "Email": ""
        ]

        Task {
            await ApiService.shared.post(
                path: GoApi.userRename,
                body: bodyData
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
                        print("requestCreatePassword Response: \(responseDict)")

                    }
                    onLoginResponse(jsonData: data)

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

}
