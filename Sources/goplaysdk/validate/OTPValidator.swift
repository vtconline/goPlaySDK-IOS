//
//  passwordValidator.swift
//  goplaysdk
//
//  Created on 24/4/25.
//

class OTPValidator: TextFieldValidator {
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
            errorMessage = "OTP phải dài từ \(minLength) đến \(maxLength) ký tự."
            return (isValid, errorMessage)
        }
        return (isValid,errorMessage)
    }
}
