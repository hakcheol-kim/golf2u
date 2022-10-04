//
//  FriendInvation.swift
//  golf2u
//
//  Created by 이원영 on 2020/12/04.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON
import MessageUI//문자전송

protocol FriendInvationDelegate: class {
    func ClickEvent(type:Int, data : [String:String])
}

class FriendInvation: VariousViewController {
    private var SO:Single = Single.getSO();
    private let JS = JsonC();
    
    private var m_nSelMenu = 0;
    
    @IBOutlet weak var uiTopTabView: ReportCustomSegmentedControl!{
        didSet{
            uiTopTabView.setButtonTitles(buttonTitles: ["초대코드 생성".localized,"초대코드 입력".localized])
            uiTopTabView.selectorViewColor = UIColor(rgb: 0x00BA87)
            uiTopTabView.selectorTextColor = UIColor(rgb: 0x00BA87)
            uiTopTabView.textColor = .black
            uiTopTabView.backgroundColor = .white
        }
    }
    @IBOutlet weak var uiContentsView: UIView!
    @IBOutlet weak var uiBottomCoverView: UIView!
    
    private var m_tIV : Invation?;
    private var m_tCI : CodeInput?;
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "초대 이벤트".localized)
        super.viewDidLoad()
        
        uiTopTabView.delegate = self;
        
        uiContentsView.layer.addBorder([.top], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
        m_tIV = Invation(frame: self.uiContentsView.bounds)
        m_tIV?.m_tClickEvent = self;
        m_tCI = CodeInput(frame: self.uiContentsView.bounds)
        m_tCI?.m_tClickEvent = self;
        setContentsView(uiView: m_tIV!)
    }
    

    func setContentsView(uiView : UIView){
        self.uiContentsView.addSubview(uiView)
        
        uiView.translatesAutoresizingMaskIntoConstraints = false
        uiView.topAnchor.constraint(equalTo: uiContentsView.topAnchor,constant: 0).isActive = true
        uiView.leftAnchor.constraint(equalTo:uiContentsView.leftAnchor,constant: 0).isActive = true
        uiView.rightAnchor.constraint(equalTo: uiContentsView.rightAnchor, constant: 0).isActive = true
        uiView.bottomAnchor.constraint(equalTo: uiContentsView.bottomAnchor, constant: 0).isActive = true
    }
}
extension FriendInvation : ReportCustomSegmentedControlDelegate{
    func changeToIndex(index: Int) {
        if m_nSelMenu == index{
            return;
        }
        m_nSelMenu = index;
        for v in uiContentsView.subviews{
            v.removeFromSuperview()
        }
        if m_nSelMenu == 0 {
            uiBottomCoverView.backgroundColor = UIColor.white
            setContentsView(uiView: m_tIV!);
        }else if m_nSelMenu == 1 {
            uiBottomCoverView.backgroundColor = UIColor(rgb: 0xF47C73)
            setContentsView(uiView: m_tCI!);
        }
        
    }
}

