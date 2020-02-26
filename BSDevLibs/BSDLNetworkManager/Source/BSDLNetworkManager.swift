//
//  ILNetworkManager.swift
//  Wyre
//
//  Created by Kedar Sukerkar on 21/10/19.
//  Copyright © 2019 Bhavesh Sarwar. All rights reserved.
//

import Alamofire

public class BSDLNetworkManager: NSObject {

    /// Singleton
    public static let shared = BSDLNetworkManager()
    private override init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 4 // seconds
//        configuration.timeoutIntervalForResource = 4
        
        self.alamoFireManager = Alamofire.SessionManager(configuration: configuration)
    }
    
    
    
    /// Response model closure
    public typealias responseModel = (_ response: Any? , _ error:Error?) -> Void
    public typealias downloadProgress = (_ progres: Double) -> Void
    public typealias validateDownload = (_ validate: Request.ValidationResult) -> Void
    public typealias downloadResponse = (_ response: NSDictionary?) -> Void
    /// URL
    public var serverURL = ""
    public let alamoFireManager:SessionManager?
    
//    let alamofireSessionManager

    
    
    /// Sending normal request
    
    public func sendRequest(baseUrl:String = BSDLNetworkManager.shared.serverURL,
                     methodType:HTTPMethod,
                     apiName:String,
                     parameters:NSDictionary?,
                     headers:NSDictionary?,
                     encoding:ParameterEncoding = JSONEncoding.default  ,
                     completionHandler:@escaping responseModel){
        
        
        // Check network rechability
        if NetworkReachabilityManager()?.isReachable == true{
            
            let urlString = baseUrl + apiName
            
            // Sending alamofire request
            
//            alamoFireManager.req
            
            alamoFireManager!.request(urlString,
                              method: methodType,
                              parameters: parameters as? [String:String],
                              encoding: encoding,
                              headers: headers as? [String:String]  ).responseJSON
            { (response:DataResponse<Any>) in
                
                completionHandler(response.result.value, response.error)
            
            }

        }else{
            print("Internet connection not available")
        }
    }
    
    
    
    public func sendImagesRequest(baseUrl:String = BSDLNetworkManager.shared.serverURL,
                           methodType:HTTPMethod,
                           apiName:String,
                           parameters:NSDictionary?,
                           headers:NSDictionary?,
                           images:[UIImage]?,
                           completionHandler:@escaping responseModel){
        
        
        
        // Check network rechability
        if NetworkReachabilityManager()?.isReachable == true{
            // Create multipart image
            var multipartImagesData = [Data]()
        
            if let imagesArray = images{
                DispatchQueue.main.async {
                    multipartImagesData =  imagesArray.compactMap{$0.jpegData(compressionQuality: 0.3)}
                }
                
            }
            
            DispatchQueue.main.async {
                Alamofire.upload(multipartFormData: { (multipartFormData) in
                    // Convert parameters in to the Strings
                    if parameters != nil{
                        for (key, value) in parameters! {
                            multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as! String)
                        }
                    }
                    // Convert images in to the multipart data
                    multipartImagesData.forEach({ (imageData) in
                        multipartFormData.append(imageData, withName: "media" ,
                                                 fileName: "image.jpeg",
                                                 mimeType:(imageData.mimeType))
                    })
                }, to: baseUrl+apiName,
                   method: methodType,
                   headers : headers as? [String:String]
                ) { (result) in
                    switch result{
                    case .success(let upload, _, _):
                        upload.responseJSON { response in
                            print("Succesfully uploaded")
                            if let err = response.error{
                                print(err)
                                completionHandler(response.result.value, response.error)
                            }
                            completionHandler(response.result.value, response.error)
                        }
                    case .failure(let error):
                        print("Error in upload: \(error.localizedDescription)")
                    }
                }
                
            }
        }else{
            print("Internet connection not available")
        }
        
    }
    
    func sendRawDataRequest(methodType:HTTPMethod , apiName:String , parameters: [String: Any]?, headers: [String: String]?, encoding:ParameterEncoding = JSONEncoding.prettyPrinted, baseUrl: String, completionHandler:@escaping responseModel){
        
        
        if NetworkReachabilityManager()?.isReachable ?? false{
        
            
            var request = URLRequest(url: URL(string: baseUrl + apiName)!)
            request.httpMethod = methodType.rawValue
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters ?? [:])
            request.allHTTPHeaderFields = headers
            
            
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 10
            configuration.timeoutIntervalForResource = 60
            

            self.alamoFireManager?.request(URL(string: baseUrl + apiName)!, method: methodType, parameters: parameters, encoding: JSONEncoding(), headers: headers).responseJSON(completionHandler: { (response) in
                completionHandler(response.result.value, response.error)
                
            })
        
        }else{
            print("Internet connection not available")
            
        }
        
            
            
        
    }
    
    
    
    public func downloadRequest(baseUrl:String,
                                 methodType:HTTPMethod,
                                 params:Dictionary<String,Any>?,
                                 headers:[String:String]?,
                                 destinationUrl:String,
                                 progressHandler:@escaping downloadProgress,
                                 validation:@escaping validateDownload,
                                 response:@escaping downloadResponse){
        
        //        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
        //            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        //            documentsURL.appendPathComponent("file.csv")
        //            return (documentsURL, [.removePreviousFile])
        //        }
        let url = baseUrl
        
        //        let fileURL: URL
        let _: DownloadRequest.DownloadFileDestination = { _, _ in
            return (URL(string: destinationUrl)!, [.createIntermediateDirectories, .removePreviousFile])
        }
        //        let parameters: Parameters = ["foo": "bar"]
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = methodType.rawValue
        request.timeoutInterval = 0 // Default timout for all api is 60 Sec
        alamoFireManager?.download(request).downloadProgress(closure: { (progress) in
            progressHandler(progress.fractionCompleted)
        }).responseJSON(completionHandler: { (response) in
            debugPrint(response)
            print(response.temporaryURL as Any)
            print(response.destinationURL as Any)
        })
//        alamoFireManager!.download(url,
//                                   method:methodType,
//                                   parameters: params,
//                                   encoding: JSONEncoding.default,
//                                   to: destination)
//            .downloadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
////                print("Progress: \(progress.fractionCompleted)")
//                progressHandler(progress.fractionCompleted)
//            }
//            .validate { request, response, temporaryURL, destinationURL in
//                // Custom evaluation closure now includes file URLs (allows you to parse out error messages if necessary)
//                return .success
//            }
//            .responseJSON { response in
//                debugPrint(response)
//                print(response.temporaryURL)
//                print(response.destinationURL)
//        }
    }
    
    
    


}


extension Data {
    private static let mimeTypeSignatures: [UInt8 : String] = [
        0xFF : "image/jpeg",
        0x89 : "image/png",
        0x47 : "image/gif",
        0x49 : "image/tiff",
        0x4D : "image/tiff",
        0x25 : "application/pdf",
        0xD0 : "application/vnd",
        0x46 : "text/plain",
        ]
    
    var mimeType: String {
        var c: UInt8 = 0
        copyBytes(to: &c, count: 1)
        return Data.mimeTypeSignatures[c] ?? "application/octet-stream"
    }
}
