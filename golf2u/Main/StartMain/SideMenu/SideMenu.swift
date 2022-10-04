//
//  SideMenu.swift
//  golf2u
//
//  Created by 이원영 on 2020/09/22.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON
import ImageSlideshow

class SideMenu: VariousViewController {
    private let SO = Single.getSO();
    private let JS = JsonC();
    
    @IBOutlet weak var uiTopContentView: UIView!
    @IBOutlet weak var uiButtonVIEW: UIView!
    
    @IBOutlet var uiLoginView: UIView!
    @IBOutlet weak var uiUserImg: UIImageView!
    @IBOutlet weak var uiUsername: UILabel!
    @IBOutlet weak var uiCloverBtn: UIButton!
    
    
    @IBOutlet var uiNotLoginView: UIView!
    @IBOutlet weak var uiWelcomLabel: UILabel!
    @IBOutlet weak var uiWelcomsublb: UILabel!
    @IBOutlet weak var uiNUserImg: UIImageView!
    @IBOutlet weak var uiLoginBtn: UIButton!
    @IBOutlet weak var uiNewPushImg: UIImageView!
    @IBOutlet weak var uiPushBtn: UIButton!
    
    @IBOutlet weak var uiLogoutBtn: UIButton!
    
    @IBOutlet weak var uiTradeBtn: UIButton!
    @IBOutlet weak var uiDeliveryBtn: UIButton!
    @IBOutlet weak var uiCuponBtn: UIButton!
    @IBOutlet weak var uiFriendBtn: UIButton!
    @IBOutlet weak var uiContactBtn: UIButton!
    @IBOutlet weak var uiSettingBtn: UIButton!
    
    private var m_sUserImgUrl = "";
    
    
    
    private var m_UserInfo = [String : String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiLoginBtn.setTitle("로그인".localized, for: .normal)
        uiLogoutBtn.setTitle("로그아웃".localized, for: .normal)
        uiWelcomsublb.text = "서비스 이용을 위해 로그인이 필요합니다.".localized;
        uiTradeBtn.setTitle("트레이드 현황".localized, for: .normal)
        uiDeliveryBtn.setTitle("배송조회".localized, for: .normal)
        uiCuponBtn.setTitle("쿠폰함".localized, for: .normal)
        uiFriendBtn.setTitle("친구관리".localized, for: .normal)
        uiContactBtn.setTitle("고객센터".localized, for: .normal)
        uiSettingBtn.setTitle("설정".localized, for: .normal)
        
        uiLoginBtn.layer.cornerRadius = 8.0;
        uiLoginBtn.layer.borderWidth = 1.0
        uiLoginBtn.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        uiWelcomLabel.TextPartColor(partstr: "Random2u!", Color: UIColor(rgb: 0x00BA87))
        
        uiUserImg.layer.cornerRadius = uiUserImg.frame.height/2
        
        let tapGestureRecognizer1 = UITapGestureRecognizer(target:self, action: #selector(self.onPCPhoto(tapGesture:)))
        tapGestureRecognizer1.numberOfTapsRequired = 1
        uiUserImg.isUserInteractionEnabled = true
        uiUserImg.addGestureRecognizer(tapGestureRecognizer1)
        
        
    }
    @objc func onPCPhoto(tapGesture: UITapGestureRecognizer){
        //let imgView = tapGesture.view as! UIImageView
        if (m_sUserImgUrl != "") //Give your image View tag
        {
            super.ProfileImagePlus(UserImgUrl: m_sUserImgUrl)
        }
        else{

        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //메뉴 화면에 들어올때마다 해당 주기에서 실시간 체크
        
        m_UserInfo = SO.getUserInfo();
        
        if m_UserInfo["seq"] == "" || m_UserInfo["seq"] == nil {
            uiLogoutBtn.isHidden = true;
            uiButtonVIEW.isHidden = true;
            uiPushBtn.isHidden = true;
            uiNewPushImg.isHidden = true;
            setContentsView(PrentV: uiTopContentView, uiView: uiNotLoginView)
        }else{
            m_sUserImgUrl = "";
            JS.checkNew(param: ["account_seq" : getUserSeq()], callbackf: checkNewCallback)
            
            uiLogoutBtn.isHidden = false;
            uiButtonVIEW.isHidden = false;
            uiPushBtn.isHidden = false
            setContentsView(PrentV: uiTopContentView, uiView: uiLoginView)
            
            if let imgurl = m_UserInfo["profile_image_url"]{
                if imgurl != ""{
                    m_sUserImgUrl = "\(Single.DE_URLIMGSERVER)\(imgurl)"
                    uiUserImg.setImage(with: m_sUserImgUrl)
                }
            }
            uiUsername.text = m_UserInfo["name"];
            uiCloverBtn.setTitle(m_UserInfo["point_total"]?.DecimalWon(), for: .normal)
            self.uiTopContentView.layer.addBorder([.bottom], color: UIColor(rgb: 0xf8f8f8), width: 8.0)
        }
        
    }
    func checkNewCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            if alldata["data"] == "1" {
                uiNewPushImg.isHidden = false;
            }else{
                uiNewPushImg.isHidden = true;
            }
        }
    }
    func setContentsView(PrentV : UIView, uiView : UIView){
        for v in PrentV.subviews{
            v.removeFromSuperview()
        }
        
        PrentV.addSubview(uiView)
        
        uiView.translatesAutoresizingMaskIntoConstraints = false
        uiView.topAnchor.constraint(equalTo: PrentV.topAnchor,constant: 0).isActive = true
        uiView.leftAnchor.constraint(equalTo:PrentV.leftAnchor,constant: 0).isActive = true
        uiView.rightAnchor.constraint(equalTo: PrentV.rightAnchor, constant: 0).isActive = true
        uiView.bottomAnchor.constraint(equalTo: PrentV.bottomAnchor, constant: 0).isActive = true
    }
    
