/*
 * Copyright (C) 2019 Pungle Canada Inc - All Rights Reserved
 */

import UIKit

enum PLEnvironment {
    case staging
    case production
}

class Pungle {
    
    static let s = Pungle()
    var apiKey: String?
    static let pungleStagingUrlStr = "https://api.staging.pungle.co/api/v1/"
    static let pungleProdUrlStr = "https://api.pungle.io/api/v1/"
    static let pungleProdUrlv2Str = "https://api.pungle.io/api/v2/"
    var baseUrl = ""
    
    // A pungle error before an API call is a different number other than an HTTP code.
    static let pungleStatusErrorCode = 2010
    
    init(){}
    
    class func config(publicApiKey _apiKey: String, environment: PLEnvironment) {
        Pungle.s.apiKey = _apiKey
        if environment == .production{
            Pungle.s.baseUrl = Pungle.pungleProdUrlStr
            return
        }
        
        Pungle.s.baseUrl = Pungle.pungleStagingUrlStr
    }
    
    class func fetchCardToken(creditCard: PLCreditCard,
                              success: @escaping(Any?, Int?) -> Swift.Void,
                              fail: @escaping(Any?, NSError?, Int?) -> Swift.Void ){
        
        // VERIFY AND VALIDATE request parameters are in order.
        // Check API key was configured
        guard let _apiKey = Pungle.s.apiKey else {
            
            let plError = PLError(errorType: PLValidationError.noApiKey, errorMessage: "Missing Public API key")
            let errDict = Pungle.s.getErrorsDictionary(errors: [plError])
            
            fail(nil, Pungle.s.getError(errorDict: errDict), PLConstants.pungleStatusErrorCode);
            
            return
        }
        
        // VALIDATE CREDIT CARD. If the error array is not empty we have errors.
        let errors = creditCard.validate()
        if errors.count != 0 {
            let errDict = Pungle.s.getErrorsDictionary(errors: errors)
            fail(nil, Pungle.s.getError(errorDict: errDict), PLConstants.pungleStatusErrorCode);
            return
        }
        
        // GET BODY
        var body = Data()
        do {
            try body = JSONSerialization.data(withJSONObject: creditCard.getDictionary(), options: [])
        } catch {
            let error = PLError(errorType: .JSONSerialization, errorMessage: error.localizedDescription)
            let errDict = Pungle.s.getErrorsDictionary(errors: [error])
            fail(nil, Pungle.s.getError(errorDict: errDict), PLConstants.pungleStatusErrorCode);
            return
        }
        
        // REQUEST
        let urlRequest = Pungle.s.getURLRequest(apiKey: _apiKey, body: body)
        let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
        
        let cardTokenDataTask: URLSessionDataTask = defaultSession.dataTask(with: urlRequest,
                                                                            completionHandler: { (data, response, error) in
                                                                                
            // First try and get a status code from the response
            var status: Int? = nil
            
            if let httpResponse = response as? HTTPURLResponse {
                status = httpResponse.statusCode
            }
            
            // Parse data into JSON
            let json = Pungle.getParsedJson(data: data)
            
            // Catch general errors, this will not catch http errors like 400 and above
            // But it will catch other worse errors, like no connectivity, server not found, etc...
            if let requestError = error {
                fail(json, requestError as NSError, status)
                return
            }
            
            // Catch HTTP status errors
            if let statusCode = status {
                if statusCode > Int(299) {
                    PLLog.e("status error: \(String(describing: status))")
                    fail(json, nil, status)
                    return
                }
            }
            
            // Response susccess
            success(json, status)
                                                                                
        })
        cardTokenDataTask.resume()
        
    }
    
    class func getParsedJson(data: Data?) -> Any? {
        
        do {
            guard let data = data else {
                PLLog.e ("getParsedJson - no data")
                return nil
            }
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                PLLog.e ("getParsedJson - conversion from JSON failed")
                return nil
            }
            
            return json
            
        } catch let error as NSError {
            PLLog.e("getParsedJson - JSON parse error: \(error.debugDescription)")
        }
        
        return nil
        
    }
    
    private func getError(errorDict: [String: Any]) -> NSError{
        return NSError(domain: "pungle://",
                       code: PLConstants.pungleStatusErrorCode,
                       userInfo: errorDict)
    }
    
    private func getErrorsDictionary(errors: [PLError]) -> [ String: [PLError] ]{
        return  [PLConstants.errors: errors]
    }
    
    private func getURLRequest(apiKey: String, body: Data) -> URLRequest {
        let urlStr = "\(Pungle.s.baseUrl)tokens"
        var urlRequest = URLRequest(url: URL(string: urlStr)! )
        // Set public key for request.
        let keyBearer = "Bearer \(apiKey)"
        urlRequest.setValue(keyBearer, forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = body
        return urlRequest
        
    }
    
    func JSONDictToString(_ dictionary: [String: Any]) -> String? {
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: []) {
            
            if let jsonStr = String(data: jsonData, encoding: .ascii) {
                return jsonStr
            }
            
        } else {
            PLLog.e("JSONDictToString - Error converting dictionary to string")
        }
        
        return nil
    }
    
}

class PLLog {
    static let s = PLLog()
    var enabled = false
    
    init(){}
    
    class func e (_ str: String){
        if PLLog.s.enabled { print("Pungle Error - \(str)") }
    }
    
    class func v (_ str: String){
        if PLLog.s.enabled { print("Pungle - \(str)") }
    }

}
