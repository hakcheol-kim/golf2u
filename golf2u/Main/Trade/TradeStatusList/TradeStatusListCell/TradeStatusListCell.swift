//
//  TradeStatusListCell.swift
//  golf2u
//
//  Created by 이원영 on 2020/10/20.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class TradeStatusListCell: UITableViewCell {
    @IBOutlet weak var uiUserPImg: UIImageView!
    @IBOutlet weak var uiStatusLabel: UILabel!
    @IBOutlet weak var uiDataLabel: UILabel!
    @IBOutlet weak var uiIconImg: UIImageView!
    @IBOutlet weak var uiIconIngImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        uiUserPImg.layer.cornerRadius = uiUserPImg.frame.height/2
    }
    func setData(data : [String : String], row : Int, viewtype : Int){
        uiUserPImg.image = nil;
        if let imgurl = data["profile_image_url"]{
            if imgurl != ""{
                uiUserPImg.setImage(with: "\(Single.DE_URLIMGSERVER)\(imgurl)")
            }
        }
        
        if data["direction"] == "0" {
            if data["is_retry"] == "0" {
                uiStatusLabel.text = "님에게 제안한 트레이드".localized(txt: "\(data["name"]!)");
                //uiStatusLabel.TextPartColor(partstr: "님에게".localized, Color: UIColor(rgb: 0x00BA87))
            }else if data["is_retry"] == "1" {
                uiStatusLabel.text = "님에게 제안한 흥정".localized(txt: "\(data["name"]!)");
                //uiStatusLabel.TextPartColor(partstr: "님에게", Color: UIColor(rgb: 0x00BA87))
            }
            
        }else if data["direction"] == "1" {
            if data["is_retry"] == "0" {
                uiStatusLabel.text = "님이 제안한 트레이드".localized(txt: "\(data["name"]!)");
                //uiStatusLabel.TextPartColor(partstr: "님이", Color: UIColor(rgb: 0x00BA87))
            }else if data["is_retry"] == "1" {
                uiStatusLabel.text = "님이 제안한 흥정".localized(txt: "\(data["name"]!)");
                //uiStatusLabel.TextPartColor(partstr: "님이", Color: UIColor(rgb: 0x00BA87))
            }
            
        }
        
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "KST") as TimeZone?
        let date:Date = dateFormatter.date(from: data["created_at"]!)!
        let calcday = date.offset(from: date, now: now)
        self.uiDataLabel.text = calcday;
        
        if viewtype == 0 {
            uiIconImg.isHidden = true;
            //uiIconIngImg.isHidden = false;
            if data["icon_state"] == "0" {
                uiIconIngImg.image = UIImage(named:"trade_01")
            }else if data["icon_state"] == "1" {
                uiIconIngImg.image = UIImage(named:"trade_02")
            }else if data["icon_state"] == "2" {
                uiIconIngImg.image = UIImage(named:"trade_03")
            }else if data["icon_state"] == "3" {
                uiIconIngImg.image = UIImage(named:"trade_04")
            }
        }else if viewtype == 1 {
            uiIconImg.isHidden = false;
            uiIconIngImg.isHidden = true;
            if data["state"] == "1" {
                //uiIconImg.image = UIImage(named:"trade_01")
            }else if data["state"] == "2" {
                uiIconImg.image = UIImage(named:"tradeicon_state_03")
            }else if data["state"] == "3" {
                uiIconImg.image = UIImage(named:"tradeicon_state_05")
            }else if data["state"] == "4" {
                //uiIconImg.image = UIImage(named:"trade_01")
            }else if data["state"] == "5" {
                uiIconImg.image = UIImage(named:"tradeicon_state_01")
            }else if data["state"] == "6" {
                uiIconImg.image = UIImage(named:"tradeicon_state_04")
            }
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        contentView.layer.addBorder([.all], color: UIColor(rgb: 0xe4e4e4), width: 0.0)
        if selected {
            contentView.backgroundColor = UIColor.white
            
        } else {
            contentView.backgroundColor = UIColor.white
        }
    }
    
}
