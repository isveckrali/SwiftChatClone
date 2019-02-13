//
//  SignUpViewController.swift
//  FirebaseChat
//
//  Created by Flyco Developer on 30.01.2019.
//  Copyright © 2019 Flyco Global. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var textPasswordRepetition: UITextField!
    @IBOutlet weak var textPassword: UITextField!
    @IBOutlet weak var textMail: UITextField!
    @IBOutlet weak var textName: UITextField!
    @IBOutlet weak var imagePhoto: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        let action = UITapGestureRecognizer(target: self, action: #selector(onpenGalery))
        imagePhoto.addGestureRecognizer(action)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func Close(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func register(_ sender: Any) {
        
        let name = textName.text!
        let mail = textMail.text!
        let password = textPassword.text!
        let passwordRepetition = textPasswordRepetition.text!
        
        if name.isEmpty || mail.isEmpty || password.isEmpty || password.isEmpty || passwordRepetition.isEmpty {
            Helper.dialogMessage(message: "Fields can't be empty", vc: self)
            return
        }
        
        if password != passwordRepetition {
            Helper.dialogMessage(message: "Passwords don't match", vc: self)
            return
        }
        
        let databaseRef = Database.database().reference()
        let storageRef = Storage.storage().reference()
        let auth = Auth.auth()
        
        auth.createUser(withEmail: mail, password: password) { (userData, error) in
            if error != nil {
                Helper.dialogMessage(message: (error?.localizedDescription)!, vc: self)
            } else {
                let imageName = UUID().uuidString + ".jpg"
                let path = "image"
                let imageRef = storageRef.child(path).child(imageName)
                imageRef.putData((self.imagePhoto.image?.jpegData(compressionQuality: 0.5))!, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        Helper.dialogMessage(message: (error?.localizedDescription)!, vc: self)
                    } else {
                        imageRef.downloadURL(completion: { (url, error) in
                            if error != nil {
                                Helper.dialogMessage(message: (error?.localizedDescription)!, vc: self)
                            } else {
                                // print(url?.absoluteString)
                                 let userData = ["name":name, "mail":mail, "uid":auth.currentUser?.uid, "photoUrl":url?.absoluteString]
                                 databaseRef.child(Child.USERS).childByAutoId().setValue(userData, withCompletionBlock: { (error, databaseReference) in
                                 let vc = self.storyboard?.instantiateViewController(withIdentifier: "homeViewController") as! HomeViewController
                                    self.present(vc, animated: true, completion: nil)
                                })
                            }
                        })
                    }
                    
                })
                
            }
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imagePhoto.image = image
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func onpenGalery() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
        
    }
}
