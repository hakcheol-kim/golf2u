//
//  DeliveryInfoDtailCell.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/24.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class DeliveryInfoDtailCell: UICollectionViewCell {
    @IBOutlet weak var uiProImg: UIImageView!
    @IBOutlet weak var uiName: UILabel!
    @IBOutlet weak var uiPrice: UILabel!
    @IBOutlet weak var uiDelPrice: UILabel!
    @IBOutlet weak var uiPayInfo: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.layer.addBorder([.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
        uiProImg.layer.cornerRadius = 8.0
        uiProImg.layer.borderWidth = 1.0
        uiProImg.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
    }
    func setData(data : [String:String], row:Int){
        uiProImg.image = nil;
        if let imgurl = data["thumbnail"]{
            if imgurl != ""{
                uiProImg.setImage(with: "\(Single.DE_URLIMGSERVER)\(imgurl)")
            }
        }
        
        uiName.text = data["name"]
        let fm_sLine1 = " | 수량".localized(txt: "\((data["price"] ?? "0").DecimalWon())")
        let fm_sLine2 = " 개".localized(txt: "\((data["prd_cnt"] ?? "0"))")
        uiPrice.text = "\(fm_sLine1)\(fm_sLine2)"
        uiDelPrice.text = data["pay_txt"]
        uiPayInfo.text = data["method_txt"]
    }
}
