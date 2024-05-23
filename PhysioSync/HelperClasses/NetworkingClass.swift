//
//  PatientOnboardingVC.swift
//  PhysioSync
//
//  Created by Sanjeev Mehta on 22/05/24.
//
import Alamofire
import SwiftyJSON
import UIKit
import CoreLocation

class ApiHelper {

    static let shareInstance = ApiHelper()

    func hitApi(view:UIViewController,parm:[String:Any],url:String,isLoader: Bool = true ,completion: @escaping(JSON,Error?) -> ()){
        var av = UIView()
        if isLoader {
            av = Loader.start(view: view.view)
        }
        
        if !Reachability.isConnectedToNetwork(){
            av.removeFromSuperview()
            view.displayAlert(title: "Alert!", msg: "No internet connection.", ok: "Ok")
            
            return
        }
        
        
        var headers:HTTPHeaders? = nil
        
        guard let url = URL(string: url) else{return}
            print(url)
        
        Alamofire.request(url,method: .post, parameters: parm,encoding: URLEncoding.default,headers: headers).validate(statusCode: 200..<500).responseJSON {response in
                   av.removeFromSuperview()
                   switch response.result{
                   case .success(let value):
                       
                       do {
                           let jsonData = try JSON(data: response.data!)
                           completion(jsonData, nil)
                           
                       }catch{
                       }
                   case .failure(let err):
                       print(err)
                       
                       do {
                           try completion(JSON(data: NSData() as Data), err)
                       }catch{
                           completion(JSON.null,err)
                       }
                   }
               }
      }
    
    
    func hitApiwithoutloader(view:UIViewController,parm:[String:Any],url:String, completion: @escaping(JSON,Error?) -> ()){

      
        if !Reachability.isConnectedToNetwork(){
           
            view.displayAlert(title: "Alert!", msg: "No internet connection.", ok: "Ok")
            
            return
        }
        
        
        var headers:HTTPHeaders? = nil
        
        
        guard let url = URL(string: url) else{return}
            print(url)
        
        Alamofire.request(url,method: .post, parameters: parm,encoding: URLEncoding.default,headers: headers).validate(statusCode: 200..<500).responseJSON {response in
                 
                   switch response.result{
                   case .success(let value):
                       
                       do {
                           let jsonData = try JSON(data: response.data!)
                           completion(jsonData, nil)
                           
                       }catch{
                       }
                   case .failure(let err):
                       print(err)
                       
                       do {
                           try completion(JSON(data: NSData() as Data), err)
                       }catch{
                           completion(JSON.null,err)
                       }
                   }
               }
      }
    
    
    func hitApi(view:UIViewController,method:HTTPMethod,parm:[String:Any],url:String, isHeader:Bool,isLoader:Bool, completion: @escaping(JSON,Error?) -> ()) {
        
        var av = UIView()
        if isLoader{
            av = Loader.start(view: view.view)
        }
        
        if !Reachability.isConnectedToNetwork(){
            av.removeFromSuperview()
            view.displayAlert(title: "Alert!", msg: "No internet connection.", ok: "Ok")
            
            return
        }
        
        guard let url = URL(string: url) else{return}
        print(url)
        var headers:HTTPHeaders? = nil
        
        
        Alamofire.request(url, method: method, parameters: parm,encoding: JSONEncoding(), headers:headers).responseJSON { response in
            av.removeFromSuperview()
            switch response.result{
            case .success(let value):
                
                do {
                    let jsonData = try JSON(data: response.data!)
                    if jsonData["status"].intValue == 401{
                        view.displayAlert(title: "Session Expired", msg: "Please try to login again", ok: "Ok") {
                            //                            let vc =  view.switchController(identifier: "LoginVC") as! LoginVC
                            //                              view.present(vc, animated: true, completion: nil)
                        }
                        
                        
                    }else if(jsonData["status"].intValue == 200){
                        
                        completion(jsonData, nil)
                    }else {
                        view.displayAlert(title: "Alert", msg: jsonData["message"].stringValue, ok: "Ok")
                    }
                    
                    
                }catch{}
            case .failure(let err):
                print(err)
                
                do {
                    try completion(JSON(data: NSData() as Data), err)
                }catch{
                    completion(JSON.null,err)
                }
            }
        }
        
    }
    
