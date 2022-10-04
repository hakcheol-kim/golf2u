//
//  WeeklyRankListCell.swift
//  golf2u
//
//  Created by 이원영 on 2020/10/23.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class WeeklyRankListCell: UICollectionViewCell {
    @IBOutlet weak var uiMadalImg: UIImageView!
    @IBOutlet weak var uiUProfileImg: UIImageView!
    @IBOutlet weak var uiUserNameLable: UILabel!
    @IBOutlet weak var uiRankLabel: UILabel!
    @IBOutlet weak var uirankLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        uiUProfileImg.layer.cornerRadius = uiUProfileImg.frame.height/2
    }
    func setData(data : [String:String], row : Int){
        uiUProfileImg.tag = row
        uiMadalImg.isHidden = true;
        uirankLabel.isHidden = true;
        uiRankLabel.font = UIFont(name:"HelveticaNeue", size: 16.0)
        uiRankLabel.textColor = UIColor(rgb: 0x333333)
        if row == 0 {
            uiMadalImg.isHidden = false;
            uiMadalImg.image = UIImage(named: "comty_first")
            uiRankLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 20.0)
            uiRankLabel.textColor = UIColor(rgb: 0x00BA87)
        }else if row == 1 {
            uiMadalImg.isHidden = false;
            uiMadalImg.image = UIImage(named: "comty_second")
        }else if row == 2 {
            uiMadalImg.isHidden = false;
            uiMadalImg.image = UIImage(named: "comty_third")
        }else{
            uirankLabel.isHidden = false;
            uirankLabel.text = "\(row + 1)";
        }
        if let imgurl = data["profile_image_url"]{
            uiUProfileImg.setImage(with: "\(Single.DE_URLIMGSERVER)\(imgurl)")
        }
        uiUserNameLable.text = data["name"];
        uiRankLabel.text = data["score"]?.DecimalWon();
    }
}
