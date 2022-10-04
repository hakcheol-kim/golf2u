//
//  VariousViewController.swift
//  golf2u
//
//  Created by 이원영 on 2020/10/15.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SideMenu
import EzPopup
import KakaoSDKCommon
import KakaoSDKTalk
import KakaoSDKTemplate
import KakaoSDKShare
import FBSDKShareKit
import StoreKit
import FBSDKCoreKit
import ImageSlideshow
import AppsFlyerLib
import FirebaseCore
import FirebaseStorage
import FirebaseAuth
import FirebaseAnalytics
import FirebaseAnalyticsSwift

class VariousViewController: UIViewController {
    
    private var SO:Single = Single.getSO();
    private let JS = JsonC();
    
    private var m_nType = 0;
    private var m_sTitle = "";
    private var m_sUserSeq = "";
    
    private var m_SideMenu : SideMenuNavigationController?;
    private var MainLogoBtn : UIButton!;
    private var MenuBtn : UIButton!;
    
    private let m_isUserPZoom = ImageSlideshow()
    
    func InitVC(type : Int = 0, title : String = ""){
        self.m_nType = type;
        self.m_sTitle = title
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if m_nType == Single.DE_INITNAVISUB {
            InitSubNaviGation()
        }else if m_nType == Single.DE_INITNAVIMAIN {
            InitMainNaviGation()
        }else if m_nType == Single.DE_INITNAVIMAINNONELOGOINTITLE {
            InitMainNaviGationNoneLogoOnTextTtitle()
        }
        m_sUserSeq = SO.getUserInfoKey(key: "seq");
    }
    func Analytics(eventname : String, params : [String: Any]){
        //페이스북 애널리틱스 이벤트
        //AppEventsLogger.log("My custom event.");
        //let params : [String: Any] = ["myParamName210" : "myParamValue210"]
        
        let eventName: AppEvents.Name = AppEvents.Name(rawValue: eventname)
        //AppEvents.activateApp()
        AppEvents.logEvent(eventName, parameters: params)
        //AppEvents.logEvent(AppEvents.Name.completedRegistration);

        //AppEvents.logEvent(AppEvents.Name.completedTutorial);

        //파이어베이스 애널리틱스 이벤트
        FirebaseAnalytics.Analytics.logEvent(eventname, parameters: params)
    }
    func FirebaseBoxBuyAnalytics(paramsP : [String: Any], paramsB : [String: Any]){
        //파이어베이스 애널리틱스 이벤트
        FirebaseAnalytics.Analytics.logEvent("boxbuysucc", parameters: paramsB)
        FirebaseAnalytics.Analytics.logEvent("purchase", parameters: paramsP)
        FirebaseAnalytics.Analytics.logEvent(AnalyticsEventPurchase, parameters: paramsP)
        //https://support.google.com/firebase/answer/9267735?hl=ko&ref_topic=6317484
        
    }
    func FacebbokBoxBuyAnalytics(params : [String: Any]){
        let params2 : [String: Any] = [
            //AppEvents.ParameterName.contentType.rawValue : "1",
            //AppEvents.ParameterName.content.rawValue : [["id":"6", "quantity":"5", "item_price":"999"], ["id":"7", "quantity":"5", "item_price":"1000"]],
            //AppEvents.ParameterName.contentID.rawValue : "3",
            AppEvents.ParameterName.numItems.rawValue : Int(params["totalboxcnt"] as? String ?? "0") ?? 0,
            AppEvents.ParameterName.currency.rawValue : Single.DE_CURRENCY
        ]
//        let params = [
//        "contentType" : contentType,
//        "content" : contentData,
//        "contentID" : contentId,
//        "currency" : currency
//        ]
        //let eventName: AppEvents.Name = AppEvents.Name.purchased
        //AppEvents.activateApp()
        //AppEvents.logEvent(eventName, parameters: params2)
        let fm_sTotalTprice : String = params["totalboxprice"] as? String ?? "0";
        //AppEvents.logPurchase(Double(fm_sTotalTprice) ?? 0.0, currency: Single.DE_CURRENCY, parameters: params)
        AppEvents.logEvent(AppEvents.Name.purchased, valueToSum: Double(fm_sTotalTprice) ?? 0.0, parameters: params2)
        //AppEvents.logEvent(AppEvents.Name.purchased, valueToSum: 1000, parameters: params2)
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        VersionCheck();
    }
    func VersionCheck(){
        let fm_sSysVs = SO.getSystemInfoKey(key: "version_least")
        let fm_nSysVs = Float(fm_sSysVs) ?? 0.0;
        let fm_nAppVs = Float(SO.version!) ?? 0.0;
        if fm_nAppVs < fm_nSysVs {
            let refreshAlert = UIAlertController(title: "안내".localized, message: "최신버전으로 업데이트후 사용해주세요.".localized, preferredStyle: UIAlertController.Style.alert)

            refreshAlert.addAction(UIAlertAction(title: "확인".localized, style: .default, handler: { (action: UIAlertAction!) in
                if let url = URL(string: Single.DE_APPSTROEURL), UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }

              //exit(0)
            }))

            present(refreshAlert, animated: true, completion: nil)
        }
    }
    func AppReview(){
//        if UserDefaults.standard.value(forKey: Single.DE_APPREVIEW) != nil{
//            return;
//        }
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
            //UserDefaults.standard.set("1", forKey: Single.DE_APPREVIEW)
        } else {
            // Fallback on earlier versions
            // Try any other 3rd party or manual method here.
        }
    }
    func InitSubNaviGation(){
        let navigationBar = self.navigationController?.navigationBar
        navigationBar?.setValue(true, forKey: "hidesShadow")
        navigationBar?.barTintColor = UIColor(rgb: 0xffffff)
        self.navigationItem.title = m_sTitle
        //self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        //self.navigationItem.backBarButtonItem = UIBarButtonItem(title: m_sTitle, style: .plain, target: nil, action: nil)
        
        
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        //navigationItem.backBarButtonItem?.width = 50
        
//        let f_MainLogoBtn = UIButton(type: .custom)
//        f_MainLogoBtn.frame = CGRect(x: 0.0, y: 0.0, width: 12, height: 22)
//        f_MainLogoBtn.setImage(UIImage(named:"back"), for: .normal)
//        //f_MainLogoBtn.addTarget(self, action: "onMainLogoBtn", for: UIControl.Event.touchUpInside)
//        let MainLogoBarItem = UIBarButtonItem(customView: f_MainLogoBtn)
//        let MainLogocurrWidth = MainLogoBarItem.customView?.widthAnchor.constraint(equalToConstant: 12)
//        MainLogocurrWidth?.isActive = true
//        let MainLogocurrHeight = MainLogoBarItem.customView?.heightAnchor.constraint(equalToConstant: 20)
//        MainLogocurrHeight?.isActive = true
//        self.navigationItem.setLeftBarButtonItems([MainLogoBarItem], animated: false)
        
        
    }
    func InitMainNaviGation(){
        let fm_tSDStory: UIStoryboard = UIStoryboard(name: "SideMenu", bundle: nil)
        let fm_tSDCT = fm_tSDStory.instantiateViewController(withIdentifier: "SideMenu") as! SideMenu
        m_SideMenu = SideMenuNavigationController(rootViewController: fm_tSDCT);
        m_SideMenu?.leftSide = false;
        m_SideMenu?.setNavigationBarHidden(true, animated: false)
        m_SideMenu?.menuWidth = 300
        SideMenuManager.default.addPanGestureToPresent(toView: self.view)
        SideMenuManager.default.rightMenuNavigationController = m_SideMenu
        //SideMenuManager.default.leftMenuNavigationController?.dismissOnPush = false
        //SideMenuManager.default.rightMenuNavigationController?.dismissOnPush = false;
        //SideMenuManager.default.leftMenuNavigationController?.delegate = self
        let settings = makeSettings()
        SideMenuManager.default.leftMenuNavigationController?.settings = settings
        SideMenuManager.default.rightMenuNavigationController?.settings = settings
        
        let navigationBar = self.navigationController?.navigationBar
        navigationBar?.setValue(true, forKey: "hidesShadow")
        navigationBar?.barTintColor = UIColor(rgb: 0xffffff)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        //self.navigationItem.backBarButtonItem = UIBarButtonItem(title: m_sTitle, style: .plain, target: nil, action: nil)
        
        
        
        MainLogoBtn = UIButton(type: .custom)
        MainLogoBtn.frame = CGRect(x: 0.0, y: 0.0, width: 140, height: 28)
        MainLogoBtn.setImage(UIImage(named:"mainlogo"), for: .normal)
        MainLogoBtn.addTarget(self, action: #selector(self.onMainLogoBtn), for: UIControl.Event.touchUpInside)
        let MainLogoBarItem = UIBarButtonItem(customView: MainLogoBtn)
        let MainLogocurrWidth = MainLogoBarItem.customView?.widthAnchor.constraint(equalToConstant: 115)
        MainLogocurrWidth?.isActive = true
        let MainLogocurrHeight = MainLogoBarItem.customView?.heightAnchor.constraint(equalToConstant: 28)
        MainLogocurrHeight?.isActive = true
        self.navigationItem.setLeftBarButtonItems([MainLogoBarItem], animated: false)
        
        MenuBtn = UIButton(type: .custom)
        MenuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 20, height: 20)
        MenuBtn.setImage(UIImage(named:"menu"), for: .normal)
        MenuBtn.addTarget(self, action: #selector(onMenuBtn(_:)), for: UIControl.Event.touchUpInside)
        let MenuBarItem = UIBarButtonItem(customView: MenuBtn)
        let MenucurrWidth = MenuBarItem.customView?.widthAnchor.constraint(equalToConstant: 20)
        MenucurrWidth?.isActive = true
        let MenucurrHeight = MenuBarItem.customView?.heightAnchor.constraint(equalToConstant: 20)
        MenucurrHeight?.isActive = true
        self.navigationItem.setRightBarButtonItems([MenuBarItem], animated: false)
    }
    func InitMainNaviGationNoneLogoOnTextTtitle(){
        let fm_tSDStory: UIStoryboard = UIStoryboard(name: "SideMenu", bundle: nil)
        let fm_tSDCT = fm_tSDStory.instantiateViewController(withIdentifier: "SideMenu") as! SideMenu
        m_SideMenu = SideMenuNavigationController(rootViewController: fm_tSDCT);
        m_SideMenu?.leftSide = false;
        m_SideMenu?.setNavigationBarHidden(true, animated: false)
        m_SideMenu?.menuWidth = 300
        SideMenuManager.default.addPanGestureToPresent(toView: self.view)
        SideMenuManager.default.rightMenuNavigationController = m_SideMenu
        let settings = makeSettings()
        SideMenuManager.default.leftMenuNavigationController?.settings = settings
        SideMenuManager.default.rightMenuNavigationController?.settings = settings
        
        let navigationBar = self.navigationController?.navigationBar
        navigationBar?.setValue(true, forKey: "hidesShadow")
        navigationBar?.barTintColor = UIColor(rgb: 0xffffff)
        self.navigationItem.title = m_sTitle
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        //self.navigationItem.backBarButtonItem = UIBarButtonItem(title: m_sTitle, style: .plain, target: nil, action: nil)
        
        
        
        MenuBtn = UIButton(type: .custom)
        MenuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 20, height: 20)
        MenuBtn.setImage(UIImage(named:"menu"), for: .normal)
        MenuBtn.addTarget(self, action: #selector(onMenuBtn(_:)), for: UIControl.Event.touchUpInside)
        let MenuBarItem = UIBarButtonItem(customView: MenuBtn)
        let MenucurrWidth = MenuBarItem.customView?.widthAnchor.constraint(equalToConstant: 20)
        MenucurrWidth?.isActive = true
        let MenucurrHeight = MenuBarItem.customView?.heightAnchor.constraint(equalToConstant: 20)
        MenucurrHeight?.isActive = true
        self.navigationItem.setRightBarButtonItems([MenuBarItem], animated: false)
    }
    @objc func onMainLogoBtn() {
    }
    @objc func onMenuBtn(_ sender: Any) {
        present(m_SideMenu!, animated: true)
    }

    func MainConMove(){
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "StartMain", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "StartMain") as! TabBarControllerMain
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true, completion: nil)
    }
    func LoginMove(){
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "LoginMg", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginView") as! UINavigationController
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true, completion: nil)
        //self.navigationController?.pushViewController(viewController, animated: true)
    }
    func PassChangeMove(){
//        let Storyboard: UIStoryboard = UIStoryboard(name: "PassModify", bundle: nil)
//        let viewController = Storyboard.instantiateViewController(withIdentifier: "PassModifyidx") as! PassModify
//        viewController.setData(viewtype: 1)
//        viewController.modalPresentationStyle = .fullScreen
//        self.present(viewController, animated: true, completion: nil)
        let bounds = UIScreen.main.bounds
        let width = bounds.size.width //화면 너비
        let m_tWRP = PassChangeFix.instantiate()
        guard let customAlertVC = m_tWRP else { return; }
        
        let popupVC = PopupViewController(contentController: customAlertVC, popupWidth: (width + Single.DE_TEXTPOPSIZEW), popupHeight: 380)
        popupVC.backgroundAlpha = 0.3
        popupVC.backgroundColor = .black
        popupVC.canTapOutsideToDismiss = false
        popupVC.cornerRadius = 10
        popupVC.shadowEnabled = false
        present(popupVC, animated: true, completion: nil)
    }
    func getUserSeq() -> String{
        m_sUserSeq = SO.getUserInfoKey(key: "seq");
        return m_sUserSeq;
    }
    func MessagePop(title : String = "안내".localized, msg : String, btntype : Int = 1, ostuch : Bool = false, lbtn : String = "닫기".localized, rbtn : String = "확인".localized, fcolorRv : Bool = false){
        
        var heightT : CGFloat = 133.0;
        
        let bounds = UIScreen.main.bounds
        let width = bounds.size.width //화면 너비
        //let height = bounds.size.height //화면 높이
        
        heightT += msg.heightT(withConstrainedWidth: (width + Single.DE_TEXTPOPSIZEW), font: UIFont.systemFont(ofSize: CGFloat(12)))
        
        let m_tWRP = TextPopup.instantiate()
        guard let customAlertVC = m_tWRP else { return; }
        customAlertVC.setText(title: title, msg: msg)
        customAlertVC.setBtnType(type: btntype, colorRv : fcolorRv)
        customAlertVC.setButtonText(can : lbtn, suc: rbtn)
        let popupVC = PopupViewController(contentController: customAlertVC, popupWidth: (width + Single.DE_TEXTPOPSIZEW), popupHeight: heightT)
        popupVC.backgroundAlpha = 0.3
        popupVC.backgroundColor = .black
        popupVC.canTapOutsideToDismiss = ostuch
        popupVC.cornerRadius = 10
        popupVC.shadowEnabled = false
        present(popupVC, animated: true, completion: nil)
    }
    func MessagePop (title : String = "안내".localized, msg : String, btntype : Int = 1, ostuch : Bool = false, lbtn : String = "닫기".localized, rbtn : String = "확인".localized, fcolorRv : Bool = false, succallbackf :  @escaping (()->()), closecallbackf :  @escaping (()->())){
       
        var heightT : CGFloat = 133.0;
        
        let bounds = UIScreen.main.bounds
        let width = bounds.size.width //화면 너비
        //let height = bounds.size.height //화면 높이
        
        heightT += msg.heightT(withConstrainedWidth: (width + Single.DE_TEXTPOPSIZEW), font: UIFont.systemFont(ofSize: CGFloat(12)))
        
        let m_tWRP = TextPopup.instantiate()
        guard let customAlertVC = m_tWRP else { return; }
        customAlertVC.setText(title: title, msg: msg)
        customAlertVC.setBtnType(type: btntype, colorRv : fcolorRv)
        customAlertVC.setButtonText(can : lbtn, suc: rbtn)
        customAlertVC.sucHandler = succallbackf
        customAlertVC.closeHandler = closecallbackf
        let popupVC = PopupViewController(contentController: customAlertVC, popupWidth: (width + Single.DE_TEXTPOPSIZEW), popupHeight: heightT)
        popupVC.backgroundAlpha = 0.3
        popupVC.backgroundColor = .black
        popupVC.canTapOutsideToDismiss = ostuch
        popupVC.cornerRadius = 10
        popupVC.shadowEnabled = false
        present(popupVC, animated: true, completion: nil)
    }
    
    func KakaoShare(text : String, btnname : String  = "골프투유", imgurl: String){

        var content = [String:Any]()
        content["title"] = ""
        content["description"] = "\(text)"
        content["image_url"] = imgurl
        content["link"] = ["mobile_web_url" : "https://golf2u.kr", "web_url": "https://golf2u.kr"]
        
        var shareData = [String:Any]()
        shareData["object_type"] = "feed"
        shareData["content"] = content
        shareData["button_title"] = btnname
//        shareData["buttons"] = [["title" : btnname, "link":["android_execution_params":"", "ios_execution_params":""]]]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: shareData, options: .fragmentsAllowed)
            let templatable = try SdkJSONDecoder.custom.decode(FeedTemplate.self, from: data)
            
            ShareApi.shared.shareDefault(templatable: templatable) {(linkResult, error) in
                if let error = error {
                    print(error)
                }
                else {

                    if let linkResult = linkResult {
                        UIApplication.shared.open(linkResult.url, options: [:], completionHandler: nil)
                    }
                }
            }
        }
        catch let error {
            print("error: kakao tempate json decoder \(error).")
        }
    }
    func KakaoShare(title : String, contents : String, imgurl : String){
        //let text = "골프투유\\n선물코드 : \(m_sCodeCreate)"

        let textTemplateJsonStringData =
            """
                {
                    "object_type": "feed",
                    "content": {
                        "title": "\(title)",
                        "description": "\(contents)",
                        "image_url": "\(imgurl)",
                        "link": {
                            "mobile_web_url": "https://developers.kakao.com",
                            "web_url": "https://developers.kakao.com"
                        }
                    },
                    "buttons": [
                        {
                            "title": "골프투유",
                            "link": {
                                "android_execution_params": "",
                                "ios_execution_params": ""
                            }
                        }
                    ]
                }
                """.data(using: .utf8)!
        
        if let templatable = try? SdkJSONDecoder.custom.decode(FeedTemplate.self, from: textTemplateJsonStringData) {
            ShareApi.shared.shareDefault(templatable: templatable) {(linkResult, error) in
                if let error = error {
                    print(error)
                }
                else {

                    if let linkResult = linkResult {
                        UIApplication.shared.open(linkResult.url, options: [:], completionHandler: nil)
                    }
                }
            }
        }
    }
    func FaceBookShare(img : UIImage, link : String){
       
//         guard let url = URL(string: link) else {
//                     preconditionFailure("URL is invalid")
//                 }
//
//                 let content = ShareLinkContent()
//                 content.contentURL = url
//                 content.hashtag = Hashtag("#골프투유")
//
//                 dialog(withContent: content).show()
//
        
        let photo = SharePhoto(image: img, userGenerated: true)
       
        let content = SharePhotoContent()
        content.photos = [photo]
        content.hashtag = Hashtag("#골프투유_당첨인증")
        //content.contentURL = URL(string: link)!
        //content.contentURL = URL(string: Single.DE_APPSTOREKRURL)!

        let dialog = self.dialog(withContent: content)

        // Recommended to validate before trying to display the dialog
        do {
            try dialog.validate()
        } catch {
            print(error)
        }
        
        dialog.show()
    }
    func dialog(withContent content: SharingContent) -> ShareDialog {
        return ShareDialog(
            fromViewController: self,
            content: content,
            delegate: self
        )
    }
    
    func ProfileImagePlus(UserImgUrl : String){
        //이걸 붙여야 드래그 해서 이미지뷰를 종료할수있음
        //원리는 클릭했던 뷰 위치가 필요한대 addsubview 를 하지않아 위치가 명확하지않기 때문에 종료를 할수가 없던거임
        m_isUserPZoom.removeFromSuperview()
        self.view.addSubview(m_isUserPZoom)
       
        var fm_tPicArr = [KingfisherSource]();
        
        if let URLString = KingfisherSource(urlString: UserImgUrl){
            fm_tPicArr.append(URLString)
        }
        
        m_isUserPZoom.contentScaleMode = UIViewContentMode.scaleAspectFit
//        uiImageVIew.slideshowInterval = 3.0
//        uiImageVIew.pageIndicatorPosition = PageIndicatorPosition(horizontal: .center, vertical: .bottom)
//        uiImageVIew.pageIndicator = nil
//        uiImageVIew.activityIndicator = DefaultActivityIndicator()
//        uiImageVIew.delegate = self
        m_isUserPZoom.setImageInputs(fm_tPicArr)
        let fullScreenController = m_isUserPZoom.presentFullScreenController(from: self)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .large, color: nil)
        
        //uiImageVIew.removeFromSuperview()
        
    }
    
    private func selectedPresentationStyle() -> SideMenuPresentationStyle {
        let modes: [SideMenuPresentationStyle] = [.menuSlideIn, .viewSlideOut, .viewSlideOutMenuIn, .menuDissolveIn]
        return modes[0]
    }
    private func makeSettings() -> SideMenuSettings {
        let presentationStyle = selectedPresentationStyle()
        presentationStyle.backgroundColor = UIColor.black
        presentationStyle.menuStartAlpha = CGFloat(0.5)
        //presentationStyle.menuScaleFactor = CGFloat(0.5)
        presentationStyle.onTopShadowOpacity = 0.5
        presentationStyle.presentingEndAlpha = CGFloat(0.5)
        //presentationStyle.presentingScaleFactor = CGFloat(0.5)
        
        var settings = SideMenuSettings()
        settings.presentationStyle = presentationStyle
        //settings.menuWidth = min(view.frame.width, view.frame.height) * CGFloat(0.5)
        settings.menuWidth = 300
        let styles:[UIBlurEffect.Style?] = [nil, .dark, .light, .extraLight]
        settings.blurEffectStyle = styles[0]
        settings.statusBarEndAlpha = true ? 1 : 0
        
        return settings
    }
    
    //MARK: 앱서플라이 로그
    func AppsflyerLog(AFTitle : String, params : [String: Any]){
        AppsFlyerLib.shared().logEvent(AFTitle, withValues: params);
    }
    func AppsflerMemberCUID(cuid : String){
//        AppsFlyerLib.shared().customerUserID = cuid
        //single 에 setUserInfoKey 여기에 넣어놨음
    }
}
extension VariousViewController : SharingDelegate{
    func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
        
    }
    
    func sharer(_ sharer: Sharing, didFailWithError error: Error) {
        
    }
    
    func sharerDidCancel(_ sharer: Sharing) {
        
    }
    
    
}
extension VariousViewController: SideMenuNavigationControllerDelegate {
    
    func sideMenuWillAppear(menu: SideMenuNavigationController, animated: Bool) {
        //print("SideMenu Appearing! (animated: \(animated))")
    }
    
    func sideMenuDidAppear(menu: SideMenuNavigationController, animated: Bool) {
        //print("SideMenu Appeared! (animated: \(animated))")
    }
    
    func sideMenuWillDisappear(menu: SideMenuNavigationController, animated: Bool) {
        //print("SideMenu Disappearing! (animated: \(animated))")
    }
    
    func sideMenuDidDisappear(menu: SideMenuNavigationController, animated: Bool) {
        //print("SideMenu Disappeared! (animated: \(animated))")
    }
}
