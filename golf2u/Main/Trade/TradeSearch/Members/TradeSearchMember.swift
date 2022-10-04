//
//  TradeSearchMember.swift
//  golf2u
//
//  Created by 이원영 on 2020/10/16.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import RangeSeekSlider

class TradeSearchMember: UIView {
    private var SO:Single = Single.getSO();
    private let JS = JsonC();
    private let xibName = "TradeSearchMember"
    
    private var m_sUserSeq : String = "";
    
    
    @IBOutlet weak var uiCheckBtn: RectCheckBoxBtn!
    
    @IBOutlet weak var uiSlider: RangeSeekSlider!
    @IBOutlet weak var uiMarketSetlb: UILabel!
    @IBOutlet weak var uiLimitChecklb: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing(true)
    }
    private func commonInit(){
        let view = Bundle.main.loadNibNamed(xibName, owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        
        uiMarketSetlb.text = "마켓등록 필터 설정".localized;
        uiLimitChecklb.text = "제한없음".localized;
        
        m_sUserSeq = SO.getUserInfoKey(key: "seq")
        
        //self.SO.setTradeSearchMemberMinAndMax(f_nTradeSearchMemberMin: 0, f_nTradeSearchMemberMax: 100)
        //SO.setTradeSearchMemberCheck(f_nTradeSearchMemberCheck: false)
        uiCheckBtn.buttonStateModify(isA: SO.getTradeSearchMemberCheck())
            
        
        // custom number formatter range slider
        
        uiSlider.minValue = 1.0
        uiSlider.maxValue = 100.0
        uiSlider.selectedMinValue = CGFloat(SO.getTradeSearchMemberMin())
        uiSlider.selectedMaxValue = CGFloat(SO.getTradeSearchMemberMax())
        uiSlider.handleImage = UIImage(named: "trade_Gauge")?.resizeImage(targetSize: CGSize(width: 40, height: 40))
        uiSlider.selectedHandleDiameterMultiplier = 1.0
        uiSlider.colorBetweenHandles = UIColor(rgb: 0x00BA87)
        uiSlider.tintColor = UIColor(rgb: 0x999999)
        uiSlider.lineHeight = 8.0
        uiSlider.numberFormatter.positivePrefix = ""
        uiSlider.numberFormatter.positiveSuffix = ""
        
        uiSlider.delegate = self
        
//        uiSliderView.setValueChangedCallback { (minValue, maxValue) in
//            self.SO.setTradeSearchMemberMinAndMax(f_nTradeSearchMemberMin: minValue, f_nTradeSearchMemberMax: maxValue)
//                }
//        uiSliderView.setMinValueDisplayTextGetter { (minValue) -> String? in
//                    return "\(minValue)"
//                }
//        uiSliderView.setMaxValueDisplayTextGetter { (maxValue) -> String? in
//                    return "\(maxValue)"
//                }
//        uiSliderView.setMinAndMaxRange(0, maxRange: 100)
//        uiSliderView.setMinAndMaxValue(SO.getTradeSearchMemberMin(), maxValue: SO.getTradeSearchMemberMax())
//        //uiSliderView.tintColor = UIColor.red;
//        uiSliderView.trackHighlightTintColor = UIColor(rgb: 0x00BA87)
//        uiSliderView.minValueThumbTintColor = UIColor(rgb: 0x00BA87)
//        uiSliderView.maxValueThumbTintColor = UIColor(rgb: 0x00BA87)
        
    }
    
    @IBAction func onCheckBoxBtn(_ sender: Any) {
        SO.setTradeSearchMemberCheck(f_nTradeSearchMemberCheck: (!uiCheckBtn.isChecked))
    }
    
}
extension TradeSearchMember: RangeSeekSliderDelegate {

    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        if slider === uiSlider {
            self.SO.setTradeSearchMemberMinAndMax(f_nTradeSearchMemberMin: Int(minValue), f_nTradeSearchMemberMax: Int(maxValue))
        }
    }
    
    func didStartTouches(in slider: RangeSeekSlider) {
        //print("did start touches")
    }

    func didEndTouches(in slider: RangeSeekSlider) {
        //print("did end touches")
    }
    func rangeSeekSlider(_ slider: RangeSeekSlider, stringForMinValue minValue: CGFloat) -> String? {
        let intt = Int(minValue)
        return String(intt).DecimalWon()
        
    }
    func rangeSeekSlider(_ slider: RangeSeekSlider, stringForMaxValue maxValue: CGFloat) -> String? {
        let intt = Int(maxValue)
        return String(intt).DecimalWon()
    }
}
 
