//
//  ResetVC.swift
//  CampusTalk
//
//  Created by Erman Sahin Tatar on 11/20/17.
//  Copyright © 2017 Erman Sahin Tatar. All rights reserved.
//

import UIKit

class ResetVC: UIViewController{

    @IBOutlet var emailTxt: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    //reset button clicked
    @IBAction func reset_click(_ sender: Any) {
        
        if emailTxt.text!.isEmpty {
            
            emailTxt.attributedPlaceholder = NSAttributedString(string: "email", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
        }else {
            
            // remove keyboard
            self.view.endEditing(true)
            
            // shortcut ref to text in email TextField
            let email = emailTxt.text!.lowercased()
            
            // send mysql / php / hosting request
            
            // url path to php file
            let url = URL(string: "http://localhost/CampusTalk/resetPassword.php")!
            
            // request to send to this file
            var request = URLRequest(url: url)
            
            // method of passing inf to this file
            request.httpMethod = "POST"
            
            // body to be appended to url. It passes inf to this file
            let body = "email=\(email)"
            request.httpBody = body.data(using: .utf8)
            
            // proces reqeust
            URLSession.shared.dataTask(with: request) { data, response, error in
                
                if error == nil {
                    
                    // give main queue to UI to communicate back
                    DispatchQueue.main.async(execute: {
                        
                        do {
                            let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                            
                            guard let parseJSON = json else {
                                print("Error while parsing")
                                return
                            }
                            
                            let email = parseJSON["email"]
                            
                            // successfully reset
                            if email != nil {
                                
                                // get main queue to communicate back to user
                                DispatchQueue.main.async(execute: {
                                    let message = parseJSON["message"] as! String
                                    appDelegate.infoView(message: message, color: colorLightGreen)
                                    
                                })
                                
                                // error
                            } else {
                                
                                // get main queue to communicate back to user
                                DispatchQueue.main.async(execute: {
                                    let message = parseJSON["message"] as! String
                                   appDelegate.infoView(message: message, color: colorSmoothRed)
                                    
                                })
                                return
                                
                            }
                            
                            
                        } catch {
                            
                            // get main queue to communicate back to user
                            DispatchQueue.main.async(execute: {
                                let message = "\(error)"
                                appDelegate.infoView(message: message, color: colorSmoothRed)
                            })
                            return
                            
                        }
                        
                    })
                    
                    
                } else {
                    
                    // get main queue to communicate back to user
                    DispatchQueue.main.async(execute: {
                        let message = error!.localizedDescription
                        appDelegate.infoView(message: message, color: colorSmoothRed)
                    })
                    return
                    
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
