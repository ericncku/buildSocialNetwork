//
//  FeedVC.swift
//  socialNetwork
//
//  Created by HOISIO LONG on 24/2/2017.
//  Copyright © 2017年 Eric Hoi. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        DataService.ds.REF_POSTS.observe(.value) { (snapshot) in
            print(snapshot.value)
            
        }
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
//        let keychainResult: Bool = KeychainWrapper.standard.remove(key: KEY_UID)
        let keychainResult: Bool = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("ID removed from Keychain, \(keychainResult)")
        try! FIRAuth.auth()?.signOut()
        performSegue(withIdentifier: "goToSignin", sender: nil)
        
    }
    

}
