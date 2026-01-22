import SwiftUI

public struct PhoneActiveView: View {
    @Environment(\.presentationMode) var presentationMode

    @Environment(\.hostingController) private var hostingController

    private let onBack: () -> Void

    @StateObjectCompat private var navigationManager = NavigationManager()

    @State private var step = 0
    @State private var otpNumber = ""
    @State private var phoneNumber = ""

    @State private var otpRemainTxt = ""
    @State private var otpTimeTotal = 0

    @StateObjectCompat private var passwordValidator = PasswordValidator()
    @StateObjectCompat private var phoneNumberValidator = PhoneValidator()
    @StateObjectCompat private var otpValidator = OTPValidator()

    public init(onBack: @escaping () -> Void = {}) {
        self.onBack = onBack
    }
    var spaceOriented: CGFloat {
        // Dynamically set space based on the device orientation
        return DeviceOrientation.shared.isLandscape ? 10 : 10
    }

    public var body: some View {
        VStack(alignment: .center, spacing: spaceOriented) {
            if step == 0 {
                inputPhoneview()
            } else {
                verifyOTPview()
            }
            OTPNoteView()
                .frame(maxWidth: DeviceOrientation.shared.isLandscape ? .infinity : 300, alignment: .leading)
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
    private func inputPhoneview() -> some View {
        //        VStack(alignment: .center, spacing: spaceOriented) {
        Text(
            "Bạn cần hoàn thành xác thực tài khoản để sử dụng các tính năng và tham gia trò chơi."
        )
        .font(.system(size: 16))
        .padding(.vertical, 12)

        Text("Nhập số điện thoại đang dùng tại đây")
            .fontWeight(.semibold)
            .font(.system(size: 16))
            .foregroundColor(.black)
            .padding(.vertical, 10)
            .frame(maxWidth: 300, alignment: .leading)
        GoTextField<PhoneValidator>(
            text: $phoneNumber,
            placeholder: "Nhập số điện thoại",
            isPwd: false,
            validator: phoneNumberValidator
        )
        .keyboardType(.phonePad)
        .padding(.horizontal, 16)

        GoButton(color: .black, action: submitGetOtp) {
            Text("Gửi OTP")
                .font(.system(size: 16))
                .foregroundColor(.white)
        }
        Spacer()

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

        GoButton(color: .black, action: requestVerifyOtp) {
            Text("Xác nhận")
                .font(.system(size: 16))
                .foregroundColor(.white)
        }
        Spacer()

    }

    private func submitGetOtp() {
        guard !phoneNumber.isEmpty else {
            //            alertMessage = "SĐT không được bỏ trống"
            AlertDialog.instance.show(message: "SĐT không được bỏ trống")
            return
        }
//        if(GoPlaySDK.instance.isSandBox){
//            print("use https://sandbox.goplay.vn/thong-tin-testt.html để lấy otp")
//            let testData: [String: Any] = [:]
//            checkOtpResponse(response: testData)
//            return
//        }
        
        LoadingDialog.instance.show()
        Task {
            var bodyData: [String: Any] = [
                "mobile": phoneNumber,
                
            ]
            
            //test
//            var params222 = GoApiService.shared.getuserParams(nil)
//            bodyData = bodyData.merging(params222 ?? [:]) { current, _ in current }
//            //test
//            
//            
//            var bodyMerge = Utils.getPartnerParams()
//            bodyData = bodyData.merging(bodyMerge ?? [:]) { current, _ in current }
            
            
            
            await ApiService.shared.post(
                path: GoApi.oauthPhoneGetOtp,
                body: bodyData,
                bodyJwtSign: [:],
                payloadType: GoPayloadType.userInfo
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
            let apiResponse : GoPlayApiResponse<Int>
            
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
                step = 1
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
                                step = 0
                                otpRemainTxt = ""
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

    private func requestVerifyOtp() {
        guard !otpNumber.isEmpty else {
            AlertDialog.instance.show(
                message: "Vui lòng nhập OTP"
            )
            return
        }
        //        let userValidation = userNameValidator.validate(text: userName)
        let otpValidation = otpValidator.validate(text: otpNumber)

        if otpValidation.isValid == false {
            AlertDialog.instance.show(
                message: otpValidation.errorMessage ?? "Vui lòng nhập đủ OTP"
            )
            return
        }
        LoadingDialog.instance.show()

        // This would be a sample data payload to send in the POST request
        //ios
        //    apple login swift sample dev    goId: Ma xac thuc cua ban la: 298604, MKC2 cua ban la: 124A2805. MKC2 chi co tac dung sau khi xac thuc.
        var bodyData: [String: Any] = [
            "mobile": phoneNumber,
            "otp": otpNumber
        ]
        //test
//        var params222 = GoApiService.shared.getuserParams(nil)
//        bodyData = bodyData.merging(params222 ?? [:]) { current, _ in current }
//        //test
//
//        var bodyMerge = Utils.getPartnerParams()
//        bodyData = bodyData.merging(bodyMerge ?? [:]) { current, _ in current }

//        print("oApi.phoneactive params \(bodyData)")
        Task {
            await ApiService.shared.post(
                path: GoApi.oauthPhoneActiveOtp,  //GoApi.verifyPhone GoApi.userRename
                body: bodyData,
                bodyJwtSign: [:],
                payloadType: GoPayloadType.userInfo
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
//                        print("requestVerifyOtp Response: \(responseDict)")
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
                GoPlayApiResponse<Int>.self,
                from: jsonData
            )

            var message = "Lỗi OTP"

            if apiResponse.isSuccess() {
                if(AuthManager.shared.currentSesion() != nil){
                    AuthManager.shared.handleLoginSuccess(AuthManager.shared.currentSesion()!)
                }
                

                hostingController?.close()
            } else {
                message = apiResponse.message
                AlertDialog.instance.show(message: apiResponse.message)
            }

        } catch {
            print("error OTP \(error)")
            AlertDialog.instance.show(message: error.localizedDescription)
        }
    }

}
