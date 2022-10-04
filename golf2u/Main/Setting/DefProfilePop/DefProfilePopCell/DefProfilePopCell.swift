//
//  DefProfilePopCell.swift
//  golf2u
//
//  Created by 이원영 on 2020/12/08.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class DefProfilePopCell: UICollectionViewCell {

    @IBOutlet weak var uiImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setImage(url : UIImage){
        uiImg.image = url
    }

}
