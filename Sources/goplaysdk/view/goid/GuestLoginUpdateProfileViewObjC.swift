import SwiftUI

public struct GuestLoginUpdateProfileViewObjC: View {

    public var body: some View {
        VStack(spacing: 0) {
//            HeaderView()
            if #available(iOS 16.0, *) {
                NavigationStack {
                    GuestLoginUpdateProfileView()
                }
            } else {
                // Nếu iOS < 16, dùng NavigationView
                NavigationView {
                    GuestLoginUpdateProfileView()
                }
            }
        }

        

    }

   
}
