//
//  FriendGiftProCell.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/10.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class FriendGiftProCell: UICollectionViewCell {
    @IBOutlet weak var uiProImg: UIImageView!
    @IBOutlet weak var uiNAme: UILabel!
    @IBOutlet weak var uiPrice: UILabel!
    @IBOutlet weak var uiGager: UILabel!
    @IBOutlet weak var uiDate: UILabel!
    @IBOutlet weak var uiChoisImg: UIImageView!
    @IBOutlet weak var uiEventImg: UIImageView!
    private var m_isSel = false;
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 8.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        self.layer.masksToBounds = true
    }
    func setData(data : [String:String], row:Int){
        uiProImg.image = nil;
        if let imgurl = data["thumbnail"]{
            if imgurl != ""{
                uiProImg.setImage(with: "\(Single.DE_URLIMGSERVER)\(imgurl)")
            }
        }
        uiNAme.text = data["name"]
        uiPrice.text = "정가 | 원".localized(txt: "\(data["price"]!.DecimalWon())");
        uiGager.text = "배송게이지 | ".localized(txt: "\(data["delivery_gauge"]!)")
        uiDate.text = "보관만료일 | ".localized(txt: "\(data["expired_at"]!)")
        
        if data["box_type"] == "2"{
            uiEventImg.isHidden = false;
        }else{
            uiEventImg.isHidden = true;
        }
        
        
    }
    func setChoise(type : Bool){
        m_isSel = type
        if m_isSel {
            uiChoisImg.isHidden = false;
            self.layer.cornerRadius = 8.0
            self.layer.borderWidth = 1.0
            self.layer.borderColor = UIColor(rgb: 0x00BA87).cgColor
        }else{
            uiChoisImg.isHidden = true;
            self.layer.cornerRadius = 8.0
            self.layer.borderWidth = 1.0
            self.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        }
    }
}
