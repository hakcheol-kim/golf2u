//
//  NewsRoomCell.swift
//  golf2u
//
//  Created by 이원영 on 2020/10/22.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class NewsRoomCell: UICollectionViewCell {
    @IBOutlet weak var uiProIMg: UIImageView!
    @IBOutlet weak var uiUserImg: UIImageView!
    @IBOutlet weak var uiUserLabel: UILabel!
    @IBOutlet weak var uiProNameLabel: UILabel!
    @IBOutlet weak var uiPriceLabel: UILabel!
    @IBOutlet weak var uiCommCnt: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        uiUserImg.layer.cornerRadius = uiUserImg.frame.height/2
        
        uiProIMg.layer.cornerRadius = 8.0
        uiProIMg.layer.borderWidth = 1.0
        uiProIMg.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiProIMg.layer.masksToBounds = true
        
        self.layer.addBorder([.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
    }
    
    func setData(data : [String:String], row : Int){
        uiProIMg.tag = row
        uiCommCnt.tag = row
        uiUserImg.tag = row
        if let imgurl = data["thumbnail"]{
            uiProIMg.setImage(with: "\(Single.DE_URLIMGSERVER)\(imgurl)")
        }
        if let imgurl = data["profile_image_url"]{
            uiUserImg.setImage(with: "\(Single.DE_URLIMGSERVER)\(imgurl)")
        }
        uiUserLabel.text = "님 축하해요!".localized(txt: "\(data["name"]!)");
        uiUserLabel.TextPartColor(partstr: data["name"]!, Color: UIColor(rgb: 0x00BA87))
        
        uiProNameLabel.text = data["product_name"];
        
        uiPriceLabel.text = "정가 | 원".localized(txt: "\(data["price"]!.DecimalWon())");
        
        uiCommCnt.text = "댓글()".localized(txt: "\(data["comment_cnt"]!.DecimalWon())");
        
    }
    
    

}
