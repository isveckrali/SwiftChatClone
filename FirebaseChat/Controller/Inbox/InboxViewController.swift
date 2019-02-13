//
//  InboxViewController.swift
//  FirebaseChat
//
//  Created by Flyco Developer on 13.02.2019.
//  Copyright © 2019 Flyco Global. All rights reserved.
//

import UIKit
import Firebase

class InboxViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
    var list = [ListItem]()
    var databaseRef:DatabaseReference!
    var auth:Auth!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        databaseRef = Database.database().reference()
        auth = Auth.auth()

        self.tableLoad()
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func tableLoad() {
        databaseRef.child(Child.CHAT_INBOX)
            .queryOrdered(byChild: "senderUid")
            .queryEqual(toValue: self.auth.currentUser!.uid).observe(.value) { (snapshot) in
                
                self.list.removeAll()
                
                for child in snapshot.children {
                    let snap = child as! DataSnapshot
                    let dict = snap.value as! NSDictionary
                    
                    let rowKey = snap.key
                    let recipientUid = dict["recipientUid"] as! String
                    let isRead = dict["isRead"] as! String
                    
                    self.databaseRef.child(Child.USERS)
                        .queryOrdered(byChild: "uid")
                        .queryEqual(toValue: recipientUid).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                            for child in snapshot.children {
                                
                                let snap = child as! DataSnapshot
                                let dict = snap.value as! NSDictionary
                                
                                let name = dict["name"] as! String
                                let photoUrl = dict["photoUrl"] as! String
                                
                                self.list.append(ListItem(uid: recipientUid, name: name, photoUrl: photoUrl, isRead: isRead, rowKey: rowKey))
                            }
                            self.tableView.reloadData()
                    })
                }
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell") as! HomeTableViewCell
        
        let info = self.list[indexPath.row]
        cell.labelName.text = info.name
        Helper.imageLoad(imageView: cell.imagePhoto, url: info.photoUrl!)
        cell.imagePhoto.layer.cornerRadius = cell.imagePhoto.frame.width / 2
        cell.imagePhoto.layer.borderWidth = 2.0
        
        if info.isRead == "1" {
            cell.imagePhoto.layer.borderColor = UIColor.red.cgColor
        } else {
            cell.imagePhoto.layer.borderColor = UIColor.white.cgColor
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        databaseRef.child(Child.CHAT_INBOX).child(self.list[indexPath.row].rowKey!).child("isRead").setValue("0")
        
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "chatViewController") as! ChatViewController
        vc.recipientUid = self.list[indexPath.row].uid!
        vc.recipientName = self.list[indexPath.row].name!
        self.present(vc, animated: true, completion: nil)
        
    }
    
    class ListItem {
        
        var rowKey:String?
        var uid:String?
        var name:String?
        var photoUrl:String?
        var isRead:String?
        
        init(uid:String, name:String, photoUrl:String, isRead:String, rowKey:String) {
            self.rowKey = rowKey
            self.uid = uid
            self.name = name
            self.photoUrl = photoUrl
            self.isRead = isRead
        }
        
    }
    
}
