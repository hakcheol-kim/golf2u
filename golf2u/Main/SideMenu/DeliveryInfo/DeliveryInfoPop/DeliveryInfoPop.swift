//
//  DeliveryInfoPop.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/24.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON

class DeliveryInfoPop: VariousViewController {
    private let SO = Single.getSO();
    private let JS = JsonC();
    
    private var m_sUserSeq : String = "";
    private var m_sDeliSeq : String = "";
    
    private var m_sDelState : String = "";
    
    @IBOutlet weak var uiTitle1lb: UILabel!
    @IBOutlet weak var uiTitle2lb: UILabel!
    @IBOutlet weak var uiTitle3lb: UILabel!
    @IBOutlet weak var uiTitle4lb: UILabel!
    @IBOutlet weak var uiTitle5lb: UILabel!
    
    @IBOutlet weak var uiDeliStatus: UILabel!
    @IBOutlet weak var uiProducts: UITextView!
    @IBOutlet weak var uiUserNAme: UILabel!
    @IBOutlet weak var uiPhone: UILabel!
    @IBOutlet weak var uiAddr: UILabel!
    @IBOutlet weak var uiDeliMsg: UITextView!
    @IBOutlet weak var uiAccBtn: UIButton!
    @IBOutlet weak var uiBankBtn: UIButton!
    private var m_sBankInfo = "" ;
    
    private var m_sDeliTrackingID = "";
    
    
    static func instantiate() -> DeliveryInfoPop? {
        return UIStoryboard(name: "DeliveryInfoPop", bundle: nil).instantiateViewController(withIdentifier: "\(DeliveryInfoPop.self)") as? DeliveryInfoPop
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiTitle1lb.text = "배송 상세정보".localized
        uiTitle2lb.text = "배송상태".localized
        uiTitle3lb.text = "배송상품".localized
        uiTitle4lb.text = "배송지 정보".localized
        uiTitle5lb.text = "배송 메세지".localized
        uiAccBtn.setTitle("확인".localized, for: .normal)
        uiBankBtn.setTitle("입금계좌정보".localized, for: .normal)
        
        m_sUserSeq = super.getUserSeq()
        
        self.uiAccBtn.layer.addBorder([.top], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        uiBankBtn.layer.cornerRadius = 8.0;
        uiBankBtn.layer.borderWidth = 1.0
        uiBankBtn.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        let tapGestureRecognizer1 = UITapGestureRecognizer(target:self, action: #selector(self.onDeliStateTxt(tapGesture:)))
        tapGestureRecognizer1.numberOfTapsRequired = 1
        uiDeliStatus.isUserInteractionEnabled = true
        uiDeliStatus.addGestureRecognizer(tapGestureRecognizer1)
        
        LoadItem();
    }
    @objc func onDeliStateTxt(tapGesture: UITapGestureRecognizer){
        if m_sDelState == "10" || m_sDelState == "100" {
            UIPasteboard.general.string = m_sDeliTrackingID
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            window?.makeToast("클립보드에 복사되었습니다.".localized)
        }
    }
    func setData(DeliSeq : String){
        m_sDeliSeq = DeliSeq
    }
    func LoadItem(){
        LoadingHUD.show()
        JS.getOrder(param: ["order_seq":m_sDeliSeq,"account_seq":m_sUserSeq], callbackf: getOrderCallback)
    }
    func getOrderCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            m_sDeliTrackingID = "\(alldata["data"]["logistics_tracking_id"].stringValue) \(alldata["data"]["logistics_company_title"].stringValue)"
            m_sDelState =  alldata["data"]["state"].stringValue
            uiDeliStatus.text = alldata["data"]["state_txt"].stringValue
            if m_sDelState == "10" || m_sDelState == "100" {
                //배송중, 배송완료 일때 복사 기능넣기위해서
                let rangeToUnderLine = (alldata["data"]["state_txt"].stringValue as NSString).range(of: "\(alldata["data"]["logistics_company_title"].stringValue) \(alldata["data"]["logistics_tracking_id"].stringValue)")
                let underLineTxt = NSMutableAttributedString(string: alldata["data"]["state_txt"].stringValue, attributes: [:])
                underLineTxt.addAttribute(.foregroundColor, value: UIColor.blue, range: (alldata["data"]["state_txt"].stringValue as NSString).range(of: "\(alldata["data"]["logistics_company_title"].stringValue) \(alldata["data"]["logistics_tracking_id"].stringValue)"))
                underLineTxt.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: rangeToUnderLine)
                uiDeliStatus.attributedText = underLineTxt
            }
            uiProducts.text = alldata["data"]["products_txt"].stringValue
            uiUserNAme.text = alldata["data"]["name"].stringValue
            uiPhone.text = alldata["data"]["phone_number"].stringValue
            uiAddr.text = "\(alldata["data"]["address1"].stringValue)\n\(alldata["data"]["address2"].stringValue)"
            uiDeliMsg.text = alldata["data"]["comment"].stringValue
            if alldata["data"]["vbank_exists"].stringValue == "1" {
                uiBankBtn.isHidden = false;
            }else{
                uiBankBtn.isHidden = true;
            }
            
            let fm_Line1 = "은행명 : ".localized(txt: "\(alldata["data"]["vbank_name"].stringValue)")
            let fm_Line2 = "입금계좌번호 : ".localized(txt: "\(alldata["data"]["vbank_number"].stringValue)")
            let fm_Line3 = "입금만기일 : ".localized(txt: "\(alldata["data"]["vbank_expire_at"].stringValue)")
            m_sBankInfo = "\(fm_Line1)\n\(fm_Line2)\n\(fm_Line3)"
        }
        LoadingHUD.hide()
    }
    @IBAction func onAcc(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func onBankBtn(_ sender: Any) {
        MessagePop(title : "입금 계좌 정보".localized, msg: m_sBankInfo, btntype : 2)
    }
    
}
