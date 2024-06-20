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

}
