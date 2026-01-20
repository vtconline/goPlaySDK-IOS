//
//  OTPNoteView.swift
//  goplaysdk
//
//  Created by pate on 20/1/26.
//


import SwiftUI

struct OTPNoteView: View {
    var body: some View {
        if #available(iOS 15.0, *) {
            Text(makeAttributedText())
                .font(.system(size: 14))
                .multilineTextAlignment(.leading)
        } else {
            EmptyView()
        }
    }

    @available(iOS 15.0, *)
    private func makeAttributedText() -> AttributedString {
        var text = AttributedString(
            """
            Một số điện thoại có thể xác thực tối đa 5 tài khoản.
            Sử dụng sim Viettel, Vina, Mobiphone.
            Nếu không nhận tin nhắn OTP, vui lòng liên hệ tổng đài 1900 636 876 từ 8:00 - 22:00 (1000 đồng/ phút) hoặc nhắn tin CSKH để được tư vấn.
            """
        )

        // 🔹 Bold "5 tài khoản"
        if let range = text.range(of: "5 tài khoản") {
            text[range].font = .boldSystemFont(ofSize: 14)
        }

        // 🔹 Bold "1900 636 876"
        if let range = text.range(of: "1900 636 876") {
            text[range].font = .boldSystemFont(ofSize: 14)
        }

        // 🔹 CSKH màu xanh + mở Facebook
        if let range = text.range(of: "CSKH") {
            text[range].foregroundColor = .blue
            text[range].underlineStyle = .single
            text[range].link = URL(string: "https://www.facebook.com/goPlayPortal")!
        }

        return text
    }
}
