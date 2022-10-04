//
//  BoxBuy_Step2.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/20.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class BoxBuy_Step2: UICollectionViewCell {
    weak var m_tClickEvent: BoxBuyClickCellBtnDelegate? = nil;

    @IBOutlet weak var uiTitle: UILabel!
    @IBOutlet weak var uiRandomView: UIView!
    @IBOutlet weak var uiEventView: UIView!
    @IBOutlet weak var uiRanBtnView: UIView!
    @IBOutlet weak var uiEvenBtnView: UIView!
    @IBOutlet weak var uiRanMinusBtn: UIButton!
    @IBOutlet weak var uiEvenMinusBtn: UIButton!
    @IBOutlet weak var uiRanInput: UITextField!{
        didSet {
            uiRanInput?.addDoneToolbar(onDone: (target: self, action: #selector(doneButtonTappedForMyNumericTextField)))
        }
    }
    @IBOutlet weak var uiEvenInput: UITextField!{
        didSet {
            uiEvenInput?.addDoneToolbar(onDone: (target: self, action: #selector(doneButtonTappedForMyNumericTextField)))
        }
    }
    @IBOutlet weak var uiRanPlusBtn: UIButton!
    @IBOutlet weak var uiEvenPlusBtn: UIButton!
    @IBOutlet weak var uiRandomBoxPrice: UILabel!
    @IBOutlet weak var uiEventBoxPrice: UILabel!
    @IBOutlet weak var uiEventSoldout: UILabel!
    @IBOutlet weak var uiHelpBtn: UIButton!
    private var m_eventbox_remain_cnt = 0;
    private var m_randonbox_remain_cnt = 0;
    private var m_nRanCnt = 0;
    private var m_nEvenCnt = 0;
    private var m_nEventBoxPrice = 0;
    private var m_nPageIdx = 0;
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        uiTitle.text = "랜덤박스 선택".localized;
        uiRandomBoxPrice.text = "랜덤박스 (10,000원)".localized;
        uiEventSoldout.text = "매진".localized;
        uiEventBoxPrice.text = "이벤트박스 (0C)".localized;
        
        uiRandomView.layer.cornerRadius = 8.0;
        uiRandomView.layer.borderWidth = 1.0
        uiRandomView.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiEventView.layer.cornerRadius = 8.0;
        uiEventView.layer.borderWidth = 1.0
        uiEventView.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiRanBtnView.layer.cornerRadius = 8.0;
        uiRanBtnView.layer.borderWidth = 1.0
        uiRanBtnView.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiEvenBtnView.layer.cornerRadius = 8.0;
        uiEvenBtnView.layer.borderWidth = 1.0
        uiEvenBtnView.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        uiRanInput.attributedPlaceholder = NSAttributedString(string: "0",
                                                              attributes: [NSAttributedString.Key.foregroundColor: UIColor(rgb: 0x333333)])
        uiEvenInput.attributedPlaceholder = NSAttributedString(string: "0",
                                                              attributes: [NSAttributedString.Key.foregroundColor: UIColor(rgb: 0x333333)])
        
        self.uiRanInput.layer.addBorder([.left,.right], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        self.uiEvenInput.layer.addBorder([.left,.right], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
        uiRanInput.addTarget(self, action: #selector(onBoxCntInput(_:)), for: .editingChanged)
        uiEvenInput.addTarget(self, action: #selector(onBoxCntInput(_:)), for: .editingChanged)
        
    }
    func DataReset(){
        uiRanInput.text = "";
        uiEvenInput.text = "";
        m_nRanCnt = 0;
        m_nEvenCnt = 0;
        CalcPrice()
    }
    func PageSlideChanged(pageidx : Int){
        if m_nPageIdx == pageidx {
            return;
        }
        m_nPageIdx = pageidx
        if m_nPageIdx == 0 {
            uiRandomView.isHidden = false;
            uiEventView.isHidden = true;
        }else if m_nPageIdx == 1 {
            uiRandomView.isHidden = true;
            uiEventView.isHidden = false;
        }
        DataReset();
    }
    @objc func doneButtonTappedForMyNumericTextField() {
        self.endEditing(true)
    }
    @objc private func onBoxCntInput(_ selectedValue: UITextField) {
        if selectedValue == uiRanInput {
            if selectedValue.text == ""{
                uiRanInput.text = "";
                m_nRanCnt = 0;
            }else{
                var fm_nInputCupon = Int(selectedValue.text ?? "0") ?? 0
                if fm_nInputCupon >= m_randonbox_remain_cnt {
                    fm_nInputCupon = m_randonbox_remain_cnt;
                    
                }
                uiRanInput.text = String(fm_nInputCupon)
                m_nRanCnt = fm_nInputCupon;
            }
        }else if selectedValue == uiEvenInput {
            if selectedValue.text == ""{
                uiEvenInput.text = "";
                m_nEvenCnt = 0;
            }else{
                var fm_nInputCupon = Int(selectedValue.text ?? "0") ?? 0
                if fm_nInputCupon >= m_eventbox_remain_cnt {
                    fm_nInputCupon = m_eventbox_remain_cnt;
                    
                }
                uiEvenInput.text = String(fm_nInputCupon)
                m_nEvenCnt = fm_nInputCupon;
            }
        }
        CalcPrice()
    }
    func setData(data : [String : String]){
        m_eventbox_remain_cnt = Int(data["eventbox_remain_cnt"] ?? "0") ?? 0
        m_randonbox_remain_cnt = Int(data["randombox_remain_cnt"] ?? "0") ?? 0
        uiEventBoxPrice.text = "이벤트박스 (C)".localized(txt: "\((data["eventbox_price"] ?? "0").DecimalWon())");
        m_nEventBoxPrice = Int(data["eventbox_price"] ?? "0") ?? 0
        //m_eventbox_remain_cnt = 0 // 현재는 커밍순 상태라  매진으로 처리
        if m_eventbox_remain_cnt <= 0 {
            uiEvenBtnView.isHidden = true;
            uiHelpBtn.isHidden = true;
            uiEventSoldout.isHidden = false;
            uiEventView.backgroundColor = UIColor(rgb: 0xf2f2f2)
            uiEventBoxPrice.textColor = UIColor(rgb: 0x999999)
            //uiEventBoxPrice.text = "이벤트박스".localized; // 현재는 커밍순 상태라  매진으로 처리
            //uiEventSoldout.text = "COMING SOON".localized
        }else{
            uiEvenBtnView.isHidden = false;
            uiHelpBtn.isHidden = false;
            uiEventSoldout.isHidden = true;
            uiEventView.backgroundColor = UIColor(rgb: 0xffffff)
            uiEventBoxPrice.textColor = UIColor(rgb: 0x333333)
        }
    }
    @IBAction func onRanMinus(_ sender: Any) {
        if m_nRanCnt == 0 {
            return;
        }
        m_nRanCnt -= 1;
        if m_nRanCnt == 0 {
            uiRanInput.text = "";
        }else{
            uiRanInput.text = "\(m_nRanCnt)";
        }
        CalcPrice()
    }
    @IBAction func onRanPlus(_ sender: Any) {
        if m_nRanCnt == m_randonbox_remain_cnt {
            return;
        }
        m_nRanCnt += 1;
        uiRanInput.text = "\(m_nRanCnt)";
        CalcPrice()
    }
    @IBAction func onEvenMinus(_ sender: Any) {
        if m_nEvenCnt == 0 {
            return;
        }
        m_nEvenCnt -= 1;
        if m_nEvenCnt == 0 {
            uiEvenInput.text = "";
        }else{
            uiEvenInput.text = "\(m_nEvenCnt)";
        }
        CalcPrice()
    }
    @IBAction func onEvenPlus(_ sender: Any) {
        if m_nEvenCnt == m_eventbox_remain_cnt {
            return;
        }
        m_nEvenCnt += 1;
        uiEvenInput.text = "\(m_nEvenCnt)";
        CalcPrice()
    }
    func CalcPrice(){
        let price = (m_nRanCnt * 10000) + (m_nEvenCnt * m_nEventBoxPrice)
        m_tClickEvent?.ClickEvent(type: 3, data: ["cntprice":"\(price)", "rancnt":"\(m_nRanCnt)", "evencnt":"\(m_nEvenCnt)"])
    }
    @IBAction func onHelp(_ sender: Any) {
        m_tClickEvent?.ClickEvent(type: 11, data: [:])
    }
}
