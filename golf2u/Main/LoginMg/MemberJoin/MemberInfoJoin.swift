//
//  MemberInfoJoin.swift
//  golf2u
//
//  Created by 이원영 on 2020/09/19.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import EzPopup
import SwiftyJSON
import AppsFlyerLib

class MemberInfoJoin: VariousViewController, UITextFieldDelegate {
    private var SO:Single = Single.getSO();
    private let JS = JsonC();
    
    @IBOutlet weak var uiTitlelb: UILabel!
    @IBOutlet weak var uiSub1lb: UILabel!
    @IBOutlet weak var uiSub2lb: UILabel!
    @IBOutlet weak var nickinput: UITextField!
    @IBOutlet weak var emailinput: UITextField!
    @IBOutlet weak var passinput: UITextField!
    @IBOutlet weak var passokinput: UITextField!
    @IBOutlet weak var acceptbtn: UIButton!
    @IBOutlet weak var mailauthview: UIView!
    
    @IBOutlet weak var emailcodeinput: UITextField!
    @IBOutlet weak var emailcodebtn: UIButton!
    @IBOutlet weak var emailcodestlabel: UILabel!
    
    private var m_isEmailCheck : Bool = false;
    private var m_isEmailAccept : Bool = false;
    private var m_isSVEmailCheck : Bool = false;
    
    
    private var m_nType : Int = 1;//1:일반 회원가입, 2:sns회원가입, 3:휴면계정 메일인증
    private var m_isAgree1 : Bool = false;
    private var m_isAgree2 : Bool = false;
    private var m_isAgree3 : Bool = false;
    private var m_isAgree4 : Bool = false;
    private var m_sSnsType : String = "";
    private var m_sUserKey : String = "";
    
    @IBOutlet weak var uiStep1img: UIImageView!
    @IBOutlet weak var uiStep2img: UIImageView!
    @IBOutlet weak var uiStep2Title: UILabel!
    @IBOutlet weak var uiStep2SubTitle: UILabel!
    @IBOutlet weak var uiStep2SubTitle2: UILabel!
    
    
    private var m_sServerCode : String = "";
    private var m_sPreBenEmail : String = "";
    
    private var uiEmailViewConstraint: NSLayoutConstraint?
    private var uiEmailAuthViewConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "")
        super.viewDidLoad()
        
        uiTitlelb.text = "회원 정보 입력".localized;
        uiSub1lb.text = "회원정보를 입력하신 후\n이메일인증을 하시면 가입이 완료됩니다.".localized;
        uiSub2lb.text = "(휴먼회원 안내를 위해 닉네임 및 이메일 주소가 필요합니다.)".localized;
        emailcodebtn.setTitle("확인".localized, for: .normal)
        acceptbtn.setTitle("인증메일신청".localized, for: .normal)
        
        nickinput.layer.cornerRadius = 8.0;
        nickinput.layer.borderWidth = 1.0
        nickinput.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        nickinput.addLeftPadding()
        nickinput.placeholder = "닉네임 입력(최대 10글자)".localized
        emailinput.layer.cornerRadius = 8.0;
        emailinput.layer.borderWidth = 1.0
        emailinput.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        emailinput.addLeftPadding()
        emailinput.placeholder = "이메일(아이디) 입력".localized
        uiEmailViewConstraint = emailinput.topConstraint
        passinput.layer.cornerRadius = 8.0;
        passinput.layer.borderWidth = 1.0
        passinput.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        passinput.addLeftPadding()
        passinput.placeholder = "비밀번호 입력(영문+숫자+특수문자 8~18자리 조합)".localized
        passokinput.layer.cornerRadius = 8.0;
        passokinput.layer.borderWidth = 1.0
        passokinput.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        passokinput.addLeftPadding()
        passokinput.placeholder = "비밀번호 확인".localized
