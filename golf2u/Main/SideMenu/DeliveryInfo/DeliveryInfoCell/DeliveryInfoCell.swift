//
//  DeliveryInfoCell.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/24.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class DeliveryInfoCell: UICollectionViewCell {
    weak var m_tClickEvent: DeliveryInfoDelegate? = nil;
    @IBOutlet weak var uiDateStatus: UILabel!
    @IBOutlet weak var uiComBtn: UIButton!
    @IBOutlet weak var uiDelInfo: UIButton!
    @IBOutlet weak var uiProImg: UIImageView!
    @IBOutlet weak var uiName: UILabel!
    @IBOutlet weak var uiPrice: UILabel!
    @IBOutlet weak var uiDelPrice: UILabel!
    @IBOutlet weak var uiPayInfo: UILabel!
    
    private var m_Data = [String : String]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        uiComBtn.setTitle("후기입력".localized, for: .normal)
        uiDelInfo.setTitle("상세정보".localized, for: .normal)
        
        self.layer.addBorder([.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
        uiProImg.layer.cornerRadius = 8.0
        uiProImg.layer.borderWidth = 1.0
        uiProImg.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        uiComBtn.layer.cornerRadius = 8.0
        uiComBtn.layer.borderWidth = 1.0
        uiComBtn.layer.borderColor = UIColor(rgb: 0x999999).cgColor
        
        uiDelInfo.layer.cornerRadius = 8.0
        uiDelInfo.layer.borderWidth = 1.0
        uiDelInfo.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
    }
    func setData(data : [String:String], row:Int){
        m_Data = data;
        var delistatustxt = "";
        if data["state"] == "3" {
            delistatustxt = "입금대기".localized;
        }else if data["state"] == "4" {
            delistatustxt = "배송요청".localized;
        }else if data["state"] == "10" {
            delistatustxt = "배송중".localized;
        }else if data["state"] == "20" {
            delistatustxt = "배송취소".localized;
        }else if data["state"] == "100" {
            delistatustxt = "배송완료".localized;
        }
        uiDateStatus.text = "\(data["created_at_dt"] ?? "") | \(delistatustxt)";
        uiDateStatus.TextPartColor(partstr: delistatustxt, Color: UIColor(rgb: 0x00BA87))
        
        uiProImg.image = nil;
        if let imgurl = data["thumbnail"]{
            if imgurl != ""{
                uiProImg.setImage(with: "\(Single.DE_URLIMGSERVER)\(imgurl)")
            }
        }
        
        uiName.text = data["name"]
        let fm_sLine1 = " | 수량".localized(txt: "\((data["price"] ?? "0").DecimalWon())")
        let fm_sLine2 = " 개".localized(txt: "\((data["prd_cnt"] ?? "0"))")
        uiPrice.text = "정가 ".localized(txt: "\(fm_sLine1)\(fm_sLine2)")
        uiDelPrice.text = "배송비 ".localized(txt: "\(data["pay_txt"] ?? "")")
        uiPayInfo.text = "결제수단 ".localized(txt: "\(data["method_txt"] ?? "")")
        
        uiComBtn.isHidden = false
        if data["state"] == "3" || data["state"] == "4" {
            uiComBtn.setTitle("배송취소".localized, for: .normal)
        }else if data["state"] == "100" {
            uiComBtn.setTitle("후기입력".localized, for: .normal)
        }else{
            uiComBtn.isHidden = true
        }
    }
    @IBAction func onComBtn(_ sender: Any) {
        if m_Data["state"] == "3" || m_Data["state"] == "4" {
            m_tClickEvent?.ClickEvent(type: 1, data: m_Data)
        }else if m_Data["state"] == "100" {
            m_tClickEvent?.ClickEvent(type: 2, data: m_Data)
        }
        
    }
    @IBAction func onInfoBtn(_ sender: Any) {
        m_tClickEvent?.ClickEvent(type: 3, data: m_Data)
    }
    
}
