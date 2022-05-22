//
//  ViewController.swift
//  UploadImage
//
//  Created by Eihab Ahmed on 20/05/2022.
//

import UIKit
import Alamofire
import MobileCoreServices

class ViewController: UIViewController {
    
    struct RequestBodyFormDataKeyValue {
        var sKey: String
        var sValue: String
        var dBlobData: Data
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func uploadImage(_ sender: Any) {
        
        var bodyKeyValue = [RequestBodyFormDataKeyValue]()
        
        bodyKeyValue.append(RequestBodyFormDataKeyValue(sKey: "a", sValue: "b", dBlobData: Data()))
        bodyKeyValue.append(RequestBodyFormDataKeyValue(sKey: "c", sValue: "d", dBlobData: Data()))
        bodyKeyValue.append(RequestBodyFormDataKeyValue(sKey: "e", sValue: "f", dBlobData: Data()))
        
        let oArrArray = "lukaa.jpg".components(separatedBy: ".")
        
        let mimeType = self.returnMimeType(fileExtension: oArrArray[1])

        let oImage = UIImage(named: "lukaa.jpg")
        
        let dData = oImage?.pngData() // Data format
        
        bodyKeyValue.append(RequestBodyFormDataKeyValue(sKey: "file", sValue: "lukaa.jpg", dBlobData: dData!))
        
        var sURL: String!
        
        sURL = "https://httpbin.org/post"
        
        let serializer = DataResponseSerializer(emptyResponseCodes: Set([200, 204, 205]))
        
        var sampleRequest = URLRequest(url: URL(string: sURL)!)
        sampleRequest.httpMethod = HTTPMethod.post.rawValue
        
        AF.upload(multipartFormData: { multipartFormData in
            for formData in bodyKeyValue {
                if (formData.dBlobData.isEmpty) {
                    multipartFormData.append(Data(formData.sValue.utf8), withName: formData.sKey)
                } else {
                    multipartFormData.append(formData.dBlobData, withName: formData.sKey, fileName: "lukaa.jpg", mimeType: mimeType)
                }
                
            }
        }, to: sURL, method: .post)
        .uploadProgress { progress in
            print(CGFloat(progress.fractionCompleted * 100))
        }
        .response { response in
            if (response.error == nil) {
                var responseString: String!
                responseString = ""
                
                if (response.data != nil) {
                    responseString = String(bytes: response.data!, encoding: .utf8)
                } else {
                    responseString = response.response?.description
                }
                
                //print(responseString ?? "")
                print(response.response!.statusCode)
                
                var responseData: NSData!
                
                responseData = response.data! as NSData
                
                let iDataLength = responseData.length
                
                print("Size: \(iDataLength) Bytes")
                
                print("Response Time \(response.metrics!.taskInterval.duration)")
            }
        }
        
    }
    
    func returnMimeType(fileExtension: String) -> String {
        if let oUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as NSString, nil)?.takeRetainedValue() {
            if let mimeType = UTTypeCreatePreferredIdentifierForTag(oUTI, kUTTagClassMIMEType, nil)?.takeRetainedValue() {
                return mimeType as String
            }
        }
        
        return ""
    }
    
}

