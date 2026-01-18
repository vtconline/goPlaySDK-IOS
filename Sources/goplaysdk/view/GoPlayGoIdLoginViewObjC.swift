


import SwiftUI

public struct GoPlayGoIdLoginViewObjC: View {
    let haveSocialLogin: Bool
    public init(haveSocialLogin: Bool = true) {
        self.haveSocialLogin = haveSocialLogin
    }

    public var body: some View {
        // Kiểm tra nếu là iOS 16 trở lên, dùng NavigationStack
        VStack(spacing: 0) {
//            HeaderView()
            if #available(iOS 16.0, *) {
                NavigationStack {
                    GoIdAuthenViewV2(enalbeSocialLogin: haveSocialLogin)
                }
            } else {
                // Nếu iOS < 16, dùng NavigationView
                NavigationView {
                    GoIdAuthenViewV2(enalbeSocialLogin: haveSocialLogin)
                }
            }
        }
    }
}


