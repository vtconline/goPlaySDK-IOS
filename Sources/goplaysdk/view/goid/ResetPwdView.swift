import SwiftUI

public struct ResetPwdView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.hostingController) private var hostingController
    @StateObject private var navigationManager = NavigationManager()

    @State private var otp = ""
    @State private var passWord = ""
    @State private var rePassWord = ""

    @StateObject private var passwordValidator = PasswordValidator()
    @StateObject private var rePasswordValidator = PasswordValidator()

    let goPlaySession: GoPlaySession?
    let userProfile: UserProfile?
    public init() {
        userProfile = AuthManager.shared.currentUser()
        goPlaySession = AuthManager.shared.currentSesion()
    }
    var spaceOriented: CGFloat {
        // Dynamically set space based on the device orientation
        return DeviceOrientation.shared.isLandscape ? 10 : 1
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
        //        .resetNavigationWhenInActive(navigationManager: navigationManager, scenePhase: scenePhase)
        //        .navigationBarHidden(true) // hide navigaotr bar at top
        .navigationTitle("Quên mật khẩu")
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
    }
    func bodyViewPortraid() -> some View {

        VStack(alignment: .center, spacing: spaceOriented) {
            Text(
                "Vui lòng sử dụng SĐT \(userProfile?.phone ?? "") để lấy mã OTP khôi phục mật khẩu bằng cách:"
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
            //            Spacer()
            //                .frame(height: paddingVertialOriented)
            OTPInputView(otp: $otp)
            //            Spacer()
            //                .frame(height: paddingVertialOriented)
            GoButton(text: "XÁC NHẬN", action: resetPassword)

            Spacer()
        }
        .padding()
        

    }

    func bodyViewLandScape() -> some View {

        List {
            Spacer().listRowSeparator(.hidden)
                .listRowInsets(
                            EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                        )
                .listRowBackground(Color.clear)
            Text(
                "Vui lòng sử dụng SĐT \(userProfile?.phone ?? "") để lấy mã OTP khôi phục mật khẩu bằng cách:"
            )
            .foregroundColor(.black)
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity, alignment: .center)
            .listRowSeparator(.hidden)
            .listRowInsets(
                        EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                    )
                   .listRowBackground(Color.clear)

            
            smsSyntaxViewLandScape
                .frame(maxWidth: .infinity, alignment: .center)
                .listRowSeparator(.hidden)
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
                .listRowSeparator(.hidden)
                .listRowInsets(
                            EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                        )
                       .listRowBackground(Color.clear)
            
            
            Text("Nhập mã OTP")
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .center)
                .listRowSeparator(.hidden)
                .listRowInsets(
                            EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                        )
                       .listRowBackground(Color.clear)
            OTPInputView(otp: $otp)
                .frame(maxWidth: .infinity, alignment: .center)
                .listRowSeparator(.hidden)
                       .listRowBackground(Color.clear)
            GoButton(text: "XÁC NHẬN", action: resetPassword)
                .frame(maxWidth: .infinity, alignment: .center)
                .listRowSeparator(.hidden)
                .listRowInsets(
                            EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                        )
                       .listRowBackground(Color.clear)
            
        }
        .listStyle(.plain)
//        .scrollContentBackground(.hidden)   // 🔥 bỏ bg List (iOS 16+)
        .background(Color.clear)

    }

    var smsSyntaxView: some View {
        return VStack(alignment: .center, spacing: spaceOriented) {

            Text("GO OTP \(String(goPlaySession?.userId ?? 0)) ")
                .foregroundColor(.blue)
                + Text("gửi ")
                .foregroundColor(.black)
                + Text("8100 ")
                .foregroundColor(.blue)

            Text("(1500 đồng/sms)")
                .foregroundColor(.black)
            //               .frame(maxWidth: .infinity, alignment: .center)
        }

    }
    
    var smsSyntaxViewLandScape: some View {
        return VStack(alignment: .center) {
            Text("Soạn tin nhắn ")
                .foregroundColor(.black)
                + Text("GO OTP \(String(goPlaySession?.userId ?? 0)) ")
                .foregroundColor(.blue)
                + Text("gửi ")
                .foregroundColor(.black)
                + Text("8100 ")
                .foregroundColor(.blue)
                + Text("(1500 đồng/sms)")
                .foregroundColor(.black)
                
            //               .frame(maxWidth: .infinity, alignment: .center)
        }

    }

    public func resetPassword() {
        print("OTP =", otp)
    }

}
