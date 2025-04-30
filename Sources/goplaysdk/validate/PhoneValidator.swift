//
//  passwordValidator.swift
//  goplaysdk
//
//  Created by Ngô Đồng on 24/4/25.
//

class PhoneValidator: TextFieldValidator {
    let minLength: Int
    let maxLength: Int
    init(minLength: Int = 6, maxLength: Int = 20) {
            self.minLength = minLength
            self.maxLength = maxLength
        }

    

    override func validate(text: String) -> (isValid: Bool, errorMessage: String)  {
        isValid = true
        errorMessage = ""
        guard text.count >= minLength && text.count <= maxLength else {
            isValid = false
            errorMessage = "Số điện thoại phải dài từ \(minLength) đến \(maxLength) ký tự."
            return (isValid, errorMessage)
        }
        guard text.hasPrefix("0") || text.hasPrefix("84") || text.hasPrefix("+84") else {
            isValid = false
            errorMessage = "Số điện thoại phải bắt đầu bằng 0, 84 hoặc +84."
            return (isValid, errorMessage)
        }
        return (isValid,errorMessage)
    }
}
