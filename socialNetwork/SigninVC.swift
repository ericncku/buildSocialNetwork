//
//  ViewController.swift
//  socialNetwork
//
//  Created by HOISIO LONG on 24/2/2017.
//  Copyright © 2017年 Eric Hoi. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseAuth
import FirebaseStorage
import SwiftKeychainWrapper


class SigninVC: UIViewController {

    
    @IBOutlet weak var emailTxtField: BorderTxtField!
    @IBOutlet weak var passwordTxtField: BorderTxtField!
    var newUser: User!
    var profileImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
//            loadUser(id: id)
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
    }
    
//    func loadUser(id: String) {
//
//        DataService.ds.REF_USERS.child(id).observeSingleEvent(of: .value, with: { (snapshot) in
//            // Get user value
//            if let userDict = snapshot.value as? Dictionary<String, Any> {
//                self.newUser = User()
//                self.newUser.id = id
//                self.newUser.name = userDict["name"] as! String
//                self.newUser.email = userDict["email"] as! String
//                self.newUser.profileImgUrl = userDict["profileImgUrl"] as! String
//                self.newUser.provider = userDict["provider"] as! String
//                print("ERIC: old user had key, pass user data from firebase database, username: \(self.newUser.name)")
//            }
//
//            
//        }) { (error) in
//            print(error.localizedDescription)
//        }
//
//    }
    
    @IBAction func fbBtnPressed(_ sender: RoundButton) {
        
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, error) in
            if error != nil {
                print("Unable to authenticate with Facebook - \(error)")
            } else if result?.isCancelled == true {
                print("User cancelled Facebook authentication")
            } else {
                print("Successfully authenticated with Facebook")
                
                //Request user facebook information, eg: name, email, profile picture
                self.newUser = User()
                self.newUser.fetchFBUserInfo {
                    //download user profile image from facebook
                    let url = URL(string: self.newUser.profileImgUrl)!
                    print("start download FB user profile image")
                    DispatchQueue.global().async {
                        do {
                            let data = try Data(contentsOf: url)
                            DispatchQueue.global().sync {
                                self.profileImg = UIImageView()
                                self.profileImg.image = UIImage(data: data)
                                print("successfully download profile image from facebook")
                                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                                self.firebaseAuth(credential)
                            }
                        } catch {
                            print("ERIC: error for loading author image data")
                        }
                    }
                }
                
            }
        }
        
    }
    
    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("Unable to authenticate with Firebase - \(error)")
            } else {
                print("Successfully authenticated with Firebase")
                
                if let user = user {
                    
                    self.newUser.provider = credential.provider
                    self.newUser.id = user.uid
                    if let img = self.profileImg.image {
                        print("successfully read profile image")
                        self.uploadImg(img: img) {
                            let userData = ["provider": self.newUser.provider, "email": self.newUser.email, "name": self.newUser.name, "profileImgUrl": self.newUser.profileImgUrl]
                            self.completeSignIn(id: self.newUser.id, userData: userData)
                        }
                    } else {
                        print("no image in profileImg")
                    }

                }
                
                
            }
        })
    }
    
    func uploadImg(img: UIImage, completed: @escaping DownloadComplete) {
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            let imgUid = NSUUID().uuidString
            let metadata = FIRStorageMetadata()
            DataService.ds.REF_USER_IMAGES.child(imgUid).put(imgData, metadata: metadata, completion: { (metadata, error) in
                if error != nil {
                    print("ERIC: unable to upload image to Firebase Storage, \(error)")
                } else {
                    print("ERIC: Successfully uploaded image to Firebase Storage")
                    let downloadUrl = metadata?.downloadURL()?.absoluteString
                    if let url = downloadUrl {
                        self.newUser.profileImgUrl = url
                    }
                }
                completed()
            })
        }
    }
    
    @IBAction func signinBtnPressed(_ sender: RoundButton) {
        
        if let email = emailTxtField.text, let pwd = passwordTxtField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if error == nil {
                    print("Email user authenticated with Firebase")
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
                        if error != nil {
                            print("error: unabel to authenticate with Firebase using email")
                        } else {
                            print("Successfully authenticated and created user with Firebase")
                            if let user = user {
                                let userData = ["provider": user.providerID]
                                self.completeSignIn(id: user.uid, userData: userData)
                            }
                            
                        }
                    })
                }
            })
        }
        
    }
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("Data saved to keychain, \(keychainResult)")
        print("ERIC: new user register, prepare to pass the user data to segue")
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let destination = segue.destination as? FeedVC {
//            if let user = sender as? User {
//                destination.user = user
//            }
//        }
//    }
    

}

