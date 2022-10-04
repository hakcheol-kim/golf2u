//
//  GiftCode.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/10.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import EzPopup
import SwiftyJSON
import MessageUI//문자전송


class GiftCode: VariousViewController {
    private let SO = Single.getSO();
    private let JS = JsonC();
    
    private var m_sTitle = "선물".localized;
    
    @IBOutlet weak var uiImg: UIImageView!
    @IBOutlet weak var uiName: UILabel!
    @IBOutlet weak var uiPay: UILabel!
    @IBOutlet weak var uiDate: UILabel!
    @IBOutlet weak var uiTopView: UIView!
    private var uiTopViewConstraint: NSLayoutConstraint?
    @IBOutlet weak var uiBottomView: UIView!
    
    @IBOutlet weak var uiCodeBtnPre: UIButton!
    @IBOutlet weak var uiCodeBtnRPre: UIButton!
    @IBOutlet weak var uiCodeBtnNext: UIButton!
    @IBOutlet weak var uiUseDate: UILabel!
    
    @IBOutlet weak var uiPreContentsLabel: UILabel!
    @IBOutlet weak var uiFriendGiftBtn: UIButton!
    
    @IBOutlet weak var uiCodeCopyBtn: UIButton!
    @IBOutlet weak var uiKakaoBtn: UIButton!
    @IBOutlet weak var uiSmsBtn: UIButton!
    @IBOutlet weak var uiNextContentsLabel: UILabel!
    
    
    @IBOutlet var uiPreCodeView: UIView!
    @IBOutlet var uiNextCodeView: UIView!
    
    @IBOutlet var uiPreContentsView: UIView!
    @IBOutlet var uiNextContentsView: UIView!
    
    @IBOutlet weak var uiEventImg: UIImageView!
    
    private var m_nViewType = 0;//1:랜덤, 2:이벤트박스, 3:상품
    private var m_sData = [String : String]()
    private var m_sBoxSeq = "";
    private var m_sProSeq = "";
    private var m_sCodeCreate = "";
    private var m_sAleadyCode = "";
    private var m_sUseCodeDate = "";
    private var m_nShereImg = "";
    private let m_sContentsText = [
        "선물코드의 유효기간은 72시간입니다.\n유효기간 내 선물코드 변경 및 취소, 해당 랜덤박스의 박스열기, 결제취소는 불가능합니다.\n유효기간 내에 상대방이 선물을 수령하지 않을 경우, 선물코드 발행이 취소되고 해당 랜덤박스는 박스보관함으로 이동됩니다.".localized
        
    ,"선물코드의 유효기간은 72시간입니다.\n유효기간 내 선물코드의 변경 및 취소, 해당 상품의 트레이드, 배송신청, 클로버환급은 불가능합니다.\n유효기간 내에 상대방이 선물을 수령하지 않을 경우, 선물코드 발행이 취소되고 해당 상품은 상품보관함으로 이동됩니다.\n(단, 보관만료일이 5일 이하로 남게될 경우 유효기간과 관계없이 코드발행이 취소됩니다 .)".localized
    ];
    
