//
//  CodeInput.swift
//  golf2u
//
//  Created by 이원영 on 2020/12/04.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON

class CodeInput: UIView {
    weak var m_tClickEvent: FriendInvationDelegate? = nil;
    private var SO:Single = Single.getSO();
    private let JS = JsonC();
    private let xibName = "CodeInput"
    
    @IBOutlet weak var uiCodeInput: UITextField!
    @IBOutlet weak var uiAccBtn: UIButton!
    @IBOutlet weak var uiHelplb: UILabel!
    
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
        
        uiHelplb.text = "-초대코드를 입력하면 1,000클로버가 지급되며,\n계정당 1회만 적용 가능합니다.\n-초대코드 입력을 위해서는 본인인증이 필요합니다.";
        
        uiCodeInput.layer.cornerRadius = 8.0;
        uiCodeInput.layer.borderWidth = 1.0
        uiCodeInput.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiCodeInput.addLeftPadding()
        uiCodeInput.placeholder = "초대코드를 입력하세요.".localized;
        
        uiAccBtn.setTitle("입력완료".localized, for: .normal)
        uiAccBtn.backgroundColor = UIColor(rgb: 0x00BA87)
    }
    @IBAction func onAccBtn(_ sender: Any) {
        let Code = uiCodeInput.text!;
        if Code == "" {
            self.makeToast("코드를 입력해주세요.".localized)
            return;
        }
        if m_isAccBtn {
            return;
        }
        m_isAccBtn = true;
        m_tClickEvent?.ClickEvent(type: 4, data: ["code":Code])
        uiCodeInput.text = "";
    }
    func FinishBtn(){
        m_isAccBtn = false;
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
}
