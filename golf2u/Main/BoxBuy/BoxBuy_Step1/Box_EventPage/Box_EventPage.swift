//
//  Box_EventPage.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/20.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class Box_EventPage: UIView {
    private let xibName = "Box_EventPage"
    weak var m_tClickEvent: BoxBuyClickCellBtnDelegate? = nil;
    
    @IBOutlet weak var uiMsgBoxLabel: UILabel!
    
    @IBOutlet weak var uiListBtn: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    private func commonInit(){
        let view = Bundle.main.loadNibNamed(xibName, owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        uiListBtn.setTitle("이벤트박스 상품보기".localized, for: .normal)
        uiListBtn.layer.cornerRadius = uiListBtn.frame.height/2
    }
    func setData(data : [String : String]){
        let textprice = (data["eventbox_price"] ?? "0").DecimalWon()
        //textprice = "클로버".localized(txt: "\(textprice)")
        //uiMsgBoxLabel.text = "COMING SOON"
        uiMsgBoxLabel.text = "다양한 상품을\n에 만나보세요!".localized(txt: "\(textprice)C")
        //uiMsgBoxLabel.TextPartBold(partstr: textprice, fontSize: 14)
    }
    @IBAction func onBoxList(_ sender: Any) {
        m_tClickEvent?.ClickEvent(type: 2, data: [:])
    }
    
}
