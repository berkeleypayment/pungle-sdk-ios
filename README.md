v 0.5.3

## Installation
Unzip the `PungleSDK.zip` file and drop the folder on your Xcode project. If you want to copy the files over to the project or keep them linked to a directory is your choice.

## Initializing the SDK
Make sure to add your public API key first. You only need to do this once so you could do this in your AppDelegate.


```swift
Pungle.config(publicApiKey: "YOUR_API_KEY", environment: .staging)

```

The `environment` parameter can be either `.staging` or `.production`.

Some logs can be enabled for debugging:

```swift
PLLog.s.enabled = true
```
Logs are disabled by default. We're not logging requests or responses. The response object is returned in the closure, so if needed it can be logged.


## Card Tokenization

First you must create a card object.

```swift
let card = PLCreditCard(name: "John Smith",
                number: "4895070000003551",
                brand: "visa",
                addressLine1: "900 Metro Center Blv",
                addressLine2: "",
                addressPostalCode: "94404",
                addressCountry: "CAN",
                addressCity: "Toronto",
                addressState: "ON",
                expiryMonth: "11",
                expiryYear: "2022",
                cvv: "034")
```

Next you need to call `fetchCardToken` to retrieve the token. This not only calls Pungle's API to get the token, it will also do some light validation on the card information before calling the service.

```swift
// Fetch the card Token
Pungle.fetchCardToken(creditCard: card, success: { (response, err, status) in
    
    print("Success: \(String(describing: response))")
	
}) { (response, err, status) in
	
    print("Error \(String(describing: err))")
	
}
```

If you get a succesful result, you can get the credit card token like this:
	
```swift

if let jsonResponse = response as? [String: [String:Any]] {
    if let token = jsonResponse["data"]?["token"] as? String{
        print("Token: \(token)")
    }
}
```

For errors caught by local validation you'll get an array of `PLError` objects. You can access them like this `err.userInfo[PLConstants.errors]`.

`PLError` has two props: `errorType` and `errorMessage`. `errorType` is an ENUM, and errorMessage is a String that you can choose to use or not (you might want to create your own to present to the user).

`errorType` uses the ENUM described below. Each one of the ENUM cases will tell you where did the check failed:


```swift
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
```

If you get a local error, the `NSError` object will return a `2010` code. So you can handle those separately from HTTP and connectivity errors if you like.

```
if let error = err {
    let errArr = error.userInfo[PLConstants.errors]
    print("Error Array: \(errArr ?? "Error Arr doesn't exist")")
}
```

Errors on responses are optionals, so they won't always be there. But you can check the status when it's an HTTP error, and you'll get some JSON in the response.
