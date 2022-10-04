//
//  MemberListCell.swift
//  golf2u
//
//  Created by 이원영 on 2020/10/16.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class MemberListCell: UICollectionViewCell {
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var uimarketLabel: UILabel!
    @IBOutlet weak var uiDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setData(data : [String:String]){
        
        img.layer.cornerRadius = 8.0
        img.layer.borderWidth = 1.0
        img.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        img.layer.masksToBounds = true
        
        //self.layer.shadowColor = UIColor.black.cgColor
        //self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        //self.layer.shadowRadius = 2.0
        //self.layer.shadowOpacity = 0.5
        
        if let imgurl = data["profile_image_url"]{
            img.setImage(with: "\(Single.DE_URLIMGSERVER)\(imgurl)")
        }
        name.text = data["name"];
        uimarketLabel.text = "마켓등록".localized(txt: "\(data["reg_count"]!.DecimalWon())");
        
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "KST") as TimeZone?
        let date:Date = dateFormatter.date(from: data["last_reged_at"] ?? dateFormatter.string(from: now))!
        let calcday = date.offset(from: date, now: now)
        uiDateLabel.text = "최근등록".localized(txt: "\(calcday)");
    }
}
