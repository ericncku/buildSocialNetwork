//
//  User.swift
//  socialNetwork
//
//  Created by HOISIO LONG on 2/3/2017.
//  Copyright © 2017年 Eric Hoi. All rights reserved.
//

import Foundation
import FBSDKLoginKit

class User {
    private var _id: String!
    private var _name: String!
    private var _email: String!
    private var _provider: String!
    private var _profileImgUrl: String!
    
    var id: String {
        get {
            return _id
        } set {
            _id = newValue
        }
    }
    
    var name: String {
        get {
            return _name
        } set {
            _name = newValue
        }

    }
    
    var email: String {
        get {
           return _email
        } set {
            _email = newValue
        }
        
    }
    
    var provider: String {
        get {
            return _provider
        } set {
            _provider = newValue
        }
        
    }
    
    var profileImgUrl: String {
        get {
            return _profileImgUrl
        } set {
            _profileImgUrl = newValue
        }
        
    }
    
    
    func fetchFBUserInfo(completed: @escaping DownloadComplete) {
        
        let fbRequest = FBSDKGraphRequest(graphPath: "/me", parameters: ["fields" : "email, name, gender, first_name, picture.type(large)"])
        
        fbRequest?.start(completionHandler: { (connection, result, error) in
            
            if error != nil {
                
                print("error for fetch user facebook info")
                
            } else {
                
                if let dict = result as? Dictionary<String, AnyObject> {
                    
                    if let name = dict["name"] as? String {
                        
                        self._name = name
                    }
                    
                    if let email = dict["email"] as? String {
                        self._email = email
                    }
                    
                    if let profileImgObj = dict["picture"] as? Dictionary<String, AnyObject> {
                        if let imgData = profileImgObj["data"] as? Dictionary<String, AnyObject> {
                            let url = imgData["url"] as! String
                            self._profileImgUrl = url
                            print("success get profile image url from facebook")
                        }

                    }
                }
                
            }
            completed()
        })
    }
    
}