extension FriendInvation: FriendInvationDelegate {
    func ClickEvent(type: Int, data: [String : String]) {
        if type == 1 {
            //친구 코드 생성
            LoadingHUD.show()
            JS.setInvCode(param: ["seq":super.getUserSeq()], callbackf: setInvCodeCallback)
        }
        else if type == 2 {
            //카카오 공유
            //let text = "랜덤투유\\n친구초대코드 :".localized(txt: "\(data["code"] ?? "")")
            let text = "홀인원보다 짜릿한 랜덤쇼핑!\n만원의 행복 골프투유 입니다.\n코드를 복사하여 입력하면 1천원 할인 쿠폰이 지급됩니다.\n\n친구 초대코드 : \(data["code"] ?? "")"
            self.KakaoShare(text : text, btnname: "코드 입력하러 가기", imgurl: "https://r2u-image-storage-staging.s3.ap-northeast-2.amazonaws.com/images/default/profile/ic_kakao.png")
        }else if type == 3 {
            //sms 공유
            guard MFMessageComposeViewController.canSendText() else {
                print("SMS services are not available")
                return
            }
            
            let composeViewController = MFMessageComposeViewController()
            composeViewController.messageComposeDelegate = self
            composeViewController.recipients = [""]
            composeViewController.body = """
                홀인원보다 짜릿한 랜덤쇼핑!
                만원의 행복 골프투유 입니다.
                코드를 복사하여 입력하면 1천원 할인 쿠폰이 지급됩니다.
                친구 초대코드 : \(data["code"] ?? "")
                """
            //https://random2u.page.link/LbNr
            //self.navigationController?.pushViewController(composeViewController, animated: true)
            self.present(composeViewController, animated: true, completion: nil)
        }else if type == 4 {
            //코드입력
            LoadingHUD.show()
            JS.insertInvCode(param: ["seq":super.getUserSeq(), "code":data["code"] ?? ""], callbackf: insertInvCodeCallback)
        }
    }
    func setInvCodeCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            if alldata["errorcode"] == "6" {
                MessagePop(title : "본인 인증 필요".localized, msg: "초대코드 생성을 위해서는 본인인증이 필요합니다.".localized, ostuch:false, lbtn: "취소".localized, rbtn: "인증하기".localized,succallbackf: { ()-> Void in
                    //self.navigationController?.popViewController(animated: true);
                    let Storyboard: UIStoryboard = UIStoryboard(name: "UserVerification", bundle: nil)
                    let viewController = Storyboard.instantiateViewController(withIdentifier: "UserVerificationidx") as! UserVerification
                    viewController.setData(data: ["os_type":Single.DE_PLATFORMIDX, "account_seq":super.getUserSeq()])
                    self.navigationController?.pushViewController(viewController, animated: true)
                }, closecallbackf: { ()-> Void in
                    //self.navigationController?.popViewController(animated: true);
                })
            }else{
                MessagePop(msg: alldata["errormessage"].stringValue, btntype : 2)
            }
        }else{
            m_tIV?.setCode(code: alldata["data"].stringValue)
        }
        m_tIV?.FinishBtn()
        LoadingHUD.hide()
    }
    func insertInvCodeCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            if alldata["errorcode"] == "6" {
                MessagePop(title : "본인인증".localized, msg: "본인인증 하시겠습니까?".localized, ostuch:false, lbtn: "취소".localized, rbtn: "본인인증".localized,succallbackf: { ()-> Void in
                    //self.navigationController?.popViewController(animated: true);
                    let Storyboard: UIStoryboard = UIStoryboard(name: "UserVerification", bundle: nil)
                    let viewController = Storyboard.instantiateViewController(withIdentifier: "UserVerificationidx") as! UserVerification
                    viewController.setData(data: ["os_type":Single.DE_PLATFORMIDX, "account_seq":super.getUserSeq()])
                    self.navigationController?.pushViewController(viewController, animated: true)
                }, closecallbackf: { ()-> Void in
                    //self.navigationController?.popViewController(animated: true);
                })
            }else{
                MessagePop(msg: alldata["errormessage"].stringValue, btntype : 2)
            }
        }else{
            SO.setUserInfoKey(key: "point_total", value: alldata["data"].stringValue);
            MessagePop(msg: "친구초대 코드입력으로\n1,000클로버가 정상 지급되었습니다.".localized, btntype : 2)
        }
        m_tCI?.FinishBtn()
        LoadingHUD.hide()
    }
    
}
extension FriendInvation: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .cancelled:
            print("cancelled")
            dismiss(animated: true, completion: nil)
        case .sent:
            print("sent message:", controller.body ?? "")
            dismiss(animated: true, completion: nil)
        case .failed:
            print("failed")
            dismiss(animated: true, completion: nil)
        @unknown default:
            print("unkown Error")
            dismiss(animated: true, completion: nil)
        }
    }
}
