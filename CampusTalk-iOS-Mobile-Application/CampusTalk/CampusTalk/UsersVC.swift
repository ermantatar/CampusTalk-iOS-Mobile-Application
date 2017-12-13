//
//  UsersVC.swift
//  CampusTalk
//
//  Created by Erman Sahin Tatar on 12/12/17.
//  Copyright © 2017 Erman Sahin Tatar. All rights reserved.
//

import UIKit

class UsersVC: UITableViewController {

    @IBOutlet var searchBar: UISearchBar!
    // array of objects to store all users' information
    var users = [AnyObject]()
    var avas = [UIImage]()
    
    
    // first load func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // search bar customization
        searchBar.barTintColor = .white // search bar color
        searchBar.tintColor = colorBrand // elements of searchbar
        searchBar.showsCancelButton = false
        
        // call func to find users
        doSearch("")
    }
    
    
    // once entered a text in searchbar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // search php request
        doSearch(searchBar.text!)
    }
    
    
    // did begin editing of text in search bar
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    
    // clicked cancel butotn of searchbar
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        // reset UI
        searchBar.endEditing(false) // reomove keyboard
        searchBar.showsCancelButton = false // remove cancel button
        searchBar.text = ""
        
        // clean up
        users.removeAll(keepingCapacity: false)
        avas.removeAll(keepingCapacity: false)
        tableView.reloadData()
        
        doSearch("")
    }
    
    
    
    // cell numb
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    
    // cell config
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UsersCell
        
        // get one by one user related inf from users var
        let user = users[indexPath.row]
        let ava = avas[indexPath.row]
        
        // shortcuts
        let username = user["username"] as? String
        let fullname = user["fullname"] as? String
        
        // refer str to cell obj
        cell.usernameLbl.text = username
        cell.fullnameLbl.text = fullname
        cell.avaImg.image = ava
        
        return cell
    }
    
    
    // search / retrieve users
    func doSearch(_ word : String) {
        
        // shortucs
        let word = searchBar.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let username = user!["username"] as! String
        
        let url = URL(string: "http://localhost/CampusTalk/users.php")!  // url path to users.php file
        
        var request = URLRequest(url: url) // create request to work with users.php file
        
        request.httpMethod = "POST" // method of passing inf to users.php
        
        let body = "word=\(word)&username=\(username)" // body that passes inf to users.php
        
        request.httpBody = body.data(using: .utf8) // convert str to utf8 str - supports all languages
        
        // launch session
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            // getting main queue of proceeding inf to communicate back, in another way it will do it in background
            // and user will no see changes :)
            DispatchQueue.main.async(execute: {
                
                if error == nil {
                    
                    do {
                        // declare json var to store $returnArray inf we got users.php
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                        
                        // clean up
                        self.users.removeAll(keepingCapacity: false)
                        self.avas.removeAll(keepingCapacity: false)
                        self.tableView.reloadData()
                        
                        // delcare new secure var to store json
                        guard let parseJSON = json else {
                            print("Error while parsing")
                            return
                        }
                        
                        // declare new secure vat to store $returnArray["users"]
                        guard let parseUSERS = parseJSON["users"] else {
                            print(parseJSON["message"] ?? [NSDictionary]())
                            return
                        }
                        
                        // append $returnArray["users"] to self.users var
                        self.users = parseUSERS as! [AnyObject]
                        
                        
                        // for i=0; i < users.count; i++
                        for i in 0 ..< self.users.count {
                            
                            // getting path to ava file of user
                            let ava = self.users[i]["ava"] as? String
                            
                            // if path exists -> laod ava via path
                            if !ava!.isEmpty {
                                let url = URL(string: ava!)! // convert parth of str to url
                                let imageData = try? Data(contentsOf: url) // get data via url and assing to imageData
                                let image = UIImage(data: imageData!)! // convert data of image via data imageData to UIImage
                                self.avas.append(image)
                                
                                // else use placeholder for ava
                            } else {
                                let image = UIImage(named: "ava.png")
                                self.avas.append(image!)
                            }
                            
                        }
                        
                        
                        self.tableView.reloadData()
                        
                        
                        
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
            
            } .resume()
        
        
        
    }
    
    
  

    

}
