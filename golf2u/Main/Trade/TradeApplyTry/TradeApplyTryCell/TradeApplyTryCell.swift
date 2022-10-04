//
//  TradeApplyTryCell.swift
//  golf2u
//
//  Created by 이원영 on 2020/10/19.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class TradeApplyTryCell: UICollectionViewCell {

    @IBOutlet weak var uiPImg: UIImageView!
    @IBOutlet weak var uiPName: UILabel!
    @IBOutlet weak var uiPPrice: UILabel!
    @IBOutlet weak var uiPGage: UILabel!
    @IBOutlet weak var uiPDate: UILabel!
    @IBOutlet weak var uiLimitDateView: UIView!
    @IBOutlet weak var uiLimitDateLb: UILabel!
    @IBOutlet weak var uiEventImg: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //uiPImg.layer.cornerRadius = 8.0
        uiPImg.layer.borderWidth = 1.0
        uiPImg.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        self.layer.cornerRadius = 8.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        uiLimitDateLb.text = "기간연장 제한".localized;
    }
    func setData(data : [String:String]){
        
       if let imgurl = data["thumbnail"]{
        uiPImg.setImage(with: "\(Single.DE_URLIMGSERVER)\(imgurl)")
       }
        uiPName.text = data["name"];
        uiPPrice.text = "정가 | \(data["price"]!.DecimalWon())";
        uiPGage.text = "배송게이지 | \(data["delivery_gauge"] ?? "")";
        uiPDate.text = "보관만료일 | \(data["expired_at"] ?? "")";
        
        if data["is_refresh_on_trade"] == "0" {
            uiLimitDateView.isHidden = false;
        }else{
            uiLimitDateView.isHidden = true;
        }
        if data["box_type"] == "2" {
            uiEventImg.isHidden = false;
        }else{
            uiEventImg.isHidden = true;
        }
    }
}
