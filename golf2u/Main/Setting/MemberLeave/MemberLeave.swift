//
//  MemberLeave.swift
//  golf2u
//
//  Created by 이원영 on 2020/12/07.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON
//import DownPickerSwift

class MemberLeave: VariousViewController {
    private let SO = Single.getSO();
    private let JS = JsonC();
    
    @IBOutlet weak var uiTypeInput: UITextField!
    @IBOutlet weak var uiAgree: CircleCheckBoxBtn!
    @IBOutlet weak var uiAccBtn: UIButton!
    private var uiTypeComboDP: DownPickerSwift?
    @IBOutlet weak var uiBottomView: UIView!
    @IBOutlet weak var uiHelp1lb: UILabel!
    @IBOutlet weak var uiHelp2lb: UILabel!
    
    private var m_sType = "";
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "회원탈퇴".localized)
        super.viewDidLoad()
        
        uiHelp1lb.text = "[회원탈퇴 유의사항]\n- 랜덤투유 회원탈퇴 시 본 어플리케이션 서비스에 탈퇴되며, 탈퇴한 계정의정보는 복구가 불가능합니다.\n- 탈퇴한 계정의 정보는 모두 삭제됩니다.\n\n■ 삭제 정보\n닉네임, 이메일, 클로버 정보, 상품 정보, 박스 내역정보 등의 랜덤투유 전체 이용 정보".localized
        
        uiHelp2lb.text = "내용을 확인하였으며, 랜덤투유 계정을 삭제합니다.".localized
        
        uiAccBtn.setTitle("탈퇴하기".localized, for: .normal)
        
        uiTypeInput.layer.cornerRadius = 8.0;
        uiTypeInput.layer.borderWidth = 1.0
        uiTypeInput.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiTypeInput.addLeftPadding();
        
        let fm_arrType = ["더 이상 앱을 사용하고 싶지 않아서".localized,"앱 시스템으로 인한 불편함을 느껴서".localized,"재가입을 하기 위해서".localized,"기타 이유".localized]
        uiTypeComboDP = DownPickerSwift(with: uiTypeInput, with: fm_arrType)
        uiTypeComboDP?.showArrowImage(false)
        uiTypeComboDP?.setToolbarDoneButton(with: "확인")
        uiTypeComboDP?.setToolbarCancelButton(with: "취소")
        uiTypeComboDP?.setPlaceholder(with: "탈퇴사유를 선택하세요.".localized)
        uiTypeComboDP?.addTarget(self, action: #selector(onTypeCombo(selectedValue:)), for: .valueChanged)
        
        self.uiBottomView.layer.addBorder([.top], color: UIColor(rgb: 0xe4e4e4), width: 1.0)

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
    @objc private func onTypeCombo(selectedValue: DownPickerSwift) {
        m_sType = selectedValue.getTextField().text!;
    }
    @IBAction func onAccBtn(_ sender: Any) {
        if m_sType == "" {
            MessagePop(msg: "탈퇴사유를 선택하세요.".localized, btntype : 2)
            return;
        }else if !uiAgree.isChecked {
            MessagePop(title:"회원탈퇴 확인란을 체크하세요.".localized,msg: "탈퇴를 원하실경우 회원탈퇴\n확인란을 체크하세요.".localized, btntype : 2)
            return;
        }
        let fm_sLeaveDis = """
         유의사항을 모두 확인하셨다면
         <확인>버튼을 눌러주세요.
         <확인>버튼을 누르면 탈퇴가 완료 됩니다.
        """;
        super.MessagePop(title : "안내".localized, msg: fm_sLeaveDis.localized, lbtn: "확인".localized, rbtn: "취소".localized, fcolorRv: true,succallbackf: { ()-> Void in
            
            
        }, closecallbackf: { ()-> Void in
            //여기가 확인임
            self.dismiss(animated: false, completion: nil)
            LoadingHUD.show()
            self.JS.UserLeave(param: ["seq":super.getUserSeq(), "reason":self.m_sType], callbackf: self.UserLeaveCallback)
        })
        
    }
    func UserLeaveCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            MessagePop(msg: alldata["errormessage"].stringValue, btntype : 2)
        }else{
            MessagePop(title : "회원탈퇴 완료".localized, msg: "탈퇴가 정상 처리되었습니다.".localized, btntype : 2, ostuch:false, rbtn: "확인".localized,succallbackf: { ()-> Void in
                LoadingHUD.show()
                self.JS.logout(param: ["seq":super.getUserSeq()], callbackf: self.logoutCallback)
            }, closecallbackf: { ()-> Void in
            })
        }
        LoadingHUD.hide()
    }
    func logoutCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            MessagePop(msg: alldata["errormessage"].stringValue, btntype:2)
        }else{
            UserDefaults.standard.removeObject(forKey: Single.DE_AUTOLOGIN)
            SO.UserLogout();
            if SO.getTabbarIndex() == 0 {
                SO.getStartMain()?.viewWillAppear(true)
            }else if SO.getTabbarIndex() == 3 {
                SO.getInventoryMain()?.viewWillAppear(true)
            }
            SO.setTabbarIndex(TabbarIndex: 0)
            
            let fm_Contrllers = self.navigationController?.viewControllers
            if let val = fm_Contrllers{
                for VC in val{
                    if VC is StartMain {
                        self.navigationController?.popToViewController(VC, animated: true)
                        break;
                    }else if VC is TradeMain {
                        self.navigationController?.popToViewController(VC, animated: true)
                        break;
                    }else if VC is CommunityMain {
                        self.navigationController?.popToViewController(VC, animated: true)
                        break;
                    }else if VC is InventoryMain {
                        self.navigationController?.popToViewController(VC, animated: true)
                        break;
                    }
                    
                }
            }
        }
        LoadingHUD.hide()
    }
}
