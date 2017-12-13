//
//  LoginVC.swift
//  CampusTalk
//
//  Created by Erman Sahin Tatar on 11/19/17.
//  Copyright © 2017 Erman Sahin Tatar. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    // UI objects
    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // clicked login button.
    @IBAction func login_click(_ sender: Any) {
        
        if usernameTxt.text!.isEmpty || passwordTxt.text!.isEmpty {
            
            usernameTxt.attributedPlaceholder = NSAttributedString(string: "username", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            passwordTxt.attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            
        }else {
            
            // remove keyboard
            self.view.endEditing(true)
            
            // shortcuts
            let username = usernameTxt.text!.lowercased()
            let password = passwordTxt.text!
            
            // send request to mysql db
            // url to access our php file
            let url = URL(string: "http://localhost/CampusTalk/login.php")!
            
            // request url
            var request = URLRequest(url: url)
            
            // method to pass data POST - cause it is secured
            request.httpMethod = "POST"
            
            // body gonna be appended to url
            let body = "username=\(username)&password=\(password)"
            
            // append body to our request that gonna be sent
            request.httpBody = body.data(using: .utf8)
            
            // launch session
            URLSession.shared.dataTask(with: request) { data, response, error in
                
                // no error
                if error == nil {
                    
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                        
                        guard let parseJSON = json else {
                            print("Error while parsing")
                            return
                        }
                        
                        print(parseJSON)
                        
                        
                        let id = parseJSON["id"] as? String
                        
                        // successfully logged in
                        if id != nil {
                            
                            // save user information we received from our host
                            UserDefaults.standard.set(parseJSON, forKey: "parseJSON")
                            user = UserDefaults.standard.value(forKey: "parseJSON") as? NSDictionary
                            
                            // go to tabbar / home page
                            DispatchQueue.main.async(execute: {
                                appDelegate.login()
                            })
                            
                            // error
                        }else {
                            
                            // get main queue to communicate back to user
                            DispatchQueue.main.async(execute: {
                                let message = parseJSON["message"] as! String
                                appDelegate.infoView(message: message, color: colorSmoothRed)
                            })
                            return
                        }
                
                    } catch {
                        DispatchQueue.main.async(execute: {
                            let message = error as! String
                            appDelegate.infoView(message: message, color: colorSmoothRed)
                        })
                        
                        
                    }
                    
                } else {
                    
                    // get main queue to communicate back to user
                    DispatchQueue.main.async(execute: {
                        let message = error!.localizedDescription
                        appDelegate.infoView(message: message, color: colorSmoothRed)
                    })
                    
                    
                }
                
                }.resume()
            
        }
    }
    
    
    // white status bar
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    
    // touched screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // hide keyboard
        self.view.endEditing(false)
    }
    

}
