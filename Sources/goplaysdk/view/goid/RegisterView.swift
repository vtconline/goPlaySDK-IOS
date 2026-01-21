import SwiftUI

public struct RegisterView: View {
    //    @Environment(\.presentationMode) var presentationMode
  
    @Environment(\.hostingController) private var hostingController
    @StateObjectCompat private var navigationManager = NavigationManager()

    @State private var userName = ""
    @State private var passWord = ""
    @State private var rePassWord = ""
    
    @State private var showUIUpdatePhone = false
    
    
    @State private var usernameLock = false

    @StateObjectCompat private var userNameValidator = UsernameValidator()
    @StateObjectCompat private var passwordValidator = PasswordValidator()
    @StateObjectCompat private var rePassWordValidator = PasswordValidator()
    /*@StateObjectCompat private var emailValidator = EmailValidator()*/



    public init(user: String = "") { 
        _userName = State(initialValue: user)
       _usernameLock =  State(initialValue: !user.isEmpty)
    }

    var spaceOriented: CGFloat {
        // Dynamically set space based on the device orientation
        return DeviceOrientation.shared.isLandscape ? 10 : 10
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
            GoTextField<UsernameValidator>(
                text: $userName, placeholder: "Nhập tài khoản", isPwd: false,
                validator: userNameValidator, leftIconName: "ic_user_focused",
                isSystemIcon: false, isDisabled: $usernameLock
            )
            .keyboardType(.default)
            .padding(.horizontal, 16)

            //Mật khẩu gồm ít nhất 1 chữ thường, 1 số, 1 viết hoa
//            Ít nhất 8 ký tự
            GoTextField<PasswordValidator>(
                text: $passWord, placeholder: "Nhập mật khẩu", isPwd: true,
                validator: passwordValidator, leftIconName: "ic_lock_focused",
                isSystemIcon: false
            )
            .keyboardType(.default)
            .padding(.horizontal, 16)

            GoTextField<PasswordValidator>(
                text: $rePassWord, placeholder: "Nhập lại mật khẩu", isPwd: true,
                validator: rePassWordValidator, leftIconName: "ic_lock_focused",
                isSystemIcon: false
            )
            .padding(.horizontal, 16)
            
            Text("Mật khẩu bao gồm:\n- Mật khẩu gồm ít nhất 1 chữ thường, 1 số, 1 viết hoa\n- Ít nhất 8 ký tự")
//                .fontWeight(.semibold)
                .font(.system(size: 14))
                .foregroundColor(.black)
                .padding(.vertical, 10)
                .frame(maxWidth: 300, alignment: .leading)
           

            GoButton(color: .black, action: {
                 submitRegister()
                
            }){
                Text("Đăng ký")
                .font(.system(size: 16))
                .foregroundColor(.white)
            }

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

    private func submitRegister()  {
        guard !userName.isEmpty, !passWord.isEmpty, !rePassWord.isEmpty else {
            AlertDialog.instance.show(message: "Vui lòng nhập tài khoản và mật khẩu")
            return
        }
        guard passWord == rePassWord else {
            AlertDialog.instance.show(message: "2 mật khẩu không khớp")
            return
        }
        let userValidation = userNameValidator.validate(text: userName)
        let pwdValidation = passwordValidator.validate(text: passWord)
        let rePwdValidation = rePassWordValidator.validate(text: passWord)

        if userValidation.isValid == false || pwdValidation.isValid == false || rePwdValidation.isValid == false {
            var str: String = ""
            if !userValidation.errorMessage.isEmpty {
                str = userValidation.errorMessage
            }else if !pwdValidation.errorMessage.isEmpty {
                str = pwdValidation.errorMessage
            }else if !rePwdValidation.errorMessage.isEmpty {
                str = rePwdValidation.errorMessage
            }
            AlertDialog.instance.show(message:str)
            return
        }
        LoadingDialog.instance.show()

        // This would be a sample data payload to send in the POST request
        var bodyData: [String: Any] = [
            "username": userName,
            "password": passWord,
//            "mobile":"09xxx"
        ]
        
        Task{
            await ApiService.shared.post(path: GoApi.oauthRegister, bodyJwtSign: bodyData) { result in
               
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

        // Now, you can call the `post` method on ApiService
    
        
    }

    func onRegisterResponse(response: [String: Any]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: response, options: [])
            let apiResponse = try JSONDecoder().decode(
                GoPlayApiResponse<TokenData>.self, from: jsonData)

            var message = "Lỗi đăng ký"

            if apiResponse.isSuccess() {

                if(apiResponse.isMustActive()){
                    showUIUpdatePhone = true
                }else{
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
