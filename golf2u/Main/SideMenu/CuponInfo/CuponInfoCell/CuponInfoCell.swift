//
//  CuponInfoCell.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/25.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class CuponInfoCell: UICollectionViewCell {
    weak var m_tClickEvent: CuponInfoDelegate? = nil;
    @IBOutlet weak var uiLeftImg: UIImageView!
    @IBOutlet weak var uiRightImg: UIImageView!
    @IBOutlet weak var uiBtn: UIButton!
    
    @IBOutlet weak var uiDDay: UIButton!
    @IBOutlet weak var uiTitle: UILabel!
    @IBOutlet weak var uiType: UILabel!
    @IBOutlet weak var uiDate: UILabel!
    @IBOutlet weak var uiBtnTitlelb: UILabel!
    
    private var m_Data = [String:String]();
    private var m_nViewtype = 0;
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        uiDDay.layer.cornerRadius = uiDDay.bounds.height / 2;
        uiDDay.layer.borderWidth = 1.0
        uiDDay.layer.borderColor = UIColor(rgb: 0x00BA87).cgColor
    }
    func setData(data : [String:String], row:Int, viewtype : Int){
        m_Data = data;
        m_nViewtype = viewtype
        
        uiDDay.setTitle("D-\(data["d_day"] ?? "0")", for: .normal)
        uiTitle.text = m_Data["title"];
        uiType.text = "할인쿠폰".localized;
        uiDate.text = "유효기간 | ".localized(txt: "\(m_Data["usage_end_date"] ?? "")");
        
        if m_nViewtype == 0 {
            if m_Data["downloaded"] == "0" {
                uiLeftImg.image = UIImage(named: "coupon_bg_01")
                uiRightImg.image = UIImage(named: "coupon_bg_02")
                uiBtn.setImage(UIImage(named: "coupon_icon_01"), for: .normal)
                uiBtnTitlelb.text = "다운로드".localized
            }else{
                uiLeftImg.image = UIImage(named: "coupon_bg_03")
                uiRightImg.image = UIImage(named: "coupon_bg_04")
                uiBtn.setImage(UIImage(named: "coupon_icon_02"), for: .normal)
                uiBtnTitlelb.text = "획득완료".localized
            }
        }else{
            uiLeftImg.image = UIImage(named: "coupon_bg_01")
            uiRightImg.image = UIImage(named: "coupon_bg_02")
            uiBtn.setImage(UIImage(named: "coupon_icon_03"), for: .normal)
            uiBtnTitlelb.text = "쿠폰사용".localized
        }
    }
    @IBAction func onBtn(_ sender: Any) {
        if m_nViewtype == 0 {
            if m_Data["downloaded"] == "0" {
                m_tClickEvent?.ClickEvent(type: 1, data: m_Data)
            }else{
                m_tClickEvent?.ClickEvent(type: 2, data: m_Data)
            }
        }else{
            m_tClickEvent?.ClickEvent(type: 3, data: m_Data)
        }
    }
}
