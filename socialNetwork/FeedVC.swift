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
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var imageSelected = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    if let postDict = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDict)
                        self.posts.append(post)
                    }
                }
            }
            self.tableView.reloadData()
        })
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            
            if let img = FeedVC.imageCache.object(forKey: post.imageUrl as NSString) {
                cell.configureCell(post: post, img: img)
                print("read image from NSCache!")
                
            } else {
                cell.configureCell(post: post, img: nil)
            }
            
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
                        self.postToFirebase(imgUrl: url)
                    }
                }
            })
        }
    }
    
    func postToFirebase(imgUrl: String) {
        let post: Dictionary<String, Any> = [
        "caption": captionField.text!,
        "imageUrl": imgUrl,
        "likes": 0
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
