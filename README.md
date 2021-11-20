# MyLimeSignManager

### Distribution method
 The framework is distributed as a static library (libMyLimeSignManager.a).
### Installation
  
- Copy the file to an application location.
- Add the library reference within the Frameworks, Libraries and Embedded Content section of the application target.
- 
### Content
 
 The library's public interface consists of two methods plus a constructor:
 
```swift
 public init?(baseURL: URL, token: String?, client: String?, uid: String?, id: Int?)
 public func initKeychain(completion: @escaping (MyLimeSignError?) -> Void)
 public func sign(data: Data) throws -> MlSignature
 ```
### Usage
 
 To initialize the library, the baseURL and the user data retrieved from the login (client, uid and token) must be provided:
 ```swift
 let signManager = MyLimeSignManager(baseURL: #baseurl#,  token:  #aValidToken#, client:  #aValidClient#, uid: #aValidUID#)
 ```
 
 Once instantiated, you will need to invoke the keychain initialization method. The purpose of this method is to obtain and persist, if not already present, the private key used later to sign the calls. The method accepts a completion closure that can be used to know the result of the operation:
 
  ```swift
 self?.signManager?.initKeychain { error in
     if let error = error {
         // C'è stato un errore durante l'inizializzazione del keychain
     }
 }
  ```
  
 To sign calls you will need to invoke the sign method. The purpose of this method is to generate an MlSignature object sent later by the app in the headers of the networks calls you want to sign. The method takes a single parameter, called data, which represents the http body of the request that you want to sign:
 
  ```swift
 let body = "request body".data(using: .utf8)!
 
 var request = URLRequest(url: #avalidurl#)
 let signature = try manager?.sign(data: body)

 request.addValue(signature.timestamp, forHTTPHeaderField: "X-Timestamp")
 request.addValue(signature.nonce, forHTTPHeaderField: "X-nonce")
 request.addValue(signature.body, forHTTPHeaderField: "X-signature")
   ```