    func setData(type : Int, data : [String : String], code : String = ""){
        m_nViewType = type
        m_sData = data
        m_sAleadyCode = code
    }
    override func viewDidLoad() {
        if m_nViewType == 1 {
            m_sTitle = "박스 선물".localized;
        }else  if m_nViewType == 2 {
            m_sTitle = "박스 선물".localized;
        }else  if m_nViewType == 3 {
            m_sTitle = "상품 선물".localized;
        }
        super.InitVC(type: Single.DE_INITNAVISUB, title: m_sTitle)
        super.viewDidLoad()
        
        uiCodeBtnPre.setTitle("선물코드를 생성하세요".localized, for: .normal)
        uiCodeBtnRPre.setTitle("코드 생성".localized, for: .normal)
        uiCodeBtnNext.setTitle("선물코드를 생성하세요".localized, for: .normal)
        uiFriendGiftBtn.setTitle("친구에게 선물하기".localized, for: .normal)
        uiCodeCopyBtn.setTitle("코드 복사하기".localized, for: .normal)
        uiKakaoBtn.setTitle("카카오톡 전송하기".localized, for: .normal)
        uiSmsBtn.setTitle("SMS 전송하기".localized, for: .normal)
        
        uiImg.layer.cornerRadius = 8.0;
        uiImg.layer.borderWidth = 1.0
        uiImg.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        //uiCodeBtnPre.layer.roundCorners(corners: [.topLeft, .bottomLeft], radius: 8.0)
        uiCodeBtnPre.layer.cornerRadius = 8.0;
        uiCodeBtnPre.layer.borderWidth = 1.0
        uiCodeBtnPre.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        uiCodeBtnRPre.layer.roundCorners(corners: [.topRight, .bottomRight
        ], radius: 8.0)
        uiFriendGiftBtn.layer.cornerRadius = uiFriendGiftBtn.frame.height/2
        
        uiCodeBtnNext.layer.cornerRadius = 8.0;
        uiCodeBtnNext.layer.borderWidth = 1.0
        uiCodeBtnNext.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        uiCodeCopyBtn.layer.cornerRadius = 8.0;
        uiCodeCopyBtn.layer.borderWidth = 1.0
        uiCodeCopyBtn.layer.borderColor = UIColor(rgb: 0x00BA87).cgColor
        
        uiKakaoBtn.layer.cornerRadius = 8.0;
        uiKakaoBtn.layer.borderWidth = 1.0
        uiKakaoBtn.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        uiSmsBtn.layer.cornerRadius = 8.0;
        uiSmsBtn.layer.borderWidth = 1.0
        uiSmsBtn.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
//        uiBottomView.layer.addBorder([.top], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
        if m_nViewType == 1 {
            m_nShereImg = "\(Single.DE_URLIMGSERVER)/uploads/static/randombox.png"
            uiImg.image = UIImage(named: "randombox")
            uiName.text = "랜덤투유 랜덤박스".localized;
            uiPay.text = m_sData["box_explain"];
            uiDate.text = "구매일 | ".localized(txt: "\(m_sData["created_at"]!)");
            uiPreContentsLabel.text = m_sContentsText[0]
            uiNextContentsLabel.text = m_sContentsText[0]
            m_sBoxSeq = m_sData["seq"]!;
        }else  if m_nViewType == 2 {
            m_nShereImg = "\(Single.DE_URLIMGSERVER)/uploads/static/eventbox.png"
            uiImg.image = UIImage(named: "inven_eventbox")
            uiName.text = "랜덤투유 이벤트박스".localized;
            uiPay.text = m_sData["box_explain"];
            uiDate.text = "구매일 | \(m_sData["created_at"]!)".localized(txt: "\(m_sData["created_at"]!)");
            uiPreContentsLabel.text = m_sContentsText[0]
            uiNextContentsLabel.text = m_sContentsText[0]
            m_sBoxSeq = m_sData["seq"]!;
        }else  if m_nViewType == 3 {
            uiImg.image = nil
            if let imgurl = m_sData["thumbnail"]{
                uiImg.setImage(with: "\(Single.DE_URLIMGSERVER)\(imgurl)")
                m_nShereImg = "\(Single.DE_URLIMGSERVER)\(imgurl)"
            }
            uiName.text = m_sData["name"];
            uiPay.text = "정가 | 원".localized(txt: "\(m_sData["price"]!.DecimalWon())");
            uiDate.text = "보관만료일 | ".localized(txt: "\(m_sData["expired_at_dt"]!)");
            uiPreContentsLabel.text = m_sContentsText[1]
            uiNextContentsLabel.text = m_sContentsText[1]
            m_sProSeq = m_sData["my_product_seq"]!;
            if m_sData["box_type"] == "2" {
                uiEventImg.isHidden = false;
            }else{
                uiEventImg.isHidden = true;
            }
        }
        
        if m_sAleadyCode == "" {
            setContentsView(PrentV: uiTopView, uiView: uiPreCodeView)
            setContentsView(PrentV: uiBottomView, uiView: uiPreContentsView)
        }else{
            m_sCodeCreate = m_sAleadyCode
            uiCodeBtnNext.setTitle(m_sCodeCreate, for: .normal)
            uiUseDate.text = "유효기간 | ".localized(txt: "\(m_sData["gift_expired_at_dt"] ?? "")")
            setContentsView(PrentV: uiTopView, uiView: uiNextCodeView)
            setContentsView(PrentV: uiBottomView, uiView: uiNextContentsView)
        }
        
        uiTopViewConstraint = uiTopView.heightConstraint;
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if m_sAleadyCode == "" {
            self.uiTopViewConstraint?.constant = 70
            self.view.layoutIfNeeded()
        }else{
            self.uiTopViewConstraint?.constant = 120
            self.view.layoutIfNeeded()
        }
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    func setContentsView(PrentV : UIView, uiView : UIView){
        for v in PrentV.subviews{
            v.removeFromSuperview()
        }
        
        PrentV.addSubview(uiView)
        
        uiView.translatesAutoresizingMaskIntoConstraints = false
        uiView.topAnchor.constraint(equalTo: PrentV.topAnchor,constant: 0).isActive = true
        uiView.leftAnchor.constraint(equalTo:PrentV.leftAnchor,constant: 0).isActive = true
        uiView.rightAnchor.constraint(equalTo: PrentV.rightAnchor, constant: 0).isActive = true
        uiView.bottomAnchor.constraint(equalTo: PrentV.bottomAnchor, constant: 0).isActive = true
    }
    @IBAction func onFriendGiftBtn(_ sender: Any) {
        let Storyboard: UIStoryboard = UIStoryboard(name: "FriendMain", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "FriendMainidx") as! FriendMain
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    @IBAction func onCodeCreateBtn(_ sender: Any) {
        if SO.getUserInfoKey(key: Single.DE_USERVERIFIED) == "0" {
            MessagePop(title : "본인인증".localized, msg: "본인인증 후 사용하실수있습니다.".localized, ostuch:false, lbtn: "취소".localized, rbtn: "본인인증".localized,succallbackf: { ()-> Void in
                //self.navigationController?.popViewController(animated: true);
                let Storyboard: UIStoryboard = UIStoryboard(name: "UserVerification", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "UserVerificationidx") as! UserVerification
                viewController.setData(data: ["os_type":Single.DE_PLATFORMIDX, "account_seq":super.getUserSeq()])
                self.navigationController?.pushViewController(viewController, animated: true)
            }, closecallbackf: { ()-> Void in
                //self.navigationController?.popViewController(animated: true);
            })
        }else{
            MessagePop(title : "선물코드 생성".localized, msg: "선물코드 유효기간(72시간) 내 코드 변경 및 취소 불가능\n\n유효기간 내 박스열기, 결제취소 불가능\n\n코드를 생성 하시겠습니까?".localized, lbtn: "취소".localized, rbtn: "코드 생성".localized,succallbackf: { ()-> Void in
                LoadingHUD.show()
                self.JS.GiftCodeCreate(param: ["random_box_seq":self.m_sBoxSeq,"my_product_seq":self.m_sProSeq,"account_seq":super.getUserSeq()], callbackf: self.GiftCodeCreateCallback)
            }, closecallbackf: { ()-> Void in
                
            })
        }
        
    }
    
    func GiftCodeCreateCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            MessagePop(msg: alldata["errormessage"].stringValue, btntype : 2)
        }else{
            self.uiTopViewConstraint?.constant = 120
            self.view.layoutIfNeeded()
            m_sCodeCreate = alldata["data"]["code"].stringValue;
            uiCodeBtnNext.setTitle(m_sCodeCreate, for: .normal)
            uiUseDate.text = "유효기간 | ".localized(txt: "\(alldata["data"]["expired_at_dt"].stringValue)")
            m_sUseCodeDate = "\(alldata["data"]["expired_at_dt"].stringValue)"
            setContentsView(PrentV: uiTopView, uiView: uiNextCodeView)
            setContentsView(PrentV: uiBottomView, uiView: uiNextContentsView)
            //SO.getInventoryMain()?.ViewRefrashEvent()
            if m_nViewType == 3 {
                //상품 보관함에서 선물할경우는 상품보관함 을 새로고침하면 너무 비효율적이라 해당 항목만 초기화
                SO.getInventoryMain()?.GiftFinishCallback()
            }else {
                //상품보관함 이 아닌 나머지는 새로고침
                SO.getInventoryMain()?.ViewRefrashEvent()
            }
            
        }
        LoadingHUD.hide()
    }
    @IBAction func onCopyBtn(_ sender: Any) {
        UIPasteboard.general.string = m_sCodeCreate
        self.view.makeToast("코드가 복사되었습니다.".localized)
    }
    @IBAction func onKakaoShare(_ sender: Any) {

        //let text = "랜덤투유\\n선물코드 : ".localized(txt: "\(m_sCodeCreate)")
        if m_nViewType == 3 {
            //상품공유
            KakaoShare(title: "선물코드 : \(m_sCodeCreate)\\n유효기간 : \(m_sUseCodeDate)까지", contents: "유효기간 내에 선물을 수령하세요!\\n회원가입 > 인벤토리 > 선물함", imgurl: m_nShereImg)
        }else{
            KakaoShare(title: "선물코드 : \(m_sCodeCreate)\\n유효기간 : \(m_sUseCodeDate)까지", contents: "유효기간 내에 선물을 수령하세요!\\n회원가입 > 인벤토리 > 선물함", imgurl: m_nShereImg)
        }
        
    }
    @IBAction func onSmsShare(_ sender: Any) {
        guard MFMessageComposeViewController.canSendText() else {
            print("SMS services are not available")
            return
        }
        let text = "선물코드 : \(m_sCodeCreate)\n유효기간 : \(m_sUseCodeDate)까지\n유효기간 내에 선물을 수령하세요!\n회원가입 > 인벤토리 > 선물함";//\nhttps://random2u.page.link/LbNr
        let composeViewController = MFMessageComposeViewController()
        composeViewController.messageComposeDelegate = self
        composeViewController.recipients = [""]
        composeViewController.body = text
        //self.navigationController?.pushViewController(composeViewController, animated: true)
        self.present(composeViewController, animated: true, completion: nil)
    }
}
extension GiftCode: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .cancelled:
            print("cancelled")
            dismiss(animated: true, completion: nil)
        case .sent:
            print("sent message:", controller.body ?? "")
            dismiss(animated: true, completion: nil)
        case .failed:
            print("failed")
            dismiss(animated: true, completion: nil)
        @unknown default:
            print("unkown Error")
            dismiss(animated: true, completion: nil)
        }
    }
}
