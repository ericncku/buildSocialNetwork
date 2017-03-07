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

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageAdd: UIImageView!
    @IBOutlet weak var captionField: BorderTxtField!
    
    var posts = [Post]()
    var users = [User]()
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var imageSelected = false
    var user: User!

    var profileImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("start view did load")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        //fetch user data from Firebase
        if let id = KeychainWrapper.standard.string(forKey: KEY_UID) {
            print("start to fetch current user data from Firebase")
            loadUser(id: id)
        }
        
        //fetch post data from Firebase
        fetchPost() {
            
            print("finish fetch post")
        }
        
    }
    
    func fetchAuthor(id: String, completed: @escaping DownloadComplete) {
        var isFetch = false
        DataService.ds.REF_USERS.child(id).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get author profile image url
                if let userDict = snapshot.value as? Dictionary<String, Any> {
                    if let profileImgUrl = userDict["profileImgUrl"] as? String {
                        print(profileImgUrl)
                        isFetch = true
                        if isFetch {
                            completed()
                        }
                    }
                }
                
            })
        
        
    }
    
    func fetchPost(completed: @escaping DownloadComplete) {
        //fetch post data from Firebase
        var counter = 0
        DataService.ds.REF_POSTS.queryOrdered(byChild: "postDate").observe(.value, with: { (snapshot) in
            
            //Fix: clean all the posts for each time the posts' value have changed, eg: likes
            self.posts = []
            
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                //add counter to know the fetching is finished
                for snap in snapshot {
                    if let postDict = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        
                        let post = Post(postKey: key, postData: postDict)

                        if post.authorId != "" {
                            //ERIC: how to fetch the profileImgUrl then pass to the post item?
                            self.fetchAuthor(id: post.authorId) {
                                print(post.authorId)
                                self.posts.insert(post, at: 0)
                                counter = counter + 1
                                
                            }
                            
                        } else {
                            self.posts.insert(post, at: 0)
                            counter = counter + 1
                        }
                        if (counter == snapshot.count) {
                            print("refresh the table")
                            completed()
                        }
                        print("ERIC: add post item")
                        
                        

                    }
                    
                }
            }
        self.tableView.reloadData()
        })
    }
    
    func loadUser(id: String) {
        
        DataService.ds.REF_USERS.child(id).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let userDict = snapshot.value as? Dictionary<String, Any> {
                let user = User()
                user.id = id
                user.name = userDict["name"] as! String
                user.email = userDict["email"] as! String
                user.profileImgUrl = userDict["profileImgUrl"] as! String
                user.provider = userDict["provider"] as! String
                self.user = user
                print("ERIC: old user had key, pass user data from firebase database, username: \(self.user.name)")
            }
            
//            completed()
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 378
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        print("ERIC: in cell for row beginning, \(post.authorId)")
        let postImg = UIImageView()
        let authorImg = UIImageView()
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            //set default image
            cell.profileImg.image = UIImage(named: "profile")
            cell.postImg.image = UIImage(named: "placeholder")
            cell.likeImg.image = UIImage(named: "empty-heart")
            
            if let img = FeedVC.imageCache.object(forKey: post.imageUrl as NSString) {
                postImg.image = img
                print("read post image from NSCache!")
            } else {
                postImg.image = nil
            }
            
            if let img = FeedVC.imageCache.object(forKey: post.authorImgUrl as NSString) {
                authorImg.image = img
                print("read author image from NSCache!")
            } else {
                authorImg.image = nil
            }
            
            cell.configureCell(post: post, img: postImg.image, authorImg: authorImg.image)
            
            return cell
            
        } else {
            
            return PostCell()
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageAdd.image = image
            imageSelected = true
        } else {
            print("Eric: A valid image wasn't selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addImagePressed(_ sender: Any) {
        present(imagePicker, animated:true, completion: nil)
    }
    
    @IBAction func postBtnPressed( _ sender: RoundButton) {
        guard let caption = captionField.text, caption != "" else {
            print("ERIC: caption must be entered")
            return
        }
        
        guard let img = imageAdd.image, imageSelected == true else {
            print("ERIC: image must be selected")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            let imgUid = NSUUID().uuidString
            let metadata = FIRStorageMetadata()
            DataService.ds.REF_POST_IMAGES.child(imgUid).put(imgData, metadata: metadata, completion: { (metadata, error) in
                if error != nil {
                    print("ERIC: unable to upload image to Firebase Storage")
                } else {
                    print("ERIC: Successfully uploaded image to Firebase Storage")
                    let downloadUrl = metadata?.downloadURL()?.absoluteString
                    if let url = downloadUrl {
                        self.postToFirebase(imgUrl: url, user: self.user)
                    }
                }
            })
        }
    }
    
    func postToFirebase(imgUrl: String, user: User) {
        let post: Dictionary<String, Any> = [
        "caption": captionField.text!,
        "imageUrl": imgUrl,
        "likes": 0,
        "author": user.name,
        "authorId": user.id,
        "postDate": FIRServerValue.timestamp()
        ]
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        captionField.text = ""
        imageSelected = false
        imageAdd.image = UIImage(named: "add-image")
        
        tableView.reloadData()
    }
    
    
    @IBAction func signOutBtnPressed(_ sender: RoundButton) {
//        let keychainResult: Bool = KeychainWrapper.standard.remove(key: KEY_UID)
        let keychainResult: Bool = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("ID removed from Keychain, \(keychainResult)")
        try! FIRAuth.auth()?.signOut()
        performSegue(withIdentifier: "goToSignin", sender: nil)
        
    }

}
