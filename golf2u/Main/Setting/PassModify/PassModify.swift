//
//  PassModify.swift
//  golf2u
//
//  Created by 이원영 on 2020/12/07.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON

class PassModify: VariousViewController {
    private let SO = Single.getSO();
    private let JS = JsonC();
    
    @IBOutlet weak var uiTitle1lb: UILabel!
    @IBOutlet weak var uiTitle2lb: UILabel!
    @IBOutlet weak var uiTitle3lb: UILabel!
    
    @IBOutlet weak var uiNowPassInput: UITextField!
    @IBOutlet weak var uiNewPassInput: UITextField!
    @IBOutlet weak var uiAccPassInput: UITextField!
    @IBOutlet weak var uiAccBtn: UIButton!
    
    //2021-3-15 부터 안씀 새로 운 비밀번호 팝업으로대처
    private var m_nViewType = 0;//0:setting, 1:main
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "비밀번호 변경".localized)
        super.viewDidLoad()
        
        uiTitle1lb.text = "현재 비밀번호".localized
        uiTitle2lb.text = "새 비밀번호".localized
        uiTitle3lb.text = "비밀번호 확인".localized
        
        uiAccBtn.setTitle("변경하기".localized, for: .normal)
        
        uiNowPassInput.layer.cornerRadius = 8.0;
        uiNowPassInput.layer.borderWidth = 1.0
        uiNowPassInput.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiNowPassInput.addLeftPadding()
        uiNowPassInput.placeholder = "현재 비밀번호를 입력하세요.";
        
        uiNewPassInput.layer.cornerRadius = 8.0;
        uiNewPassInput.layer.borderWidth = 1.0
        uiNewPassInput.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiNewPassInput.addLeftPadding()
        uiNewPassInput.placeholder = "비밀번호(영문+숫자+특수문자 8~18자리 조합)";
        
        uiAccPassInput.layer.cornerRadius = 8.0;
        uiAccPassInput.layer.borderWidth = 1.0
        uiAccPassInput.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiAccPassInput.addLeftPadding()
        uiAccPassInput.placeholder = "비밀번호 확인";

    }
    func setData(viewtype : Int = 0){
        m_nViewType = viewtype
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
                uiAccBtn.frame = CGRect(x: 0, y: Int(uiAccBtn.frame.minY), width: Int(uiAccBtn.frame.size.width), height: Int(uiAccBtn.frame.size.height + bottomPadding))
                uiAccBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
            }

        }
    }
    @IBAction func onAccBtn(_ sender: Any) {
        let fm_sPrePass = uiNowPassInput.text!
        let fm_sNextPass = uiNewPassInput.text!
        let fm_sAccNextPass = uiAccPassInput.text!
        if fm_sPrePass == "" {
            return;
        }else if fm_sNextPass == "" {
            return;
        }else if fm_sAccNextPass == "" {
            return;
        }else if fm_sAccNextPass != fm_sNextPass {
            MessagePop(msg: "새 비밀번호가 다릅니다.".localized, btntype : 2)
            return;
        }
        LoadingHUD.show()
        JS.setPassword(param: ["seq":super.getUserSeq(), "old_password":fm_sPrePass,"new_password":fm_sNextPass], callbackf: setPasswordCallback)
    }
    func setPasswordCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            MessagePop(msg: alldata["errormessage"].stringValue, btntype : 2)
        }else{
            uiNowPassInput.text = "";
            uiNewPassInput.text = "";
            uiAccPassInput.text = "";
            if self.m_nViewType == 1 {
                self.SO.setUserInfoKey(key: Single.DE_NEEDPASSCHANGE, value: "0")
                self.dismiss(animated: true, completion: nil)
            }else{
                MessagePop(title : "안내".localized, msg: "비밀번호가 정상적으로 변경되었습니다.".localized, btntype : 2)
            }
        }
        LoadingHUD.hide()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
