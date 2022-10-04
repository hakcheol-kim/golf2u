//
//  FriendMain.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/09.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import EzPopup
import Toast_Swift
import SwiftyJSON

protocol ClickCellBtnDelegate: class {
    func ClickEvent(viewtype : Int, type:Int, data : [String:String])
}

class FriendMain: VariousViewController {
    private let SO = Single.getSO();
    private let JS = JsonC();
    
    @IBOutlet weak var uiTopView: ReportCustomSegmentedControl!{
        didSet{
            uiTopView.setButtonTitles(buttonTitles: ["친구 목록".localized,"친구 신청".localized])
            uiTopView.selectorViewColor = UIColor(rgb: 0x00BA87)
            uiTopView.selectorTextColor = UIColor(rgb: 0x00BA87)
            uiTopView.textColor = .black
            uiTopView.backgroundColor = .white
        }
    }
    
    private var m_FriendListView : FriendList?;
    private var m_FriendSendView : FriendSend?;
    private var m_FriendListSearch : FriendListSearch?;
    private var m_FriendBlackList : FriendBlackList?;
    private var m_BlackListSearch : FriendListSearch?;
    private var m_FriendGift : FriendGift?
    
    private var m_nSelMenu = 0;
    @IBOutlet weak var uiContentsView: UIView!
    
