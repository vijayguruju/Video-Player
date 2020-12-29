//
//  Utility.swift
//  Player Task
//
//  Created by Vijay Guruju on 21/12/20.
//  Copyright © 2020 V2Apps. All rights reserved.
//

import Foundation
import SystemConfiguration
import UIKit

private var UtilityInstance:Utility? = nil

class Utility: NSObject {
    
    static var shared :Utility{
        if UtilityInstance == nil{
            UtilityInstance = Utility()
        }
        return UtilityInstance!
    }


    func isInternetAvailable() -> Bool
    {
        let reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, "https://google.com")
        
        var flags : SCNetworkReachabilityFlags = SCNetworkReachabilityFlags()
        
        if SCNetworkReachabilityGetFlags(reachability!, &flags) == false {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    
    }
    func showActivityIndicator(view: UIView, target: UIView) {

        var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        activityIndicator.backgroundColor = .clear
        activityIndicator.color = .lightGray
        activityIndicator.layer.cornerRadius = 6
        activityIndicator.center = target.center
        activityIndicator.style = .large
        activityIndicator.tag = 1
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    func hideActivityIndicator(view: UIView) {
        let activityIndicator = view.viewWithTag(1) as? UIActivityIndicatorView
        activityIndicator?.stopAnimating()
        activityIndicator?.removeFromSuperview()
    }
    
    func showAlert(message:String,targetVC:UIViewController){
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .cancel, handler:  {(action: UIAlertAction) in

        })
        alert.addAction(okButton)
        targetVC.present(alert, animated: true, completion: nil)
    }
}


struct API {
    static let baseUrl = "https://interview-e18de.firebaseio.com/media.json?print=pretty"
}
