//
//  BoxOpenStep2Cell.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/06.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class BoxOpenStep2Cell: UICollectionViewCell {
    @IBOutlet weak var uiProImg: UIImageView!
    @IBOutlet weak var uiShareBtn: UIButton!
    @IBOutlet weak var uiProName: UILabel!
    @IBOutlet weak var uiPrice: UILabel!
    @IBOutlet weak var uiGage: UILabel!
    @IBOutlet weak var uiDate: UILabel!
    @IBOutlet weak var uiContentsView: UIView!
    @IBOutlet weak var uiMd: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //self.uiContentsView.layer.addBorder([.top,], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        self.layer.cornerRadius = 8.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        self.layer.masksToBounds = true
    }
    func setData(data : [String:String], row : Int){
        uiShareBtn.tag = row
        if let imgurl = data["thumbnail"]{
            uiProImg.setImage(with: "\(Single.DE_URLIMGSERVER)\(imgurl)")
        }
        uiProName.text = data["name"]
        uiPrice.text = "정가 | 원".localized(txt: "\(data["price"]?.DecimalWon() ?? "0")")
        uiGage.text = "배송게이지 | ".localized(txt: "\(data["delivery_gauge"] ?? "0")")
        uiDate.text = "보관만료일 | ".localized(txt: "\(data["expired_at"] ?? "0")")
        uiMd.text = data["md_comment"];
    }
}
