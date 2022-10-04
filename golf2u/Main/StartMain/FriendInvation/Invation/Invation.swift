//
//  Invation.swift
//  golf2u
//
//  Created by 이원영 on 2020/12/04.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON
class Invation: UIView {
    weak var m_tClickEvent: FriendInvationDelegate? = nil;
    private var SO:Single = Single.getSO();
    private let JS = JsonC();
    private let xibName = "Invation"
    
    @IBOutlet weak var uiCodeBtnPre: UIButton!
    @IBOutlet weak var uiCodeBtnRPre: UIButton!
    @IBOutlet weak var uiCodeCopyBtn: UIButton!
    @IBOutlet weak var uiKakaoBtn: UIButton!
    @IBOutlet weak var uiSmsBtn: UIButton!
    @IBOutlet weak var uiHelplb: UILabel!
    
    private var m_sCodeCreate = "";
    
    private var m_isAccBtn = false;
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit(){
        let view = Bundle.main.loadNibNamed(xibName, owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        
        uiCodeBtnPre.setTitle("코드를 생성해주세요.".localized, for: .normal)
        uiCodeBtnRPre.setTitle("코드 생성".localized, for: .normal)
        uiCodeCopyBtn.setTitle("코드 복사하기".localized, for: .normal)
        uiKakaoBtn.setTitle("카카오톡 전송하기".localized, for: .normal)
        uiSmsBtn.setTitle("SMS 전송하기".localized, for: .normal)
        uiHelplb.text = "초대한 회원 혜택\n- 친구가 초대코드를 입력하면 500클로버가 지급됩니다.\n- 초대할 수 있는 친구의 수는 제한이 없습니다.\n초대받은 친구 혜택\n- 회원 가입 후 초대 코드를 입력하면 1000클로버가 지급됩니다.\n주의사항\n- 본 이벤트는 로그인(본인인증) 후 참여하실 수 있습니다.\n- 본 이벤트는 조기 종료되거나 사전 예고 없이 변경될 수 있습니다.";
        
        //uiCodeBtnPre.layer.roundCorners(corners: [.topLeft, .bottomLeft], radius: 8.0)
        uiCodeBtnPre.layer.cornerRadius = 8.0;
        uiCodeBtnPre.layer.borderWidth = 1.0
        uiCodeBtnPre.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        uiCodeBtnRPre.layer.roundCorners(corners: [.topRight, .bottomRight
        ], radius: 8.0)
        
        uiCodeCopyBtn.layer.cornerRadius = 8.0;
        uiCodeCopyBtn.layer.borderWidth = 1.0
        uiCodeCopyBtn.layer.borderColor = UIColor(rgb: 0x00BA87).cgColor
        
        uiKakaoBtn.layer.cornerRadius = 8.0;
        uiKakaoBtn.layer.borderWidth = 1.0
        uiKakaoBtn.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        uiSmsBtn.layer.cornerRadius = 8.0;
        uiSmsBtn.layer.borderWidth = 1.0
        uiSmsBtn.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
    }
    @IBAction func onCodeCreateBtn(_ sender: Any) {
        if m_isAccBtn {
            return;
        }
        m_isAccBtn = true;
        m_tClickEvent?.ClickEvent(type: 1, data: [:])
    }
    @IBAction func onCopyBtn(_ sender: Any) {
        if m_sCodeCreate == "" {
            self.makeToast("코드를 생성해주세요.".localized)
            return;
        }
        UIPasteboard.general.string = m_sCodeCreate
        self.makeToast("코드가 복사되었습니다.".localized)
    }
    @IBAction func onKakaoShare(_ sender: Any) {
        if m_sCodeCreate == "" {
            self.makeToast("코드를 생성해주세요.".localized)
            return;
        }
        m_tClickEvent?.ClickEvent(type: 2, data: ["code":m_sCodeCreate])
    }
    @IBAction func onSmsShare(_ sender: Any) {
        if m_sCodeCreate == "" {
            self.makeToast("코드를 생성해주세요.".localized)
            return;
        }
        m_tClickEvent?.ClickEvent(type: 3, data: ["code":m_sCodeCreate])
    }
    func FinishBtn(){
        m_isAccBtn = false;
    }
    func setCode(code : String){
        m_sCodeCreate = code;
        uiCodeBtnPre.setTitle(code, for: .normal)
    }
}
