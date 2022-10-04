//
//  PassChangeFix.swift
//  golf2u
//
//  Created by 이원영 on 2021/03/12.
//  Copyright © 2021 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON

class PassChangeFix: VariousViewController, UITextFieldDelegate {
    private var SO:Single = Single.getSO();
    private let JS = JsonC();
    
    @IBOutlet weak var uiTitlelb: UILabel!
    @IBOutlet weak var uiTitleSublb: UILabel!
    @IBOutlet weak var uiTitleSub1lb: UILabel!
    @IBOutlet weak var uiTitleSub2lb: UILabel!
    @IBOutlet weak var uiPasstext1: UITextField!
    @IBOutlet weak var uiPasstext2: UITextField!
    @IBOutlet weak var uiAccBtn: UIButton!
    @IBOutlet weak var uiToastLb: UILabel!
    
    static func instantiate() -> PassChangeFix? {
        return UIStoryboard(name: "PassChangeFix", bundle: nil).instantiateViewController(withIdentifier: "\(PassChangeFix.self)") as? PassChangeFix
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiTitlelb.text = "비밀번호 변경".localized;
        uiTitleSublb.text = "안전한 사용을 위하여, 비밀번호 변경이 필요합니다.\n새 비밀번호를 입력해주세요.".localized;
        uiTitleSub1lb.text = "비밀번호".localized;
        uiTitleSub2lb.text = "비밀번호 확인".localized;
        
        uiPasstext1.layer.cornerRadius = 8.0;
        uiPasstext1.layer.borderWidth = 1.0
        uiPasstext1.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiPasstext1.addLeftPadding()
        uiPasstext1.placeholder = "비밀번호 입력(영문+숫자+특수문자 8~18자리 조합)".localized;
        
        uiPasstext2.layer.cornerRadius = 8.0;
        uiPasstext2.layer.borderWidth = 1.0
        uiPasstext2.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiPasstext2.addLeftPadding()
        uiPasstext2.placeholder = "비밀번호 확인".localized;
        
        self.uiPasstext1.delegate = self;
        self.uiPasstext2.delegate = self;
        
        self.uiPasstext1.returnKeyType = .done;
        self.uiPasstext2.returnKeyType = .done;
        
        uiAccBtn.setTitle("확인".localized, for: .normal)

    }
    @IBAction func onAccBtn(_ sender: Any) {
        let fm_sPass1 = uiPasstext1.text!
        let fm_sPass2 = uiPasstext2.text!
        if fm_sPass1 == "" {
            uiToastLb.text = "비밀번호를 입력해주세요.".localized;
            return;
        }else if fm_sPass2 == "" {
            uiToastLb.text = "비밀번호 확인을 입력해주세요.".localized;
            return;
        }else if fm_sPass2 != fm_sPass1 {
            uiToastLb.text = "비밀번호가 일치하지 않습니다.".localized;
            return;
        }
        LoadingHUD.show()
        JS.setPasswordForced(param: ["seq":super.getUserSeq(), "new_password":fm_sPass1], callbackf: setPasswordForcedCallback)
    }
    func setPasswordForcedCallback(alldata: JSON)->Void {
        LoadingHUD.hide()
        if alldata["errorcode"] != "0"{
            uiToastLb.text = alldata["errormessage"].string!;
        }else{
            self.SO.setUserInfoKey(key: Single.DE_NEEDPASSCHANGE, value: "0")
            dismiss(animated: true, completion: nil)
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
        if uiPasstext1.isEditing == true{
            keyboardAnimate(keyboardRectangle: keyboardRectangle, view: uiAccBtn)
        }
        else if uiPasstext2.isEditing == true{
            keyboardAnimate(keyboardRectangle: keyboardRectangle, view: uiAccBtn)
        }
        
    }
    func keyboardAnimate(keyboardRectangle: CGRect ,textField: UITextField){
        if keyboardRectangle.height > (self.view.frame.height - textField.frame.maxY){
            self.view.transform = CGAffineTransform(translationX: 0, y: (self.view.frame.height - keyboardRectangle.height - textField.frame.maxY))
        }
    }
    func keyboardAnimate(keyboardRectangle: CGRect ,view: UIButton){
        if keyboardRectangle.height > (self.view.frame.height - view.frame.maxY){
            self.view.transform = CGAffineTransform(translationX: 0, y: (self.view.frame.height - keyboardRectangle.height - view.frame.maxY - 50))
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
    
}
