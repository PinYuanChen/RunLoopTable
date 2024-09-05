//
//  LogoTableViewCell.swift
//  RunLoopTable
//
//  Created by Champion Chen on 2024/9/5.
//

import UIKit

class LogoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var logoImage: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        logoImage.image = nil
        titleLabel.text = ""
    }
}
