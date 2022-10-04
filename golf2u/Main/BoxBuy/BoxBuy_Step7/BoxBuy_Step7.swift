//
//  BoxBuy_Step7.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/20.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class BoxBuy_Step7: UICollectionViewCell {
    weak var m_tClickEvent: BoxBuyClickCellBtnDelegate? = nil;
    @IBOutlet weak var uiCheck: CircleCheckBoxBtn!
    @IBOutlet weak var uilb1: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.addBorder([.top,.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        uilb1.text = "구매 조건 확인 및 결제 진행 동의".localized
    }
    @IBAction func onCheck(_ sender: Any) {
        m_tClickEvent?.ClickEvent(type: 9, data: ["isAgree":(uiCheck.isChecked ? "0" : "1")])
    }
    
}
