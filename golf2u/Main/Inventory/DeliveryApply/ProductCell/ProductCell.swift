//
//  ProductCell.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/12.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class ProductCell: UICollectionViewCell {
    weak var m_tClickEvent: DeliveryApplyClickCellBtnDelegate? = nil;
    
    @IBOutlet weak var uiProImg: UIImageView!
    @IBOutlet weak var uiName: UILabel!
    @IBOutlet weak var uiPrice: UILabel!
    @IBOutlet weak var uiGage: UILabel!
    private var m_Data = [String : String]()
    @IBOutlet weak var uiDelBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        uiProImg.layer.cornerRadius = 8.0;
        uiProImg.layer.borderWidth = 1.0
        uiProImg.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
    }
    func setData(data : [String : String], row : Int){
        m_Data = data;
        m_Data["cellrow"] = "\(row)"
        uiProImg.image = nil;
        if let imgurl = data["thumbnail"]{
            if imgurl != ""{
                uiProImg.setImage(with: "\(Single.DE_URLIMGSERVER)\(imgurl)")
            }
        }
        uiName.text = data["name"];
        uiPrice.text = "정가 원".localized(txt: "\(data["price"]!.DecimalWon())");
        uiGage.text = "배송게이지 ".localized(txt: "\(data["delivery_gauge"]!)");
        
        
    }
    func setHiddenDelBtn(type : Bool){
        uiDelBtn.isHidden = type;
    }
    @IBAction func onDelBtn(_ sender: Any) {
        m_tClickEvent?.ClickEvent(celltype : 1, type: 4, data: m_Data)
    }
}
