//
//  Authen.swift
//  goplaysdk
//
//  Created by Ngô Đồng on 17/4/25.
//
// Sources/LoginSDK/LoginView.swift

import SwiftUI

public struct SelectLoginType: View {
    @State private var responseMessage: String = ""
    public init() {}

    public var body: some View {
        VStack(spacing: 20) {
            HeaderView()
            Spacer()
            GoNavigationLink(
                text: "ĐĂNG NHẬP SĐT",
                destination: PhoneLoginView(),
                systemImageName: "phone.fill",

                imageSize: CGSize(width: 16, height: 16),
                font: .system(size: 16, weight: .semibold),
                textColor: .white,
                backgroundColor: AppTheme.Colors.primary
            )
            GoNavigationLink(
                text: "ĐĂNG NHẬP GOID New",
                destination:GoIdAuthenViewV2(enalbeSocialLogin: false),
                assetImageName: "logo_goplay",

                imageSize: CGSize(width: 24, height: 24),
                font: .system(size: 16, weight: .semibold),
                textColor: .white,
                backgroundColor: AppTheme.Colors.primary
            )
            
            GoNavigationLink(
                text: "ĐĂNG NHẬP GOID",
                destination: GoIdAuthenView(enalbeSocialLogin: false),
                assetImageName: "logo_goplay",

                imageSize: CGSize(width: 24, height: 24),
                font: .system(size: 16, weight: .semibold),
                textColor: .white,
                backgroundColor: AppTheme.Colors.primary
            )

            Spacer()

            Text(responseMessage)
                .padding()
                .background(Color.white)
        }
        .padding(.vertical, 0)
        .background(Color.white)
        .foregroundColor(.white)
        //            .ignoresSafeArea()

    }
}

func loginTest() {
    //        let requestBody: [String: Any] = [
    //                            "username": "john_doe",
    //                            "password": "password123"
    //                        ]
    //
    //                        ApiService.shared.request(method: "POST", path: "/login", body: requestBody) { result in
    //                            switch result {
    //                            case .success(let data):
    //                                // Convert response data to string for display
    //                                if let responseString = String(data: data, encoding: .utf8) {
    //                                    DispatchQueue.main.async {
    //                                        responseMessage = "POST Response: \(responseString)"
    //                                    }
    //                                }
    //                            case .failure(let error):
    //                                DispatchQueue.main.async {
    //                                    responseMessage = "Error: \(error.localizedDescription)"
    //                                }
    //                            }
    //                        }
    //    }
}
