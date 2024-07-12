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
    
    func hitApiwithoutloader(parm:[String:Any],url:String, completion: @escaping(JSON,Error?) -> ()){
      
        if !Reachability.isConnectedToNetwork(){
            return
        }
        
        var headers:HTTPHeaders? = nil
        headers = ["Authorization": "Bearer \(UserDefaults.standard.getUsernameToken())"]
        
        guard let url = URL(string: url) else{return}
        
        Alamofire.request(url,method: .put, parameters: parm,encoding: JSONEncoding(),headers: headers).validate(statusCode: 200..<500).responseJSON {response in
                 
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
        view.debugPrint("\(url)")
        var headers:HTTPHeaders? = nil
        if isHeader {
            headers = ["Authorization": "Bearer \(UserDefaults.standard.getUsernameToken())"]
        }

        Alamofire.request(url, method: method, parameters: parm,encoding: JSONEncoding(), headers:headers).responseJSON { response in
            av.removeFromSuperview()
            switch response.result{
            case .success(let value):
                av.removeFromSuperview()
                do {
                    let jsonData = try JSON(data: response.data!)
                    completion(jsonData, nil)
                }catch{}
            case .failure(let err):
                print(err)
                av.removeFromSuperview()
                do {
                    try completion(JSON(data: NSData() as Data), err)
                }catch{
                    av.removeFromSuperview()
                    completion(JSON.null,err)
                }
            }
        }
        
    }
    
    func getApi(view:UIViewController,url:String, isHeader:Bool, isLoader:Bool = true, completion: @escaping(JSON,Error?) -> ()) {
        
        var av = UIView()
        if isLoader {
            av = Loader.start(view: view.view)
        }
        
        if !Reachability.isConnectedToNetwork(){
            av.removeFromSuperview()
            view.displayAlert(title: "Alert!", msg: "No internet connection.", ok: "Ok")
            
            return
        }
        
        guard let url = URL(string: url) else{return}
        view.debugPrint("\(url)")
        var header = [String: String]()
        if isHeader {
            header = ["Authorization": "Bearer \(UserDefaults.standard.getUsernameToken())"]
        }

        Alamofire.request(url, method: .get,encoding: URLEncoding.queryString, headers: header).responseJSON { response in
            av.removeFromSuperview()
            view.debugPrint("\(response)")
            switch response.result{
            case .success(let value):
                do {
                    let jsonData = try JSON(data: response.data!)
                    completion(jsonData, nil)
                }catch{}
            case .failure(let err):
                print(err)
                av.removeFromSuperview()
                do {
                    try completion(JSON(data: NSData() as Data), err)
                }catch{
                    completion(JSON.null,err)
                }
            }
        }
    }

}
