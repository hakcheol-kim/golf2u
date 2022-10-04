//
//  BoxProductListPopCell.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/05.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class BoxProductListPopCell: UICollectionViewCell {
    @IBOutlet weak var img: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.layer.cornerRadius = 8.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        self.layer.masksToBounds = true
    }
    func setData(data : [String:String]){
        if let imgurl = data["thumbnail"]{
            img.setImage(with: "\(Single.DE_URLIMGSERVER)\(imgurl)")
        }
    }

}
