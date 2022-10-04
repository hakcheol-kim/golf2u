//
//  NickModify.swift
//  golf2u
//
//  Created by 이원영 on 2020/12/07.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON

class NickModify: VariousViewController, UITextFieldDelegate {
    private let SO = Single.getSO();
    private let JS = JsonC();
    
    @IBOutlet weak var uiCodeInput: UITextField!
    @IBOutlet weak var uiAccBtn: UIButton!
    @IBOutlet weak var uiHelplb: UILabel!
    private var m_sName = "";
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "닉네임 변경".localized)
        super.viewDidLoad()
        
        uiCodeInput.placeholder = "변경할 닉네임을 입력해주세요.".localized
        uiAccBtn.setTitle("확인".localized, for: .normal)
        uiHelplb.text = "- 닉네임은 2자 이상 10자 이하의 한글,영문,숫자 조합으로 설정 가능합니다. (특수문자 사용불가)\n- 닉네임은 변경 시 3개월 이후 재변경이 가능합니다.\n- 적절하지 못한 언어 사용 시, 강제로 변경조치 될 수 있습니다.".localized;
        
        uiCodeInput.layer.cornerRadius = 8.0;
        uiCodeInput.layer.borderWidth = 1.0
        uiCodeInput.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiCodeInput.addLeftPadding()
        uiCodeInput.delegate = self;
        
        uiAccBtn.layer.cornerRadius = uiAccBtn.bounds.height/2

    }
    
    @IBAction func onAccBtn(_ sender: Any) {
        let fm_sName = uiCodeInput.text!
        if fm_sName == "" {
            return;
        }
        LoadingHUD.show()
        m_sName = fm_sName
        JS.setName(param: ["seq":super.getUserSeq(), "name":fm_sName], callbackf: setNameGiftCallback)
    }
    func setNameGiftCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            MessagePop(msg: alldata["errormessage"].stringValue, btntype : 2)
        }else{
            uiCodeInput.text = "";
            SO.setUserInfoKey(key: "name", value: m_sName)
            MessagePop(title : "닉네임 변경 완료".localized, msg: "닉네임이 정상적으로 변경되었습니다.".localized, btntype : 2)
        }
        LoadingHUD.hide()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func checkMaxLength(textField: UITextField!, maxLength: Int) {
        if (textField.text?.count ?? 0 > maxLength) {
            textField.deleteBackward()
        }
    }
    @IBAction func textDidChange(_ sender: Any) {
        checkMaxLength(textField: uiCodeInput, maxLength: 10)
    }
    
}
