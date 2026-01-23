//
//  usernameValidator.swift
//  goplaysdk
//
//  Created by pate on 24/4/25.
//
import Foundation
//@MainActor
class UsernameValidator: TextFieldValidator {
    let minLength: Int
    let disallowedCharacters: CharacterSet
    let mustNotStartWithNumber: Bool
    
    init(minLength: Int = 4,
         disallowedCharacters: CharacterSet = CharacterSet(charactersIn: "@!#%^&*(),- "),
         mustNotStartWithNumber: Bool = true) {
        self.minLength = minLength
        self.disallowedCharacters = disallowedCharacters
        self.mustNotStartWithNumber = mustNotStartWithNumber
    }
    
    
    
    override func validate(text: String) -> (isValid: Bool, errorMessage: String) {
        
        var isValid1 = true
        var errorMessage1 = ""
        if text.count < minLength {
            isValid1 = false
            errorMessage1 = "Tên đăng nhập phải có ít nhất \(minLength) ký tự."
            
        }else if text.rangeOfCharacter(from: disallowedCharacters) != nil {
            isValid1 = false
            errorMessage1 = "Tên đăng nhập không chứa \(disallowedCharactersDescription(disallowedCharacters: disallowedCharacters))"
            
            
        }else if mustNotStartWithNumber, let first = text.first, first.isNumber {
            isValid1 = false
            errorMessage1 = "Tên đăng nhập không bắt đầu với chữ số"
            
        }
        self.isValid = isValid1
        self.errorMessage = errorMessage1
        return (isValid1, errorMessage1)
    }
    
//    private func disallowedCharactersDescription() -> String {
//        var result = [String]()
//        
//        // Iterate over all Unicode scalars from 0 to 0x10FFFF (entire Unicode range)
//        for scalarValue in 0...0x10FFFF {
//            let scalar = UnicodeScalar(scalarValue)
//            if let scalar = scalar, disallowedCharacters.contains(scalar) {
//                result.append(scalar.description)
//            }
//        }
//        
//        return result.joined(separator: ", ")
//    }
    
    
}
func disallowedCharactersDescription(disallowedCharacters: CharacterSet) -> String {
    var result = [String]()
    
    // Iterate over all Unicode scalars from 0 to 0x10FFFF (entire Unicode range)
    for scalarValue in 0...0x10FFFF {
        let scalar = UnicodeScalar(scalarValue)
        if let scalar = scalar, disallowedCharacters.contains(scalar) {
            result.append(scalar.description)
        }
    }
    
    return result.joined(separator: ", ")
}
