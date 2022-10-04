//
//  DeliveryPdAddCell.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/16.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class DeliveryPdAddCell: UICollectionViewCell {
    @IBOutlet weak var uiPdImg: UIImageView!
    @IBOutlet weak var uiPdName: UILabel!
    @IBOutlet weak var uiPdPrice: UILabel!
    @IBOutlet weak var uiPdGage: UILabel!
    @IBOutlet weak var uiDate: UILabel!
    @IBOutlet weak var uiChoisImg: UIImageView!
    @IBOutlet weak var uiEventImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        uiPdImg.layer.cornerRadius = 8.0
        uiPdImg.layer.borderWidth = 1.0
        uiPdImg.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiPdImg.layer.masksToBounds = true
    }
    func setData(data : [String:String], row : Int){
        if let imgurl = data["thumbnail"]{
            uiPdImg.setImage(with: "\(Single.DE_URLIMGSERVER)\(imgurl)")
        }
        uiPdName.text = data["name"]
        uiPdPrice.text = "정가 원".localized(txt: "\((data["price"] ?? "0").DecimalWon())")
        uiPdGage.text = "배송게이지 | ".localized(txt: "\(data["delivery_gauge"] ?? "0")")
        uiDate.text = "일 남음".localized(txt: "\(data["remain_date"] ?? "0")")
        if data["box_type"] == "2" {
            uiEventImg.isHidden = false;
        }else{
            uiEventImg.isHidden = true;
        }
    }
    func setChoise(type : Bool){
        if type {
            uiChoisImg.isHidden = false;
            self.layer.cornerRadius = 8.0
            self.layer.borderWidth = 1.0
            self.layer.borderColor = UIColor(rgb: 0x00BA87).cgColor
        }else{
            uiChoisImg.isHidden = true;
            self.layer.cornerRadius = 8.0
            self.layer.borderWidth = 0
        }
    }
}
