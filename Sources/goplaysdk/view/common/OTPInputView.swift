//
//  OTPInputView.swift
//  goplaysdk
//
//  Created by pate on 14/1/26.
//

import SwiftUI


public struct OTPInputView: View {
    @Binding var otp: String
    private let length = 6

    public var body: some View {
        ZStack {
            TextField("", text: $otp)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .foregroundColor(.clear)
                .accentColor(.clear)
                .onChange(of: otp) {
                    otp = String($0.prefix(length))
                }

            HStack(spacing: 12) {
                ForEach(0..<length, id: \.self) { index in
                    Text(character(at: index))
                        .frame(width: 44, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(otp.count == index ? .blue : .gray)
                        )
                }
            }
        }
    }

    private func character(at index: Int) -> String {
        guard index < otp.count else { return "" }
        return String(otp[otp.index(otp.startIndex, offsetBy: index)])
    }
}


struct OTPBox: View {
    let text: String
    let isActive: Bool

    var body: some View {
        Text(text)
            .font(.system(size: 22, weight: .bold))
            .frame(width: 44, height: 44)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isActive ? Color.blue : Color.gray, lineWidth: 1)
            )
    }
}

