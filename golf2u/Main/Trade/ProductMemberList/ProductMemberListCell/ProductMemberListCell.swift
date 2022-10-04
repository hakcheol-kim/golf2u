//
//  ProductMemberListCell.swift
//  golf2u
//
//  Created by 이원영 on 2020/10/19.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class ProductMemberListCell: UICollectionViewCell {

    @IBOutlet weak var uiContent: UITextView!
    @IBOutlet weak var uiUPImg: UIImageView!
    @IBOutlet weak var uiUName: UILabel!
    @IBOutlet weak var uiDate: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        uiContent.layer.cornerRadius = 8.0
//        uiContent.layer.borderWidth = 1.0
//        uiContent.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        self.layer.cornerRadius = 8.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        uiUPImg.layer.cornerRadius = uiUPImg.frame.height/2
        
        uiContent.isUserInteractionEnabled = false;
    }
    func setData(data : [String:String]){
        
        uiContent.text = data["comment"]
        
        if let imgurl = data["profile_image_url"]{
            uiUPImg.setImage(with: "\(Single.DE_URLIMGSERVER)\(imgurl)")
        }
        uiUName.text = data["name"];
        
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "KST") as TimeZone?
        let date:Date = dateFormatter.date(from: data["last_reged_at"]!)!
        let calcday = date.offset(from: date, now: now)
        uiDate.text = calcday
    }
}
