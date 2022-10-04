//
//  BoxInvenCell.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/04.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class BoxInvenCell: UITableViewCell {
    @IBOutlet weak var uiBoxImg: UIImageView!
    @IBOutlet weak var uiBoxName: UILabel!
    @IBOutlet weak var uiPayLabel: UILabel!
    @IBOutlet weak var uiPayCancelBtn: UIButton!
    @IBOutlet weak var uiUseDayLabel: UILabel!
    @IBOutlet weak var uiPdListBtnView: UIView!
    @IBOutlet weak var uiBoxOpenBtnView: UIView!
    @IBOutlet weak var uiBoxGiftBtnView: UIView!
    @IBOutlet weak var uiDateLabel: UILabel!
    @IBOutlet weak var uipdlistlb: UILabel!
    @IBOutlet weak var uiboxopenlb: UILabel!
    @IBOutlet weak var uiboxgiftlb: UILabel!
    
    private var m_data = [String:String]();
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        uiBoxImg.layer.cornerRadius = uiBoxImg.frame.height/2
        
        uiPdListBtnView.layer.cornerRadius = 5.0
        uiPdListBtnView.backgroundColor = .clear
        uiPdListBtnView.layer.borderWidth = 1
        uiPdListBtnView.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        uiBoxOpenBtnView.layer.cornerRadius = 5.0
        uiBoxOpenBtnView.backgroundColor = .clear
        uiBoxOpenBtnView.layer.borderWidth = 1
        uiBoxOpenBtnView.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        uiBoxGiftBtnView.layer.cornerRadius = 5.0
        uiBoxGiftBtnView.backgroundColor = .clear
        uiBoxGiftBtnView.layer.borderWidth = 1
        uiBoxGiftBtnView.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        uipdlistlb.text = "상품리스트".localized
        uiboxopenlb.text = "박스열기".localized
        uiboxgiftlb.text = "박스선물".localized
        uiPayCancelBtn.setTitle("결제취소".localized, for: .normal)
        
        let attributedString = NSAttributedString(string: NSLocalizedString("결제취소".localized, comment: ""), attributes:[
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 10.0),
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x999999),
            NSAttributedString.Key.underlineStyle:1.0
        ])
        uiPayCancelBtn.setAttributedTitle(attributedString, for: .normal)
    }

    func setData(data : [String : String], row : Int){
        m_data = data;
        uiPdListBtnView.tag = row;
        uiBoxOpenBtnView.tag = row;
        uiBoxGiftBtnView.tag = row;
        uiPayCancelBtn.tag = row;
        
        if data["type"] == "1" {
            uiBoxImg.image = UIImage(named:"randombox");
            uiBoxName.text = "랜덤박스".localized
        }else{
            uiBoxImg.image = UIImage(named:"inven_eventbox");
            uiBoxName.text = "이벤트박스".localized
        }
        if data["is_present"] == "1" {
            uiBoxGiftBtnView.isHidden = true;
        }else{
            uiBoxGiftBtnView.isHidden = false;
        }
        uiPayLabel.text = data["box_explain"];
        uiUseDayLabel.text = "일 남음".localized(txt: "\(data["cancel_remain_day"]!)");
        uiDateLabel.text = data["paymented_at"]
        
        if data["is_present"] == "0" {
            var fm_sDayToString = "-1";
            if data["cancel_remain_day"] != "" {
                fm_sDayToString = data["cancel_remain_day"] ?? "0";
            }
            let fm_daytoInt : Int = Int(fm_sDayToString) ?? 0
            if fm_daytoInt < 0 {
                uiPayCancelBtn.isHidden = true;
                uiUseDayLabel.isHidden = true;
            }else{
                uiPayCancelBtn.isHidden = false;
                uiUseDayLabel.isHidden = false;
            }
        }else{
            uiPayCancelBtn.isHidden = true;
            uiUseDayLabel.isHidden = true;
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        contentView.layer.addBorder([.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        if selected {
            contentView.backgroundColor = UIColor.white
            
        } else {
            contentView.backgroundColor = UIColor.white
        }
    }
    
   
}
