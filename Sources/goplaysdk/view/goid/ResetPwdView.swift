import SwiftUI

public struct ResetPwdView: View {
    @Environment(\.hostingController) private var hostingController
    @StateObjectCompat private var navigationManager = NavigationManager()
    
    @Environment(\.presentationMode) private var presentationMode
    

    @State private var otp = ""
    @State private var passWord = ""
    @State private var rePassWord = ""

    @StateObjectCompat private var passwordValidator = PasswordValidator()
    @StateObjectCompat private var rePasswordValidator = PasswordValidator()
    
    private var phoneNumber : String = ""
    private var goId : Int = 0
    private var userName : String = ""
    private let onDoneCallback: ((_ mustActive: Bool) -> Void)?


    
    private var title: String = "Quên mật khẩu"

//    let goPlaySession: GoPlaySession?
//    let userProfile: UserProfile?
//    let userProfile: CheckAuthenUserInfo?
    public init(goId: Int, phoneNumber: String, userName: String, title: String = "Quên mật khẩu", onDone: ((_ isSuccess: Bool) -> Void)? = nil) {
        self.goId = goId
        self.phoneNumber = phoneNumber
        self.userName = userName
        self.title = title
        self.onDoneCallback = onDone
//        userProfile = AuthManager.shared.currentUser()
//        goPlaySession = AuthManager.shared.currentSesion()
    }
    var spaceOriented: CGFloat {
        // Dynamically set space based on the device orientation
        return DeviceOrientation.shared.isLandscape ? 1 : 10
    }

