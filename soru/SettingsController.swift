//
//  SettingsController.swift
//  soru
//
//  Created by Aditya Gurjar on 6/25/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import UIKit

class SettingsController : UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    let items = ["Primary Color", "Secondary Color", "User Chat Bubble", "Watson Chat Bubble"]
    
    var currentCell : SettingsCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SettingsCell
        cell.settingTitle.setTitle(items[indexPath.row], for: .normal)
        currentCell = cell
        cell.settingTitle.tag = indexPath.row
        cell.settingTitle.addTarget(self, action: #selector(SettingsController.clickedSettingsItem(_:)), for: .touchUpInside)
        
        
        return cell
    }
    
    
    func clickedSettingsItem(_ sender : UIButton){
        
        
        let themeAlert = UIAlertController(title: "Select theme", message: "Choose a theme to customize", preferredStyle: UIAlertControllerStyle.actionSheet)
       
        
        themeAlert.addAction(UIAlertAction(title: "Red", style: .default, handler: { (action: UIAlertAction!) in
            self.changeTheme("red",sender.tag)
            
        }))
        themeAlert.addAction(UIAlertAction(title: "Green", style: .default, handler: { (action: UIAlertAction!) in
            self.changeTheme("green",sender.tag)

        }))
        themeAlert.addAction(UIAlertAction(title: "Blue", style: .default, handler: { (action: UIAlertAction!) in
            self.changeTheme("blue",sender.tag)
        }))
        themeAlert.addAction(UIAlertAction(title: "Black", style: .default, handler: { (action: UIAlertAction!) in
            self.changeTheme("black",sender.tag)
            
        }))
        themeAlert.addAction(UIAlertAction(title: "White", style: .default, handler: { (action: UIAlertAction!) in
            self.changeTheme("white",sender.tag)
        }))
        
        present(themeAlert, animated: true, completion: nil)
        
        
        
        
       
    }
    
    func changeTheme(_ theme : String ,_ currentIndex : Int){
        print("Index",currentIndex)
        switch(currentIndex){
            
        case 0 :
            print("Primary")
            UserDefaults.standard.set(theme, forKey: "primary")
            break
            
        case 1 :
            print("Accent")
            UserDefaults.standard.set(theme, forKey: "accent")
            break
            
        case 2 :
            UserDefaults.standard.set(theme, forKey: "user")
            break
        case 3 :
            UserDefaults.standard.set(theme, forKey: "watson")
            break
        default :
            break
        }
        
    }
    
}
