//
//  ProductInvenHCell.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/10.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class ProductInvenHCell: UITableViewCell {
    weak var m_tClickEvent: InventoryMainClickCellBtnDelegate? = nil;

    @IBOutlet weak var uiProImg: UIImageView!
    @IBOutlet weak var uiName: UILabel!
    @IBOutlet weak var uiInfo: UILabel!
    private var m_data = [String:String]();
    private var m_isSl = true;
    @IBOutlet weak var uiSliderBtn: UIImageView!
    @IBOutlet weak var uiLimitDateView: UIView!
    @IBOutlet weak var uiLimitDateLb: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        uiProImg.layer.cornerRadius = 8.0
        uiProImg.layer.borderWidth = 1.0
        uiProImg.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        let tapGestureRecognizer1 = UITapGestureRecognizer(target:self, action: #selector(self.onCellPrdClick(tapGesture:)))
        tapGestureRecognizer1.numberOfTapsRequired = 1
        uiProImg.isUserInteractionEnabled = true
        uiProImg.addGestureRecognizer(tapGestureRecognizer1)
        
        uiLimitDateLb.text = "기간연장 X".localized;
    }
    @objc func onCellPrdClick(tapGesture: UITapGestureRecognizer){
        m_tClickEvent?.ClickEvent(viewtype : 1, type: 1, data: m_data)
    }
    func setSliderBtn(type : Bool){
        m_isSl = type
    }
    func setData(data : [String : String], row : Int, opened : Bool){
        m_data = data;
        
        uiProImg.image = nil;
        if let imgurl = data["thumbnail"]{
            if imgurl != ""{
                uiProImg.setImage(with: "\(Single.DE_URLIMGSERVER)\(imgurl)")
            }
        }
        uiName.text = data["name"];
//        uiName.numberOfLines = 0;
//        uiName.adjustsFontSizeToFitWidth = true;
//        uiName.minimumScaleFactor = 0.5
        //uiName.sizeToFit()
        let fm_sLine1 = "정가 원 | ".localized(txt: "\(data["price"]!.DecimalWon())");
        let fm_sLine2 = "수량 개".localized(txt: "\(data["product_cnt"]!)");
        uiInfo.text = "\(fm_sLine1)\(fm_sLine2)";
        
        if !opened {
            uiSliderBtn.image = UIImage(named: "inven_down");
        }else{
            uiSliderBtn.image = UIImage(named: "up");
        }
        if data["is_refresh_on_trade"] == "0" {
            uiLimitDateView.isHidden = false;
        }else{
            uiLimitDateView.isHidden = true;
        }
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //contentView.layer.addBorder([.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        if selected {
            contentView.backgroundColor = UIColor.white
            
        } else {
            contentView.backgroundColor = UIColor.white
        }
    }
}