    var paddingVertialOriented: CGFloat {
        // Dynamically set space based on the device orientation
        return DeviceOrientation.shared.isLandscape ? 1 : 0
    }
    public var body: some View {
        ResponsiveView(
            portraitView: bodyViewPortraid(),
            landscapeView: bodyViewLandScape()
        )
        .observeOrientation()  // Apply the modifier to detect orientation changes
        //        .navigateToDestination(navigationManager: navigationManager)  // Using the extension method
        
        //        .navigationBarHidden(true) // hide navigaotr bar at top
        .compatNavigationTitle(title)
        //                .navigationBarBackButtonHidden(false) // Show back button (default)

        .navigationBarBackButtonHidden(true)
        .compatToolbar {
            GoPlayDismissButton()
        }
    }
    func bodyViewPortraid() -> some View {

        VStack(alignment: .center, spacing: spaceOriented) {
            Text(
                "Vui lòng sử dụng SĐT \(self.phoneNumber) để lấy mã OTP khôi phục mật khẩu bằng cách:"
            )
            .foregroundColor(.black)
            .padding(.horizontal, 10)

            Text("Soạn tin nhắn ")
                .foregroundColor(.black)
            smsSyntaxView
            //            Spacer()
            //                .frame(height: paddingVertialOriented)
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

            //            Spacer()
            //                .frame(height: paddingVertialOriented)
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
            //            Spacer()
            //                .frame(height: paddingVertialOriented)
            Text("Nhập mã OTP")
                .foregroundColor(.black)
            OTPInputView(otp: $otp)
            
            
            GoButton(color: .black,  action: resetPassword){
                Text("Xác nhận")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }

            Spacer()
        }
        .padding()
        

    }

    
    func bodyViewLandScape() -> some View {

        ScrollView {
            VStack(spacing: spaceOriented) {
                Spacer()//.listRowSeparator(.hidden)
                    .listRowInsets(
                        EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                    )
                    .listRowBackground(Color.clear)
                Text(
                    "Vui lòng sử dụng SĐT \(phoneNumber ?? "") để lấy mã OTP khôi phục mật khẩu bằng cách:"
                )
                .foregroundColor(.black)
                .padding(.horizontal, 10)
                .frame(maxWidth: .infinity, alignment: .center)
                //.listRowSeparator(.hidden)
                .listRowInsets(
                    EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                )
                .listRowBackground(Color.clear)
                
                
                smsSyntaxViewLandScape
                    .frame(maxWidth: .infinity, alignment: .center)
                //.listRowSeparator(.hidden)
                    .listRowInsets(
                        EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                    )
                    .listRowBackground(Color.clear)
                HStack(spacing: 12) {
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
                    
                }.frame(maxWidth: .infinity, alignment: .center)
                //.listRowSeparator(.hidden)
                    .listRowInsets(
                        EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                    )
                    .listRowBackground(Color.clear)
                
                
                Text("Nhập mã OTP")
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .center)
                //.listRowSeparator(.hidden)
                    .listRowInsets(
                        EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                    )
                    .listRowBackground(Color.clear)
                OTPInputView(otp: $otp)
                    .frame(maxWidth: .infinity, alignment: .center)
                //.listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                GoButton(color: .black,  action: resetPassword){
                    Text("Xác nhận")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                //.listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                //                .listRowInsets(
                //                            EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                //                        )
                .listRowBackground(Color.clear)
                
            }
        }
//        .listStyle(.plain)

//        .scrollContentBackground(.hidden)   // 🔥 bỏ bg List (iOS 16+)
        .background(Color.clear)
//        .onAppear {
//            UITableView.appearance().separatorStyle = .none
//        }
//        .onDisappear {
//            UITableView.appearance().separatorStyle = .singleLine // reset
//        }

    }

    var smsSyntaxView: some View {
        var otpCmd = "GO OTP \(String(self.goId ?? 0))"
        return VStack(alignment: .center, spacing: spaceOriented) {

            Text(otpCmd)
                .foregroundColor(.blue)
                + Text(" gửi ")
                .foregroundColor(.black)
                + Text("8100 ")
                .foregroundColor(.blue)
            
            
            HStack(spacing: 8) {
                Text("(1500 đồng/sms)")
                    .foregroundColor(.black)

                Image(systemName: "paperplane.fill")
            }
            .foregroundColor(.blue)
            .onTapGesture {
                Utils.sendSMS(
                    phone: "8100",
                    body: otpCmd
                )
            }

        }

    }
    
    var smsSyntaxViewLandScape: some View {
        var otpCmd = "GO OTP \(String(self.goId ?? 0))"
        return VStack(alignment: .center) {
            HStack(spacing: 8) {
                Text("Soạn tin nhắn ")
                    .foregroundColor(.black)
                    + Text("GO OTP \(String(goId)) ")
                    .foregroundColor(.blue)
                    + Text("gửi ")
                    .foregroundColor(.black)
                    + Text("8100 ")
                    .foregroundColor(.blue)
                    + Text("(1500 đồng/sms)")
                    .foregroundColor(.black)

                Image(systemName: "paperplane.fill")
            }
            .foregroundColor(.blue)
            .onTapGesture {
                Utils.sendSMS(
                    phone: "8100",
                    body: otpCmd
                )
            }
        }

    }

    public func resetPassword() {
        
        guard !otp.isEmpty, !passWord.isEmpty, !rePassWord.isEmpty else {
            
            AlertDialog.instance.show(message: "Vui lòng đầy đủ thông tin")
            return
        }
        guard passWord == rePassWord else {
            
            AlertDialog.instance.show(message: "2 mật khẩu không khớp")
            return
        }
        let validation = passwordValidator.validate(text: passWord)
        if validation.isValid == false {
            AlertDialog.instance.show(message: validation.errorMessage)
            return
        }
        let rePwdValidation = rePasswordValidator.validate(text: rePassWord)
        if rePwdValidation.isValid == false {
            AlertDialog.instance.show(message: rePwdValidation.errorMessage)
            return
        }
        LoadingDialog.instance.show()
        let signData: [String: Any] = [
            "userId": goId,
            "userName": userName,
            "passwordmd5":  Utils.generateHashMD5(input: passWord) ?? "",
            "otp": otp
        ]
        
//        print("signData: \(signData)")

        // Now, you can call the `post` method on ApiService
        Task {
            await ApiService.shared.post(path: GoApi.oauthResetPwdOtp, bodyJwtSign: signData, payloadType: GoPayloadType.clientInfo) {
                result in

                LoadingDialog.instance.hide()

                switch result {
                case .success(let data):
                    // Handle successful response
                    
                    
                    do{
                        
                        let apiResponse = try JSONDecoder().decode(
                            GoPlayApiResponse<Int>.self,
                            from: data
                        )
                        
                        print("apiResponse isSuccessed: \(apiResponse.isSuccess()) \(apiResponse.code) \(apiResponse.message)")
                        if(apiResponse.isSuccess()){
                           
                            if let pwdData = passWord.data(using: .utf8) {
                                let result = AccountManager.updateAccount(
                                    userId: goId,
                                    credential: passWord,
                                    lastLogin: Date(),
                                    setAsCurrent: false
                                )
                                
                                AlertDialog.instance.show(message: apiResponse.message ?? "Đặt lại mật khẩu thành công")
                                if(self.onDoneCallback != nil){
                                    //back to previouse view
                                    presentationMode.wrappedValue.dismiss()
                                    self.onDoneCallback?(true)
                                }
//
                            
                                
                            }
                        }else{
                            AlertDialog.instance.show(message: apiResponse.message ?? "Lỗi. Vui lòng thử lại sau")
                        }
                        
                        
                        
                        
                    } catch {
                        DispatchQueue.main.async {
                            AlertDialog.instance.show(message: "Lỗi kiểm tra tài khoản. Vui lòng thử lại")
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

}
