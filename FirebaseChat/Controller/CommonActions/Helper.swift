//
//  Helper.swift
//  FirebaseChat
//
//  Created by Flyco Developer on 30.01.2019.
//  Copyright © 2019 Flyco Global. All rights reserved.
//

import Foundation
import UIKit

class Helper {
    
    static func dialogMessage(message:String, vc:UIViewController) {
        
        let alert = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
        
    }
}
