//
//  CuponInfoPaper.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/25.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import EzPopup
import SwiftyJSON

class CuponInfoPaper: VariousViewController {
    private let SO = Single.getSO();
    private let JS = JsonC();
    weak var m_tClickEvent: CuponInfoDelegate? = nil;
    
    @IBOutlet weak var uiCuponNumInput: UITextField!
    @IBOutlet weak var uiAccBtn: UIButton!
    @IBOutlet weak var uiHelplb: UILabel!
    
    private var m_isAccBtn : Bool = false;
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "지류쿠폰 등록".localized)
        super.viewDidLoad()
        
        uiCuponNumInput.layer.cornerRadius = 8.0;
        uiCuponNumInput.layer.borderWidth = 1.0
        uiCuponNumInput.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiCuponNumInput.addLeftPadding()
        uiCuponNumInput.placeholder = "쿠폰번호를 입력해주세요.".localized
        uiAccBtn.setTitle("쿠폰 등록".localized, for: .normal)
        uiHelplb.text = "쿠폰번호 입력을 통해 지류쿠폰을 등록할 수 있습니다.\n\n유효기간이 지났거나 1인당 참여횟수를 초과한 쿠폰은 등록이 제한됩니다.\n\n지류쿠폰은 중복참여 확인을 위해 본인인증이 필요합니다.\n\n등록 오류 시, 고객센터로 1:1문의 바랍니다.".localized;
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    @IBAction func onAccBtn(_ sender: Any) {
        let fm_sCode = uiCuponNumInput.text!
        if fm_sCode == "" {
            return;
        }
        if m_isAccBtn {
            return;
        }
        m_isAccBtn = true;
        LoadingHUD.show()
        JS.takeCodeCoupon(param: ["code":fm_sCode,"account_seq":super.getUserSeq()], callbackf: takeCodeCouponCallback)
    }
    func takeCodeCouponCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            if alldata["errorcode"] != "4" {
                MessagePop(msg: alldata["errormessage"].stringValue, btntype : 2)
            }else{
                MessagePop(title : "본인인증".localized, msg: "본인인증 하시겠습니까?".localized, ostuch:false, lbtn: "취소".localized, rbtn: "본인인증".localized,succallbackf: { ()-> Void in
                    //self.navigationController?.popViewController(animated: true);
                    let Storyboard: UIStoryboard = UIStoryboard(name: "UserVerification", bundle: nil)
                    let viewController = Storyboard.instantiateViewController(withIdentifier: "UserVerificationidx") as! UserVerification
                    viewController.setData(data: ["os_type":Single.DE_PLATFORMIDX, "account_seq":super.getUserSeq()])
                    self.navigationController?.pushViewController(viewController, animated: true)
                }, closecallbackf: { ()-> Void in
                    //self.navigationController?.popViewController(animated: true);
                })
            }
        }else{
            MessagePop(msg: "지류쿠폰이 등록되었습니다.\n획득가능쿠폰 탭에서 획득 후\n사용하실 수 있습니다.".localized, btntype : 2,succallbackf: { ()-> Void in
                self.m_tClickEvent?.ClickEvent(type: 4, data: [:])
                self.navigationController?.popViewController(animated: true);
            }, closecallbackf: { ()-> Void in
                
            })
        }
        m_isAccBtn = false;
        LoadingHUD.hide()
    }
}