    @IBAction func onCloverBtn(_ sender: Any) {
        let Storyboard: UIStoryboard = UIStoryboard(name: "CloverInfo", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "CloverInfoidx") as! CloverInfo
        self.navigationController?.pushViewController(viewController, animated: false)
    }
    @IBAction func onLoginBtn(_ sender: Any) {
        super.LoginMove();
    }
    @IBAction func onTradeInfoBtn(_ sender: Any) {
        let Storyboard: UIStoryboard = UIStoryboard(name: "TradeStatusList", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "tradestatuslistidx") as! TradeStatusList
        self.navigationController?.pushViewController(viewController, animated: false)
    }
    @IBAction func onDeliveryBtn(_ sender: Any) {
        let Storyboard: UIStoryboard = UIStoryboard(name: "DeliveryInfo", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "DeliveryInfoidx") as! DeliveryInfo
        self.navigationController?.pushViewController(viewController, animated: false)
    }
    @IBAction func onCuponBtn(_ sender: Any) {
        let Storyboard: UIStoryboard = UIStoryboard(name: "CuponInfo", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "CuponInfoidx") as! CuponInfo
        self.navigationController?.pushViewController(viewController, animated: false)
    }
    @IBAction func onFriendBtn(_ sender: Any) {
        SO.m_sProductGiftSeq = "";// 햄버거,사이드바에서 친구관리 들어갈시 인벤토리에서 선물 할려고했던 상품시퀀스 저장값을 여기서는 날려야 선물 화면 디폴트탭이
                //랜덤박스로 간다.
        let Storyboard: UIStoryboard = UIStoryboard(name: "FriendMain", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "FriendMainidx") as! FriendMain
        self.navigationController?.pushViewController(viewController, animated: false)
    }
    @IBAction func onContacBtn(_ sender: Any) {
        let Storyboard: UIStoryboard = UIStoryboard(name: "Customer", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "Customeridx") as! Customer
        self.navigationController?.pushViewController(viewController, animated: false)
    }
    @IBAction func onSettingBtn(_ sender: Any) {
        let Storyboard: UIStoryboard = UIStoryboard(name: "SettingMain", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "SettingMainidx") as! SettingMain
        self.navigationController?.pushViewController(viewController, animated: false)
    }
    @IBAction func onLogoutBtn(_ sender: Any) {
        MessagePop(title : "로그아웃".localized, msg: "로그아웃 하시겠습니까?".localized, ostuch:true, lbtn: "취소".localized, rbtn: "확인".localized,succallbackf: { ()-> Void in
            LoadingHUD.show()
            self.JS.logout(param: ["seq":super.getUserSeq()], callbackf: self.logoutCallback)
        }, closecallbackf: { ()-> Void in
        })
    }
    @IBAction func onPushBtn(_ sender: Any) {
        let Storyboard: UIStoryboard = UIStoryboard(name: "PushLIst", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "PushLIstidx") as! PushLIst
        self.navigationController?.pushViewController(viewController, animated: false)
    }
    @IBAction func onCloseBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
            }else if SO.getTabbarIndex() == 2 {
                SO.getCommunityMain()?.LoginResetView()
            }
            //SO.setTabbarIndex(TabbarIndex: 0)
            
            self.dismiss(animated: true, completion: nil)
        }
        LoadingHUD.hide()
    }
    
}
