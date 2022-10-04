//
//  DeliveryManageCell.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/16.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwipeCellKit

class DeliveryManageCell: SwipeCollectionViewCell {
    
    public var ClickEvenHandler: ((Int, [String:String])->())?//클로저
    @IBOutlet weak var uicheckimg: UIImageView!
    @IBOutlet weak var uititle: UILabel!
    @IBOutlet weak var uiAddr: UILabel!
    private var m_Data = [String:String]()
    @IBOutlet weak var uiModifyBtn: UIButton!
    @IBOutlet weak var uiSelBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.layer.addBorder([.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
        uiModifyBtn.setTitle("수정".localized, for: .normal)
        uiSelBtn.setTitle("선택".localized, for: .normal)
        
        uiModifyBtn.layer.cornerRadius = 8.0;
        uiModifyBtn.layer.borderWidth = 1.0
        uiModifyBtn.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        uiSelBtn.layer.cornerRadius = 8.0;
        uiSelBtn.layer.borderWidth = 1.0
        uiSelBtn.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
    }
    func setVisibleSelBtn(type : Bool){
        uiSelBtn.isHidden = type
    }
    func setData(data : [String:String], row : Int){
        m_Data = data;
        if data["is_default"] == "1" {
            uicheckimg.isHidden = false;
            uititle.text = " 기본주소".localized(txt: "\(data["title"] ?? "")");
            uititle.TextPartColor(partstr: "기본주소".localized, Color: UIColor(rgb: 0x00BA87))
            uititle.frame = CGRect(x: 45, y: (uititle.frame.minY), width: uititle.frame.width, height: uititle.frame.height)
        }else{
            uicheckimg.isHidden = true;
            uititle.text = "\(data["title"] ?? "")";
            uititle.frame = CGRect(x: 20, y: (uititle.frame.minY), width: uititle.frame.width, height: uititle.frame.height)
            
        }
        
        uiAddr.text =
            """
            \(data["name"] ?? "") \(data["phone_number"] ?? "")
            [\(data["zipcode"] ?? "")] \(data["address1"] ?? "")
            \(data["address2"] ?? "")
            """
    }
    @IBAction func onDelBtn(_ sender: Any) {
        ClickEvenHandler?(1, m_Data)
    }
    @IBAction func onModifyBtn(_ sender: Any) {
        ClickEvenHandler?(2, m_Data)
    }
    @IBAction func onSelBtn(_ sender: Any) {
        ClickEvenHandler?(3, m_Data)
    }
}
