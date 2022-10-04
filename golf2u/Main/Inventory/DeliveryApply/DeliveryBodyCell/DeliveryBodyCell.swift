//
//  DeliveryBodyCell.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/12.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON
//import DownPickerSwift

class DeliveryBodyCell: UICollectionViewCell {
    weak var m_tClickEvent: DeliveryApplyClickCellBtnDelegate? = nil;
    private let SO = Single.getSO();
    private let JS = JsonC();
    
    @IBOutlet weak var uiTitle1lb: UILabel!
    @IBOutlet weak var uiTitle2lb: UILabel!
    @IBOutlet weak var uiTitle3lb: UILabel!
    @IBOutlet weak var uiTitle4lb: UILabel!
    @IBOutlet weak var uiTitle5lb: UILabel!
    @IBOutlet weak var uiTitle6lb: UILabel!
    @IBOutlet weak var uiTitleSub1lb: UILabel!
    @IBOutlet weak var uiTitleSub2lb: UILabel!
    @IBOutlet weak var uiTitleSub3lb: UILabel!
    @IBOutlet weak var uiTitle7lb: UILabel!
    @IBOutlet weak var uiHelplb: UILabel!
    @IBOutlet weak var uiNotMsgDellb: UILabel!
    @IBOutlet weak var uiCuponHelplb: UILabel!
    
    
    @IBOutlet weak var uiVIew1: UIView!
    @IBOutlet weak var uiDeliAddBtn: UIButton!
    @IBOutlet weak var uiDeliAddCon: UILabel!
    @IBOutlet weak var uiMyDeAddrTitle: UILabel!
    @IBOutlet weak var uiMyDeAddr: UILabel!
    @IBOutlet weak var uiDeliMgBtn: UIButton!
    
    @IBOutlet weak var uiView2: UIView!
    @IBOutlet weak var uiView2SubView1: UIView!
    
    @IBOutlet weak var uiDeliMsgCombo: UITextField!
    private var uiDeliMsgComboDP: DownPickerSwift?
    @IBOutlet weak var uiDeliMsgInput: UITextField!
    
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
    @IBOutlet weak var uiLastPayView: UIView!
    @IBOutlet weak var uiLastPayCuponView: UIView!
    @IBOutlet weak var uiDelPayLabel: UILabel!
    @IBOutlet weak var uiUseCuponLabel: UILabel!
    @IBOutlet weak var uiUseCloverLabel: UILabel!
    
    @IBOutlet weak var uiUseDeliGageLabel: UILabel!
    
    @IBOutlet weak var uiMaxPayView: UIView!
    @IBOutlet weak var uiMaxPayLabel: UILabel!
    
    private var m_sUserSeq = "";
    private var m_sAddrSeq = "";
    
    private var m_DeliAddr = [String:String]();
    private var m_PrdData = [String:String]();
    private var m_nMyClover = 0;
    private var m_isAddedPro = 0;
    private var m_CuponListData = Array<[String:String]>();
    
    private var m_nSelCuponPrice = 0;
    private var m_nUseClover = 0;
    private var m_nMaxDeliveryPrice = 0;
    private var m_nOri_MaxDeliveryPrice = 0;
    private var m_nHasAdd_MaxDeliveryPrice = 0;
    private var m_nMaxGage = 0;
    private var m_nSelCuponSeq = "";
    
    @IBOutlet weak var uiNotAddrView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        m_sUserSeq = SO.getUserInfoKey(key: "seq")
        
