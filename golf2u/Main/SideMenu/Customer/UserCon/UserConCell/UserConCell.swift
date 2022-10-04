//
//  UserConCell.swift
//  golf2u
//
//  Created by 이원영 on 2020/12/03.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class UserConCell: UICollectionViewCell {

    @IBOutlet weak var uiTitle: UILabel!
    @IBOutlet weak var uiDate: UILabel!
    @IBOutlet weak var uiAns: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.layer.addBorder([.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
    }
    func setData(data : [String:String], row:Int){
        uiTitle.text = "[\(data["qna_category_title"] ?? "")]\(data["title"] ?? "")";
        uiDate.text = data["created_at"] ?? "";
        if data["answer_state"] == "0" {
            uiAns.text = "미답변".localized;
            uiAns.textColor = UIColor(rgb: 0x999999)
        }else{
            uiAns.text = "답변완료".localized;
            uiAns.textColor = UIColor(rgb: 0xe49e4b)
        }
    }

}
