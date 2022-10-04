//
//  Box_RandomPage.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/20.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class Box_RandomPage: UIView {
    private let xibName = "Box_RandomPage"
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
        
        uiMsgBoxLabel.text = "다양한 상품을\n10,000원에 만나보세요!".localized;
        uiListBtn.setTitle("랜덤박스 상품보기".localized, for: .normal)
        
        uiListBtn.layer.cornerRadius = uiListBtn.frame.height/2
    }
    func setData(data : [String : String]){
//        uiMsgBoxLabel.TextPartBold(partstr: "10,000원".localized, fontSize: 32)
    }
    @IBAction func onBoxList(_ sender: Any) {
        m_tClickEvent?.ClickEvent(type: 1, data: [:])
    }
    
}
