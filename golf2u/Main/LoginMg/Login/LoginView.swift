//
//  LoginView.swift
//  golf2u
//
//  Created by 이원영 on 2020/09/18.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import EzPopup
import SwiftyJSON

import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

import FBSDKLoginKit

import AuthenticationServices

import GoogleSignIn

class LoginView: VariousViewController, UITextFieldDelegate {
    private var SO:Single = Single.getSO();
    private let JS = JsonC();
    
    
    @IBOutlet weak var EmailInput: UITextField!
    @IBOutlet weak var PassInput: UITextField!
    @IBOutlet weak var LoginBtn: UIButton!
    @IBOutlet weak var isAutoLoginBtn: RectCheckBoxBtn!
    
    @IBOutlet weak var uiLoginTitle: UILabel!
    @IBOutlet weak var uiAutoLogin: UILabel!
    @IBOutlet weak var uiPassFind: UIButton!
    @IBOutlet weak var uiJoin: UIButton!
    @IBOutlet weak var uiSnsLogin: UILabel!
    
    
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "")
        super.viewDidLoad()
        
        uiLoginTitle.text = "로그인".localized
        
        
        EmailInput.layer.cornerRadius = 8.0;
        EmailInput.layer.borderWidth = 1.0
        EmailInput.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        EmailInput.addLeftPadding()
        EmailInput.placeholder = "이메일을 입력하세요.".localized;
        
        PassInput.layer.cornerRadius = 8.0;
        PassInput.layer.borderWidth = 1.0
        PassInput.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        PassInput.addLeftPadding()
        PassInput.placeholder = "비밀번호를 입력하세요.".localized;
        
        if Single.DE_ISDEBUG {
            EmailInput.text = "test1@test.com"
            PassInput.text = "asd";
        }
        
        self.EmailInput.returnKeyType = .next;
        self.PassInput.returnKeyType = .done;
        
        //LoginBtn.layer.borderColor = UIColor.black.cgColor
        //LoginBtn.layer.borderWidth = 1
        LoginBtn.layer.cornerRadius = 25
        
        self.EmailInput.delegate = self
        self.PassInput.delegate = self
        
        LoginBtn.setTitle("로그인".localized, for: .normal)
        uiAutoLogin.text = "자동로그인".localized;
        uiPassFind.setTitle("비밀번호 찾기".localized, for: .normal)
        uiJoin.setTitle("회원가입하기".localized, for: .normal)
        uiSnsLogin.text = "소셜 계정으로 로그인".localized;
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if  self.EmailInput == textField{
            self.PassInput.becomeFirstResponder()
            
        }else{
            self.view.endEditing(true)
        }
        
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.count ?? 0
        if range.length + range.location > currentCharacterCount {
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        
        var fm_sInputText = self.PassInput.text!
        if textField == self.PassInput{
            fm_sInputText = self.EmailInput.text!
        }
        
        if newLength <= 0 || fm_sInputText.count <= 0 {
            LoginBtn.backgroundColor = UIColor(rgb: 0xc5c5c5)
        }else{
            LoginBtn.backgroundColor = UIColor(rgb: 0x00BA87)
        }
        
        return true
    }
    
    @IBAction func onMemberJoin(_ sender: Any) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "memberjoinid") as! MemberJoin
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    @IBAction func onPassFind(_ sender: Any) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "passfindid") as! PassFind
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    func LoginCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            //self.MessagePop(msg: "아이디 또는 비밀번호가 존재하지않거나 일치하지 않습니다.".localized, btntype : 2)
            var fm_sErrorPopTitle  = "안내";
            if alldata["errorcode"] == "10"{
                fm_sErrorPopTitle  = "계정 일시정지 안내";
                self.MessagePop(title : fm_sErrorPopTitle, msg: alldata["errormessage"].stringValue, btntype : 2)
            }else if alldata["errorcode"] == "20"{
                fm_sErrorPopTitle  = "휴면회원 안내";
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "EmailCheckidx") as! EmailCheck
                viewController.setData(type: 3, PreBenEmail: alldata["data"]["email"].stringValue)
                self.navigationController?.pushViewController(viewController, animated: true)
            }else if alldata["errorcode"] == "30"{
                //통합회원 동의필요
                let fm_sIntergDis = """
                이미 등록된 아이디(이메일)입니다. 통합 회원 절차로 이동하시겠습니까? "확인" 버튼을 누르면 통합회원 동의 페이지로 이동합니다.


                ※ 통합 계정 사용을 원치 않으실 경우 다른 아이디(이메일)를 사용해야 합니다.
                """;
                super.MessagePop(title : "안내".localized, msg: fm_sIntergDis.localized, lbtn: "취소".localized, rbtn: "확인".localized,succallbackf: { ()-> Void in
                    self.dismiss(animated: false, completion: nil)
                    let fm_USeq = alldata["data"]["seq"].stringValue;
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "IntegratedLoginidx") as! IntegratedLogin
                    viewController.setData(useq : fm_USeq, type: 0)
                    self.navigationController?.pushViewController(viewController, animated: true)
                }, closecallbackf: { ()-> Void in
                    
                })
            }else{
                self.MessagePop(title : fm_sErrorPopTitle, msg: alldata["errormessage"].stringValue, btntype : 2)
            }
            
        }else{
            for (k, v) in alldata["data"]{
                if let val = v.string{
                    SO.setUserInfoKey(key: k, value: val)
                }
            }
            //DispatchQueue.main.async {
                if self.isAutoLoginBtn.isChecked {
                    UserDefaults.standard.set(alldata["data"]["seq"].string, forKey: Single.DE_AUTOLOGIN)
                }
                self.dismiss(animated: true, completion: nil)
                self.StartMain();
            //}
        }
        LoadingHUD.hide()
    }
    func checkSnsCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            var fm_sErrorPopTitle  = "안내";
            if alldata["errorcode"] == "10"{
                fm_sErrorPopTitle  = "계정 일시정지 안내";
                self.MessagePop(title : fm_sErrorPopTitle, msg: alldata["errormessage"].stringValue, btntype : 2)
            }else if alldata["errorcode"] == "20"{
                fm_sErrorPopTitle  = "휴면회원 안내";
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "EmailCheckidx") as! EmailCheck
                viewController.setData(type: 3,PreBenEmail: alldata["data"]["user"][["email"]].stringValue)
                self.navigationController?.pushViewController(viewController, animated: true)
            }else if alldata["errorcode"] == "30"{
                fm_sErrorPopTitle  = "휴면회원 안내";
                self.MessagePop(title : fm_sErrorPopTitle, msg: alldata["errormessage"].stringValue, btntype : 2)
            }else{
                self.MessagePop(title : fm_sErrorPopTitle, msg: alldata["errormessage"].stringValue, btntype : 2)
            }
            
        }else{
            if alldata["data"]["is_joined"] == "1" {
                for (k, v) in alldata["data"]["user"]{
                    if let val = v.string{
                        SO.setUserInfoKey(key: k, value: val)
                    }
                }
                if self.isAutoLoginBtn.isChecked {
                    UserDefaults.standard.set(alldata["data"]["user"]["seq"].string, forKey: Single.DE_AUTOLOGIN)
                }
                self.dismiss(animated: true, completion: nil)
                self.StartMain();
            }else{
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "EmailCheckidx") as! EmailCheck
                viewController.setData(type: 2, snstype: alldata["data"]["sns_type"].stringValue, usersnskey: alldata["data"]["user_key"].stringValue)
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
        LoadingHUD.hide()
    }
    func MemberJoinFinish(){
        self.dismiss(animated: true){
            self.StartMain();
        }
    }
    @IBAction func onCloseBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func StartMain(){
        if SO.getTabbarIndex() == 0 {
            SO.getStartMain()?.viewWillAppear(true)
        }else if SO.getTabbarIndex() == 1 {
            SO.getTradeMain()?.ReflashView()
        }else if SO.getTabbarIndex() == 2 {
            SO.getCommunityMain()?.LoginResetView()
        }
        SO.setInventoryTabIdx(TabbarIndex: 0)
        SO.getInventoryMain()?.InitInventoryMainSubView()
        //MainConMove();
    }
    @IBAction func onLoginBtn(_ sender: Any) {
        if !isLogicCheck(){
            return;
        }
        let fm_sEmail = self.EmailInput.text!;
        let fm_sPass = self.PassInput.text!;
        LoadingHUD.show()
        JS.Login(param: ["email":fm_sEmail,"password":fm_sPass], callbackf: LoginCallback)
    }
    
    func isLogicCheck() -> Bool{
        var fm_isCheck = true;
        var fm_sMsg = "";
        
        let fm_sEmail = self.EmailInput.text!;
        let fm_sPass = self.PassInput.text!;
        
        if fm_sEmail == "" {
            fm_sMsg = "이메일을 입력하세요.".localized;
            fm_isCheck = false;
        }else if fm_sPass == "" {
            fm_sMsg = "비밀번호를 입력하세요.".localized;
            fm_isCheck = false;
        }
        if !fm_isCheck {
            MessagePop(msg: fm_sMsg, btntype : 2)
        }
        
        return fm_isCheck;
    }
    
    //MARK: SNS KAKAO LOGIN
    
    @IBAction func onKaKaoLoginBtn(_ sender: Any) {
        if (UserApi.isKakaoTalkLoginAvailable()){
            UserApi.shared.loginWithKakaoTalk{(OAuthToken, Error) in
                if let e = Error{
                    print(e)
                }else{
                    
                    UserApi.shared.accessTokenInfo{(AccessTokenInfo, Error) in
                        if let e = Error{
                            print(e)
                        }else{
                            //print(OAuthToken)

                            
                            if let accid = AccessTokenInfo!.id{
                                LoadingHUD.show()
                                self.JS.checkSns(param: ["sns_type":"3","user_key":"kakao@\(accid)"], callbackf: self.checkSnsCallback)
                            }
                            //self.JS.SNSLogin(param: ["sns_type":"3","name":"","user_key":"kakao@\(AccessTokenInfo!.id)","email":""], callbackf: self.LoginCallback)
                            /*UserApi.shared.me{(User, Error) in
                             if let e = User{
                             if let e1 = e.kakaoAccount{
                             if let e2 = e1.email{
                             //self.JS.SNSLogin(param: ["sns_type":"3","name":"","user_key":"kakao@\(AccessTokenInfo!.id)","email":e2], callbackf: self.LoginCallback)
                             }
                             }
                             }
                             }*/
                            
                        }
                    }
                }
                
            }
        }else{
            //카카오가 설치가안된 폰은 웹뷰로
            UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    UserApi.shared.me() {(user, error) in
                        if let error = error {
                            print(error)
                        }
                        else {
                            if let accid = user!.id {
                                LoadingHUD.show()
                                self.JS.checkSns(param: ["sns_type":"3","user_key":"kakao@\(accid)"], callbackf: self.checkSnsCallback)
                            }
                        }
                    }
                }
            }
        }
    }
    //MARK: SNS APPLE LOGIN
    @IBAction func onAppleLoginBtn(_ sender: Any) {
        let fm_sAppleDis = """
        애플 계정 이메일이 이미 생성된 랜덤투유 계정 이메일과 일치할 경우, 해당 랜덤투유 계정의 로그인 방식이 Apple 로그인으로 전환됩니다.
        "나의 이메일 가리기"를 선택한 애플 계정의 경우 통합 회원 계정 이용이 불가능합니다.

        ※ Apple 로그인으로 변경 후 이전 계정으로의 재변경은 불가능합니다. ※
        """;
        MessagePop(title : "Apple 로그인 유의사항".localized, msg: fm_sAppleDis.localized, lbtn: "취소".localized, rbtn: "진행".localized,succallbackf: { ()-> Void in
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email];
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            //controller.presentationContextProvider = self
            controller.performRequests()
        }, closecallbackf: { ()-> Void in
            
        })
        
        
    }
    
    //MARK: SNS FACEBOOK LOGIN
    @IBAction func onFaceBookLoginBtn(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile"], from: self) { (LoginResult, error) in
            if let error = error {
                print("Process error: \(error)")
                return
            }
            guard let result = LoginResult else {
                print("No Result")
                return
            }
            if result.isCancelled {
                print("Login Cancelled")
                return
            }
            //  프로필 가져오기
            Profile.loadCurrentProfile(completion: {(profile, error) in
                if let userid = profile?.userID{
                    print("login : ", userid)
                    LoadingHUD.show()
                    self.JS.checkSns(param: ["sns_type":"1","user_key":"facebook@\(userid)"], callbackf: self.checkSnsCallback)
                }
            })
            
        }
    }
    
    //MARK: SNS GOOGLE LOGIN
    @IBAction func onGoogleLoginBtn(_ sender: Any) {
        //GIDSignIn.sharedInstance().signOut() logout
        GIDSignIn.sharedInstance()?.presentingViewController = self
        (UIApplication.shared.delegate as! AppDelegate).GooglesignInCallback = GooglerefreshInterface
        GIDSignIn.sharedInstance()?.signIn()
    }
    func GooglerefreshInterface(){
        //앱딜리게이트 에서 콜백 받아옴
        if let currentUser = GIDSignIn.sharedInstance().currentUser {
            let UserToken = "google@\(String(describing: currentUser.userID!))"
            LoadingHUD.show()
            self.JS.checkSns(param: ["sns_type":"2","user_key":UserToken], callbackf: self.checkSnsCallback)
        } else {
            //Welcom, Please Sign-In first.
        }
        
    }
    
}
extension LoginView : ASAuthorizationControllerDelegate{
    func authorizationController(controller : ASAuthorizationController, didCompleteWithAuthorization authorization : ASAuthorization){
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential{
            //let user = credential.user;
            
            let userIdentifier = credential.user
            
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            appleIDProvider.getCredentialState(forUserID: userIdentifier) {  (credentialState, error) in
                switch credentialState {
                case .authorized:
                    // The Apple ID credential is valid.
                    let fm_sEmail = credential.email ?? "";
                    //LoadingHUD.show()
                    //let fm_sUserName = "\(credential.fullName?.familyName ?? "user")\(credential.fullName?.givenName ?? "")"
                    self.JS.checkSns(param: ["sns_type":"4","email":fm_sEmail,"user_key":"apple@\(userIdentifier)"], callbackf: self.checkSnsCallback)
//                    if let email = credential.email{
//                        self.JS.checkSns(param: ["sns_type":"4","user_key":"apple@\(userIdentifier)"], callbackf: self.checkSnsCallback)
//                    }else{
//                        self.JS.checkSns(param: ["sns_type":"4","user_key":"apple@\(userIdentifier)"], callbackf: self.checkSnsCallback)
//                    }
                    break
                case .revoked:
                    // The Apple ID credential is revoked.
                    break
                case .notFound:
                // No credential was found, so show the sign-in UI.
                    break
                default:
                    break
                }
            }
        }
        
    }
    func authorizationController(controller : ASAuthorizationController, didCompleteWithError error : Error){
       //애플로그인 취소
    }
}
/*extension ViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
           return self.view.window!
    }
}*/
