//
//  ChatViewController.swift
//  FirebaseChat
//
//  Created by Flyco Developer on 30.01.2019.
//  Copyright © 2019 Flyco Global. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController, UIScrollViewDelegate , UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var textMessage: UITextField!
    @IBOutlet weak var viewSendBottomConst: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
    
    var list = [ListItem]()
    var databaseRef:DatabaseReference!
    var auth:Auth!
    var recipientName:String = ""
    var recipientUid:String = ""
    var chatInboxInfo:NSDictionary!
    var chatLastInfo:NSDictionary!
    var rowKeyChatInbox:String = ""
    var rowKeyChatLast:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        databaseRef = Database.database().reference()
        auth = Auth.auth()
        navBar.topItem?.title = recipientName
        
        self.tableView.register(ChatTableViewCell.self, forCellReuseIdentifier: "chatTableViewCell")
        // Do any additional setup after loading the view.
        tableView.tableFooterView = UIView()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        crateChat()
        
        
    }
    
    
    func tableViewScrollToBottom(animated: Bool) {
        UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }) { (true) in
            if self.list.count > 0 {
            self.tableView.scrollToRow(at: IndexPath(row: (self.list.count - 1), section: 0), at: .bottom, animated: animated)
            }
        }
    }
    
    
    @IBAction func close(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func crateChat() {
        
        databaseRef.child(Child.CHAT_INBOX)
            .queryOrdered(byChild: "senderUid")
            .queryEqual(toValue: self.auth.currentUser?.uid)
            .observeSingleEvent(of: .value) { (snapshot) in
                for child in snapshot.children {
                    let snap = child as! DataSnapshot
                    let dict = snap.value as! NSDictionary
                    if (dict["recipientUid"] as! String) == self.recipientUid {
                        self.chatInboxInfo = dict
                       // self.rowKeyChatInbox = snap.key
                        self.databaseRef.child(Child.CHAT_INBOX)
                            .queryOrdered(byChild: "senderUid")
                            .queryEqual(toValue: self.recipientUid)
                            .observeSingleEvent(of: .value, with: { (snapshot) in
                                for child in snapshot.children {
                                    let snap = child as! DataSnapshot
                                    self.rowKeyChatInbox = snap.key
                                }
                            })
                        self.databaseRef.child(Child.CHAT_LAST)
                            .queryOrdered(byChild: "inboxKey")
                            .queryEqual(toValue: (dict["inboxKey"] as! String))
                            .observeSingleEvent(of: .value, with: { (snapshot) in
                                for child in snapshot.children {
                                    let snap = child as! DataSnapshot
                                    self.rowKeyChatLast = snap.key
                                }
                            })
                        break
                    }
                }
                self.createChatInboxAndLastChat()
                self.chats()
                self.chatLast()
        }
        
    }
    
    func createChatInboxAndLastChat() {
        
        if chatInboxInfo == nil {
            let key = databaseRef.childByAutoId().key
            
            //For sender
            self.chatInboxInfo = ["inboxKey":key!, "senderUid":self.auth.currentUser!.uid, "recipientUid":self.recipientUid, "isRead":"0"]
            databaseRef.child(Child.CHAT_INBOX).childByAutoId().setValue(self.chatInboxInfo)
            
            //For recipient
            self.chatInboxInfo = ["inboxKey":key!, "senderUid":self.recipientUid, "recipientUid":self.auth.currentUser!.uid, "isRead":"0"]
            databaseRef.child(Child.CHAT_INBOX).childByAutoId().setValue(self.chatInboxInfo) { (error, snapshot) in
               
                self.rowKeyChatInbox = snapshot.key!
            }
            
            // for last message
            self.chatLastInfo  = ["inboxKey":key!, "messageKey":""]
            databaseRef.child(Child.CHAT_LAST).childByAutoId().setValue(self.chatLastInfo) { (error, snapshot) in
                self.rowKeyChatLast = snapshot.key!
            }

        }
    }
    
    func chats() {
        
        databaseRef.child(Child.CHATS)
            .queryOrdered(byChild: "inboxKey")
            .queryEqual(toValue: (self.chatInboxInfo["inboxKey"] as! String))
            .observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let dict = snap.value as! NSDictionary
                let senderUid = dict["senderUid"] as! String
                let message = dict["message"] as! String
                self.list.append(ListItem(senderUid: senderUid, message: message))
            }
                self.tableView.reloadData()
                self.tableViewScrollToBottom(animated: true)
        }
    }
    
    func chatLast() {
        databaseRef.child(Child.CHAT_LAST)
            .queryOrdered(byChild: "inboxKey")
            .queryEqual(toValue: (self.chatInboxInfo["inboxKey"] as! String))
            .observe(.childChanged) { (snapshot) in
                if let dict = snapshot.value as? NSDictionary {
                    let messageKey = dict["messageKey"] as! String
                    self.databaseRef.child(Child.CHATS)
                        .child(messageKey)
                        .observeSingleEvent(of: .value, with: { (snapshot) in
                        if let dict = snapshot.value as? NSDictionary {
                            let senderUid = dict["senderUid"] as! String
                            let message = dict["message"] as! String
                            self.list.append(ListItem(senderUid: senderUid, message: message))
                        }
                            self.tableView.reloadData()
                            self.tableViewScrollToBottom(animated: false)
                    })
                }
        }

    }
    
    @IBAction func btnSendMessage(_ sender: Any) {
        sendMessage()
    }
    
    func sendMessage() {
        let inboxKey = chatInboxInfo["inboxKey"] as! String
        let senderUid = auth.currentUser!.uid
        let message = textMessage.text!
        let postData = ["inboxKey":inboxKey, "senderUid":senderUid, "message":message]
        databaseRef.child(Child.CHATS).childByAutoId().setValue(postData) { (error, snapshot) in
            self.textMessage.text = ""
            self.databaseRef.child(Child.CHAT_LAST).child(self.rowKeyChatLast).child("messageKey").setValue(snapshot.key!)
            self.databaseRef.child(Child.CHAT_INBOX).child(self.rowKeyChatInbox).child("isRead").setValue("1")
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatTableViewCell")! as! ChatTableViewCell
        let info = self.list[indexPath.row]
        
        if self.auth.currentUser!.uid == info.senderUid {
            cell.messageType(isIncoming: false)
        } else {
            cell.messageType(isIncoming: true)
        }
        
        cell.label.text = info.message
        return cell
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.view.endEditing(true)
    }
    
    
   @objc func keyboardWillShow(notification:Notification) {
   // print("keyboard was appeared")
    
    if let userInfo = notification.userInfo {
        if let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
           // print(keyboardSize.height)
            self.viewSendBottomConst.constant = -(keyboardSize.height - self.view.safeAreaInsets.bottom)
            self.tableViewScrollToBottom(animated: true)
        }
      }
    }
    
    @objc func keyboardWillHide(notification:Notification) {
        self.viewSendBottomConst.constant = 0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    

    class ListItem {
    
    var senderUid:String?
    var message:String?
    
        init(senderUid:String, message:String) {
            self.senderUid = senderUid
            self.message = message
        }
    }

}
