//
//  FeedVC.swift
//  socialNetwork
//
//  Created by HOISIO LONG on 24/2/2017.
//  Copyright © 2017年 Eric Hoi. All rights reserved.
//

import UIKit
import FirebaseAuth
import SwiftKeychainWrapper

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
    }
    
    
    
    
    @IBAction func signOutBtnPressed(_ sender: RoundButton) {
        let keychainResult = KeychainWrapper.standard.remove(key: KEY_UID)
        print("ID removed from Keychain")
        try! FIRAuth.auth()?.signOut()
        performSegue(withIdentifier: "goToSignin", sender: nil)
        
    }
    

}
