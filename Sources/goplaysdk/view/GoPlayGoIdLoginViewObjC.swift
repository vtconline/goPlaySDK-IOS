import SwiftUI

public struct GoPlayGoIdLoginViewObjC: View {
    let enalbeSocialLogin: Bool

    public init(enalbeSocialLogin: Bool = true) {
        self.enalbeSocialLogin = enalbeSocialLogin
    }

    public var body: some View {
        // Kiểm tra nếu là iOS 16 trở lên, dùng NavigationStack
        VStack(spacing: 0) {
            HeaderView()
            if #available(iOS 16.0, *) {
                NavigationStack {
                    GoIdAuthenView(enalbeSocialLogin: enalbeSocialLogin)
                }
            } else {
                // Nếu iOS < 16, dùng NavigationView
                NavigationView {
                    GoIdAuthenView(enalbeSocialLogin: enalbeSocialLogin)
                }
            }
        }
    }
}
