//
//  TradeDealAndRejecPop.swift
//  golf2u
//
//  Created by 이원영 on 2020/10/20.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class TradeDealAndRejecPop: VariousViewController {
    public var closeHandler: ((String)->())?//클로저

    @IBOutlet weak var uiTitlelb: UILabel!
    @IBOutlet weak var uiSubTitlelb: UILabel!
    @IBOutlet weak var uiComboBtn: UIButton!
    @IBOutlet weak var uiAccBtn: UIButton!
    private var m_sIssu = "";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiComboBtn.layer.cornerRadius = 8.0
        uiComboBtn.layer.borderWidth = 1.0
        uiComboBtn.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        uiTitlelb.text = "거절 사유".localized;
        uiSubTitlelb.text = "트레이드 거절의 따른 사유를 선택해주세요.".localized;
        uiComboBtn.setTitle("거절 사유 선택".localized, for: .normal)
        uiAccBtn.setTitle("확인".localized, for: .normal)

    }
    static func instantiate() -> TradeDealAndRejecPop? {
        return UIStoryboard(name: "TradeDealAndRejecPop", bundle: nil).instantiateViewController(withIdentifier: "\(TradeDealAndRejecPop.self)") as? TradeDealAndRejecPop
    }
    func setText(){
    }
    @IBAction func onCloseBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onIssuBtn(_ sender: Any) {
        popList();
    }
    @IBAction func onAcceptBtn(_ sender: Any) {
        if m_sIssu == "" {
            popList();
            return;
        }
        closeHandler?(m_sIssu);
        dismiss(animated: true, completion: nil)
    }
    func popList(){
        let optionMenu = UIAlertController(title: nil, message: "사유".localized, preferredStyle: .actionSheet)
        //옵션 초기화
        let alertacop1 = UIAlertAction(title: "노코멘트하겠습니다.".localized, style: .default, handler: alertHandleOp1)
        let alertacop2 = UIAlertAction(title: "비슷한 정가의 상품을 제안주시죠.".localized, style: .default, handler: alertHandleOp1)
        let alertacop3 = UIAlertAction(title: "이 상품은 저에게 필요하지 않아요.".localized, style: .default, handler: alertHandleOp1)
        let alertacop4 = UIAlertAction(title: "거래가 예정된 상품입니다.".localized, style: .default, handler: alertHandleOp1)
        let cancelAction = UIAlertAction(title: "닫기".localized, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(alertacop1)
        optionMenu.addAction(alertacop2)
        optionMenu.addAction(alertacop3)
        optionMenu.addAction(alertacop4)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    func alertHandleOp1(alertAction: UIAlertAction!) -> Void {
        m_sIssu = alertAction.title!;
        uiComboBtn.setTitle(alertAction.title!, for: .normal)
    }
    
}
