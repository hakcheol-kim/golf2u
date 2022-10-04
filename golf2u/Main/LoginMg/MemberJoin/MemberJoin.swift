//
//  MemberJoin.swift
//  golf2u
//
//  Created by 이원영 on 2020/09/18.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import EzPopup

class MemberJoin: VariousViewController {
    
    @IBOutlet weak var uiTitle: UILabel!
    @IBOutlet weak var uiSubTitle: UILabel!
    @IBOutlet weak var uiAllAgreelb: UILabel!
    @IBOutlet weak var uiAgreetitlelb: UILabel!
    @IBOutlet weak var uiAgree1lb: UILabel!
    @IBOutlet weak var uiAgree2lb: UILabel!
    @IBOutlet weak var uiAgree3lb: UILabel!
    @IBOutlet weak var uiAgree4lb: UILabel!
    @IBOutlet weak var uiHelplb: UILabel!
    @IBOutlet weak var allgreebtn: CircleCheckBoxBtn!
    @IBOutlet weak var servicebtn: UIButton!
    @IBOutlet weak var userinfobtn: UIButton!
    
    @IBOutlet weak var serviceagreebtn: CircleCheckBoxBtn!
    @IBOutlet weak var userinfoagreebtn: CircleCheckBoxBtn!
    @IBOutlet weak var tradeareebtn: CircleCheckBoxBtn!
    @IBOutlet weak var eventagreebtn: CircleCheckBoxBtn!
    
    @IBOutlet weak var nextbtn: UIButton!
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "")
        super.viewDidLoad()
        
        uiTitle.text = "회원가입 약관 동의".localized
        uiSubTitle.text = "필수 약관에 동의해야 회원가입이 가능합니다.".localized
        uiAllAgreelb.text = "전체동의".localized
        uiAgreetitlelb.text = "동의항목".localized
        uiAgree1lb.text = "서비스 이용약관 동의(필수)".localized
        uiAgree2lb.text = "개인정보 수집 및 이용 동의(필수)".localized
        uiAgree3lb.text = "트레이드, 시스템 알림 동의".localized
        uiAgree4lb.text = "이벤트 광고 알림 동의".localized
        servicebtn.setTitle("자세히".localized, for: .normal)
        userinfobtn.setTitle("자세히".localized, for: .normal)
        uiHelplb.text = "Random2u에 회원가입을 신청하시면 신청자는 만 14세 이상이며, 이용약관, 개인정보 수집 및 이용 동의 내용을 확인 및 동의하는 것을 간주합니다.".localized
        nextbtn.setTitle("다음".localized, for: .normal)
        
        self.allgreebtn.m_tClickEvent = self;
        
        //버튼 밑줄긋기
        let attributedString = NSAttributedString(string: NSLocalizedString("자세히".localized, comment: ""), attributes:[
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14.0),
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x999999),
            NSAttributedString.Key.underlineStyle:1.0
        ])
        servicebtn.setAttributedTitle(attributedString, for: .normal)
        userinfobtn.setAttributedTitle(attributedString, for: .normal)
        
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 11.0, *) {
            if (UIDevice.current.hasNotch) {
                //아이폰x 부터 하단 safe 영역 버튼이 있으면 여기서 처리
                //let topPadding = self.view.safeAreaInsets.top
                //let leftPadding = self.view.safeAreaInsets.left
                //let rightPadding = self.view.safeAreaInsets.right
                let bottomPadding = self.view.safeAreaInsets.bottom;
                nextbtn.frame = CGRect(x: 0, y: Int(nextbtn.frame.minY), width: Int(nextbtn.frame.size.width), height: Int(nextbtn.frame.size.height + bottomPadding))
                nextbtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
            }
        }
    }
    @IBAction func onNextBtn(_ sender: Any) {
        if !serviceagreebtn.isChecked || !userinfoagreebtn.isChecked {
            MessagePop(msg: "필수 동의 항목을 체크 하세요.".localized, btntype : 2);
            
            return;
        }
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "EmailCheckidx") as! EmailCheck
        viewController.setData(type: 1, Agree1: serviceagreebtn.isChecked, Agree2: userinfoagreebtn.isChecked, Agree3: tradeareebtn.isChecked, Agree4: eventagreebtn.isChecked)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        guard let view = segue.destination as? MemberInfoJoin else{return}
//        view.m_isAgree1 = serviceagreebtn.isChecked
//        view.m_isAgree2 = userinfoagreebtn.isChecked
//        view.m_isAgree3 = tradeareebtn.isChecked
//        view.m_isAgree4 = eventagreebtn.isChecked
//        
//    }
    @IBAction func onAgree1(_ sender: Any) {
        let Storyboard: UIStoryboard = UIStoryboard(name: "UsePolicy", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "UsePolicyidx") as! UsePolicy
        viewController.setUrl(url: "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Policy/Policy", f_sTitle: "이용 약관".localized, menuidx : 0)
        viewController.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    @IBAction func onAgree2(_ sender: Any) {
        let Storyboard: UIStoryboard = UIStoryboard(name: "UsePolicy", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "UsePolicyidx") as! UsePolicy
        viewController.setUrl(url: "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Policy/Privacy", f_sTitle: "개인정보처리방침".localized, menuidx : 1)
        viewController.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
}

extension MemberJoin: ClickCircleEventDelegate {
    func ClickEvent(isChecked: Bool, compo : CircleCheckBoxBtn){
        if compo == allgreebtn{
            if isChecked {
                self.serviceagreebtn.buttonStateModify(isA:true)
                self.userinfoagreebtn.buttonStateModify(isA:true)
                self.tradeareebtn.buttonStateModify(isA:true)
                self.eventagreebtn.buttonStateModify(isA:true)
            }else{
                self.serviceagreebtn.buttonStateModify(isA:false)
                self.userinfoagreebtn.buttonStateModify(isA:false)
                self.tradeareebtn.buttonStateModify(isA:false)
                self.eventagreebtn.buttonStateModify(isA:false)
            }
        }
        
    }
}