    func getApi(view:UIViewController,url:String, isHeader:Bool, isLoader:Bool, completion: @escaping(JSON,Error?) -> ()) {
        
        var av = UIView()
        if isLoader{
            av = Loader.start(view: view.view)
        }
        
        if !Reachability.isConnectedToNetwork(){
            av.removeFromSuperview()
            view.displayAlert(title: "Alert!", msg: "No internet connection.", ok: "Ok")
            
            return
        }
        
        guard let url = URL(string: url) else{return}
        var header = [String: String]()
        
        Alamofire.request(url, method: .get,encoding: URLEncoding.queryString, headers: header).responseJSON { response in
            av.removeFromSuperview()
            switch response.result{
            case .success(let value):
                
                do {
                    let jsonData = try JSON(data: response.data!)
                    if jsonData["status"].intValue == 401{
                        view.displayAlert(title: "Session Expired", msg: "Please try to login again", ok: "Ok") {

                        }
                        
                        
                    }else if(jsonData["status"].intValue == 200){
                        
                        completion(jsonData, nil)
                    }else {
                        view.displayAlert(title: "Error", msg: jsonData["message"].stringValue, ok: "Ok")
                    }
                    
                    
                }catch{}
            case .failure(let err):
                print(err)
                
                do {
                    try completion(JSON(data: NSData() as Data), err)
                }catch{
                    completion(JSON.null,err)
                }
            }
        }
    }
    
    func hitApiVIN(method:HTTPMethod,parm:[String:Any],url:String, isHeader:Bool,isLoader:Bool, completion: @escaping(JSON,Error?) -> ()) {
        
       
        guard let url = URL(string: url) else{return}
        print(url)
        var headers:HTTPHeaders? = nil
        
        
        Alamofire.request(url, method: method, parameters: parm,encoding: JSONEncoding(), headers:headers).responseJSON { response in
           
            switch response.result{
            case .success(let value):
                
                do {
                    let jsonData = try JSON(data: response.data!)
                    if jsonData["status"].intValue == 401{
                       
                        
                        
                    }else if(jsonData["status"].intValue == 200){
                        
                        completion(jsonData, nil)
                    }else {
                        
                    }
                    
                    
                }catch{}
            case .failure(let err):
                print(err)
                
                do {
                    try completion(JSON(data: NSData() as Data), err)
                }catch{
                    completion(JSON.null,err)
                }
            }
        }
        
    }
    
    
    
