//
//  FriendGiftBoxCell.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/10.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class FriendGiftBoxCell: UICollectionViewCell {

    @IBOutlet weak var uiBoxImg: UIImageView!
    @IBOutlet weak var uiBoxName: UILabel!
    @IBOutlet weak var uiPrice: UILabel!
    @IBOutlet weak var uiPay: UILabel!
    @IBOutlet weak var uiDate: UILabel!
    @IBOutlet weak var uiChoisImg: UIImageView!
    private var m_isSel = false;
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.cornerRadius = 8.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        self.layer.masksToBounds = true
    }
    func setData(data : [String:String], row:Int){
        if data["type"] == "1" {
            uiBoxImg.image = UIImage(named: "friend_randombox_B")
            uiBoxName.text = "일반 랜덤박스".localized;
        }else if data["type"] == "2" {
            uiBoxImg.image = UIImage(named: "friend_eventbox_B")
            uiBoxName.text = "이벤트 랜덤박스".localized;
        }
        uiPrice.text = "원".localized(txt: "\(data["price"]!.DecimalWon())");
        uiPay.text = "(\(data["box_explain"]!))"
        uiDate.text = data["paymented_at"];
        
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
