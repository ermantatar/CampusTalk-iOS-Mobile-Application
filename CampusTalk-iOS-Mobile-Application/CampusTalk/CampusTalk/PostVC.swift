//
//  PostVC.swift
//  CampusTalk
//
//  Created by Erman Sahin Tatar on 11/26/17.
//  Copyright © 2017 Erman Sahin Tatar. All rights reserved.
//

import UIKit

class PostVC: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    @IBOutlet var textTxt: UITextView!
    @IBOutlet var countLbl: UILabel!
    @IBOutlet var selectBtn: UIButton!
    @IBOutlet var pictureImg: UIImageView!
    
    @IBOutlet var postBtn: UIButton!
    
    // unique id of post
    var uuid = String()
    var imageSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // round corners
        textTxt.layer.cornerRadius = textTxt.bounds.width / 50
        postBtn.layer.cornerRadius = postBtn.bounds.width / 20
        
        // colors
        selectBtn.setTitleColor(colorBrand, for: UIControlState())
        postBtn.backgroundColor = colorBrand
        countLbl.textColor = colorSmoothGray
        
        // disable auto scroll layout
        self.automaticallyAdjustsScrollViewInsets = false
        
        // disable button from the begining
        postBtn.isEnabled = false
        postBtn.alpha = 0.4
        
    }
    
    
    // entered some text in TextView
    func textViewDidChange(_ textView: UITextView) {
        
        // numb of characters in textView
        let chars = textView.text.characters.count
        
        // white spacing in text
        let spacing = CharacterSet.whitespacesAndNewlines
        
        // calculate string's length and convert to String
        countLbl.text = String(140 - chars)
        
        // if number of chars more than 140
        if chars > 140 {
            countLbl.textColor = colorSmoothRed
            postBtn.isEnabled = false
            postBtn.alpha = 0.4
            
            // if entered only spaces and new lines
        } else if textView.text.trimmingCharacters(in: spacing).isEmpty {
            postBtn.isEnabled = false
            postBtn.alpha = 0.4
            
            // everything is correct
        } else {
            countLbl.textColor = colorSmoothGray
            postBtn.isEnabled = true
            postBtn.alpha = 1
        }
        
    }
    
    
    // touched screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // hide keyboard
        self.view.endEditing(false)
    }
    
    
    
    // custom body of HTTP request to upload image file
    func createBodyWithParams(_ parameters: [String: String]?, filePathKey: String?, imageDataKey: Data, boundary: String) -> Data {
        
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        
        // if file is not selected, it will not upload a file to server, because we did not declare a name file
        var filename = ""
        
        if imageSelected == true {
            filename = "post-\(uuid).jpg"
        }
        
        
        let mimetype = "image/jpg"
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey)
        body.appendString("\r\n")
        
        body.appendString("--\(boundary)--\r\n")
        
        return body as Data
        
    }
    
    // function sending requset to PHP to uplaod a file
    func uploadPost() {
        
        // shortcuts to data to be passed to php file
        let id = user!["id"] as! String
        uuid = UUID().uuidString
        let text = textTxt.text.trunc(140) as String
        
        
        // url path to php file
        let url = URL(string: "http://localhost/CampusTalk/posts.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // param to be passed to php file
        let param = [
            "id" : id,
            "uuid" : uuid,
            "text" : text
        ]
        
        // body
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // if picture is selected, compress it by half
        var imageData = Data()
        
        if pictureImg.image != nil {
            imageData = UIImageJPEGRepresentation(pictureImg.image!, 0.5)!
        }
        
        // ... body
        request.httpBody = createBodyWithParams(param, filePathKey: "file", imageDataKey: imageData, boundary: boundary)
        
        // launch session
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            // get main queu to communicate back to user
            DispatchQueue.main.async(execute: {
                
                
                if error == nil {
                    
                    do {
                        
                        // json containes $returnArray from php
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                        
                        // declare new var to store json inf
                        guard let parseJSON = json else {
                            print("Error while parsing")
                            return
                        }
                        
                        // get message from $returnArray["message"]
                        let message = parseJSON["message"]
                        
                        // if there is some message - post is made
                        if message != nil {
                            
                            // reset UI
                            self.textTxt.text = ""
                            self.countLbl.text = "140"
                            self.pictureImg.image = nil
                            self.postBtn.isEnabled = false
                            self.postBtn.alpha = 0.4
                            self.imageSelected = false
                            
                            // switch to another scene
                            self.tabBarController?.selectedIndex = 0
                            
                        }
                        
                    } catch {
                        
                        // get main queue to communicate back to user
                        DispatchQueue.main.async(execute: {
                            let message = "\(error)"
                            appDelegate.infoView(message: message, color: colorSmoothRed)
                        })
                        return
                        
                    }
                    
                } else {
                    
                    // get main queue to communicate back to user
                    DispatchQueue.main.async(execute: {
                        let message = error!.localizedDescription
                        appDelegate.infoView(message: message, color: colorSmoothRed)
                    })
                    return
                    
                }
                
                
            })
            
            }.resume()
        
    }
    
    @IBAction func select_click(_ sender: Any) {
        
        // calling picker for selecting iamge
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    
    // selected image in picker view
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        pictureImg.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        // cast as a true to save image file in server
        if pictureImg.image == info[UIImagePickerControllerEditedImage] as? UIImage {
            imageSelected = true
        }
    }
    

    @IBAction func post_click(_ sender: Any) {
        
        // if entered some text and text is less than 140 chars
        if !textTxt.text.isEmpty && textTxt.text.characters.count <= 140 {
            
            // call func to uplaod post
            uploadPost()
            
        }
        
    }
    

}







// Extension to stirng type of variables
extension String {
    
    // cut / trimm our string
    func trunc(_ length: Int, trailing: String? = "...") -> String {
        
        if self.characters.count > length {
            return self.substring(to: self.characters.index(self.startIndex, offsetBy: length)) + (trailing ?? "")
        } else {
            return self
        }
        
    }
    
}
