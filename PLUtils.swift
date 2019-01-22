/*
 * Copyright (C) 2019 Pungle Canada Inc - All Rights Reserved
 */

import UIKit

class PLUtils {
    
    func yearIsValid(_ year: String) -> Bool {
        
        guard let cardYear = Int(year) else { return false }
        
        let currentYr = Date().getYear()
        if cardYear < currentYr { return false }
        
        return true
    }
    
    func addressIsValid(_ address: String) -> Bool {
        
        return address.validate(regex: "^[a-zA-Z0-9 ,.'\\-]{1,35}$")
        //return address.validate(regex: "/^[a-zA-Z0-9 ,.'\\-]{1,35}$/")
        // return "/^[a-zA-Z0-9 ,.'\\-]{1,35}$/".regexValid(stringToValidate: address)
    }
    
    func cityIsValid(_ city: String) -> Bool {
        return city.validate(regex: "^[a-zA-Z,.'\\- ]{1,25}$")
    }
    
    func countryIsValid(_ country: String) -> Bool {
        return country.validate(regex: "^[A-Z]{3}$")
    }
    
    func stateIsValid(_ state: String) -> Bool {
        return state.validate(regex: "^[A-Z]{2}$")
    }
    
    func postalCodeIsValid(_ postalCode: String) -> Bool {
        return postalCode.validate(regex: "^[a-zA-Z0-9]{5,9}$")
    }
    
    func cleanPostalCode(_ postalCode: String) -> String {
        let postal = NSMutableString()
        postal.append(postalCode)
        return postal.replace(pattern: "[\\s-]+", replaceStr: "") as String
    }
    
    func luhnCheckIsValid(number: String) -> Bool {
        var sum = 0
        let reversedCharacters = number.reversed().map { String($0) }
        for (idx, element) in reversedCharacters.enumerated() {
            guard let digit = Int(element) else { return false }
            switch ((idx % 2 == 1), digit) {
                case (true, 9): sum += 9
                case (true, 0...8): sum += (digit * 2) % 9
                default: sum += digit
            }
        }
        return sum % 10 == 0
    }
    
}
