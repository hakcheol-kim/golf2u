//
//  PushLIstCell.swift
//  golf2u
//
//  Created by 이원영 on 2020/12/07.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class PushLIstCell: UITableViewCell {
    @IBOutlet weak var uitypeImg: UIImageView!
    @IBOutlet weak var uititle: UILabel!
    @IBOutlet weak var uisub: UILabel!
    @IBOutlet weak var uidate: UILabel!
    private var m_SaveColor : UIColor = UIColor.white;
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        contentView.layer.addBorder([.all], color: UIColor(rgb: 0xe4e4e4), width: 0.0)
        if selected {
            contentView.backgroundColor = UIColor.white
            
        } else {
            contentView.backgroundColor = m_SaveColor
        }
    }
    func setSaveColor(color : UIColor){
        m_SaveColor = color
    }
    func setData(data : [String : String], row : Int, viewtype : Int){
        if data["type"] == "0" {
            uitypeImg.image = UIImage(named: "push_010")
        }else if data["type"] == "1" {
            uitypeImg.image = UIImage(named: "push_01")
        }else if data["type"] == "2" {
            uitypeImg.image = UIImage(named: "push_02")
        }else if data["type"] == "3" {
            uitypeImg.image = UIImage(named: "push_03")
        }else if data["type"] == "4" {
            uitypeImg.image = UIImage(named: "push_04")
        }else if data["type"] == "5" {
            uitypeImg.image = UIImage(named: "push_05")
        }else if data["type"] == "6" {
            uitypeImg.image = UIImage(named: "push_06")
        }else if data["type"] == "7" {
            uitypeImg.image = UIImage(named: "push_07")
        }else if data["type"] == "8" {
            uitypeImg.image = UIImage(named: "push_08")
        }else if data["type"] == "9" {
            uitypeImg.image = UIImage(named: "push_09")
        }
        uititle.text = data["title"]
        uisub.text = data["content"]
        uidate.text = data["created_at"]
    }
}
