/*
 * Copyright (C) 2019 Pungle Canada Inc - All Rights Reserved
 */

import Foundation

extension String {
    
    func charactersAreValid(min: Int, max: Int) -> Bool {
    
        let numberOfDigits = self.count
        
        if numberOfDigits >= min && numberOfDigits <= max {
            return true
        }
        
        return false
    }
    
    func isValidEmail(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        var valid = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
        if valid {
            valid = !email.contains("Invalid email id")
        }
        return valid
    }
    
    func regexValid (stringToValidate: String) -> Bool {
        let regex = self
        let regexTest = NSPredicate(format:"SELF MATCHES %@", regex)
        return regexTest.evaluate(with: stringToValidate)
    }
    
    func validate(regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
}

extension NSMutableString {
    
    func replace(pattern: String, replaceStr: String) -> NSMutableString {
        let value = self
        let regex = try? NSRegularExpression(pattern: pattern)
        regex?.replaceMatches(in: value, options: .reportProgress,
                              range: NSRange(location: 0, length: self.length),
                              withTemplate: replaceStr)
        return value
    }
}

