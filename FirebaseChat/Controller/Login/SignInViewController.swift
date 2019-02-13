//
//  ViewController.swift
//  FirebaseChat
//
//  Created by Flyco Developer on 30.01.2019.
//  Copyright © 2019 Flyco Global. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {

    @IBOutlet weak var textPassword: UITextField!
    @IBOutlet weak var textMail: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func login(_ sender: Any) {
        
        let mail = textMail.text!
        let password = textPassword.text!
        
        if mail.isEmpty || password.isEmpty {
            Helper.dialogMessage(message: "Fields can't be empty", vc: self)
            return
        }
        Auth.auth().signIn(withEmail: mail, password: password) { (userData, error) in
            if error != nil {
                Helper.dialogMessage(message: (error?.localizedDescription)!, vc: self)
            } else {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "homeViewController") as! HomeViewController
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
}

