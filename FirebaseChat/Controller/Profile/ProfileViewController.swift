//
//  ProfileViewController.swift
//  FirebaseChat
//
//  Created by Flyco Developer on 13.02.2019.
//  Copyright © 2019 Flyco Global. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {

    @IBOutlet weak var labelInfo: UILabel!
    @IBOutlet weak var imagePhoto: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let databaseRef = Database.database().reference()
        let auth = Auth.auth()
        
        databaseRef.child(Child.USERS)
            .queryOrdered(byChild: "uid")
            .queryEqual(toValue: auth.currentUser!.uid)
            .observeSingleEvent(of: .value) { (snapshot) in
                for child in snapshot.children {
                    let snap = child as! DataSnapshot
                    let dict = snap.value as! NSDictionary
                    
                    let name = dict["name"] as! String
                    let photoUrl = dict["photoUrl"] as! String
                    
                    self.labelInfo.text = name
                    Helper.imageLoad(imageView: self.imagePhoto, url: photoUrl)
                }
        }
    }
    

    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
