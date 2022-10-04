//
//  EventInfoCell.swift
//  golf2u
//
//  Created by 이원영 on 2020/12/03.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class EventInfoCell: UICollectionViewCell {
    
    @IBOutlet weak var uiIMg: UIImageView!
    @IBOutlet weak var uiDateView: UIView!
    @IBOutlet weak var uiDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.layer.cornerRadius = 10.0
        
        uiIMg.layer.cornerRadius = 10.0
        uiIMg.backgroundColor = .clear
        uiIMg.layer.borderWidth = 1
        uiIMg.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        uiDateView.layer.cornerRadius = uiDateView.bounds.height / 2
    }
    func setData(data : [String : String], row : Int){
        uiIMg.image = nil;
        if let imgurl = data["image_url"]{
            if imgurl != ""{
                uiIMg.setImage(with: "\(Single.DE_URLIMGSERVER)\(imgurl)")
            }
        }
        uiDate.text = data["period_txt"]
        let fm_sAvailable = data["available"] ?? "0"
        
        if fm_sAvailable == "0" {
            uiIMg.alpha = 0.3;
            uiDateView.isHidden = true;
        }else{
            uiIMg.alpha = 1.0;
            uiDateView.isHidden = false;
        }
    }
}