//        emailcodeinput.placeholderColor = UIColor(rgb: 0x999999)
//        emailcodeinput.borderColor  = UIColor(rgb: 0x00BA87)
//        emailcodeinput.placeholderFontScale = 1
        emailcodeinput.placeholder = "인증코드를 입력해주세요.".localized
        
        self.nickinput.returnKeyType = .done;
        self.emailinput.returnKeyType = .done;
        self.passinput.returnKeyType = .done;
        self.passokinput.returnKeyType = .done;
        self.emailcodeinput.returnKeyType = .done;
        
        emailcodeinput.addLeftPadding()
        emailcodeinput.layer.cornerRadius = 8.0;
        emailcodeinput.layer.borderWidth = 1.0
        emailcodeinput.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        //emailcodebtn.layer.cornerRadius = 20
        emailcodebtn.layer.roundCorners(corners: [.topRight, .bottomRight
        ], radius: 8.0)
        
        self.emailinput.delegate = self;
        self.nickinput.delegate = self;
        self.passinput.delegate = self;
        self.passokinput.delegate = self;
        self.emailcodeinput.delegate = self;
        
        uiEmailAuthViewConstraint = mailauthview.topConstraint
        
        if m_nType == 2 {
            passinput.isHidden = true;
            passokinput.isHidden = true;
            uiStep1img.isHidden = true;
            uiStep2img.isHidden = true;
            uiStep2SubTitle2.isHidden = false;
            uiStep2Title.text = "추가정보 입력".localized;
            uiStep2SubTitle.text = "회원정보를 입력하신 후\n이메일인증을 하시면 가입이 완료됩니다.".localized;
        }else if m_nType == 3 {
            passinput.isHidden = true;
            passokinput.isHidden = true;
            uiStep1img.isHidden = true;
            uiStep2img.isHidden = true;
            nickinput.isHidden = true;
            uiStep2SubTitle2.isHidden = true;
            uiStep2Title.text = "이메일 재인증".localized;
            uiStep2SubTitle.text = "회원가입 시 인증한 이메일로 재인증을 진행하시면\n휴면계정이 활성화됩니다.".localized;
            emailcodeinput.placeholder = "회원가입시 인증한 이메일을 입력하세요.".localized
        }
        
    }
    func setData(type : Int, Agree1 : Bool, Agree2 : Bool, Agree3 : Bool, Agree4 : Bool){
        m_nType = type
        m_isAgree1 = Agree1;
        m_isAgree2 = Agree2;
        m_isAgree3 = Agree3;
        m_isAgree4 = Agree4;
    }
    func setData(type : Int, snstype : String, usersnskey : String){
        m_nType = type
        m_sSnsType = snstype;
        m_sUserKey = usersnskey;
    }
    func setData(type : Int, PreBenEmail :String){
        m_nType = type
        m_sPreBenEmail = PreBenEmail
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
                acceptbtn.frame = CGRect(x: 0, y: Int(acceptbtn.frame.minY), width: Int(acceptbtn.frame.size.width), height: Int(acceptbtn.frame.size.height + bottomPadding))
                acceptbtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
            }
        }
        if m_nType == 2 {
            mailauthview.frame = CGRect(x: mailauthview.frame.minX, y: emailinput.frame.maxY + 30, width: mailauthview.frame.width, height: mailauthview.frame.height)
        }else if m_nType == 3 {
        }
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if m_nType == 3 {
            self.uiEmailViewConstraint?.constant = -55;
            self.uiEmailAuthViewConstraint?.constant = -110
            self.view.layoutIfNeeded()
//            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
//                        self.uiPassChangeViewConstraint?.constant = 0
//                        self.view.layoutIfNeeded()
//                    }, completion: nil)
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func isLogicCheck() -> Bool{
        var fm_isCheck = true;
        var fm_sMsg = "";
        
        let fm_sNick = self.nickinput.text!;
        let fm_sEmail = self.emailinput.text!;
        let fm_sPass = self.passinput.text!;
        let fm_sPassok = self.passokinput.text!;
        
        if fm_sNick == "" && m_nType != 3{
            fm_sMsg = "닉네임을 입력하세요.(최대 10글자)".localized;
            fm_isCheck = false;
        }else if fm_sEmail == ""{
            fm_sMsg = "이메일(아이디)를 입력하세요.".localized;
            fm_isCheck = false;
        }else if fm_sPass == ""  && m_nType == 1{
            fm_sMsg = "비밀번호 입력(영문+숫자+특수문자 8~18자리 조합) 하세요.".localized;
            fm_isCheck = false;
        }else if fm_sPassok == ""   && m_nType == 1{
            fm_sMsg = "비밀번호 확인을 입력하세요.".localized;
            fm_isCheck = false;
        }else if fm_sPassok != fm_sPass   && m_nType == 1{
            fm_sMsg = "비밀번호와 비밀번호 확인이 맞지 않습니다.".localized;
            fm_isCheck = false;
        }else if !fm_sEmail.validateEmail() {
            fm_sMsg = "이메일 형식이 올바르지않습니다.".localized;
            fm_isCheck = false;
        }else if !fm_sPass.validatePassword()   && m_nType == 1{
            fm_sMsg = "비밀번호는 영문+숫자+특수문자 8~18자리 로 조합 해주세요.".localized;
            fm_isCheck = false;
        }
        
        if !fm_isCheck {
            MessagePop(msg: fm_sMsg, btntype : 2);
        }
        
        return fm_isCheck;
    }
    
    @IBAction func onEmailCodeCheck(_ sender: Any) {
        if !isLogicCheck(){
            return;
        }
        let fm_sEmailCode = self.emailcodeinput.text!;
        if fm_sEmailCode == "" {
            MessagePop(msg: "코드를 입력해주세요.".localized, btntype : 2);
            return;
        }
        self.emailcodestlabel.isHidden = false;
        if fm_sEmailCode == m_sServerCode{
            m_isEmailAccept = true;
            self.emailcodestlabel.text = "인증이 완료되었습니다.".localized;
            self.emailcodestlabel.textColor = UIColor(rgb: 0x31c858);
            //MessagePop(msg: "인증코드가 확인되었습니다.", btntype : 2)
        }else{
            self.emailcodestlabel.text = "인증코드가 일치하지 않습니다.".localized;
            self.emailcodestlabel.textColor = .red;
            //MessagePop(msg: "인증코드가 일치하지 않습니다.", btntype : 2)
        }
    }
    func EmailSendPlzRtsCodeCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            self.view.makeToast("인증코드 이메일 발송완료".localized)
            m_sServerCode = alldata["data"].string!
        }
        LoadingHUD.hide()
    }
    @IBAction func onAccept(_ sender: Any) {
        
        if !isLogicCheck(){
            return;
        }
        if !m_isSVEmailCheck {
            MessagePop(msg:"이미 사용중인 이메일(아이디)입니다.".localized, btntype : 2)
            return;
        }
        //테스트로 이메일체크와 코드체크를 하지않고 넘김
//        m_isEmailAccept = true;
//        m_isEmailCheck = true
        if !m_isEmailCheck{
            self.emailinput.isEnabled = false
            self.emailinput.textColor = UIColor(rgb: 0x999999)
            self.emailinput.backgroundColor = UIColor(rgb: 0xf2f2f2)
            mailauthview.isHidden = false;
            m_isEmailCheck = true;
            
            if m_nType == 3 {
                acceptbtn.setTitle("인증완료".localized, for: .normal)
            }else{
                acceptbtn.setTitle("가입".localized, for: .normal)
            }
            let fm_sEmail = self.emailinput.text!;
            LoadingHUD.show()
            JS.EmailSendPlzRtsCode(param: ["email" : fm_sEmail], callbackf: EmailSendPlzRtsCodeCallback)
            //이메일 인증 받기전
        }else{
            //이메일 인증 받은후
            if !m_isEmailAccept{
                MessagePop(msg:"이메일 코드를 인증해주세요.".localized, btntype : 2)
                return;
            }
            let fm_sNick = self.nickinput.text!;
            let fm_sEmail = self.emailinput.text!;
            let fm_sPass = self.passinput.text!;
            if m_nType == 1 {
                JS.MemberJoin(param: ["name":fm_sNick,"email":fm_sEmail,"password":fm_sPass,"is_agree1_terms":(m_isAgree1 ? "1":"0"),"is_agree2_terms":(m_isAgree2 ? "1":"0"),"is_agree3_terms":(m_isAgree3 ? "1":"0"),"is_agree4_terms":(m_isAgree4 ? "1":"0")], callbackf: MemberJoinCallback)
            }else if m_nType == 2 {
                self.JS.SNSLogin(param: ["sns_type":m_sSnsType,"name":fm_sNick,"user_key":m_sUserKey,"email":fm_sEmail], callbackf: self.MemberJoinCallback)
            }else if m_nType == 3 {
                self.JS.loginInactive(param: ["email":fm_sEmail], callbackf: self.MemberJoinCallback)
            }
        }
        
    }
    func MemberJoinCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            if m_nType == 1 {
                UserDefaults.standard.removeObject(forKey: Single.DE_TUTORIALMAIN)//신규 가입자일경우 기존 튜토리얼 본것을 지움
                let params : [String: Any] = [
                    "memberinfo":alldata["data"]
                    ,"joinmethod":"golf2u"
                    
                ];
                Analytics(eventname: "memberjoin", params: params)
                
                let paramsAF : [String: Any] = [
                    AFEventParamRegistrationMethod : "golf2u"
                ];
                AppsflyerLog(AFTitle: "af_complete_registration", params: paramsAF)
            }else if m_nType == 2 {
                UserDefaults.standard.removeObject(forKey: Single.DE_TUTORIALMAIN)//신규 가입자일경우 기존 튜토리얼 본것을 지움
                let params : [String: Any] = [
                    "memberinfo":alldata["data"]
                    ,"joinmethod":m_sSnsType
                    
                ];
                Analytics(eventname: "memberjoin", params: params)
                
                let paramsAF : [String: Any] = [
                    AFEventParamRegistrationMethod : m_sSnsType
                ];
                AppsflyerLog(AFTitle: "af_complete_registration", params: paramsAF)
            }
            
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForKeyboardNotifications()//키보드관련
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterForKeyboardNotifications()//키보드관련
    }
    func registerForKeyboardNotifications() {
        // 옵저버 등록
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    func unregisterForKeyboardNotifications() {
        // 옵저버 등록 해제
        NotificationCenter.default.removeObserver(self, name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name:UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    @objc func keyboardWillShow(_ notification: NSNotification){
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame: NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        if nickinput.isEditing == true{
            keyboardAnimate(keyboardRectangle: keyboardRectangle, textField: nickinput)
        }
        else if emailinput.isEditing == true{
            keyboardAnimate(keyboardRectangle: keyboardRectangle, textField: emailinput)
        }
        else if passinput.isEditing == true{
            keyboardAnimate(keyboardRectangle: keyboardRectangle, textField: passinput)
        }
        else if passokinput.isEditing == true{
            keyboardAnimate(keyboardRectangle: keyboardRectangle, textField: passokinput)
        }
        else if emailcodeinput.isEditing == true{
            keyboardAnimate(keyboardRectangle: keyboardRectangle, view: mailauthview)
        }
    }
    func keyboardAnimate(keyboardRectangle: CGRect ,textField: UITextField){
        if keyboardRectangle.height > (self.view.frame.height - textField.frame.maxY){
            self.view.transform = CGAffineTransform(translationX: 0, y: (self.view.frame.height - keyboardRectangle.height - textField.frame.maxY))
        }
    }
    func keyboardAnimate(keyboardRectangle: CGRect ,view: UIView){
        if keyboardRectangle.height > (self.view.frame.height - view.frame.maxY){
            self.view.transform = CGAffineTransform(translationX: 0, y: (self.view.frame.height - keyboardRectangle.height - view.frame.maxY))
        }
    }
    @objc func keyboardWillHide(_ notification: NSNotification){
        self.view.transform = .identity
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if  self.nickinput == textField{
//            self.emailinput.becomeFirstResponder()
//
//        }else if  self.emailinput == textField{
//            self.passinput.becomeFirstResponder()
//
//        }else if  self.passinput == textField{
//            self.passokinput.becomeFirstResponder()
//
//        }else if  self.passokinput == textField{
//            self.view.endEditing(true)
//
//        }else if  self.emailcodeinput == textField{
//            self.view.endEditing(true)
//
//        }
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //self.activeTextField = textField
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool{
        if textField == nickinput{
            let fm_sNick = self.nickinput.text!;
            if fm_sNick != "" {
                LoadingHUD.show()
                JS.NickNameCheck(param: ["name":fm_sNick], callbackf: NickNameCallback)
            }
        }else if textField == emailinput{
            let fm_sEmail = self.emailinput.text!;
            if fm_sEmail != "" {
                LoadingHUD.show()
                JS.EmailCheck(param: ["email":fm_sEmail,"type" : "\(m_nType == 3 ? 1 : 0)","prev_email":m_sPreBenEmail], callbackf: EmailCallback)
            }
        }
        return true;
    }
    func NickNameCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            
        }
        LoadingHUD.hide()
    }
    func EmailCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            m_isSVEmailCheck = false;
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            m_isSVEmailCheck = true;
        }
        LoadingHUD.hide()
    }
    func checkMaxLength(textField: UITextField!, maxLength: Int) {
        if (textField.text?.count ?? 0 > maxLength) {
            textField.deleteBackward()
        }
    }
    @IBAction func textDidChange(_ sender: Any) {
        checkMaxLength(textField: nickinput, maxLength: 10)
    }
    
    
}
