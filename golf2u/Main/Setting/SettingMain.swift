//
//  SettingMain.swift
//  golf2u
//
//  Created by 이원영 on 2020/12/04.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import YPImagePicker
import AVFoundation
import AVKit
import Photos
import SwiftyJSON
import EzPopup

class SettingMain: VariousViewController {
    private let SO = Single.getSO();
    private let JS = JsonC();
    
    @IBOutlet weak var uiTitle1lb: UILabel!
    @IBOutlet weak var uiTitle1Sub1lb: UILabel!
    @IBOutlet weak var uiTitle1Sub2lb: UILabel!
    @IBOutlet weak var uiTitle1Sub3lb: UILabel!
    @IBOutlet weak var uiTitle2lb: UILabel!
    @IBOutlet weak var uiTitle2Sub1lb: UILabel!
    @IBOutlet weak var uiTitle2Sub2lb: UILabel!
    @IBOutlet weak var uiTitle2Sub3lb: UILabel!
    @IBOutlet weak var uiTitle2Sub4lb: UILabel!
    @IBOutlet weak var uiTitle2Sub5lb: UILabel!
    @IBOutlet weak var uiTitle3lb: UILabel!
    @IBOutlet weak var uiTitle4lb: UILabel!
    @IBOutlet weak var uiTitle5lb: UILabel!
    @IBOutlet weak var uiTitle5Sub1lb: UILabel!
    @IBOutlet weak var uiTitle6lb: UILabel!
    
    @IBOutlet weak var uiButton1_1: UIButton!
    @IBOutlet weak var uiButton1_2: UIButton!
    @IBOutlet weak var uiButton1_3: UIButton!
    @IBOutlet weak var uiButton1_4: UIButton!
    
    @IBOutlet weak var uiButton3_1: UIButton!
    @IBOutlet weak var uiButton3_2: UIButton!
    
    @IBOutlet weak var uiButton4_1: UIButton!
    @IBOutlet weak var uiButton4_2: UIButton!
    
    @IBOutlet weak var uiButton6_1: UIButton!
    @IBOutlet weak var uiButton6_2: UIButton!
    @IBOutlet weak var uiButton6_3: UIButton!
    @IBOutlet weak var uiButton6_4: UIButton!
    @IBOutlet weak var uiButton6_5: UIButton!
    @IBOutlet weak var uiButton6_6: UIButton!
    
    
    @IBOutlet weak var uiUserImg: UIImageView!
    @IBOutlet weak var uiUserName: UILabel!
    @IBOutlet weak var uiUserEmail: UILabel!
    
    @IBOutlet weak var uiAutoLoginCheck: UISwitch!
    @IBOutlet weak var uiTradeBoxSet: UISwitch!
    @IBOutlet weak var uiPushTrade: UISwitch!
    @IBOutlet weak var uiPushBoxPro: UISwitch!
    @IBOutlet weak var uiPushSys: UISwitch!
    @IBOutlet weak var uiPushCust: UISwitch!
    @IBOutlet weak var uiPushEvent: UISwitch!
    
    @IBOutlet weak var uiUserCertiLabel: UILabel!
    @IBOutlet weak var uiUserCertiImg: UIImageView!
    
    private var selectedItems = [YPMediaItem]()
    private var m_tSelImg : UIImage?
    
    @IBOutlet weak var uiPassChangeView: UIView!
    @IBOutlet weak var uiDeliAddrView: UIView!
    
    @IBOutlet weak var uiVersion: UILabel!
    
    private var m_sUserVerif = "0";
    
    private var m_sLoadSetting = [String : String]();
    
    private var m_sPushChgTitle = "";
    private var m_isPushToggle = false;
    
