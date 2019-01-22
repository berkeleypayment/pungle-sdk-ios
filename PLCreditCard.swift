/*
 * Copyright (C) 2019 Pungle Canada Inc - All Rights Reserved
 */

import UIKit

enum PLValidationError {
    case name
    case cardNumber
    case cvvNumber
    case expiryYear
    case expiryMonth
    case state
    case postalCode
    case country
    case city
    case addressLine1
    case addressLine2
    case noApiKey
    case JSONSerialization
}

struct PLConstants {
    static let errors = "errorMessage"
    static let errorMessage = "errorMessage"
    static let errorType = "errorType"
    
    /** This identifies an error as a pungle validation error made before an API call,
     as opposed to an HTTP status error. */
    static let pungleStatusErrorCode = 2010
}

struct PLError {
    let errorType: PLValidationError
    let errorMessage: String
}

struct PLCreditCard {
    
    // Cardholder Name
    let name: String
    
    // Payment Card Number
    let number: String
    
    let brand: String
    
    // Billing Address lines
    let addressLine1: String
    let addressLine2: String
    
    // Billing Address postal code
    var addressPostalCode: String = ""

    // Billing Address Country
    let addressCountry: String
    
    // Billing Address City
    let addressCity: String
    
    // Billing Address State/Province/Region
    let addressState: String
    
    // Expiry Month - 2 digits
    let expiryMonth: String
    
    // Expiry Year - 4 digits
    let expiryYear: String
    
    // CVV Value - 3 or 4 digits
    let cvv: String

    init(name: String, number: String,
         brand: String, addressLine1: String,
         addressLine2: String, addressPostalCode: String,
         addressCountry: String, addressCity: String,
         addressState: String, expiryMonth: String,
         expiryYear: String, cvv: String) {

        self.name = name
        self.number = number
        self.brand = brand
        self.addressLine1 = addressLine1
        self.addressLine2 = addressLine2
        self.addressCountry = addressCountry
        self.addressCity = addressCity
        self.addressState = addressState
        self.expiryMonth = expiryMonth
        self.expiryYear = expiryYear
        self.cvv = cvv
        self.addressPostalCode = PLUtils().cleanPostalCode(addressPostalCode)

    }

    func getDictionary() -> [String: [String: Any]]{
        return [
            "card": [
                "name": self.name,
                "number": self.number,
                "brand": self.brand,
                "address_line1": self.addressLine1,
                "address_line2": self.addressLine2,
                "address_postal_code": self.addressPostalCode,
                "address_country": self.addressCountry,
                "address_city": self.addressCity,
                "address_state": self.addressState,
                "expiry_month": self.expiryMonth,
                "expiry_year": self.expiryYear,
                "cvv": self.cvv,
            ]
        ]
    }
    
    func validate() -> [PLError] {
        
        var errors: [PLError] = []
        
        if !PLUtils().yearIsValid(self.expiryYear) {
            errors.append( PLError(errorType: .expiryYear, errorMessage: "Expiry year incorrect. Either the year is in the past or not a number.") )
        }
        
        if !PLUtils().addressIsValid(self.addressLine1) {
            errors.append( PLError(errorType: .addressLine1,
                                   errorMessage: "Address line 1 has invalid symbols or it's too long.") )
        }
        
        if !PLUtils().addressIsValid(self.addressLine1) {
            errors.append( PLError(errorType: .addressLine2,
                                   errorMessage: "Address line 2 has invalid symbols or it's too long.") )
        }
        
        if !PLUtils().cityIsValid(self.addressCity) {
            errors.append( PLError(errorType: .city,
                                   errorMessage: "City has invalid symbols or it's too long.") )
        }
        
        if !PLUtils().countryIsValid(self.addressCountry) {
            errors.append( PLError(errorType: .country,
                                   errorMessage: "Country is too long or it has invalid symbols.") )
        }
        
        if !PLUtils().stateIsValid(self.addressState){
            errors.append( PLError(errorType: .state,
                                   errorMessage: "State is too long or it has invalid symbols.") )
        }
        
        if !PLUtils().postalCodeIsValid(self.addressPostalCode){
            errors.append( PLError(errorType: .postalCode,
                                   errorMessage: "Postal Code is missing characters ot it's too long.") )
        }
        
        // Expiry Year - 4 digits
        if !self.expiryYear.charactersAreValid(min: 4, max: 4) {
            errors.append( PLError(errorType: .expiryYear, errorMessage: "Expiry year must be 4 digits long") )
        }

        // Expiry Month - 2 digits
        if !self.expiryMonth.charactersAreValid(min: 2, max: 2) {
            errors.append( PLError(errorType: .expiryMonth, errorMessage: "Expiry month must be 2 digits long") )
        }
        
        // CVV Value - 3 or 4 digits
        if !self.cvv.charactersAreValid(min: 3, max: 4) {
            errors.append( PLError(errorType: .cvvNumber, errorMessage: "CVV code must be 3 to 4 digits long") )
        }
        
        // Card number
        if !PLUtils().luhnCheckIsValid(number: self.number) {
            errors.append( PLError(errorType: .cardNumber, errorMessage: "Credit Card number is invalid") )
        }

        return errors
        
    }
    

}
