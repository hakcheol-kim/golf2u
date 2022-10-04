//
//  GiftInvenCode.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/18.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class GiftInvenCode: VariousViewController {
    weak var m_tClickEvent: InventoryMainClickCellBtnDelegate? = nil;

    @IBOutlet weak var uiCodeInput: UITextField!
    @IBOutlet weak var uiAccBtn: UIButton!
    @IBOutlet weak var uiHelplb: UILabel!
    private var m_isAccBtn = false;
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "선물코드 입력".localized)
        super.viewDidLoad()

        uiCodeInput.layer.cornerRadius = 8.0;
        uiCodeInput.layer.borderWidth = 1.0
        uiCodeInput.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiCodeInput.addLeftPadding()
        uiCodeInput.placeholder = "선물코드를 입력하세요.".localized;
        uiAccBtn.setTitle("입력완료".localized, for: .normal)
        uiHelplb.text = "받으신 선물코드를 상단 입력란에 입력해주세요.\n선물받기가 완료되면 상품 or 박스 보관함에서 확인 가능합니다.".localized;
    }
    
    @IBAction func onAccBtn(_ sender: Any) {
        if m_isAccBtn {
            return;
        }
        let fm_sCode = uiCodeInput.text!
        if fm_sCode == "" {
            return;
        }
        m_isAccBtn  = true
        m_tClickEvent?.ClickEvent(viewtype : 1, type: 8, data: [fm_sCode])
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func AccViewDiss(){
       
        self.navigationController?.popViewController(animated: true);
    }
    func GiftRecvFinish(){
        m_isAccBtn = false;
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
    

}
