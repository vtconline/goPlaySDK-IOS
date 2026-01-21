import SwiftUI

public struct GoIdAuthenViewV2: View {
    @Environment(\.hostingController) private var hostingController

    @StateObjectCompat private var navigationManager = NavigationManager()
    
    @State private var step = AuthenStep.inputUser

    @State private var username = ""  // Store the username
    @State private var password = ""  // Store the password
    
    @State private var phoneNumber = ""
    @State private var goIdNumber = 0
    @State private var usernameLock = false

    @State private var usernameFocus = false
    @State private var passwordFocus = false

    @State private var rememberMe = true  // 🔐 Toggle for remembering credentials
    @State private var isShowingSafari = false

    @StateObjectCompat private var usernameValidator = UsernameValidator()
    @StateObjectCompat private var pwdValidator = PasswordSimpleValidator()
    
    @State private var showUIUpdatePhone = false
    
    @State private var alertMessage = ""  // Alert message

    let enalbeSocialLogin: Bool

    public init(enalbeSocialLogin: Bool = true) {
        self.enalbeSocialLogin = enalbeSocialLogin
    }

    var spaceOriented: CGFloat {
        // Dynamically set space based on the device orientation
        return DeviceOrientation.shared.isLandscape ? 4 : 6
    }

    public var body: some View {
            VStack(alignment: .center, spacing: spaceOriented) {
                NavigationLink(
                                destination: PhoneActiveView(),
                                isActive: $showUIUpdatePhone,
                                label: {
                                    EmptyView()
                                }
                            )
                
                Text("Tên đăng nhập")
                    .fontWeight(.semibold)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .padding(.vertical, 10)
                    .frame(maxWidth: 300, alignment: .leading)
                GoTextField<UsernameValidator>(
                    text: $username,
                    placeholder: "Nhập tên đăng nhập",
                    isPwd: false,
                    validator: usernameValidator,
                    //                leftIconName: "ic_user_focused",  // This should be the name of your image in Resources/Images
                    isSystemIcon: false, isDisabled: $usernameLock,
                )
                .keyboardType(.asciiCapable)
                
                if(step == AuthenStep.inputUser) {
                    GoButton(color: .black,  action: submitCheckUser){
                        Text("Tiếp tục")
                            .fontWeight(.semibold)
                        //                        .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                    .padding(.top, spaceOriented)
                }
                
                if(step == AuthenStep.loginWithPwd) {
                    Text("Mật khẩu")
                        .fontWeight(.semibold)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .padding(.vertical, 10)
                        .frame(maxWidth: 300, alignment: .leading)
                    
                    GoTextField<PasswordSimpleValidator>(
                        text: $password,
                        placeholder: "Nhập mật khẩu",
                        isPwd: true,
                        validator: pwdValidator,
                        isSystemIcon: false,
                    )
                    .keyboardType(.default)
                    
                    HStack(spacing: 0) {
                        RememberMeView(rememberMe: $rememberMe)
                        Spacer()
                        // ResetPwf Button using NavigationLink
                        if #available(iOS 15.0, *), phoneNumber.isEmpty == false {
                            NavigationLink(destination: ResetPwdView(goId: self.goIdNumber, phoneNumber: self.phoneNumber)) {
                                Text("Quên mật khẩu?")
                                    .foregroundColor(.blue)
                                //                                .padding(.horizontal, 10)
                            }
                        } else {
                            GoButton(
                                color: .white, padding: EdgeInsets(), useDefaultWidth: false,
                                action: {
//                                    isShowingSafari = true
                                    AlertDialog.instance.show(message: "Tài khoản \(username) chưa kích hoạt số điện thoại. Vui lòng nhập tài khoản khác!\n* Trường hợp số điện thoại xác thực không sử dụng được hoặc tài khoản chưa xác thực số điện thoại vui lòng liên hệ vui lòng liên hệ tổng đài 1900 636 876 từ 8:00 - 22:00 (1000 đồng/ phút) hoặc nhắn tin CSKH để được tư vấn.")
                                }
                            ) {
                                Text("Quên mật khẩu?")
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 10)
                            }
//                            .sheet(isPresented: $isShowingSafari) {
//                                SafariView(url: URL(string: GoConstants.urlForgotPassword)!)
//                            }
                        }
                    }
                    .frame(
                        maxWidth: min(
                            UIScreen.main.bounds.width - 2
                            * AppTheme.Paddings.horizontal,
                            300
                        ),
                        alignment: .center
                    )
                    .padding(.top, spaceOriented)  // Space between login and buttons in row
                    .padding(.bottom, spaceOriented)
                    
                    
                    
                    //login btn
                    
                    GoButton(color: .black,  action: submitLoginGoId){
                        Text("Đăng nhập")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    
                    GoButton(color: .white, action: {
                        usernameLock = false
                        step = AuthenStep.inputUser
                    }){
                        Text("Đổi tài khoản")
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
                    }
                    
                }
                
                
                if(step == AuthenStep.askCreateAccountOrBack){
                    askCreateAccountOrBackView()
                }
                

                if enalbeSocialLogin {
                    SocialLoginGroupView(haveGoIdLogin: false)
                }
                
            }
            .padding()
            .onAppear {
                let saveRememberMe = UserDefaults.standard.bool(
                    forKey: GoConstants.rememberMe
                )
                rememberMe = saveRememberMe
                if saveRememberMe {
                    if let savedUsername = UserDefaults.standard.string(
                        forKey: GoConstants.savedUserName
                    ) {
                        username = savedUsername
                    }
                    if let pwdData = KeychainHelper.load(
                        key: GoConstants.savedPassword
                    ),
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
//            .navigateToDestination(navigationManager: navigationManager)  // Using the extension method
            .compatNavigationTitle("Đăng nhập/Tạo tài khoản")
            //        .hidecompatNavigationTitleWhenLandscape()
            //.navigationBarBackButtonHidden(false) // Show back button (default)
            
            .navigationBarBackButtonHidden(true)
            .compatToolbar {
                GoPlayDismissButton()
            }
            .dismissKeyboardOnInteraction()
        
    }


    private func submitLoginGoId() {
        let validation = usernameValidator.validate(text: username)
        let validationPwd = pwdValidator.validate(text: password)
        if validation.isValid == false || validationPwd.isValid == false {
            var str: String = ""
            if !validation.errorMessage.isEmpty {
                str = validation.errorMessage
            }else if !validationPwd.errorMessage.isEmpty {
                str = validationPwd.errorMessage
            }
            AlertDialog.instance.show(message:str)
            return
        }
        if rememberMe {
            UserDefaults.standard.set(
                username,
                forKey: GoConstants.savedUserName
            )
            if let pwdData = password.data(using: .utf8) {
                KeychainHelper.save(
                    key: GoConstants.savedPassword,
                    data: pwdData
                )
            }
        } else {
            KeychainHelper.remove(key: GoConstants.savedPassword)
        }

        LoadingDialog.instance.show()

        // This would be a sample data payload to send in the POST request
        let md5: String = Utils.generateHashMD5(input: password) ?? ""
        let bodyData: [String: Any] = [
            "username": username,
            "passwordmd5": md5,

        ]

        // Now, you can call the `post` method on ApiService
        Task {
            await ApiService.shared.post(path: GoApi.oauthLogin, bodyJwtSign: bodyData)
            { result in

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
//                        print("submitLoginGoId Response: \(responseDict)")
                        
                        onLoginResponse(response: responseDict)
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

    func onLoginResponse(response: [String: Any]) {
        do {
            let jsonData = try JSONSerialization.data(
                withJSONObject: response,
                options: []
            )
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
                        let isMustActive =  apiResponse.isMustActive() // || GoPlaySDK.instance.isSandBox
                        AuthManager.shared.handleLoginSuccess(session, !isMustActive)
                        if(isMustActive){
                            //active xong sẽ noti envet login done sau
                            showUIUpdatePhone = true
                        }else{
                            //close current view popup
                            hostingController?.close()
                        }
                        
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
    
    func askCreateAccountOrBackView() -> some View {
        VStack(spacing: spaceOriented){
            HStack(spacing: 10) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 16))
                            .foregroundColor(.red)
                Text("Tài khoản \(self.username) chưa được đăng ký tài khoản goPlay. Vui lòng chọn Tạo tài khoản để tiếp tục sử dụng.")
                    .foregroundColor(.red)
                    .padding(.horizontal, 10)
            }
            GoNavigationLink(
                text: "Tạo tài khoản",
                destination: RegisterView(user: username),
//                systemImageName: "phone.fill",

//                imageSize: CGSize(width: 16, height: 16),
                font: .system(size: 16, weight: .semibold),
                textColor: .white,
                backgroundColor: .black
            )

            GoButton(color: .white, action: {
                usernameLock = false
                step = AuthenStep.inputUser
            }){
                Text("Quay lại")
                    .font(.system(size: 16))
                    .foregroundColor(.black)
            }
        }
        
        // HStack for buttons in a row, centered horizontally

    }
    
    private func submitCheckUser() {
        guard !username.isEmpty else {
            alertMessage = "Vui lòng nhập tài khoản"
            AlertDialog.instance.show(message: alertMessage)
            return
        }
        let validation = usernameValidator.validate(text: username)
        if validation.isValid == false {
            return
        }
        LoadingDialog.instance.show()

        let bodyData: [String: Any] = [
            "otpname": username,
            "loginType": LoginType.auto.rawValue,
        ]

        // Now, you can call the `post` method on ApiService
        Task {
            await ApiService.shared.post(path: GoApi.oauthCheckAuthenOtp, bodyJwtSign: bodyData) {
                result in

                LoadingDialog.instance.hide()

                switch result {
                case .success(let data):
                    // Handle successful response
                    
                    usernameLock = true
                    do{
                        let apiResponse = try JSONDecoder().decode(CheckAuthenOtp.self, from: data)
                        
//                        print("apiResponse isSuccessed: \(apiResponse.isSuccessed) \(apiResponse.userCount)")
                        if(apiResponse.isSuccessed == false || apiResponse.userCount == 0){
                            step = AuthenStep.askCreateAccountOrBack
                            phoneNumber = ""
                            goIdNumber = 0
                        }else{
//                            print("apiResponse phone: \(apiResponse.data[0].mobile)")
                            step = AuthenStep.loginWithPwd
                            phoneNumber = apiResponse.data[0].mobile ?? ""
                            goIdNumber = apiResponse.data[0].accountID ?? 0
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

struct RememberMeView: View {
    @Binding var rememberMe: Bool

    var body: some View {
        Button {
            rememberMe.toggle()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: rememberMe
                      ? "checkmark.square.fill"
                      : "square")
                    .font(.system(size: 16))
                    .foregroundColor(rememberMe ? .blue : .gray)

                Text("Lưu đăng nhập")
            }
        }
        .buttonStyle(.plain)
    }
}

public class AuthenStep {
    public static let inputUser: Int = 0
    public static let askCreateAccountOrBack: Int = 1
    public static let loginWithPwd: Int = 2
    public static let register: Int = 3
}
