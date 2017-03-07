//
//  Post.swift
//  socialNetwork
//
//  Created by HOISIO LONG on 1/3/2017.
//  Copyright © 2017年 Eric Hoi. All rights reserved.
//

import Foundation
import Firebase

class Post {
    private var _caption: String!
    private var _imageUrl: String!
    private var _likes: Int!
    private var _postKey: String!
    private var _postRef: FIRDatabaseReference!
    private var _postAuthor: String!
    private var _authorId: String!
    private var _postDate: String!
    private var _authorImgUrl: String!
    var currentLike: Bool?
    
    var caption: String {
        return _caption
    }
    
    var imageUrl: String {
        return _imageUrl
    }
    
    var likes: Int {
        return _likes
    }
    
    var postKey: String {
        return _postKey
    }
    
    //add post Author name and id in post data model
    var postAuthor: String {
        if _postAuthor == nil {
            _postAuthor = ""
        }
        return _postAuthor
    }
    
    var authorId: String {
        if _authorId == nil {
            _authorId = ""
        }
        
        return _authorId
    }
    
    var postDate: String {
        return _postDate
    }
    
    var authorImgUrl: String {
        get {
            if _authorImgUrl != nil {
                return _authorImgUrl
            } else {
                return ""
            }
            
        } set {
            _authorImgUrl = newValue
        }
    }
    
    
//    init(caption: String, imageUrl: String, likes: Int) {
//        self._caption = caption
//        self._imageUrl = imageUrl
//        self._likes = likes
//    }
    
    init(postKey: String, postData: Dictionary<String, Any>) {
        self._postKey = postKey
        
        if let caption = postData["caption"] as? String {
            self._caption = caption
        }
        
        if let imageUrl = postData["imageUrl"] as? String {
            self._imageUrl = imageUrl
        }
        
        if let likes = postData["likes"] as? Int {
            self._likes = likes
        }
        
        if let postAuthor = postData["author"] as? String {
            self._postAuthor = postAuthor
        }
        
        if let authorId = postData["authorId"] as? String {
            self._authorId = authorId
        } else {
            self._authorId = ""
        }
        
        if let postDate = postData["postDate"] as? String {
            self._postDate = postDate
        } else {
            self._postDate = "0"
        }
        
        print("refresh post item")
        
        _postRef = DataService.ds.REF_POSTS.child(_postKey)
    }
    
    func adjustLikes(addLike: Bool) {
        if addLike {
            _likes = _likes + 1

        } else {
            _likes = _likes - 1

        }
        
        _postRef.child("likes").setValue(_likes)
    }
    
    
}