    func hitApiWithMultipart(view:UIViewController,imgData: [Data?],parm:[String:Any],url:String, completion: @escaping(JSON,Error?) -> ()){
        
        let av = Loader.start(view: view.view)
        if !Reachability.isConnectedToNetwork(){
            av.removeFromSuperview()
            view.displayAlert(title: "Alert!", msg: "No internet connection.", ok: "Ok")
            
            return
        }
        
        
        var headers:HTTPHeaders? = nil
        
     
        
        guard let url = URL(string: url) else{return}
        print(url)
        
        Alamofire.upload(multipartFormData: { (multiPart) in
            
            
            for (index,data) in imgData.enumerated(){
                if data != nil{
                    switch index {
//                    case 0:
//
//                        multiPart.append(data!, withName: "front", fileName: "forntimage\(Int(Date().timeIntervalSince1970)).jpeg", mimeType: ".jpeg")
//                    case 1:
//                        multiPart.append(data!, withName: "left", fileName: "leftimage\(Int(Date().timeIntervalSince1970)).jpeg", mimeType: ".jpeg")
//                    case 2:
//                        multiPart.append(data!, withName: "back", fileName: "backimage\(Int(Date().timeIntervalSince1970)).jpeg", mimeType: ".jpeg")
//                    case 3:
//                        multiPart.append(data!, withName: "right", fileName: "rightimage\(Int(Date().timeIntervalSince1970)).jpeg", mimeType: ".jpeg")
                    case 0:
                        multiPart.append(data!, withName: "option1", fileName: "option1image\(Int(Date().timeIntervalSince1970)).jpeg", mimeType: ".jpeg")
                    case 1:
                        multiPart.append(data!, withName: "option2", fileName: "option2image\(Int(Date().timeIntervalSince1970)).jpeg", mimeType: ".jpeg")
                    case 2:
                        multiPart.append(data!, withName: "option3", fileName: "option3image\(Int(Date().timeIntervalSince1970)).jpeg", mimeType: ".jpeg")
                    case 3:
                        multiPart.append(data!, withName: "option4", fileName: "option4image\(Int(Date().timeIntervalSince1970)).jpeg", mimeType: ".jpeg")
                    case 4:
                        multiPart.append(data!, withName: "option5", fileName: "option5image\(Int(Date().timeIntervalSince1970)).jpeg", mimeType: ".jpeg")
                    case 5:
                        multiPart.append(data!, withName: "option6", fileName: "option6image\(Int(Date().timeIntervalSince1970)).jpeg", mimeType: ".jpeg")
                    case 6:
                        multiPart.append(data!, withName: "option7", fileName: "option7image\(Int(Date().timeIntervalSince1970)).jpeg", mimeType: ".jpeg")
                    case 7:
                        multiPart.append(data!, withName: "option8", fileName: "option8image\(Int(Date().timeIntervalSince1970)).jpeg", mimeType: ".jpeg")
                    case 8:
                        multiPart.append(data!, withName: "option9", fileName: "option9image\(Int(Date().timeIntervalSince1970)).jpeg", mimeType: ".jpeg")
                    case 9:
                        multiPart.append(data!, withName: "option10", fileName: "option10image\(Int(Date().timeIntervalSince1970)).jpeg", mimeType: ".jpeg")
                        
                    default:
                        print("index Out of range")
                    }
                }
            }
            for (key, value) in parm {
               
                      
                multiPart.append(("\(value)".data(using: .utf8))!, withName: key)
            }
        }, to: url,method:.post,
                         headers:headers) { (result) in
            
            switch result{
                
            case .success(let request , _, _):
                
                request.responseJSON { (responseJSON) in
                    print(responseJSON)
                    
                    
                    av.removeFromSuperview()
                    switch responseJSON.result{
                    case .success(let value):
                        
                        do {
                            let jsonData = try JSON(data: responseJSON.data!)
                            completion(jsonData, nil)
                            
                        }catch{
                        }
                    case .failure(let err):
                        print(err)
                        
                        do {
                            try completion(JSON(data: NSData() as Data), err)
                        }catch{
                            completion(JSON.null,err)
                        }
                    }
                    
                    
                }
                
            case .failure(let error):
                
                print(error.localizedDescription)
                completion(JSON.null,error)
            }
            
        }
    }
        
    
    func hitApiWithJsonEncoding(view:UIViewController,parm:[String:Any],url:String, completion: @escaping(JSON,Error?) -> ()){

        let av = Loader.start(view: view.view)
        if !Reachability.isConnectedToNetwork(){
            av.removeFromSuperview()
            view.displayAlert(title: "Alert!", msg: "No internet connection.", ok: "Ok")
            
            return
        }
        var headers:HTTPHeaders? = nil

        guard let url = URL(string: url) else{return}
            print(url)
        
        Alamofire.request(url,method: .put, parameters: parm,encoding: JSONEncoding(),headers: headers).validate(statusCode: 200..<500).responseJSON {response in
                   av.removeFromSuperview()
                   switch response.result{
                   case .success(let value):
                       
                       do {
                           let jsonData = try JSON(data: response.data!)
                           completion(jsonData, nil)
                           
                       }catch{
                       }
                   case .failure(let err):
                       print(err)
                       
                       do {
                           try completion(JSON(data: NSData() as Data), err)
                       }catch{
                           completion(JSON.null,err)
                       }
                   }
               }
      }

    func checkLocationServiceEnabled() -> Bool{
        let manager = CLLocationManager()

        if CLLocationManager.locationServicesEnabled() {
            switch manager.authorizationStatus{
                case .notDetermined, .restricted, .denied:
                    print("No access")
                return false
                case .authorizedAlways, .authorizedWhenInUse:
                    print("Access")
                 return true
             @unknown default:
                 print("not")
                 return false
             }
        } else {
            print("Location services are not enabled")
            return false
        }
    }

    func uploadImage(view: UIViewController, imageData: Data?, parameters: [String: Any], url: String, completion: @escaping (JSON?, Error?) -> Void) {
        let av = Loader.start(view: view.view)
        
        if !Reachability.isConnectedToNetwork() {
            av.removeFromSuperview()
            view.displayAlert(title: "Alert!", msg: "No internet connection.", ok: "Ok")
            return
        }
        
        guard let url = URL(string: url) else {
            completion(nil, NSError(domain: "com.yourapp", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                if let imageData = imageData {
                    multipartFormData.append(imageData, withName: "image", fileName: "image.jpeg", mimeType: "image/jpeg")
                }
                for (key, value) in parameters {
                    if let data = "\(value)".data(using: .utf8) {
                        multipartFormData.append(data, withName: key)
                    }
                }
            },
            to: url,
            method: .post
        ) { result in
            av.removeFromSuperview()
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    switch response.result {
                    case .success(let data):
                        let jsonData = JSON(data)
                        completion(jsonData, nil)
                    case .failure(let error):
                        completion(nil, error)
                    }
                }
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}
