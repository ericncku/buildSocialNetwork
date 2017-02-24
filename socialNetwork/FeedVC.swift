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

class FeedVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func signOutBtnPressed(_ sender: RoundButton) {
        let keychainResult = KeychainWrapper.standard.remove(key: KEY_UID)
        print("ID removed from Keychain")
        try! FIRAuth.auth()?.signOut()
        performSegue(withIdentifier: "goToSignin", sender: nil)
        
    }
    

}
