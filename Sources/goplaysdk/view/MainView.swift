//
//  MainView.swift
//  goplaysdk
//
//  Created by Ngô Đồng on 24/4/25.
//

import SwiftUI

public struct MainView: View {
    public init() {}

    public var body: some View {
        // Kiểm tra nếu là iOS 16 trở lên, dùng NavigationStack
        if #available(iOS 16.0, *) {
            NavigationStack {
                SelectLoginType()
            }
        } else {
            // Nếu iOS < 16, dùng NavigationView
            NavigationView {
                SelectLoginType()
            }
        }
    }
}


