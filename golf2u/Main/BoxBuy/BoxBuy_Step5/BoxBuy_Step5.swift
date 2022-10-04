//
//  BoxBuy_Step5.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/20.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class BoxBuy_Step5: UICollectionViewCell {
    weak var m_tClickEvent: BoxBuyClickCellBtnDelegate? = nil;
    
    @IBOutlet weak var uiTabView: UIView!
    
    @IBOutlet weak var uiSilderBtn: UIButton!
    
    @IBOutlet weak var uilb1: UILabel!
    @IBOutlet weak var uilb2: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        uiTabView.layer.cornerRadius = 8.0;
        
        uilb1.text = "상품 배송 안내".localized
        uilb2.text = "랜덤박스에서 획득한 상품은 별도의 배송 신청을 통해 주문할 수 있습니다. 상품보관함에서 배송 신청이 가능합니다. (일반 배송비 3,500원 / 도서산간지역은 지역에 따라 다름 / 해외배송 및 해외 MMS 쿠폰 발송 미지원)".localized
    }
    func setData(isSlider : Bool){
        if isSlider {
            uiSilderBtn.setImage(UIImage(named: "boxbuy_arrow_down"), for: .normal)
        }else{
            uiSilderBtn.setImage(UIImage(named: "boxbuy_arrow_up"), for: .normal)
        }
    }
    @IBAction func onSlider(_ sender: Any) {
        m_tClickEvent?.ClickEvent(type: 7, data: [:])
    }
}
