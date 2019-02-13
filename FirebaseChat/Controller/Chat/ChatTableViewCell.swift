//
//  ChatTableViewCell.swift
//  FirebaseChat
//
//  Created by Flyco Developer on 30.01.2019.
//  Copyright © 2019 Flyco Global. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    let label = UILabel()
    let viewRow = UIView()
    
    var leadingConst:NSLayoutConstraint!
    var trailingConst:NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(viewRow)
        viewRow.layer.cornerRadius = 16
        viewRow.layer.masksToBounds = true
        viewRow.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(label)
        label.numberOfLines = 0
        label.textColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let const = [
            label.topAnchor.constraint(equalTo: topAnchor, constant: CGFloat(32)),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: CGFloat(-32)),
            label.widthAnchor.constraint(lessThanOrEqualToConstant: CGFloat(256)),
            viewRow.topAnchor.constraint(equalTo: label.topAnchor, constant: CGFloat(-16)),
            viewRow.leadingAnchor.constraint(equalTo: label.leadingAnchor, constant: CGFloat(-16)),
            viewRow.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: CGFloat(16)),
            viewRow.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: CGFloat(16))
        ]
        
        NSLayoutConstraint.activate(const)
        
        leadingConst = label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32)
        leadingConst.isActive = true
        
        trailingConst = label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
        trailingConst.isActive = false
        
    }
    
    func messageType(isIncoming:Bool) {
        if isIncoming {
            viewRow.backgroundColor = UIColor.orange
            leadingConst.isActive = true
            trailingConst.isActive = false
        } else {
            viewRow.backgroundColor = UIColor.blue
            leadingConst.isActive = false
            trailingConst.isActive = true
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
