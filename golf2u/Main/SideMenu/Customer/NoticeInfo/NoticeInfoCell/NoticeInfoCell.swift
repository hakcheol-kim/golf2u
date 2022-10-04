//
//  NoticeInfoCell.swift
//  golf2u
//
//  Created by 이원영 on 2020/12/03.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class NoticeInfoCell: UICollectionViewCell {
    @IBOutlet weak var uiTitle: UILabel!
    @IBOutlet weak var uiDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //self.layer.addBorder([.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
    }
    func setData(data : [String:String], row:Int){
        uiTitle.text = data["title"];
        uiDate.text = data["created_at"];
    }
    
}
