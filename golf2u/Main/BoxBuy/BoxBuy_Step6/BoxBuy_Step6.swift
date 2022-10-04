//
//  BoxBuy_Step6.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/20.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class BoxBuy_Step6: UICollectionViewCell {
    weak var m_tClickEvent: BoxBuyClickCellBtnDelegate? = nil;
    @IBOutlet weak var uiTabView: UIView!
    @IBOutlet weak var uiSilderBtn: UIButton!
    @IBOutlet weak var uilb1: UILabel!
    @IBOutlet weak var uilb2: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        uiTabView.layer.cornerRadius = 8.0;
    }
    func setData(isSlider : Bool){
        if isSlider {
            uiSilderBtn.setImage(UIImage(named: "boxbuy_arrow_down"), for: .normal)
        }else{
            uiSilderBtn.setImage(UIImage(named: "boxbuy_arrow_up"), for: .normal)
        }
        uilb1.text = "기업정보".localized
        uilb2.text = "상호명 : ㈜네모난오렌지\n사업장소재지 : 서울시 강남구 남부순환로 2722 3층 (도곡동)\n사업자등록번호 : 484-87-00475\n대표이사 : 안혜미\n통신판매업신고: 2017-서울강남-02348\n고객센터 : customer@random2u.com\n대표번호 1588-2529".localized
    }
    @IBAction func onSlider(_ sender: Any) {
        m_tClickEvent?.ClickEvent(type: 8, data: [:])
    }
}