    private var uiPassChangeViewConstraint: NSLayoutConstraint?
    private var uiDeliAddrViewConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var uiUpdateBtn: UIButton!
    @IBOutlet weak var uiUpdatelabel: UILabel!
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "설정".localized)
        super.viewDidLoad()
        
        uiTitle1lb.text = "회원 정보".localized;
        uiTitle1Sub1lb.text = "상품 보관함 공개 설정".localized;
        uiTitle1Sub2lb.text = "내 보관함에 트레이드 마켓 등록 외 상품 노출여부 설정".localized;
        uiTitle1Sub3lb.text = "자동로그인 설정".localized;
        uiTitle2lb.text = "알림 설정".localized;
        uiTitle2Sub1lb.text = "트레이드 알림".localized;
        uiTitle2Sub2lb.text = "박스 및 상품 알림".localized;
        uiTitle2Sub3lb.text = "시스템 알림".localized;
        uiTitle2Sub4lb.text = "고객지원 알림".localized;
        uiTitle2Sub5lb.text = "이벤트 광고 알림".localized;
        uiTitle3lb.text = "이용 약관".localized;
        uiTitle4lb.text = "로그인 정보 변경".localized;
        uiTitle5lb.text = "시스템 정보".localized;
        uiTitle5Sub1lb.text = "버전 정보".localized;
        uiTitle6lb.text = "튜토리얼".localized;
        uiUserCertiLabel.text = "인증되었습니다.".localized;
        
        uiButton1_1.setTitle("닉네임 변경".localized, for: .normal)
        uiButton1_2.setTitle("비밀번호 변경".localized, for: .normal)
        uiButton1_3.setTitle("배송지 관리".localized, for: .normal)
        uiButton1_4.setTitle("본인인증".localized, for: .normal)
        
        uiButton3_1.setTitle("이용 약관".localized, for: .normal)
        uiButton3_2.setTitle("개인정보처리방침".localized, for: .normal)
        
        uiButton4_1.setTitle("로그아웃".localized, for: .normal)
        uiButton4_2.setTitle("회원탈퇴".localized, for: .normal)
        
        uiButton6_1.setTitle("튜토리얼 다시보기".localized, for: .normal)
        uiButton6_2.setTitle("박스구매 및 오픈".localized, for: .normal)
        uiButton6_3.setTitle("트레이드".localized, for: .normal)
        uiButton6_4.setTitle("배송하기".localized, for: .normal)
        uiButton6_5.setTitle("친구관리".localized, for: .normal)
        uiButton6_6.setTitle("선물하기".localized, for: .normal)
        
        uiUpdateBtn.setTitle("업데이트".localized, for: .normal)

        uiUserImg.layer.cornerRadius = uiUserImg.bounds.height / 2
        
        uiUpdateBtn.layer.borderColor = UIColor(rgb: 0x00BA87).cgColor
        uiUpdateBtn.layer.borderWidth = 1.0
        uiUpdateBtn.layer.cornerRadius = uiUpdateBtn.bounds.height / 2
        
        uiUserImg.image = nil;
        let imgurl = SO.getUserInfoKey(key: "profile_image_url")
        if imgurl != ""{
            uiUserImg.setImage(with: "\(Single.DE_URLIMGSERVER)\(imgurl)")
        }
        
        uiPassChangeViewConstraint = uiPassChangeView.heightConstraint;
        uiDeliAddrViewConstraint = uiDeliAddrView.topConstraint
        
        let fm_sSysVs = SO.getSystemInfoKey(key: "version_latest")
        let fm_nSysVs = Float(fm_sSysVs) ?? 0.0;
        let fm_nAppVs = Float(SO.version!) ?? 0.0;
        
        if fm_nAppVs < fm_nSysVs {
            uiUpdateBtn.isHidden = false;
            uiUpdatelabel.text = "최신버전이 아닙니다. 업데이트를 해주세요.".localized;
        }else{
            uiUpdateBtn.isHidden = true;
            uiUpdatelabel.text = "최신버전입니다.".localized;
        }
        
        
        let tapGestureRecognizer1 = UITapGestureRecognizer(target:self, action: #selector(self.onProfileBtn(tapGesture:)))
        tapGestureRecognizer1.numberOfTapsRequired = 1
        uiUserImg.isUserInteractionEnabled = true
        uiUserImg.addGestureRecognizer(tapGestureRecognizer1)
        
        LoadSetting();
        
        
    }
    @objc func onProfileBtn(tapGesture: UITapGestureRecognizer){
        onProfileClick()
    }
    func LoadSetting(){
        LoadingHUD.show()
        m_sPushChgTitle = "";
        JS.getPushAgreeState(param: ["seq":super.getUserSeq()], callbackf: getPushAgreeStateCallback)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        uiUserName.text = SO.getUserInfoKey(key: "name")
        uiUserEmail.text = SO.getUserInfoKey(key: "email")
        
        if Single.DE_ISDEBUG{
            uiVersion.text = "\(SO.version ?? "ERROR") DEBUG MODE";
            uiVersion.TextPartColor(partstr: "DEBUG MODE", Color: UIColor(rgb: 0x00BA87))
        }else{
            uiVersion.text = SO.version;
        }
        
        
        //본인인증 체크
        if SO.getUserInfoKey(key: Single.DE_USERVERIFIED) == "0" {
            uiUserCertiLabel.isHidden = true;
            uiUserCertiImg.isHidden = false;
        }else{
            uiUserCertiLabel.isHidden = false;
            uiUserCertiImg.isHidden = true;
        }
        //자동로그인 체크
        if let userseq = UserDefaults.standard.value(forKey: Single.DE_AUTOLOGIN){
            //자동로그인 사용자
            uiAutoLoginCheck.isOn = true;
        }else{
            uiAutoLoginCheck.isOn = false;
        }
        
        
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if SO.getUserInfoKey(key: "join_type") != "0" {
            self.uiPassChangeViewConstraint?.constant = 0//비밀번호 관리 높이를 0으로 sns 로그인을 했기때문
            self.uiDeliAddrViewConstraint?.constant = 0;//배송지관리 버튼도 비밀번호버튼이 없어짐에따라 위 회색 여백 만큼 없애야됨
            self.view.layoutIfNeeded()
//            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
//                        self.uiPassChangeViewConstraint?.constant = 0
//                        self.view.layoutIfNeeded()
//                    }, completion: nil)
        }
    }
    //회원정보
    @IBAction func onNickBtn(_ sender: Any) {
        let Storyboard: UIStoryboard = UIStoryboard(name: "NickModify", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "NickModifyidx") as! NickModify
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    @IBAction func onPassModify(_ sender: Any) {
        let Storyboard: UIStoryboard = UIStoryboard(name: "PassModify", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "PassModifyidx") as! PassModify
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    @IBAction func onDelivery(_ sender: Any) {
        let Storyboard: UIStoryboard = UIStoryboard(name: "DeliveryManage", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "DeliveryManageidx") as! DeliveryManage
        viewController.setViewType(ViewType: 0)
        //viewController.m_tClickEvent = self;
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    @IBAction func onCertiBtn(_ sender: Any) {
        if SO.getUserInfoKey(key: Single.DE_USERVERIFIED) == "0" {
            UserVerify()
        }else{
        }
    }
    @IBAction func onAutoLogin(_ sender: Any) {
        if uiAutoLoginCheck.isOn {
            UserDefaults.standard.set(super.getUserSeq(), forKey: Single.DE_AUTOLOGIN)
        }else{
            UserDefaults.standard.removeObject(forKey: Single.DE_AUTOLOGIN)
        }
    }
    @IBAction func onProductView(_ sender: Any) {
        LoadingHUD.show()
        m_sPushChgTitle = "";
        JS.toggleTradeInv(param: ["seq":super.getUserSeq()], callbackf: getPushAgreeStateCallback)
    }
    
    //알림 설정
    @IBAction func onPushTrade(_ sender: Any) {
        LoadingHUD.show()
        m_sPushChgTitle = "트레이드 알림".localized;
        m_isPushToggle = uiPushTrade.isOn
        JS.togglePushState(param: ["seq":super.getUserSeq(), "no":"0"], callbackf: getPushAgreeStateCallback)
    }
    @IBAction func onPushBoxPro(_ sender: Any) {
        LoadingHUD.show()
        m_sPushChgTitle = "박스 및 상품 알림".localized;
        m_isPushToggle = uiPushBoxPro.isOn
        JS.togglePushState(param: ["seq":super.getUserSeq(), "no":"1"], callbackf: getPushAgreeStateCallback)
    }
    @IBAction func onPushSys(_ sender: Any) {
        LoadingHUD.show()
        m_sPushChgTitle = "시스템 알림".localized;
        m_isPushToggle = uiPushSys.isOn
        JS.togglePushState(param: ["seq":super.getUserSeq(), "no":"2"], callbackf: getPushAgreeStateCallback)
    }
    @IBAction func onPushCustomer(_ sender: Any) {
        LoadingHUD.show()
        m_sPushChgTitle = "고객지원 알림".localized;
        m_isPushToggle = uiPushCust.isOn
        JS.togglePushState(param: ["seq":super.getUserSeq(), "no":"3"], callbackf: getPushAgreeStateCallback)
    }
    @IBAction func onPushEvent(_ sender: Any) {
        LoadingHUD.show()
        m_sPushChgTitle = "이벤트 광고 알림".localized;
        m_isPushToggle = uiPushEvent.isOn
        JS.togglePushState(param: ["seq":super.getUserSeq(), "no":"4"], callbackf: getPushAgreeStateCallback)
    }
    
    //이용약관
    @IBAction func onAgree1(_ sender: Any) {
        let Storyboard: UIStoryboard = UIStoryboard(name: "UsePolicy", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "UsePolicyidx") as! UsePolicy
        viewController.setUrl(url: "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Policy/Policy", f_sTitle: "이용 약관".localized, menuidx : 0)
        viewController.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    @IBAction func onAgree2(_ sender: Any) {
        let Storyboard: UIStoryboard = UIStoryboard(name: "UsePolicy", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "UsePolicyidx") as! UsePolicy
        viewController.setUrl(url: "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Policy/Privacy", f_sTitle: "개인정보처리방침".localized, menuidx : 1)
        viewController.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    //로그인 정보 변경
    @IBAction func onLogout(_ sender: Any) {
        MessagePop(title : "로그아웃".localized, msg: "로그아웃 하시겠습니까?".localized, ostuch:true, lbtn: "취소".localized, rbtn: "확인".localized,succallbackf: { ()-> Void in
            LoadingHUD.show()
            self.JS.logout(param: ["seq":super.getUserSeq()], callbackf: self.logoutCallback)
        }, closecallbackf: { ()-> Void in
        })
        
    }
    @IBAction func onMemberOut(_ sender: Any) {
        let Storyboard: UIStoryboard = UIStoryboard(name: "MemberLeave", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "MemberLeaveidx") as! MemberLeave
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    @IBAction func onTutorialReplyBtn(_ sender: Any) {
        goToTutorial(url: "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Tutorial/detail", title: "튜토리얼 다시보기".localized)
    }
    @IBAction func onTutorialBoxBuyOpenBtn(_ sender: Any) {
        goToTutorial(url: "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Tutorial/detail_sub/1", title: "박스구매 및 오픈".localized)
    }
    @IBAction func onTutorialTradeBtn(_ sender: Any) {
        goToTutorial(url: "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Tutorial/detail_sub/2", title: "트레이드".localized)
    }
    @IBAction func onTutorialDeliveryBtn(_ sender: Any) {
        goToTutorial(url: "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Tutorial/detail_sub/3", title: "배송하기".localized)
    }
    @IBAction func onTutorialFriendBtn(_ sender: Any) {
        goToTutorial(url: "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Tutorial/detail_sub/4", title: "친구관리".localized)
    }
    @IBAction func onTutorialGiftBtn(_ sender: Any) {
        goToTutorial(url: "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Tutorial/detail_sub/5", title: "선물하기".localized)
    }
    func goToTutorial(url : String, title : String){
        let Storyboard: UIStoryboard = UIStoryboard(name: "TutoialWeb", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "TutoialWebidx") as! TutoialWeb
        viewController.setUrl(url: url, f_sTitle: title)
        viewController.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    @IBAction func onProfileModify(_ sender: Any) {
        onProfileClick()
    }
    func onProfileClick(){
        let optionMenu = UIAlertController(title: nil, message: "프로필 이미지 설정".localized, preferredStyle: .actionSheet)
        //옵션 초기화
        let alertacop1 = UIAlertAction(title: "카메라 촬영".localized, style: .default, handler: alertHandleOp1)
        let alertacop2 = UIAlertAction(title: "갤러리 선택".localized, style: .default, handler: alertHandleOp1)
        let alertacop3 = UIAlertAction(title: "기본이미지 선택".localized, style: .default, handler: alertHandleOp1)
        let cancelAction = UIAlertAction(title: "닫기".localized, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(alertacop1)
        optionMenu.addAction(alertacop2)
        optionMenu.addAction(alertacop3)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    @IBAction func onUpdateBtn(_ sender: Any) {
        if let url = URL(string: Single.DE_APPSTROEURL), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    func alertHandleOp1(alertAction: UIAlertAction!) -> Void {
        if alertAction.title! == "카메라 촬영".localized {
            showPicker(screen: .photo, title: "카메라".localized);
        }else if alertAction.title! == "갤러리 선택".localized {
            showPicker(screen: .library, title: "사진".localized);
        }else if alertAction.title! == "기본이미지 선택".localized {
            let m_tWRP = DefProfilePop.instantiate()
            guard let customAlertVC = m_tWRP else { return }
            customAlertVC.SaveHandler = { (idx, img)-> Void in
                self.setImageJson(type: "1", imgs: ["file1":img], defidx: "\(idx)")
            }
            let popupVC = PopupViewController(contentController: customAlertVC, popupWidth: 250, popupHeight: 350)
            popupVC.backgroundAlpha = 0.3
            popupVC.backgroundColor = .black
            popupVC.canTapOutsideToDismiss = true
            popupVC.cornerRadius = 10
            popupVC.shadowEnabled = false
            present(popupVC, animated: true, completion: nil)
        }
    }
    func showPicker(screen : YPPickerScreen, title : String) {
        
        var config = YPImagePickerConfiguration()
        
        config.library.mediaType = .photo
        config.library.itemOverlayType = .grid
        config.showsPhotoFilters = false
        config.shouldSaveNewPicturesToAlbum = false
        config.startOnScreen = screen
        
        config.screens = [screen]
        
        config.showsCrop = .none
        config.wordings.libraryTitle = title
        
        config.hidesStatusBar = false
        
        config.hidesBottomBar = false
        
        
        config.maxCameraZoomFactor = 2.0
        
        config.library.maxNumberOfItems = 1
        config.gallery.hidesRemoveButton = false
        config.library.preselectedItems = selectedItems
        
        let picker = YPImagePicker(configuration: config)
        
        picker.imagePickerDelegate = self
        
        picker.didFinishPicking { [unowned picker] items, cancelled in
            
            if cancelled {
                //print("Picker was canceled")
                picker.dismiss(animated: true, completion: nil)
                return
            }
            //_ = items.map { print("🧀 \($0)") }
            
            self.selectedItems = items
            for (_, val) in items.enumerated(){
                switch val {
                case .photo(let photo):
                    //self.SendImgArrSet(image: photo.image)
                    
                    self.setImageJson(type: "0", imgs: ["file1":photo.image], defidx: "0")
                    picker.dismiss(animated: true, completion: nil)
                case .video(let video):
                    //self.selectedImageV.image = video.thumbnail
                    let assetURL = video.url
                    let playerVC = AVPlayerViewController()
                    let player = AVPlayer(playerItem: AVPlayerItem(url:assetURL))
                    playerVC.player = player
                    
                    picker.dismiss(animated: true, completion: { [weak self] in
                        self?.present(playerVC, animated: true, completion: nil)
                        //print("😀 \(String(describing: self?.resolutionForLocalVideo(url: assetURL)!))")
                    })
                }
            }
        }
        present(picker, animated: true, completion: nil)
    }
    func setImageJson(type : String, imgs : [String : UIImage], defidx : String){
        LoadingHUD.show()
        m_tSelImg = imgs["file1"];
        JS.setProfile(param: ["seq":super.getUserSeq(), "profile_type":type, "default_index":defidx], imgs: imgs, callbackf: setProfileCallback)
    }
    func setProfileCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            MessagePop(msg: alldata["errormessage"].stringValue, btntype:2)
        }else{
            SO.setUserInfoKey(key: "profile_image_url", value: alldata["data"].stringValue)
            if let img = m_tSelImg {
                uiUserImg.image = img
            }
        }
        LoadingHUD.hide()
    }
    //MARK: 본인인증
    func UserVerify(){
        if SO.getUserInfoKey(key: Single.DE_USERVERIFIED) == "0" {
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
            //setContentsView(uiView: m_FriendListView!);
        }
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
            
            self.navigationController?.popViewController(animated: true);
        }
        LoadingHUD.hide()
    }
    func getPushAgreeStateCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            MessagePop(msg: alldata["errormessage"].stringValue, btntype:2)
        }else{
            m_sLoadSetting["use_inventory_on_trade"] = alldata["data"]["use_inventory_on_trade"].stringValue
            m_sLoadSetting["use_trade_push"] = alldata["data"]["use_trade_push"].stringValue
            m_sLoadSetting["use_box_push"] = alldata["data"]["use_box_push"].stringValue
            m_sLoadSetting["use_system_push"] = alldata["data"]["use_system_push"].stringValue
            m_sLoadSetting["use_cs_push"] = alldata["data"]["use_cs_push"].stringValue
            m_sLoadSetting["use_event_push"] = alldata["data"]["use_event_push"].stringValue
            
            uiTradeBoxSet.isOn = (m_sLoadSetting["use_inventory_on_trade"] == "0" ? false : true);
            uiPushTrade.isOn = (m_sLoadSetting["use_trade_push"] == "0" ? false : true);
            uiPushBoxPro.isOn = (m_sLoadSetting["use_box_push"] == "0" ? false : true);
            uiPushSys.isOn = (m_sLoadSetting["use_system_push"] == "0" ? false : true);
            uiPushCust.isOn = (m_sLoadSetting["use_cs_push"] == "0" ? false : true);
            uiPushEvent.isOn = (m_sLoadSetting["use_event_push"] == "0" ? false : true);
            if  m_sPushChgTitle != "" {
                if m_isPushToggle {
                    MessagePop(title : "알림 수신동의".localized, msg: "() 수신동의 처리\n되었습니다.".localized(txt: "\(m_sPushChgTitle)"), btntype:2)
                }else{
                    MessagePop(title : "알림 수신거부".localized, msg: "() 수신거부 처리\n되었습니다.".localized(txt: "\(m_sPushChgTitle)"), btntype:2)
                }
            }
            
        }
        LoadingHUD.hide()
    }
}
// YPImagePickerDelegate
extension SettingMain: YPImagePickerDelegate {
    func imagePickerHasNoItemsInLibrary(_ picker: YPImagePicker) {
        
    }
    func noPhotos() {}

    func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool {
        return true// indexPath.row != 2
    }
}
