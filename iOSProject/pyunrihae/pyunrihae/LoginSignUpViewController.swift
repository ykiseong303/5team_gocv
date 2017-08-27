//
//  LoginSignUpViewController.swift
//  pyunrihae
//
//  Created by woowabrothers on 2017. 8. 16..
//  Copyright © 2017년 busride. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase

class LoginSignUpViewController: UIViewController,GIDSignInUIDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
       
        NotificationCenter.default.addObserver(self, selector: #selector(closeSelf), name: NSNotification.Name("userLogined"), object: nil)
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onTouchCloseButton(_ sender: Any) {
        closeSelf()
    }
    func closeSelf() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTouchGoogleSignIn(_ sender: Any) {
         GIDSignIn.sharedInstance().signIn()
    }
 
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            print("\(error)")
            print("구글 계정 연결에 실패했습니다.")
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                print("\(error)")
                print("파이어베이스 계정 연동에 실패했습니다.")
                return
            }
            
            // 파이어베이스 연동 성공하면
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if Auth.auth().currentUser != nil {
                DataManager.getUserFromUID(uid: (Auth.auth().currentUser?.uid)!, completion: { (user) in
                    appDelegate.user = user
                    self.dismiss(animated: true, completion: {
                        NotificationCenter.default.post(name: NSNotification.Name("userLogined"), object: nil)
                    })
                })
            } else {
                appDelegate.user = User()
            }
        }
    }

    
}
