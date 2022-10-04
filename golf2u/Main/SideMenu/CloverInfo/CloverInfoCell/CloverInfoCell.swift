//
//  CloverInfoCell.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/24.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class CloverInfoCell: UICollectionViewCell {

    @IBOutlet weak var uiInfoName: UILabel!
    @IBOutlet weak var uiDate: UILabel!
    @IBOutlet weak var uiPoint: UILabel!
    @IBOutlet weak var uiOriPoint: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.addBorder([.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
    }
    func setData(data : [String:String], row:Int){
        uiInfoName.text = data["comment"];
        uiDate.text = data["created_at"];
        if data["type"] == "0" {
            uiPoint.text = "+\(data["amount"] ?? "0")";
            uiPoint.TextPartColor(partstr: "+\(data["amount"] ?? "0")", Color: UIColor(rgb: 0x333333))
        }else if data["type"] == "1" {
            uiPoint.text = "-\(data["amount"] ?? "0")";
            uiPoint.TextPartColor(partstr: "-\(data["amount"] ?? "0")", Color: UIColor(rgb: 0x00BA87))
        }
        uiOriPoint.text = "잔액 ".localized(txt: " \((data["prev_point"] ?? "0").DecimalWon())");
    }
}
