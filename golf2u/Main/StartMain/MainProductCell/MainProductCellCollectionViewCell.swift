//
//  MainProductCellCollectionViewCell.swift
//  golf2u
//
//  Created by 이원영 on 2020/09/23.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class MainProductCellCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var oriprice: UILabel!
    @IBOutlet weak var uiRightPrice: UILabel!
    @IBOutlet weak var uiEventImg: UIImageView!
    
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
        
        
        if let imgurl = data["thumbnail"]{
            img.setImage(with: "\(Single.DE_URLIMGSERVER)\(imgurl)")
        }
        name.text = data["name"];
        
        if data["event_active"] == "1"{
            uiEventImg.isHidden = false;
            oriprice.text = "\(data["box_price"]!.DecimalWon())C"
        }else{
            uiEventImg.isHidden = true;
            oriprice.text = "원".localized(txt: "\(data["box_price"]!.DecimalWon())")
        }
        
        uiRightPrice.text = "원".localized(txt: "\(data["price"]!.DecimalWon())")
        uiRightPrice.TextCancelLine(partstr: "원".localized(txt: "\(data["price"]!.DecimalWon())"))
    }
}
