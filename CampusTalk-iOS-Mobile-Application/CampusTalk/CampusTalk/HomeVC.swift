//
//  HomeVC.swift
//  CampusTalk
//
//  Created by Erman Sahin Tatar on 11/25/17.
//  Copyright © 2017 Erman Sahin Tatar. All rights reserved.
//

import UIKit

class HomeVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet var avaImg: UIImageView!
    
    @IBOutlet var usernameLbl: UILabel!
    
    @IBOutlet var fullnameLbl: UILabel!
    
    @IBOutlet var emailLbl: UILabel!
    
    @IBOutlet var editBtn: UIButton!
    
    
    // UI obj related to Posts
    
    @IBOutlet var tableView: UITableView!
    var tweets = [AnyObject]()
    var images = [UIImage]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // get user details from user global var
        // shortcuts to store inf
        let username = (user!["username"] as AnyObject).uppercased
        let fullname = user!["fullname"] as? String
        let email = user!["email"] as? String
        let ava = user!["ava"] as? String
        
        // assign values to labels
        usernameLbl.text = username
        fullnameLbl.text = fullname
        emailLbl.text = email
        
        
        // get user profile picture
        if ava != "" {
            
            // url path to image
            let imageURL = URL(string: ava!)!
            
            // communicate back user as main queue
            DispatchQueue.main.async(execute: {
                
                // get data from image url
                let imageData = try? Data(contentsOf: imageURL)
                
                // if data is not nill assign it to ava.Img
                if imageData != nil {
                    DispatchQueue.main.async(execute: {
                        self.avaImg.image = UIImage(data: imageData!)
                    })
                }
            })
            
        }
        
        
        // round corners
        avaImg.layer.cornerRadius = avaImg.bounds.width / 20
        avaImg.clipsToBounds = true
        
        editBtn.setTitleColor(colorBrand, for: UIControlState())
        
        self.navigationItem.title = username
 
        
        
    }

    
    
    
    @IBAction func edit_click(_ sender: Any) {
        
        // delcare sheet
        let sheet = UIAlertController(title: "Edit profile", message: nil, preferredStyle: .actionSheet)
        
        // cancel button clicked
        let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // change picture clicked
        let pictureBtn = UIAlertAction(title: "Change picture", style: .default) { (action:UIAlertAction) in
            self.selectAva()
        }
        
        // update profile clicked
        let editBtn = UIAlertAction(title: "Update profile", style: .default) { (action:UIAlertAction) in
            
            //declare var to store editvc scene from main.stbrd
            //let editvc = self.storyboard!.instantiateViewController(withIdentifier: "EditVC") as! EditVC
            //self.navigationController?.pushViewController(editvc, animated: true)
            
            // remove title from back button
            let backItem = UIBarButtonItem()
            backItem.title = ""
            self.navigationItem.backBarButtonItem = backItem
            
        }
        
        // add actions to sheet
        sheet.addAction(cancelBtn)
        sheet.addAction(pictureBtn)
        sheet.addAction(editBtn)
        
        // present action sheet
        self.present(sheet, animated: true, completion: nil)
        
    }
    
    // select profile picture
    func selectAva() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    
    
    
    // selected image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        avaImg.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        // call func of uploading file to server
        uploadAva()
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
        
        let filename = "ava.jpg"
        
        let mimetype = "image/jpg"
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey)
        body.appendString("\r\n")
        
        body.appendString("--\(boundary)--\r\n")
        
        return body as Data
        
    }
    
    
    // upload image to serve
    func uploadAva() {
        
        // shotcut id
        let id = user!["id"] as! String
        
        // url path to php file
        let url = URL(string: "http://localhost/CampusTalk/uploadAva.php")!
        
        // declare request to this file
        var request = URLRequest(url: url)
        
        // declare method of passign inf to this file
        request.httpMethod = "POST"
        
        // param to be sent in body of request
        let param = ["id" : id]
        
        // body
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // compress image and assign to imageData var
        let imageData = UIImageJPEGRepresentation(avaImg.image!, 0.5)
        
        // if not compressed, return ... do not continue to code
        if imageData == nil {
            return
        }
        
        // ... body
        request.httpBody = createBodyWithParams(param, filePathKey: "file", imageDataKey: imageData!, boundary: boundary)
        
        
        // launc session
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            // get main queue to communicate back to user
            DispatchQueue.main.async(execute: {
                
                if error == nil {
                    
                    do {
                        // json containes $returnArray from php
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                        
                        // declare new parseJSON to store json
                        guard let parseJSON = json else {
                            print("Error while parsing")
                            return
                        }
                        
                        // get id from $returnArray["id"] - parseJSON["id"]
                        let id = parseJSON["id"]
                        
                        // successfully uploaded
                        if id != nil {
                            
                            // save user information we received from our host
                            UserDefaults.standard.set(parseJSON, forKey: "parseJSON")
                            user = UserDefaults.standard.value(forKey: "parseJSON") as? NSDictionary
                            
                            // did not give back "id" value from server
                        } else {
                            
                            // get main queue to communicate back to user
                            DispatchQueue.main.async(execute: {
                                let message = parseJSON["message"] as! String
                                appDelegate.infoView(message: message, color: colorSmoothRed)
                            })
                            
                        }
                        
                        // error while jsoning
                    } catch {
                        
                        // get main queue to communicate back to user
                        DispatchQueue.main.async(execute: {
                            let message = error as! String
                            appDelegate.infoView(message: message, color: colorSmoothRed)
                        })
                        
                    }
                    
                    // error with php
                } else {
                    
                    // get main queue to communicate back to user
                    DispatchQueue.main.async(execute: {
                        let message = error!.localizedDescription
                        appDelegate.infoView(message: message, color: colorSmoothRed)
                    })
                    
                }
                
                
            })
            
            }.resume()
        
        
    }
    
    // clicked logout button
    @IBAction func logout_click(_ sender: Any) {
        
        // remove saved information
        UserDefaults.standard.removeObject(forKey: "parseJSON")
        UserDefaults.standard.synchronize()
        
        // go to login page
        let loginvc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.present(loginvc, animated: true, completion: nil)
        
    }
    
    
    // TABLEVIEW
    // cell numb
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    
    // cell config
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostCell
        
        // shortcuts
        let tweet = tweets[indexPath.row]
        let image = images[indexPath.row]
        let username = tweet["username"] as? String
        let text = tweet["text"] as? String
        let date = tweet["date"] as! String
        
        // converting date string to date
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd-HH:mm:ss"
        let newDate = dateFormater.date(from: date)!
        
        // declare settings
        let from = newDate
        let now = Date()
        let components : NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfMonth]
        let difference = (Calendar.current as NSCalendar).components(components, from: from, to: now, options: [])
        
        // calculate date
        if difference.second! <= 0 {
            cell.dateLbl.text = "now"
        }
        if difference.second! > 0 && difference.minute! == 0 {
            cell.dateLbl.text = "\(String(describing: difference.second))s." // 12s.
        }
        if difference.minute! > 0 && difference.hour! == 0 {
            cell.dateLbl.text = "\(String(describing: difference.minute))m."
        }
        if difference.hour! > 0 && difference.day! == 0 {
            cell.dateLbl.text = "\(String(describing: difference.hour))h."
        }
        if difference.day! > 0 && difference.weekOfMonth! == 0 {
            cell.dateLbl.text = "\(String(describing: difference.day))d."
        }
        if difference.weekOfMonth! > 0 {
            cell.dateLbl.text = "\(String(describing: difference.weekOfMonth))w."
        }
        
        
        // assigning shortcuts to ui obj
        cell.usernameLbl.text = username
        cell.textLbl.text = text
        cell.pictureImg.image = image
        
        
        // get main queue to this block of code to communicate back
        DispatchQueue.main.async {
            
            // if no image on the cell
            if image.size.width == 0 && image.size.height == 0 {
                // move left textLabel if no picture
                cell.textLbl.frame.origin.x = self.view.frame.size.width / 16 // 20
                cell.textLbl.frame.size.width = self.view.frame.size.width - self.view.frame.size.width / 8 // 40
                cell.textLbl.sizeToFit()
            }
        }
        
        return cell
        
    }
    
    
    // pre load func
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // call func of laoding posts
        loadPosts()
    }
    
    
    
    // func of loading posts from server
    func loadPosts() {
        
        // shortcut to id
        let id = user!["id"] as! String
        
        // accessing php file via url path
        let url = URL(string: "http://localhost/CampusTalk/posts.php")!
        
        // declare request to proceed php file
        var request = URLRequest(url: url)
        
        // declare method of passing information to php file
        request.httpMethod = "POST"
        
        // pass information to php file
        let body = "id=\(id)&text=&uuid="
        request.httpBody = body.data(using: String.Encoding.utf8)
        
        // launch session
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            // get main queue to operations inside of this block
            DispatchQueue.main.async(execute: {
                
                // no error of accessing php file
                if error == nil {
                    
                    do {
                        
                        // getting content of $returnArray variable of php file
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                        
                        // clean up
                        self.tweets.removeAll(keepingCapacity: false)
                        self.images.removeAll(keepingCapacity: false)
                        self.tableView.reloadData()
                        
                        // declare new parseJSON to store json
                        guard let parseJSON = json else {
                            print("Error while parsing")
                            return
                        }
                        
                        // declare new posts to store parseJSON
                        guard let posts = parseJSON["posts"] as? [AnyObject] else {
                            print("Error while parseJSONing")
                            return
                        }
                        
                        
                        // append all posts var's inf to tweets
                        self.tweets = posts
                        
                        
                        // getting images from url paths
                        for i in 0 ..< self.tweets.count {
                            
                            // path we are getting from $returnArray that assigned to parseJSON > to posts > tweets
                            let path = self.tweets[i]["path"] as? String
                            
                            // if we found path
                            if !path!.isEmpty {
                                let url = URL(string: path!)! // convert path str to url
                                let imageData = try? Data(contentsOf: url) // get data via url and assigned imageData
                                let image = UIImage(data: imageData!)! // get image via data imageData
                                self.images.append(image) // append found image to [images] var
                            } else {
                                let image = UIImage() // if no path found, create a gab of type uiimage
                                self.images.append(image) // append gap to uiimage to avoid crash
                            }
                            
                        }
                        
                        
                        // reload tableView to show back information
                        self.tableView.reloadData()
                        
                        
                    } catch {
                    }
                    
                } else {
                }
                
            })
            
            }.resume()
        
    }
    
    
    // DELETE SECTION
    // allow edit cell
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // cell is swiped ...
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        // we pressed delete button from swiped cell
        if editingStyle == .delete {
            
            // send delete PHP request
            deletePost(indexPath)
        }
        
    }
    
    // delete post php request
    func deletePost(_ indexPath : IndexPath) {
        
        // shortcuts
        let tweet = tweets[indexPath.row]
        let uuid = tweet["uuid"] as! String
        let path = tweet["path"] as! String
        
        let url = URL(string: "http://localhost/CampusTalk/posts.php")! // access php file
        var request = URLRequest(url: url) // declare request to proceed url
        request.httpMethod = "POST" // declare method of passing inf to php
        let body = "uuid=\(uuid)&path=\(path)" // body - here we are passing info
        request.httpBody = body.data(using: String.Encoding.utf8) // supports all lang
        
        // launc php request
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            // get main queue to this block of code to communicate back, in other case it will do all this in background
            DispatchQueue.main.async(execute: {
                
                if error == nil {
                    
                    do {
                        
                        // get back from server $returnArray of php file
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                        
                        // secure way to declare new var to store (e.g. json) data
                        guard let parseJSON = json else {
                            print("Error while parsing")
                            return
                        }
                        
                        // we are getting content of $returnArray under value "result" -> $returnArray["result"]
                        let result = parseJSON["result"]
                        // if result exists - deleted successfulyy
                        if result != nil {
                            self.tweets.remove(at: indexPath.row) // remove related content from array
                            self.images.remove(at: indexPath.row) // remove related picture
                            self.tableView.deleteRows(at: [indexPath], with: .automatic) // remove table cell
                            self.tableView.reloadData() // reload table to show updates
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
    
    
    
}





// Creating protocol of appending string to var of type data
extension NSMutableData {
    
    func appendString(_ string : String) {
        
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
        
    }
    
}












