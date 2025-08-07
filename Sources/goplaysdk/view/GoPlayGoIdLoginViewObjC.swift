


import SwiftUI

public struct GoPlayGoIdLoginViewObjC: View {
    public init() {}

    public var body: some View {
        // Kiểm tra nếu là iOS 16 trở lên, dùng NavigationStack
        VStack(spacing: 0) {
            HeaderView()
            if #available(iOS 16.0, *) {
                NavigationStack {
                    GoIdAuthenView()
                }
            } else {
                // Nếu iOS < 16, dùng NavigationView
                NavigationView {
                    GoIdAuthenView()
                }
            }
        }
    }
}


