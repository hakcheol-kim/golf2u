//
//  BoxBuy_Step3.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/20.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
//import DownPickerSwift

class BoxBuy_Step3: UICollectionViewCell {
    weak var m_tClickEvent: BoxBuyClickCellBtnDelegate? = nil;

    @IBOutlet weak var uiTitle1lb: UILabel!
    @IBOutlet weak var uiTitle2lb: UILabel!
    @IBOutlet weak var uiTitle3lb: UILabel!
    @IBOutlet weak var uiTitle4lb: UILabel!
    
    @IBOutlet weak var uiCloverInput: UITextField!{
        didSet {
            uiCloverInput?.addDoneToolbar(onDone: (target: self, action: #selector(doneButtonTappedForMyNumericTextField)))
        }
    }
    @IBOutlet weak var uiCloverAllBtn: UIButton!
    @IBOutlet weak var uiMyCloverLabel: UILabel!
    
    @IBOutlet weak var uiCuponCombo: UITextField!
    private var uiCuponComboDP: DownPickerSwift?
    
    @IBOutlet weak var uiPayCardBtn: UIButton!
    @IBOutlet weak var uiPayPhoneBtn: UIButton!
    @IBOutlet weak var uiPayRealBankBtn: UIButton!
    @IBOutlet weak var uiBankBtn: UIButton!
    
    @IBOutlet weak var uikakaopay: UIButton!
    @IBOutlet weak var uipayco: UIButton!
    @IBOutlet weak var uinaverpay: UIButton!
    @IBOutlet weak var uichaipay: UIButton!
    
    private var m_isPayType = 0; // 0:카드결제, 1:휴대폰 결제, 2:실시간 계죄이체, 3:무통장 입금, 4:카카오페이,5:페이코,6:네이버페이,7:차이페이
    
    private var m_Cupons = [[String : String]]()
    
    private var m_nSelCuponPrice = 0;
    private var m_nSelCuponSeq = "";
    
    private var m_nMyClover = 0;
    private var m_nUseClover = 0;
    
    private var m_isBtnEn = false;
    
    private var m_nPageIdx = 0;
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        uiTitle1lb.text = "클로버 사용".localized
        uiTitle2lb.text = "쿠폰사용".localized
        uiTitle3lb.text = "※쿠폰은 중복적용이 불가능합니다.".localized
        uiTitle4lb.text = "결제 수단".localized
        uiCloverAllBtn.setTitle("전액사용".localized, for: .normal)
        
        uiPayCardBtn.setTitle("카드결제".localized, for: .normal)
        uiPayPhoneBtn.setTitle("휴대폰 결제(SKT 불가)".localized, for: .normal)
        uiPayRealBankBtn.setTitle("실시간 계좌이체".localized, for: .normal)
        uiBankBtn.setTitle("무통장 입금".localized, for: .normal)
        uikakaopay.setTitle("카카오페이".localized, for: .normal)
        uipayco.setTitle("페이코".localized, for: .normal)
        uinaverpay.setTitle("네이버페이".localized, for: .normal)
        
        uiCloverInput.layer.cornerRadius = 8.0;
        uiCloverInput.layer.borderWidth = 1.0
        uiCloverInput.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiCloverAllBtn.layer.roundCorners(corners: [.topRight, .bottomRight], radius: 8.0)
        uiCloverInput.attributedPlaceholder = NSAttributedString(string: "0",
                                                              attributes: [NSAttributedString.Key.foregroundColor: UIColor(rgb: 0x333333)])
        
        uiCuponCombo.layer.cornerRadius = 8.0;
        uiCuponCombo.layer.borderWidth = 1.0
        uiCuponCombo.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiCuponCombo.addLeftPadding();
        uiCuponCombo.placeholder = "적용하실 쿠폰을 선택하세요.".localized
        
        uiCloverInput.addTarget(self, action: #selector(onCloverInput(_:)), for: .editingChanged)
        
        PayBtnInit()
    }
    func DataReset(){
        m_nUseClover = 0;
        uiCloverInput.text = "";
        //uiCuponComboDP?.setValue(at: 0)
        m_nSelCuponSeq = "";
        m_nSelCuponPrice = 0;
        
        CalcPrice()
    }
    func PageSlideChanged(pageidx : Int){
        if m_nPageIdx == pageidx {
            return;
        }
        m_nPageIdx = pageidx
        if m_nPageIdx == 0 {
            //이벤트 박스 페이지 일때는 uiCuponComboDP 가 가려져서 데이터가 메모리에 삭제되어 인덱스오브아웃메모리 예외처리가뜸
            //0인 랜덤박스일경우는 메모리에 잡혀 데이터가 있기 때문에 가능함
            uiCuponComboDP?.setValue(at: 0)
        }else if m_nPageIdx == 1 {
        }
//        DataReset()
        m_nUseClover = 0;
        uiCloverInput.text = "";
        //uiCuponComboDP?.setValue(at: 0)
        m_nSelCuponSeq = "";
        m_nSelCuponPrice = 0;
        
        CalcPrice()
    }
    @objc private func onCloverInput(_ selectedValue: UITextField) {
        if selectedValue.text == ""{
            m_nUseClover = 0;
            uiCloverInput.text = "";
        }else{
            let fm_nMaxPrice : Int = (m_tClickEvent?.getMainAllCloverMaxPrice()) ?? 0;
            var fm_nInputCupon = Int(selectedValue.text ?? "0") ?? 0
            if fm_nInputCupon > m_nMyClover{
                if fm_nInputCupon == 0 {
                    fm_nInputCupon = m_nMyClover;
                    uiCloverInput.text = ""
                }else{
                    fm_nInputCupon = m_nMyClover;
                    uiCloverInput.text = String(m_nMyClover)
                }
            }else if fm_nInputCupon > fm_nMaxPrice && fm_nMaxPrice <= m_nMyClover{
                fm_nInputCupon = fm_nMaxPrice;
                uiCloverInput.text = String(fm_nMaxPrice)
            }
            m_nUseClover = fm_nInputCupon;
        }
        CalcPrice();
    }
    @objc func doneButtonTappedForMyNumericTextField() {
        self.endEditing(true)
    }
    @objc private func onCuponCombo(selectedValue: DownPickerSwift) {
        if selectedValue.getTextField().text == "선택안함".localized {
            m_nSelCuponSeq = "";
            m_nSelCuponPrice = 0;
        }else{
            var fm_sCuponPrice = "";
            for val in m_Cupons{
                if val["title"] == selectedValue.getTextField().text {
                    fm_sCuponPrice = val["discount_price"] ?? "0";
                    m_nSelCuponSeq = val["coupon_seq"] ?? "0";
                    break;
                }
            }
            m_nSelCuponPrice = Int(fm_sCuponPrice) ?? 0
        }
        CalcPrice()
    }
    func setData(data : [String : String], cupons : [[String : String]]){
        m_Cupons = cupons;
        m_nMyClover = Int(data["point"] ?? "0") ?? 0
        var fm_arrCupon = [String]()
        for val in cupons{
            fm_arrCupon.append(val["title"] ?? "")
        }
        uiCuponComboDP = DownPickerSwift(with: uiCuponCombo, with: fm_arrCupon)
        uiCuponComboDP?.showArrowImage(false)
        uiCuponComboDP?.setToolbarDoneButton(with: "확인")
        uiCuponComboDP?.setToolbarCancelButton(with: "취소")
        
        uiCuponComboDP?.setPlaceholder(with: "적용하실 쿠폰을 선택하세요.".localized)
        uiCuponComboDP?.addTarget(self, action: #selector(onCuponCombo(selectedValue:)), for: .valueChanged)
        if fm_arrCupon.count == 1 {
            uiCuponCombo.isEnabled = false
            uiCuponComboDP?.setPlaceholder(with: "사용가능한 쿠폰이 없습니다.".localized)
        }
        
        uiMyCloverLabel.text = "보유중인 클로버 [ 클로버]".localized(txt: "\(String(m_nMyClover).DecimalWon())");
    }
    func PayBtnInit(){
        uiPayCardBtn.setTitleColor(UIColor(rgb: 0x333333), for: .normal)
        uiPayCardBtn.layer.cornerRadius = 15.0;
        uiPayCardBtn.layer.borderWidth = 1.0
        uiPayCardBtn.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiPayPhoneBtn.setTitleColor(UIColor(rgb: 0x333333), for: .normal)
        uiPayPhoneBtn.layer.cornerRadius = 15.0;
        uiPayPhoneBtn.layer.borderWidth = 1.0
        uiPayPhoneBtn.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiPayRealBankBtn.setTitleColor(UIColor(rgb: 0x333333), for: .normal)
        uiPayRealBankBtn.layer.cornerRadius = 15.0;
        uiPayRealBankBtn.layer.borderWidth = 1.0
        uiPayRealBankBtn.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiBankBtn.setTitleColor(UIColor(rgb: 0x333333), for: .normal)
        uiBankBtn.layer.cornerRadius = 15.0;
        uiBankBtn.layer.borderWidth = 1.0
        uiBankBtn.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        uikakaopay.setTitleColor(UIColor(rgb: 0x333333), for: .normal)
        uikakaopay.layer.cornerRadius = 15.0;
        uikakaopay.layer.borderWidth = 1.0
        uikakaopay.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uipayco.setTitleColor(UIColor(rgb: 0x333333), for: .normal)
        uipayco.layer.cornerRadius = 15.0;
        uipayco.layer.borderWidth = 1.0
        uipayco.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uinaverpay.setTitleColor(UIColor(rgb: 0x333333), for: .normal)
        uinaverpay.layer.cornerRadius = 15.0;
        uinaverpay.layer.borderWidth = 1.0
        uinaverpay.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uichaipay.setTitleColor(UIColor(rgb: 0x333333), for: .normal)
        uichaipay.layer.cornerRadius = 15.0;
        uichaipay.layer.borderWidth = 1.0
        uichaipay.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
    }
    func PayBtnSelInit(){
        if !m_isBtnEn {
            m_isPayType = 0;
            return;
        }
        if m_isPayType == 0 {
            uiPayCardBtn.setTitleColor(UIColor(rgb: 0x00BA87), for: .normal)
            uiPayCardBtn.layer.cornerRadius = 15.0;
            uiPayCardBtn.layer.borderWidth = 1.0
            uiPayCardBtn.layer.borderColor = UIColor(rgb: 0x00BA87).cgColor
        }else if m_isPayType == 1 {
            uiPayPhoneBtn.setTitleColor(UIColor(rgb: 0x00BA87), for: .normal)
            uiPayPhoneBtn.layer.cornerRadius = 15.0;
            uiPayPhoneBtn.layer.borderWidth = 1.0
            uiPayPhoneBtn.layer.borderColor = UIColor(rgb: 0x00BA87).cgColor
        }else if m_isPayType == 2 {
            uiPayRealBankBtn.setTitleColor(UIColor(rgb: 0x00BA87), for: .normal)
            uiPayRealBankBtn.layer.cornerRadius = 15.0;
            uiPayRealBankBtn.layer.borderWidth = 1.0
            uiPayRealBankBtn.layer.borderColor = UIColor(rgb: 0x00BA87).cgColor
        }else if m_isPayType == 3 {
            uiBankBtn.setTitleColor(UIColor(rgb: 0x00BA87), for: .normal)
            uiBankBtn.layer.cornerRadius = 15.0;
            uiBankBtn.layer.borderWidth = 1.0
            uiBankBtn.layer.borderColor = UIColor(rgb: 0x00BA87).cgColor
        }else if m_isPayType == 4 {
            uikakaopay.setTitleColor(UIColor(rgb: 0x00BA87), for: .normal)
            uikakaopay.layer.cornerRadius = 15.0;
            uikakaopay.layer.borderWidth = 1.0
            uikakaopay.layer.borderColor = UIColor(rgb: 0x00BA87).cgColor
        }else if m_isPayType == 5 {
            uipayco.setTitleColor(UIColor(rgb: 0x00BA87), for: .normal)
            uipayco.layer.cornerRadius = 15.0;
            uipayco.layer.borderWidth = 1.0
            uipayco.layer.borderColor = UIColor(rgb: 0x00BA87).cgColor
        }else if m_isPayType == 6 {
            uinaverpay.setTitleColor(UIColor(rgb: 0x00BA87), for: .normal)
            uinaverpay.layer.cornerRadius = 15.0;
            uinaverpay.layer.borderWidth = 1.0
            uinaverpay.layer.borderColor = UIColor(rgb: 0x00BA87).cgColor
        }else if m_isPayType == 7 {
            uichaipay.setTitleColor(UIColor(rgb: 0x00BA87), for: .normal)
            uichaipay.layer.cornerRadius = 15.0;
            uichaipay.layer.borderWidth = 1.0
            uichaipay.layer.borderColor = UIColor(rgb: 0x00BA87).cgColor
        }
    }
    func setPayBtnSelect(){
        PayBtnInit()
        PayBtnSelInit();
        CalcPrice();
    }
    func PayBtnEnabel(isB : Bool){
        uiPayCardBtn.isEnabled = isB
        uiPayPhoneBtn.isEnabled = isB
        uiPayRealBankBtn.isEnabled = isB
        uiBankBtn.isEnabled = isB
        uikakaopay.isEnabled = isB
        uipayco.isEnabled = isB
        uinaverpay.isEnabled = isB
        uichaipay.isEnabled = isB
        m_isBtnEn = isB;
        
        if !isB {
            PayBtnInit()
        }else{
            PayBtnInit()
            PayBtnSelInit();
        }
    }
    @IBAction func onPayBtn(_ sender: Any) {
        m_isPayType = 0;
        setPayBtnSelect()
    }
    @IBAction func onPhoneBtn(_ sender: Any) {
        m_isPayType = 1;
        setPayBtnSelect()
    }
    @IBAction func onRealBtn(_ sender: Any) {
        m_isPayType = 2;
        setPayBtnSelect()
    }
    @IBAction func onBankBtn(_ sender: Any) {
        m_isPayType = 3;
        setPayBtnSelect()
    }
    @IBAction func onKakaoPayBtn(_ sender: Any) {
        m_isPayType = 4;
        setPayBtnSelect()
    }
    @IBAction func onPaycoBtn(_ sender: Any) {
        m_isPayType = 5;
        setPayBtnSelect()
    }
    @IBAction func onNaverPayBtn(_ sender: Any) {
        m_isPayType = 6;
        setPayBtnSelect()
    }
    @IBAction func onChaiPayBtn(_ sender: Any) {
        m_isPayType = 7;
        setPayBtnSelect()
    }
    @IBAction func onCloverAll(_ sender: Any) {
        var fm_nMaxPrice : Int = (m_tClickEvent?.getMainAllCloverMaxPrice()) ?? 0;
        if fm_nMaxPrice < 0 {
            fm_nMaxPrice = 0;
        }
        var fm_nUsePoint  = 0;
        if (fm_nMaxPrice <= m_nMyClover) {
            fm_nUsePoint = fm_nMaxPrice
            
        }else{
            fm_nUsePoint = m_nMyClover
        }
        
        uiCloverInput.text = "\(fm_nUsePoint)"
        m_nUseClover = fm_nUsePoint;
        CalcPrice()
    }
    @IBAction func onHelp(_ sender: Any) {
        m_tClickEvent?.ClickEvent(type: 4, data: [:])
    }
    func CalcPrice(){
        m_tClickEvent?.ClickEvent(type: 5, data: ["usepoint":String(m_nUseClover), "cuponseq":m_nSelCuponSeq, "cuponprice":"\(m_nSelCuponPrice)", "PayType":String(m_isPayType)])
    }
}
