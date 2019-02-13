//
//  HomeViewController.swift
//  FirebaseChat
//
//  Created by Flyco Developer on 30.01.2019.
//  Copyright © 2019 Flyco Global. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController, UITabBarDelegate, UITableViewDataSource, UITableViewDelegate {
   
    

    @IBOutlet weak var tableView: UITableView!
    var list = [ListItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func logout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "signInViewController") as! SignInViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        if item.tag == 0 {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "inboxViewController") as! InboxViewController
            self.present(vc, animated: true, completion: nil)
            
        } else if item.tag == 1 {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "profileViewController") as! ProfileViewController
            self.present(vc, animated: true, completion: nil)
            
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell") as! HomeTableViewCell
        let info = self.list[indexPath.row]
        cell.labelName.text = info.name
        
        Helper.imageLoad(imageView: cell.imagePhoto!, url: info.photoUrl!)
        cell.imagePhoto.layer.cornerRadius = cell.imagePhoto.frame.width / 2
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
        return 68
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "chatViewController") as! ChatViewController
        vc.recipientName = list[indexPath.row].name!
        vc.recipientUid = list[indexPath.row].uid!
        self.present(vc, animated: true, completion: nil)
    }
    
    func tableLoad() {
        
        let databaseRef = Database.database().reference()
        
        databaseRef.child(Child.USERS).observe(.value) { (snapshot) in
            self.list.removeAll()
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let dict = snap.value as! NSDictionary
                
                let uid = dict["uid"] as! String
                let name = dict["name"] as! String
                let url = dict["photoUrl"] as! String
                
                if uid != Auth.auth().currentUser?.uid {
                self.list.append(ListItem(uid: uid, name: name, photoUrl: url))
                }
            }
            self.tableView.reloadData()
        }
        
    }
    
    class ListItem {
        var uid:String?
        var name:String?
        var photoUrl:String?
        
        init(uid:String, name:String, photoUrl:String) {
            self.uid = uid
            self.name = name
            self.photoUrl = photoUrl
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
