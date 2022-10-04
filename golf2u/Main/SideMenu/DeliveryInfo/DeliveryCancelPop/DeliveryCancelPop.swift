//
//  DeliveryCancelPop.swift
//  golf2u
//
//  Created by 이원영 on 2021/02/23.
//  Copyright © 2021 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON
import AppsFlyerLib
//import DownPickerSwift

class DeliveryCancelPop: VariousViewController {

    private var SO:Single = Single.getSO();
    private let JS = JsonC();
    
    @IBOutlet weak var uiTitlelb: UILabel!
    @IBOutlet weak var uiUserNameInput: UITextField!
    @IBOutlet weak var uiBankNumInput: UITextField!
    @IBOutlet weak var uiSucBtn: UIButton!
    @IBOutlet weak var uiCanBtn: UIButton!
    @IBOutlet weak var uiBankList: UITextField!
    private var uiBankListDP: DownPickerSwift?
    
    private var m_sSeq = "";
    private var m_sUSerSeq = "";
    private var m_tDI : DeliveryInfo?
    
    private var BankList = Array<[String]>();
    
    private var m_PayCancelData : [String:String]?
    
    static func instantiate() -> DeliveryCancelPop? {
        return UIStoryboard(name: "DeliveryCancelPop", bundle: nil).instantiateViewController(withIdentifier: "\(DeliveryCancelPop.self)") as? DeliveryCancelPop
    }
    func setData(seq : String, data : [String: String], tDI : DeliveryInfo){
        m_sSeq = seq;
        m_sUSerSeq = super.getUserSeq()
        m_PayCancelData = data
        m_tDI = tDI
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiTitlelb.text = "환불받으실 계좌 정보를\n입력해주세요.".localized;
        //self.uiSucBtn.layer.addBorder([.top,], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
        uiUserNameInput.layer.cornerRadius = 8.0;
        uiUserNameInput.layer.borderWidth = 1.0
        uiUserNameInput.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiUserNameInput.addLeftPadding()
        uiUserNameInput.placeholder = "예금주 를 입력해주세요.".localized;
        
        uiBankNumInput.layer.cornerRadius = 8.0;
        uiBankNumInput.layer.borderWidth = 1.0
        uiBankNumInput.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiBankNumInput.addLeftPadding()
        uiBankNumInput.placeholder = "계좌번호(숫자만)입력해주세요.".localized;
        
        uiSucBtn.setTitle("확인".localized, for: .normal)
        uiCanBtn.setTitle("취소".localized, for: .normal)
        
        
        BankList = SO.getBankList();
        var fm_arrBankName = [String]()
        for val in BankList{
            fm_arrBankName.append(val[1])
        }
        uiBankList.layer.cornerRadius = 8.0;
        uiBankList.layer.borderWidth = 1.0
        uiBankList.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiBankList.addLeftPadding()
        uiBankListDP = DownPickerSwift(with: uiBankList, with: fm_arrBankName)
        uiBankListDP?.showArrowImage(false)
        uiBankListDP?.setToolbarDoneButton(with: "확인")
        uiBankListDP?.setToolbarCancelButton(with: "취소")
        uiBankListDP?.setPlaceholder(with: "은행을 선택하세요.".localized)
        uiBankListDP?.addTarget(self, action: #selector(printTest(selectedValue:)), for: .valueChanged)


    }
    
    @objc private func printTest(selectedValue: DownPickerSwift) {
        //print(selectedValue.text)
    }
    @IBAction func onCloseBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func onSucBtn(_ sender: Any) {
        let fm_sUserName = uiUserNameInput.text!
        let fm_sBankNum = uiBankNumInput.text!
        let fm_sBankName = uiBankList.text!
        
        if fm_sUserName == "" {
            super.MessagePop(msg: "예금주 를 입력해주세요.".localized, btntype : 2)
            return;
        }else if fm_sBankNum == "" {
            super.MessagePop(msg: "계좌번호(숫자만) 입력해주세요.".localized, btntype : 2)
            return;
        }else if fm_sBankName == "" {
            super.MessagePop(msg: "은행을 선택해주세요.".localized, btntype : 2)
            return;
        }
        
        var fm_sBankCode = "";
        for val in BankList{
            if val[1] == fm_sBankName {
                fm_sBankCode = val[0];
                break;
            }
        }
        LoadingHUD.show()
        //JS.BoxBuyCancel(param: ["account_seq":m_sUSerSeq, "random_box_seq":m_sSeq, "refund_account":fm_sUserName, "refund_bank":fm_sBankCode, "refund_accountnumber":fm_sBankNum], callbackf: BoxBuyCancelCallback)
        self.JS.cancelOrder(param: ["account_seq":self.m_sUSerSeq,"order_seq":m_PayCancelData!["seq"] ?? "","refund_account":fm_sUserName, "refund_bank":fm_sBankCode, "refund_accountnumber":fm_sBankNum], callbackf: self.cancelOrderCallback)
        
    }
    func cancelOrderCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            MessagePop(msg: alldata["errormessage"].stringValue, btntype : 2)
        }else{
            self.view.makeToast("결제가 취소되었습니다. (환불완료까지 최대 5 영업일이 소요됩니다.)".localized)
            if let data = m_PayCancelData {
                let params : [String: Any] = [
                    "userseq":super.getUserSeq()
                    ,"payInfos":data
                    
                ];
                SO.setUserInfoKey(key: Single.DE_USERCLOVER, value: alldata["data"]["point"].stringValue )
                Analytics(eventname: "deliverycancel", params: params)
                
                let paramsAF : [String: Any] = [
                    AFEventParamReceiptId : m_PayCancelData!["seq"] ?? "",
                    "af_product_id" : alldata["data"]["product_seqs"],
                    "af_product_category" : alldata["data"]["category_seqs"],
                    "af_product_quantity" : alldata["data"]["product_cnt"],
                    "af_delivery_fee" : alldata["data"]["canceled_price"]
                ];
                AppsflyerLog(AFTitle: "af_delivery_cancel", params: paramsAF)
            }
            m_tDI?.refresh()
            dismiss(animated: true, completion: nil)
        }
        LoadingHUD.hide()
    }
//    func BoxBuyCancelCallback(alldata: JSON)->Void {
//        if alldata["errorcode"] != "0"{
//            super.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
//        }else{
//            if let data = m_PayCancelData {
//                let params : [String: Any] = [
//                    "userseq":super.getUserSeq()
//                    ,"payseq":data["purchase_seq"] ?? "0"
//                    ,"paymethod":data["payment_method"] ?? "0"
//                    ,"cancelprice":data["price"] ?? "0"
//                    ,"cancelcupon":data["coupon"] ?? "0"
//                    ,"cancelclover":data["point"] ?? "0"
//                    ,"boxtype":data["type"] ?? "0"
//
//                ];
//                SO.setUserInfoKey(key: Single.DE_USERCLOVER, value: alldata["data"]["point"].stringValue )
//                Analytics(eventname: "boxbuycancel", params: params)
//            }
//            dismiss(animated: true, completion: nil)
//        }
//
//    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    

}