    private var m_sUserSeq = "";
    
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "친구관리".localized)
        super.viewDidLoad()
        
        m_sUserSeq = super.getUserSeq()
        
        uiTopView.delegate = self;
        
        m_FriendListView = FriendList(frame: self.uiContentsView.bounds)
        m_FriendListView?.m_tClickEvent = self;
        
        m_FriendSendView = FriendSend(frame: self.uiContentsView.bounds)
        m_FriendSendView?.m_tClickEvent = self;
        
        //UserVerify()
        setContentsView(uiView: m_FriendListView!);
        
        
    }
    func setMenu(selmenu : Int){
        m_nSelMenu = selmenu
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.uiTopView.setIndex(index: m_nSelMenu)
        ChnageView()
    }
    
    func UserVerify(){
        if SO.getUserInfoKey(key: Single.DE_USERVERIFIED) == "0" {
            MessagePop(title : "본인인증".localized, msg: "본인인증 후 사용하실수있습니다.".localized, ostuch:false, lbtn: "취소".localized, rbtn: "본인인증".localized,succallbackf: { ()-> Void in
                self.navigationController?.popViewController(animated: true);
                let Storyboard: UIStoryboard = UIStoryboard(name: "UserVerification", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "UserVerificationidx") as! UserVerification
                viewController.setData(data: ["os_type":Single.DE_PLATFORMIDX, "account_seq":super.getUserSeq()])
                self.navigationController?.pushViewController(viewController, animated: true)
            }, closecallbackf: { ()-> Void in
                self.navigationController?.popViewController(animated: true);
            })
            
        }else{
            setContentsView(uiView: m_FriendListView!);
        }
    }
    func setContentsView(uiView : UIView){
        self.uiContentsView.addSubview(uiView)
        
        uiView.translatesAutoresizingMaskIntoConstraints = false
        uiView.topAnchor.constraint(equalTo: uiContentsView.topAnchor,constant: 0).isActive = true
        uiView.leftAnchor.constraint(equalTo:uiContentsView.leftAnchor,constant: 0).isActive = true
        uiView.rightAnchor.constraint(equalTo: uiContentsView.rightAnchor, constant: 0).isActive = true
        uiView.bottomAnchor.constraint(equalTo: uiContentsView.bottomAnchor, constant: 0).isActive = true
    }
    func ChnageView(){
        for v in uiContentsView.subviews{
            v.removeFromSuperview()
        }
        if m_nSelMenu == 0 {
            setContentsView(uiView: m_FriendListView!);
        }else if m_nSelMenu == 1 {
            setContentsView(uiView: m_FriendSendView!);
        }
    }
    func ListFlush(){
        if m_nSelMenu == 0 {
            m_FriendListView?.refresh()
        }else if m_nSelMenu == 1 {
            m_FriendSendView?.refresh()
        }
    }
}
extension FriendMain : ReportCustomSegmentedControlDelegate{
    func changeToIndex(index: Int) {
        if m_nSelMenu == index{
            return;
        }
        m_nSelMenu = index;
        ChnageView();
    }
    
}
extension FriendMain: ClickCellBtnDelegate {
    func ClickEvent(viewtype : Int, type:Int, data : [String:String]){
        if viewtype == 1 {
            //친구목록
            if type == 1{
                //트레이드 화면으로
                if super.getUserSeq() == "" {
                    //self.view.makeToast("로그인 후 이용해주세요.", duration: 1.0, position: .bottom)
                    super.LoginMove()
                    return;
                }
                let Storyboard: UIStoryboard = UIStoryboard(name: "TradeApply", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "tradeapplyidx") as! TradeApply
                viewController.setData(selUSeq: data["account_seq"]!, selPSeq: "");
                self.navigationController?.pushViewController(viewController, animated: true)
            }else  if type == 2{
                //선물하기
                let Storyboard: UIStoryboard = UIStoryboard(name: "FriendGift", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "FriendGiftidx") as! FriendGift
                viewController.m_tClickEvent = self;
                viewController.setUserDate(data: data)
                m_FriendGift = viewController
                self.navigationController?.pushViewController(viewController, animated: true)
            }else if type == 3 {
                //친구 끊기
                MessagePop(title : "친구 끊기".localized, msg: "해당 회원과 친구입니다.\n친구취소를 하시겠습니까?".localized, lbtn: "취소".localized, rbtn: "확인".localized,succallbackf: { ()-> Void in
                    LoadingHUD.show()
                    self.JS.FriendDelete(param: ["target_account_seq":data["account_seq"]!,"account_seq":self.m_sUserSeq], callbackf: self.FriendDeleteCallback)
                }, closecallbackf: { ()-> Void in
                    
                })
            }else  if type == 4{
                //회원검색
                let Storyboard: UIStoryboard = UIStoryboard(name: "FriendListSearch", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "FriendListSearchidx") as! FriendListSearch
                viewController.m_tClickEvent = self;
                viewController.setTypeList(type: 1)
                m_FriendListSearch = viewController
                self.navigationController?.pushViewController(viewController, animated: true)
            }else  if type == 5{
                //회원 추가
                if SO.getUserInfoKey(key: Single.DE_USERVERIFIED) == "0" {
                    MessagePop(title : "본인인증".localized, msg: "본인인증 후 사용하실수있습니다.".localized, ostuch:false, lbtn: "취소".localized, rbtn: "본인인증".localized,succallbackf: { ()-> Void in
                        let Storyboard: UIStoryboard = UIStoryboard(name: "UserVerification", bundle: nil)
                        let viewController = Storyboard.instantiateViewController(withIdentifier: "UserVerificationidx") as! UserVerification
                        viewController.setData(data: ["os_type":Single.DE_PLATFORMIDX, "account_seq":super.getUserSeq()])
                        self.navigationController?.pushViewController(viewController, animated: true)
                    }, closecallbackf: { ()-> Void in
                        //self.navigationController?.popViewController(animated: true);
                    })
                    
                }else{
                    MessagePop(title : "친구 신청".localized, msg: "상대방이 수락하면 친구가 될 수 있습니다.\n친구 신청을 하시겠습니까?".localized, lbtn: "취소".localized, rbtn: "확인".localized,succallbackf: { ()-> Void in
                        LoadingHUD.show()
                        self.JS.FriendAdd(param: ["target_account_seq":data["account_seq"]!,"account_seq":self.m_sUserSeq], callbackf: self.FriendDeleteCallback)
                    }, closecallbackf: { ()-> Void in
                        
                    })
                }
                
            }else  if type == 6{
                //블랙리스트화면으로
                let Storyboard: UIStoryboard = UIStoryboard(name: "FriendBlackList", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "FriendBlackListidx") as! FriendBlackList
                viewController.m_tClickEvent = self;
                m_FriendBlackList = viewController
                self.navigationController?.pushViewController(viewController, animated: true)
            }else  if type == 7{
                //블랙리스트 해제
                MessagePop(title : "블랙리스트 해제".localized, msg: "해당 사용자를 블랙리스트에서 해제합니다.".localized, lbtn: "취소".localized, rbtn: "확인".localized,succallbackf: { ()-> Void in
                    LoadingHUD.show()
                    self.JS.BlackListDel(param: ["target_account_seq":data["account_seq"]!,"account_seq":self.m_sUserSeq], callbackf: self.BlackListDelCallback)
                }, closecallbackf: { ()-> Void in
                    
                })
            }else  if type == 8{
                //블랙리스트 추가
                MessagePop(title : "블랙리스트".localized, msg: "블랙리스트 추가 시 해당 사용자와는 트레이드, 선물하기가 불가능합니다. 추가하시겠습니까?".localized, lbtn: "취소".localized, rbtn: "확인".localized,succallbackf: { ()-> Void in
                    LoadingHUD.show()
                    self.JS.BlackListAdd(param: ["target_account_seq":data["account_seq"]!,"account_seq":self.m_sUserSeq], callbackf: self.BlackListDelCallback)
                }, closecallbackf: { ()-> Void in
                    
                })
            }else  if type == 9{
                //블랙리스트 회원검색
                let Storyboard: UIStoryboard = UIStoryboard(name: "FriendListSearch", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "FriendListSearchidx") as! FriendListSearch
                viewController.m_tClickEvent = self;
                viewController.setTypeList(type: 0)
                m_BlackListSearch = viewController
                self.navigationController?.pushViewController(viewController, animated: true)
            }else  if type == 10{
                //친구 신청 취소
                LoadingHUD.show()
                self.JS.FriendSendResult(param: ["request_seq":data["seq"]!,"account_seq":self.m_sUserSeq,"state":"3"], callbackf: self.FriendSendResultCallback)
            }else  if type == 11{
                //친구 신청 수락
                LoadingHUD.show()
                self.JS.FriendSendResult(param: ["request_seq":data["seq"]!,"account_seq":self.m_sUserSeq,"state":"1"], callbackf: self.FriendSendResultCallback)
            }else  if type == 12{
                //친구 신청 거절
                LoadingHUD.show()
                self.JS.FriendSendResult(param: ["request_seq":data["seq"]!,"account_seq":self.m_sUserSeq,"state":"2"], callbackf: self.FriendSendResultCallback)
            }else  if type == 13{
                //프로필 사진 확대
                super.ProfileImagePlus(UserImgUrl: data["profile_image_url"] ?? "")
            }
        }
    }
    func FriendDeleteCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            MessagePop(msg: alldata["errormessage"].stringValue, btntype : 2)
        }else{
            m_FriendListView?.refresh();
            m_FriendListSearch?.refresh();
        }
        LoadingHUD.hide()
    }
    func BlackListDelCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            MessagePop(msg: alldata["errormessage"].stringValue, btntype : 2)
        }else{
            m_FriendBlackList?.refresh();
            m_BlackListSearch?.refresh();
        }
        LoadingHUD.hide()
    }
    func FriendSendResultCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            MessagePop(msg: alldata["errormessage"].stringValue, btntype : 2)
        }else{
            m_FriendListSearch?.refresh();
            m_FriendSendView?.refresh();
        }
        LoadingHUD.hide()
    }
}
