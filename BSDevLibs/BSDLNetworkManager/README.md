# Network Manager

Network manager is wrapper based on the Alamofire

## Installation

```bash
pod 'BSDevLibs/BSDLNetworkManager'
```

## Usage

```swift
import BSDevLibs

// 
// 1. Global server URL
// 2. Server URL Seperate in each API 
// 3. Image Upload
//

// Global server URL 
BSDLNetworkManager.shared.serverURL = "https://abc.xyz.com:2020/api"


BSDLNetworkManager.shared.sendRequest(methodType: .post,
                                    apiName: "Login",
                                    parameters: parameters, headers: nil) { (response, error) in

  // Handle Response & Error								
  if response != nil && error == nil{
    print("Response received")
  }else{
    print("Error Occured")
  }
}

// Seperate Server URL 
BSDLNetworkManager.shared.sendRequest(baseUrl: "https://abc.xyz.com:2020/api"
                                    methodType: .post,
                                    apiName: "Login",
                                    parameters: parameters, headers: nil) { (response, error) in
  // Handle Response & Error								
  if response != nil && error == nil{
    print("Response received")
  }else{
    print("Error Occured")
  }
}

// Upload images
BSDLNetworkManager.shared.sendRequest(methodType: .post,
                                    apiName: "Login",
                                    images: images, // Images array that you want to upload
                                    parameters: parameters, headers: nil) { (response, error) in
  // Handle Response & Error								
  if response != nil && error == nil{
    print("Response received")
  }else{
    print("Error Occured")
  }
}


```
## License
[MIT](https://choosealicense.com/licenses/mit/)
