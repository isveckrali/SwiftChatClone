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
    
    static func imageLoad(imageView:UIImageView, url:String) {
        
        let downloadTask = URLSession.shared.dataTask(with: URL(string: url)!) { (data, urlResponse, error) in
            if error == nil && data != nil {
                let image = UIImage(data: data!)
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }
        }
        downloadTask.resume()
    }
}
