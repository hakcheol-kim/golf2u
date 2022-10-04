//
//  TextPopup.swift
//  random2u_new
//
//  Created by 이원영 on 2020/09/19.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class TextPopup: VariousViewController {
    public var closeHandler: (()->())?
    public var sucHandler: (()->())?
    
    @IBOutlet weak var uiBtnContentsView: UIView!
    @IBOutlet var uiOneBtn: UIView!
    @IBOutlet var uiTwoBtnView: UIView!
    @IBOutlet weak var titme: UILabel!
    @IBOutlet weak var msg: UILabel!
    @IBOutlet weak var uiSucBtn: UIButton!
    @IBOutlet weak var onCloseBtn: UIButton!
    
    private var m_sTitle = "";
    private var m_sMsg = "";
    private var m_sSucTitle = "확인".localized;
    private var m_sCloseTitle = "닫기".localized;
    private var m_isColorRv = false;
    private var m_nBtnType = 1;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titme.text = m_sTitle;
        self.msg.text = m_sMsg;
        onCloseBtn.setTitle(m_sCloseTitle, for: .normal)
        uiSucBtn.setTitle(m_sSucTitle, for: .normal)
        //self.uiSucBtn.layer.addBorder([.top,], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        if m_nBtnType == 1{
            setContentsView(uiView: uiTwoBtnView);
        }else if m_nBtnType == 2{
            setContentsView(uiView: uiOneBtn);
        }
        if m_isColorRv {
            uiSucBtn.setTitleColor(UIColor(rgb: 0x333333), for: .normal)
            onCloseBtn.setTitleColor(UIColor(rgb: 0x00BA87), for: .normal)
        }else{
            onCloseBtn.setTitleColor(UIColor(rgb: 0x333333), for: .normal)
            uiSucBtn.setTitleColor(UIColor(rgb: 0x00BA87), for: .normal)
        }
    }
    func setContentsView(uiView : UIView){
        uiBtnContentsView.addSubview(uiView)
        
        uiView.translatesAutoresizingMaskIntoConstraints = false
        uiView.topAnchor.constraint(equalTo: uiBtnContentsView.topAnchor,constant: 0).isActive = true
        uiView.leftAnchor.constraint(equalTo:uiBtnContentsView.leftAnchor,constant: 0).isActive = true
        uiView.rightAnchor.constraint(equalTo: uiBtnContentsView.rightAnchor, constant: 0).isActive = true
        uiView.bottomAnchor.constraint(equalTo: uiBtnContentsView  .bottomAnchor, constant: 0).isActive = true
        
    }
    func setButtonText(can : String = "닫기".localized, suc : String = "확인".localized){
        m_sSucTitle = suc;
        m_sCloseTitle = can;
    }
    static func instantiate() -> TextPopup? {
        return UIStoryboard(name: "TextPopup", bundle: nil).instantiateViewController(withIdentifier: "\(TextPopup.self)") as? TextPopup
    }
    func setBtnType(type : Int, colorRv : Bool = false){
        m_nBtnType = type;
        m_isColorRv = colorRv;
    }
    func setText(title : String, msg : String){
        self.m_sTitle = title;
        self.m_sMsg = msg;
    }
    
    @IBAction func onCloseBtn(_ sender: Any) {
        closeHandler?()
        dismiss(animated: true, completion: nil)
    }
    @IBAction func onAcceptBtn(_ sender: Any) {
        sucHandler?()
        dismiss(animated: true, completion: nil)
    }
    

}
