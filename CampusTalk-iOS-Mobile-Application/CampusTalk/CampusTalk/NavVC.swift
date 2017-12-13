//
//  NavVC.swift
//  CampusTalk
//
//  Created by Erman Sahin Tatar on 11/25/17.
//  Copyright © 2017 Erman Sahin Tatar. All rights reserved.
//

import UIKit

class NavVC: UINavigationController {

    // first load func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // color of title at the top of nav controller
        self.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        
        // color of buttons in nav controller
        self.navigationBar.tintColor = .white
        
        // color of background of nav controller / nav bar
        self.navigationBar.barTintColor = colorBrand
        
        // disable translucent
        self.navigationBar.isTranslucent = false
        
    }
    
    
    // white status bar
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    


}
