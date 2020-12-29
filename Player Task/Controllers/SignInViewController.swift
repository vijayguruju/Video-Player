//
//  ViewController.swift
//  Player Task
//
//  Created by Vijay Guruju on 17/12/20.
//  Copyright © 2020 V2Apps. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn


class SignInViewController: UIViewController,GIDSignInDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
        GIDSignIn.sharedInstance().delegate = self

        
        let signInButton = GIDSignInButton(frame: CGRect(x: 20, y: 20, width: UIScreen.main.bounds.width - 40, height: 50))
        signInButton.center.y = view.center.y
        signInButton.colorScheme = .dark
        signInButton.addTarget(self, action: #selector(signButtonClicked), for: .touchUpInside)
        view.addSubview(signInButton)
    }
    
    @objc func signButtonClicked(){
        
    }

    //MARK:- Google Sign in Delegates
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
      // ...
      if let error = error {
        // ...
        print(error.localizedDescription)
        Utility.shared.showAlert(message: "Could not Sign In", targetVC: self)
        return
      }
      else{
        Utility.shared.showActivityIndicator(view: self.view, target: self.view)
        //print(user.profile.email)
      guard let authentication = user.authentication else { return }
      let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                        accessToken: authentication.accessToken)
      Auth.auth().signIn(with: credential) { (authResult, error) in
          if error == nil {
            DispatchQueue.main.async {
                Utility.shared.hideActivityIndicator(view: self.view)
            }
            let videosVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "VideosViewController")
            self.navigationController?.show(videosVC, sender: self)
              
          }
      }
    }
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
}