        uiDeliAddBtn.setTitle("배송상품 추가".localized, for: .normal)
        uiDeliMgBtn.setTitle("배송지 관리".localized, for: .normal)
        uiCloverAllBtn.setTitle("전액사용".localized, for: .normal)
        uiTitle1lb.text = "배송지 정보".localized;
        uiTitle2lb.text = "배송 메세지".localized;
        uiTitle3lb.text = "클로버 사용".localized;
        uiTitle4lb.text = "쿠폰사용".localized;
        uiTitle5lb.text = "결제 수단".localized;
        uiTitle6lb.text = "최종 결제금액".localized;
        uiTitleSub1lb.text = "배송비".localized;
        uiTitleSub2lb.text = "쿠폰사용".localized;
        uiTitleSub3lb.text = "클로버 사용".localized;
        uiTitle7lb.text = "총 결제금액".localized;
        uiHelplb.text = "상품은 배송 신청하신 다음날 출고가 진행됩니다.\n\n재고 소진의 경우 상품 수급 시 까지 출고 기간이 늦춰질 수  있습니다.\n이점 양해 부탁드립니다.".localized;
        uiNotMsgDellb.text = "등록된 배송지가 없습니다.\n배송지를 추가해주세요".localized;
        uiCuponHelplb.text = "※쿠폰은 중복적용이 불가능합니다.".localized
        uiPayCardBtn.setTitle("카드결제".localized, for: .normal)
        uiPayPhoneBtn.setTitle("휴대폰 결제(SKT 불가)".localized, for: .normal)
        uiPayRealBankBtn.setTitle("실시간 계좌이체".localized, for: .normal)
        uiBankBtn.setTitle("무통장 입금".localized, for: .normal)
        uikakaopay.setTitle("카카오페이".localized, for: .normal)
        uipayco.setTitle("페이코".localized, for: .normal)
        uinaverpay.setTitle("네이버페이".localized, for: .normal)
        uichaipay.setTitle("CHAIpay", for: .normal)
        
        
        self.uiVIew1.layer.addBorder([.top,.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        uiDeliAddBtn.layer.cornerRadius = 8.0;
        uiDeliAddBtn.layer.borderWidth = 1.0
        uiDeliAddBtn.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        uiView2.layer.cornerRadius = 8.0;
        uiView2.layer.borderWidth = 1.0
        uiView2.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        uiDeliMsgInput.layer.cornerRadius = 8.0;
        uiDeliMsgInput.layer.borderWidth = 1.0
        uiDeliMsgInput.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiDeliMsgInput.addLeftPadding();
        uiDeliMsgInput.delegate = self;
        
        uiCloverInput.layer.cornerRadius = 8.0;
        uiCloverInput.layer.borderWidth = 1.0
        uiCloverInput.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiCloverInput.attributedPlaceholder = NSAttributedString(string: "0",
                                                              attributes: [NSAttributedString.Key.foregroundColor: UIColor(rgb: 0x333333)])
        
        uiCuponCombo.layer.cornerRadius = 8.0;
        uiCuponCombo.layer.borderWidth = 1.0
        uiCuponCombo.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiCuponCombo.addLeftPadding();
        
        
        //self.uiView2SubView1.layer.addBorder([.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0, widthp: 0)
        
        
        uiCloverAllBtn.layer.roundCorners(corners: [.topRight, .bottomRight], radius: 8.0)
        
        
        PayBtnInit()
        PayBtnSelInit()
        
        self.uiLastPayView.layer.addBorder([.top,.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        //self.uiLastPayCuponView.layer.addSperater([.left,.right], color: UIColor(rgb: 0xe4e4e4), width: 1.0, heipl: -30)
        
        self.uiMaxPayView.layer.addBorder([.top,.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
        let fm_arrDeliMsg = ["직접 수령할게요".localized,"문 앞에 놓아주세요".localized,"경비실에 맡겨주세요".localized,"배송 전에 전화주세요".localized,"파손위험이 있으니 조심해주세요".localized,"직접입력".localized]
        
        uiDeliMsgCombo.layer.cornerRadius = 8.0;
        uiDeliMsgCombo.layer.borderWidth = 1.0
        uiDeliMsgCombo.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiDeliMsgCombo.addLeftPadding();
        //uiDeliMsgCombo.layer.roundCorners(corners: [.topRight, .bottomRight], radius: 8.0)
        
        uiDeliMsgComboDP = DownPickerSwift(with: uiDeliMsgCombo, with: fm_arrDeliMsg)
        uiDeliMsgComboDP?.showArrowImage(false)
        uiDeliMsgComboDP?.setToolbarDoneButton(with: "확인")
        uiDeliMsgComboDP?.setToolbarCancelButton(with: "취소")
        uiDeliMsgComboDP?.setPlaceholder(with: "직접 수령할게요".localized)
        uiDeliMsgComboDP?.addTarget(self, action: #selector(onDeliMsgCombo(selectedValue:)), for: .valueChanged)
        uiDeliMsgInput.isEnabled = false;
        uiDeliMsgInput.text = "직접 수령할게요".localized;
        
        uiCloverInput.delegate = self
        uiCloverInput.addTarget(self, action: #selector(onCloverInput(_:)), for: .editingChanged)
        
        
    }
    @objc func doneButtonTappedForMyNumericTextField() {
        self.endEditing(true)
    }
    @objc private func onCloverInput(_ selectedValue: UITextField) {
        if selectedValue.text == ""{
            uiUseCloverLabel.text = "0";
            //uiCloverInput.text = "0";
            m_nUseClover = 0;
        }else{
            let fm_nMaxPrice : Int = (m_nMaxDeliveryPrice + m_nHasAdd_MaxDeliveryPrice) - m_nSelCuponPrice;
            var fm_nInputCupon = Int(selectedValue.text ?? "0") ?? 0
            if fm_nInputCupon > m_nMyClover{
                if fm_nInputCupon == 0 {
                    fm_nInputCupon = m_nMyClover;
                    uiCloverInput.text = ""
                }else{
                    fm_nInputCupon = m_nMyClover;
                    uiCloverInput.text = String(m_nMyClover)
                }
            }else if fm_nInputCupon > fm_nMaxPrice && fm_nMaxPrice <= m_nMyClover {
                fm_nInputCupon = fm_nMaxPrice;
                uiCloverInput.text = String(fm_nMaxPrice)
            }else{
                
            }
            uiUseCloverLabel.text = String(fm_nInputCupon).DecimalWon()
            m_nUseClover = fm_nInputCupon;
        }
        LastCalcPay();
    }
    @objc private func onDeliMsgCombo(selectedValue: DownPickerSwift) {
        if selectedValue.getTextField().text == "직접입력".localized {
            uiDeliMsgInput.isEnabled = true;
            uiDeliMsgInput.text = "";
        }else{
            uiDeliMsgInput.text = selectedValue.getTextField().text!;
            uiDeliMsgInput.isEnabled = false;
        }
    }
    @objc private func onCuponCombo(selectedValue: DownPickerSwift) {
        if selectedValue.getTextField().text == "선택안함".localized {
            uiUseCuponLabel.text = "0";
            m_nSelCuponSeq = "";
            m_nSelCuponPrice = 0;
        }else{
            var fm_sCuponPrice = "";
            for val in m_CuponListData{
                if val["title"] == selectedValue.getTextField().text! {
                    fm_sCuponPrice = val["discount_price"] ?? "0";
                    m_nSelCuponSeq = val["coupon_seq"] ?? "0";
                    break;
                }
            }
            m_nSelCuponPrice = Int(fm_sCuponPrice) ?? 0
            uiUseCuponLabel.text = "\(fm_sCuponPrice.DecimalWon())";
        }
        LastCalcPay()
    }
    func setData(data : [String : String], row : Int){
        m_PrdData = data
        DeliveryInfo()
    }
    func setMaxDeliveryPrice(price : String, gage : String){
        m_nMaxDeliveryPrice = Int(price) ?? 0
        m_nOri_MaxDeliveryPrice = m_nMaxDeliveryPrice;
        m_nMaxGage = Int(gage) ?? 0
        LastCalcPay()
    }
    func DeliveryInfo(){
        LoadingHUD.show()
        JS.DeliveryDefInfo(param: ["account_seq":m_sUserSeq, "my_product_seq":m_PrdData["my_product_seq"] ?? ""], callbackf: DeliveryDefInfoCallback)
    }
    func DeliveryDefInfoCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            //self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
            print("DeliveryDefInfoCallback Error ", alldata["errormessage"].string!)
        }else{
            m_DeliAddr["seq"] = alldata["data"]["address_info"]["seq"].stringValue
            m_DeliAddr["is_default"] = alldata["data"]["address_info"]["is_default"].stringValue
            m_DeliAddr["is_last"] = alldata["data"]["address_info"]["is_last"].stringValue
            m_DeliAddr["title"] = alldata["data"]["address_info"]["title"].stringValue
            m_DeliAddr["name"] = alldata["data"]["address_info"]["name"].stringValue
            m_DeliAddr["zipcode"] = alldata["data"]["address_info"]["zipcode"].stringValue
            m_DeliAddr["address1"] = alldata["data"]["address_info"]["address1"].stringValue
            m_DeliAddr["address2"] = alldata["data"]["address_info"]["address2"].stringValue
            m_DeliAddr["phone_number"] = alldata["data"]["address_info"]["phone_number"].stringValue
            m_DeliAddr["military_address"] = alldata["data"]["address_info"]["military_address"].stringValue
            m_DeliAddr["has_additional_cost"] = alldata["data"]["address_info"]["has_additional_cost"].stringValue
            m_DeliAddr["price"] = alldata["data"]["address_info"]["price"].stringValue
           
            m_nMyClover = Int(alldata["data"]["point"].stringValue) ?? 0
            m_isAddedPro = Int(alldata["data"]["groupable"].stringValue) ?? 0
            for subd in alldata["data"]["data_arr"].arrayValue {
                var cuponitem = [String:String]()
                cuponitem["title"] = subd["title"].stringValue;
                cuponitem["discount_price"] = subd["discount_price"].stringValue;
                cuponitem["usage_start_date"] = subd["usage_start_date"].stringValue;
                cuponitem["usage_end_date"] = subd["usage_end_date"].stringValue;
                cuponitem["coupon_seq"] = subd["coupon_seq"].stringValue;
                cuponitem["account_coupon_seq"] = subd["account_coupon_seq"].stringValue;
                m_CuponListData.append(cuponitem)
            }
            setUI();
            
        }
        LoadingHUD.hide()
    }
    func setUI(){
        if m_DeliAddr["seq"]! == "" {
            uiNotAddrView.isHidden = false;
        }else {
            uiNotAddrView.isHidden = true;
        }
        
        m_sAddrSeq = m_DeliAddr["seq"]!;
        uiMyDeAddrTitle.text = " 기본주소".localized(txt: "\(m_DeliAddr["title"] ?? "")");
        uiMyDeAddrTitle.TextPartColor(partstr: "기본주소".localized, Color: UIColor(rgb: 0x00BA87))
        uiMyDeAddr.text =
            """
            \(m_DeliAddr["name"] ?? "") \(m_DeliAddr["phone_number"] ?? "")
            [\(m_DeliAddr["zipcode"] ?? "")] \(m_DeliAddr["address1"] ?? "")
            \(m_DeliAddr["address2"] ?? "")
            """
        var fm_arrCupon = [String]()
        for val in m_CuponListData{
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
        if m_isAddedPro == 0 {
            uiDeliAddCon.text =
                "고객님이 보관하고 계신 상품 중\n묶음 배송 가능한 상품이 없습니다.".localized
            uiDeliAddBtn.isEnabled = false;
            //uiDeliAddCon.TextPartColor(partstr: "없습니다.".localized, Color: UIColor(rgb: 0x00BA87))
        }else{
            uiDeliAddCon.text =
                "고객님이 보관하고 계신 상품 중\n묶음 배송 가능한 상품이 있습니다.".localized
            uiDeliAddBtn.isEnabled = true;
            //uiDeliAddCon.TextPartColor(partstr: "있습니다.".localized, Color: UIColor(rgb: 0x00BA87))
        }
        
        //신선, 냉동 상품 추가됨
        if m_PrdData["shipping_location"] == "400" {
            uiDeliAddCon.text =
                "신선식품은 신선식품간의 묶음배송만 가능합니다.".localized
            uiDeliAddBtn.isEnabled = true;
        }else if m_PrdData["shipping_location"] == "300" {
            uiDeliAddCon.text =
                "냉동식품은 냉동식품간의 묶음배송만 가능합니다.".localized
            uiDeliAddBtn.isEnabled = true;
        }
        //if m_DeliAddr["has_additional_cost"] == "1" {
            let fm_nHAC = Int(m_DeliAddr["price"] ?? "0") ?? 0
            m_nHasAdd_MaxDeliveryPrice = fm_nHAC
            LastCalcPay()
            //setHas_additional_cost()
        //}
    }
//    func setHas_additional_cost(){
//        m_nMaxDeliveryPrice = m_nOri_MaxDeliveryPrice + m_nHasAdd_MaxDeliveryPrice
//        uiDelPayLabel.text = "\(m_nMaxDeliveryPrice)".DecimalWon()
//        LastCalcPay()
//    }
    func getAddrSeq() -> String{
        return m_sAddrSeq
    }
    func getUsePoint() -> Int{
        return m_nUseClover;
    }
    func getPayType() -> Int{
        return m_isPayType; // 0:카드결제, 1:휴대폰 결제, 2:실시간 계죄이체, 3:무통장 입금
    }
    func getUseCupon() -> Int{
        return m_nSelCuponPrice;
    }
    func getUseCuponSeq() -> String {
        return m_nSelCuponSeq;
    }
    func getDeliMsg() ->String {
        return uiDeliMsgInput.text!;
    }
    
    func setAddress(data : [String : String]){
        uiNotAddrView.isHidden = true;
        m_sAddrSeq = data["seq"]!
        if data["is_default"] == "1" {
            uiMyDeAddrTitle.text = " 기본주소".localized(txt: "\(data["title"] ?? "")");
            uiMyDeAddrTitle.TextPartColor(partstr: "기본주소".localized, Color: UIColor(rgb: 0x00BA87))
            uiMyDeAddr.text =
                """
                \(data["name"] ?? "") \(data["phone_number"] ?? "")
                [\(data["zipcode"] ?? "")] \(data["address1"] ?? "")
                \(data["address2"] ?? "")
                """
        }else{
            uiMyDeAddrTitle.text = "\(data["title"] ?? "")";
            uiMyDeAddr.text =
                """
                \(data["name"] ?? "") \(data["phone_number"] ?? "")
                [\(data["zipcode"] ?? "")] \(data["address1"] ?? "")
                \(data["address2"] ?? "")
                """
            
        }
        let fm_nHAC = Int(data["price"] ?? "0") ?? 0
        m_nHasAdd_MaxDeliveryPrice = fm_nHAC
        LastCalcPay()
        //setHas_additional_cost()
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
    }
    
    @IBAction func onDeliAddBtn(_ sender: Any) {
        m_tClickEvent?.ClickEvent(celltype : 1, type: 1, data: [:])
    }
    @IBAction func onDeliAdreeManegeBtn(_ sender: Any) {
        m_tClickEvent?.ClickEvent(celltype : 1, type: 2, data: [:])
    }
    @IBAction func onCloverAllBtn(_ sender: Any) {
        let fm_nMaxPrice : Int = (m_nMaxDeliveryPrice + m_nHasAdd_MaxDeliveryPrice) - m_nSelCuponPrice;
        var fm_nUsePoint  = 0;
        if (fm_nMaxPrice <= m_nMyClover) {
            fm_nUsePoint = fm_nMaxPrice
        }else{
            fm_nUsePoint = m_nMyClover
        }
        
        uiCloverInput.text = "\(fm_nUsePoint)"
        m_nUseClover = fm_nUsePoint;
        uiUseCloverLabel.text = "\(String(fm_nUsePoint).DecimalWon())"
        LastCalcPay();
    }
    @IBAction func onCardBtn(_ sender: Any) {
        m_isPayType = 0;
        setPayBtnSelect()
    }
    @IBAction func onPhoneBtn(_ sender: Any) {
        m_isPayType = 1;
        setPayBtnSelect()
    }
    @IBAction func onRealBankBtn(_ sender: Any) {
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
    @IBAction func onHelpBtn(_ sender: Any) {
        m_tClickEvent?.ClickEvent(celltype : 1, type: 6, data: [:])
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
        
        if !isB {
            PayBtnInit()
        }else{
            
        }
    }
    func LastCalcPay(){
        let fm_nMaxPrice = ((m_nMaxDeliveryPrice + m_nHasAdd_MaxDeliveryPrice) - (m_nUseClover + m_nSelCuponPrice));
        if fm_nMaxPrice <= 0 {
            PayBtnEnabel(isB: false)
        }else{
            PayBtnEnabel(isB: true)
        }
        uiMaxPayLabel.text = "원".localized(txt: "\(String(fm_nMaxPrice).DecimalWon())");
        uiDelPayLabel.text = "\(getOriginLastPayMoney())".DecimalWon()
        uiUseDeliGageLabel.text = "사용된 배송게이지 ".localized(txt: "\(m_nMaxGage)");
        uiUseDeliGageLabel.TextPartColor(partstr: "\(m_nMaxGage)", Color: UIColor(rgb: 0x00BA87))
    }
    func getLastPayment() -> Int{
        return ((m_nMaxDeliveryPrice + m_nHasAdd_MaxDeliveryPrice) - (m_nUseClover + m_nSelCuponPrice))
    }
    func getOriginLastPayMoney() -> Int{
        return (m_nOri_MaxDeliveryPrice + m_nHasAdd_MaxDeliveryPrice)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
    func checkMaxLength(textField: UITextField!, maxLength: Int) {
        if (textField.text?.count ?? 0 > maxLength) {
            textField.deleteBackward()
        }
    }
    @IBAction func onDelirymsg(_ sender: Any) {
        checkMaxLength(textField: uiDeliMsgInput, maxLength: 50)
    }
    
}
extension DeliveryBodyCell : UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
}
