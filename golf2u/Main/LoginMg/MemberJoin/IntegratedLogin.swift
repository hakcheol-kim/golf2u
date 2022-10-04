//
//  MemberJoin.swift
//  random2u_new
//
//  Created by 이원영 on 2020/09/18.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import EzPopup
import SwiftyJSON

class IntegratedLogin: VariousViewController {
    private var SO:Single = Single.getSO();
    private let JS = JsonC();
    
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
    @IBOutlet weak var userinfobtn: UIButton!
    
    @IBOutlet weak var serviceagreebtn: CircleCheckBoxBtn!
    @IBOutlet weak var userinfoagreebtn: CircleCheckBoxBtn!
    @IBOutlet weak var tradeareebtn: CircleCheckBoxBtn!
    @IBOutlet weak var eventagreebtn: CircleCheckBoxBtn!
    
    @IBOutlet weak var nextbtn: UIButton!
    @IBOutlet weak var cancelinsbtn: UIButton!
    @IBOutlet weak var uiBtnView: UIView!
    
    private var m_nType : Int = 1;//1:일반 회원가입, 2:sns회원가입, 3:휴면계정 메일인증
    private var m_sSnsType : String = "";
    private var m_sUserKey : String = "";
    private var m_sUSeq : String = "";
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "")
        super.viewDidLoad()
        
        uiTitle.text = "네모난오렌지 통합회원 동의".localized
        uiSubTitle.text = "".localized
        uiAllAgreelb.text = "전체동의".localized
        uiAgreetitlelb.text = "동의항목".localized
        uiAgree1lb.text = "랜덤투유 통합서비스 이용약관 동의(필수)".localized
        uiAgree2lb.text = "개인정보 수집 및 이용 동의(필수)".localized
        uiAgree3lb.text = "광고성 정보 수신 동의(선택)".localized
        uiAgree4lb.text = "푸시 수신 동의(선택)".localized
        userinfobtn.setTitle("자세히".localized, for: .normal)
        uiHelplb.text = "Ran2에 회원가입을 신청하시면 신청자는\n만 14세 이상이며, 이용약관, 개인정보 수집 및 이용\n동의 내용을 확인 및 동의하는 것을 간주합니다.\n\n랜덤투유 통합회원에 동의 시 기존에 사용하시던\n서비스로 로그인이 가능합니다. ".localized
        nextbtn.setTitle("동의".localized, for: .normal)
        
        self.allgreebtn.m_tClickEvent = self;
        
        //버튼 밑줄긋기
        let attributedString = NSAttributedString(string: NSLocalizedString("자세히".localized, comment: ""), attributes:[
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14.0),
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x999999),
            NSAttributedString.Key.underlineStyle:1.0
        ])
        userinfobtn.setAttributedTitle(attributedString, for: .normal)
        
        
    }
    func setData(useq : String, type : Int){
        m_sUSeq = useq
        m_nType = type
    }
    func setData(useq : String, snstype : String, usersnskey : String){
        m_sUSeq = useq
        m_sSnsType = snstype;
        m_sUserKey = usersnskey;
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
                uiBtnView.frame = CGRect(x: 0, y: Int(uiBtnView.frame.minY), width: Int(uiBtnView.frame.size.width), height: Int(uiBtnView.frame.size.height + bottomPadding))
            }

        }
    }
    func MemberJoinCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            let fm_Contrllers = self.navigationController?.viewControllers
            if let val = fm_Contrllers{
                for VC in val{
                    if VC is LoginView {
                        let VCC = VC as! LoginView
                        for (k, v) in alldata["data"]{
                            if let val = v.string{
                                SO.setUserInfoKey(key: k, value: val)
                            }
                        }
                        self.navigationController?.popToViewController(VC, animated: true)
                        VCC.MemberJoinFinish()
                        break;
                    }
                    
                }
            }
            
            
        }
        LoadingHUD.hide()
    }
    @IBAction func onNextBtn(_ sender: Any) {
        if !serviceagreebtn.isChecked || !userinfoagreebtn.isChecked {
            MessagePop(msg: "필수 동의 항목을 체크 하세요.".localized, btntype : 2);
            
            return;
        }
        JS.IntegratedLogin(param: ["seq":m_sUSeq,"sns_type":m_sSnsType,"user_key":m_sUserKey,"is_agree1_terms":(serviceagreebtn.isChecked ? "1":"0"),"is_agree2_terms":(userinfoagreebtn.isChecked ? "1":"0"),"is_agree3_terms":(tradeareebtn.isChecked ? "1":"0"),"is_agree4_terms":(eventagreebtn.isChecked ? "1":"0")], callbackf: MemberJoinCallback)
    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        guard let view = segue.destination as? MemberInfoJoin else{return}
//        view.m_isAgree1 = serviceagreebtn.isChecked
//        view.m_isAgree2 = userinfoagreebtn.isChecked
//        view.m_isAgree3 = tradeareebtn.isChecked
//        view.m_isAgree4 = eventagreebtn.isChecked
//
//    }
    @IBAction func onCancelInsBtn(_ sender: Any) {
        let fm_Contrllers = self.navigationController?.viewControllers
        if let val = fm_Contrllers{
            for VC in val{
                if VC is LoginView {
                    //let VCC = VC as! LoginView
                    self.navigationController?.popToViewController(VC, animated: true)
                    break;
                }
                
            }
        }
    }
    
    @IBAction func onAgree2(_ sender: Any) {
        let Storyboard: UIStoryboard = UIStoryboard(name: "UsePolicy", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "UsePolicyidx") as! UsePolicy
        viewController.setUrl(url: "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Policy/Privacy", f_sTitle: "개인정보처리방침".localized, menuidx : 1)
        viewController.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
}

extension IntegratedLogin: ClickCircleEventDelegate {
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
