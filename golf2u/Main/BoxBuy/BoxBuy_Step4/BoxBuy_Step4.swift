//
//  BoxBuy_Step4.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/20.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class BoxBuy_Step4: UICollectionViewCell {
    weak var m_tClickEvent: BoxBuyClickCellBtnDelegate? = nil;
    
    @IBOutlet weak var uilb1: UILabel!
    @IBOutlet weak var uilb2: UILabel!
    @IBOutlet weak var uilb3: UILabel!
    @IBOutlet weak var uilb4: UILabel!
    @IBOutlet weak var uiSilderBtn: UIButton!
    @IBOutlet weak var uiTabView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        uiTabView.layer.cornerRadius = 8.0;
        
        uilb1.text = "결제 안내".localized;
        uilb2.text = "구매한 랜덤박스를 열면 무작위로 하나의 상품을 획득하게 됩니다. 획득가능한 상품의 목록은 골투샵의 상품 목록 또는 박스보관함의 상품리스트에서 확인할 수 있습니다.".localized;
        uilb3.text = "교환, 환불 안내".localized;
        uilb4.text = "결제취소는 결제일로부터 7일 이내에 미사용한 랜덤박스에 한해 가능합니다. \n랜덤박스를 열어서 상품을 획득한 경우, 해당 랜덤박스는 사용한 것이므로, 결제취소는 불가능합니다. \n랜덤박스를 통해 배송 받은 상품에 하자가 있을 경우, 상품을 교환 또는 결제한 랜덤박스 금액으로 환불 받을 수 있습니다. \n배송 받은 상품에 대해 하자가 아닌 단순 변심, 불만족 등으로 인한 교환 및 환불은 불가능합니다.".localized;
    }
    func setData(isSlider : Bool){
        if isSlider {
            uiSilderBtn.setImage(UIImage(named: "boxbuy_arrow_down"), for: .normal)
        }else{
            uiSilderBtn.setImage(UIImage(named: "boxbuy_arrow_up"), for: .normal)
        }
    }
    @IBAction func onSlider(_ sender: Any) {
        m_tClickEvent?.ClickEvent(type: 6, data: [:])
    }
    
}
