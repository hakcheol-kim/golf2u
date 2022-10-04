//
//  UVView.swift
//  golf2u
//
//  Created by 이원영 on 2020/12/28.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class UVView: UIView {
    private let xibName = "UVView"
    
    weak var m_tClickEvent: ClickCellBtnDelegate? = nil;//FriendMain
    private let SO = Single.getSO();
    private let JS = JsonC();
    @IBOutlet weak var uiAccBtn: UIButton!
    
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
        
        uiAccBtn.layer.cornerRadius = uiAccBtn.bounds.height/2;
        uiAccBtn.layer.borderWidth = 1.0
        uiAccBtn.layer.borderColor = UIColor(rgb: 0x00BA87).cgColor
    }
    @IBAction func onAccBtgn(_ sender: Any) {
        if let parentVC = self.parentViewController {
            let Storyboard: UIStoryboard = UIStoryboard(name: "UserVerification", bundle: nil)
            let viewController = Storyboard.instantiateViewController(withIdentifier: "UserVerificationidx") as! UserVerification
            viewController.setData(data: ["os_type":Single.DE_PLATFORMIDX, "account_seq":SO.getUserInfoKey(key: "seq")])
            parentVC.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
