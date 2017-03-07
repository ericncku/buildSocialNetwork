//
//  PostCell.swift
//  socialNetwork
//
//  Created by HOISIO LONG on 24/2/2017.
//  Copyright © 2017年 Eric Hoi. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    
    var post: Post!
    var likesRef: FIRDatabaseReference!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.isUserInteractionEnabled = true
    }

    func configureCell(post: Post, img: UIImage? = nil, authorImg: UIImage? = nil) {
        self.post = post
        //add post author's name
        self.usernameLbl.text = post.postAuthor
        self.caption.text = post.caption
        self.likesLbl.text = "\(post.likes)"
        
        //add currentLike value to decide the post is like or not
        if post.currentLike != nil {
            if let isLike = post.currentLike {
                print("read the post like status from post item")
                if isLike {
                    self.likeImg.image = UIImage(named: "filled-heart")
                } else {
                    self.likeImg.image = UIImage(named: "empty-heart")
                }
            }
        } else {
            likesRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)
            
            likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let _ = snapshot.value as? NSNull {
                    self.likeImg.image = UIImage(named: "empty-heart")
                    post.currentLike = false
                } else {
                    self.likeImg.image = UIImage(named: "filled-heart")
                    post.currentLike = true
                }
            })
        }
        
        
        //load the post image from cache or firebase
        if img != nil {
            
            self.postImg.image = img
            
        } else {

            let ref = FIRStorage.storage().reference(forURL: post.imageUrl)
            ref.data(withMaxSize:  2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("ERIC: Unable to download image from firebase storage")
                } else {
                    print("ERIC: image download from firebase storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.postImg.image = img
                            FeedVC.imageCache.setObject(img, forKey: post.imageUrl as NSString)
                        }
                    }
                }
            })
        }
        
        //load the user profile image from cache or firebase
            //first fetch author user from firebase database
        if authorImg != nil {
            self.profileImg.image = authorImg
        } else {
            if post.authorId != "" {
                DataService.ds.REF_USERS.child(post.authorId).observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get author profile image url
                    if let userDict = snapshot.value as? Dictionary<String, Any> {
                        if let profileImgUrl = userDict["profileImgUrl"] as? String {
                            
                            post.authorImgUrl = profileImgUrl
                            //download author profile image from firebase storage or cache
                            if let profileImg = FeedVC.imageCache.object(forKey: profileImgUrl as NSString) {
                                self.profileImg.image = profileImg
                                print("ERIC: download author image from cache")
                            } else {
                                let ref = FIRStorage.storage().reference(forURL: profileImgUrl)
                                ref.data(withMaxSize:  2 * 120 * 120, completion: { (data, error) in
                                    if error != nil {
                                        print("ERIC: Unable to download author image from firebase storage")
                                    } else {
                                        print("ERIC: author image download from firebase storage")
                                        if let imgData = data {
                                            if let img = UIImage(data: imgData) {
                                                self.profileImg.image = img
                                                FeedVC.imageCache.setObject(img, forKey: profileImgUrl as NSString)
                                            }
                                        }
                                    }
                                })
                            }
                            
                        }

                    }
                    
                    
                }) { (error) in
                    print(error.localizedDescription)
                }
            } else {
            self.profileImg.image = UIImage(named: "profile")
            }
        }
        
    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "filled-heart")
                self.post.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
            } else {
                self.likeImg.image = UIImage(named: "empty-heart")
                self.post.adjustLikes(addLike: false)
                self.likesRef.removeValue()
            }
        })
    }

}
