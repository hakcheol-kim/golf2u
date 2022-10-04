//
//  ViewController.swift
//  golf2u
//
//  Created by 이원영 on 2020/09/16.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SafariServices
import EzPopup
import SwiftyJSON
import FirebaseMessaging
import AdSupport
import AppTrackingTransparency
import FBSDKCoreKit


class StartMain: VariousViewController{
    private var SO:Single = Single.getSO();
    private let JS = JsonC();
    private let JSToken = JsonC();
    private let JSATT = JsonC();
    private let JSBackFore = JsonC();
    
    
    private var m_tHeaderMCH : MainProductCollectionHeader?;
    @IBOutlet weak var productCollectionView: UICollectionView!
    private var refreshControl = UIRefreshControl()
    
    private var SelProductCategory = Array<String>();
    private var m_ListData = Array<[String:String]>();
    private var m_TopBanner = Array<[String:String]>();
    private var m_BottomBanner = Array<[String:String]>();
    private var m_nPageNum = 0;
    private var m_nNextNum = 0;
    private var m_nDataCnt = 0;
    
    private var estimateWidth = 200.0
    private var cellMarginSize = 6.0
    
    private var MainLogoBtn : UIButton!;
    private var MenuBtn : UIButton!;
    
    private var m_isBannerget : Bool = false;
    
    private var m_sSortSeq : String = "0";
    
    @IBOutlet weak var uiBtnContentsView: UIView!
    @IBOutlet var uiBoxBuyVIew: UIView!
    @IBOutlet var uiLoginVIew: UIView!
    @IBOutlet weak var uiBoxBuyBtn: UIButton!
    @IBOutlet weak var uiBoxBuyImg: UIImageView!
    @IBOutlet weak var uiLoginBtn: UIButton!
    private var m_isMainPopNotice = false;
    
    private var m_isPagging = false;
    
    private var mTimer : Timer?
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVIMAIN, title: "랜덤박스".localized)
        super.viewDidLoad();

        Init();
        setupCollectionViewItemSize();
        LoadItem()
        IDFAAccControl()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        if #available(iOS 11.0, *) {
//            if (UIDevice.current.hasNotch) {
//                //아이폰x 부터 하단 safe 영역 버튼이 있으면 여기서 처리
//                //let topPadding = self.view.safeAreaInsets.top
//                //let leftPadding = self.view.safeAreaInsets.left
//                //let rightPadding = self.view.safeAreaInsets.right
//                let bottomPadding = self.view.safeAreaInsets.bottom;
//                boxbuybtn.frame = CGRect(x: 0, y: Int(boxbuybtn.frame.minY), width: Int(boxbuybtn.frame.size.width), height: Int(boxbuybtn.frame.size.height + bottomPadding))
//                boxbuybtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
//            }
//
//        }
    }
    func IDFAAccControl(){
    //해당 기능 사용위해선 info 에 디스크립션 필요
    //pod 'FBAudienceNetwork'
     //   Privacy - Tracking Usage Description
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { (status) in
                var fm_Status = "";
                switch status {
                case .authorized:
//                    print(ASIdentifierManager.shared().isAdvertisingTrackingEnabled)
//                    print(ASIdentifierManager.shared().advertisingIdentifier.uuidString)
//                    let sharedASIdentifierManager = ASIdentifierManager.shared()
//                    let adID = sharedASIdentifierManager.advertisingIdentifier
                    FBSDKCoreKit.Settings.isAdvertiserIDCollectionEnabled = true;
                    print("ATT authorized")
                    fm_Status = "1";
                case .denied:
                    print("ATT denied")
                    fm_Status = "2";
                case .notDetermined:
                    print("ATT notDetermined")
                    fm_Status = "3";
                case .restricted:
                    print("ATT restricted")
                    fm_Status = "4";
                default:
                    print("ATT default")
                    fm_Status = "5";
                }
                self.JSATT.setAttstatus(param: ["account_seq":super.getUserSeq(), "status":fm_Status], callbackf: self.AttstatusCallback)
            }
        } else {
            print("ATT IOS13>")
            // Fallback on earlier versions
        }
    }
    func AttstatusCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            print("ATT Error : ",alldata["errormessage"].string!);
        }else{
            print("ATT Callback Suc");
        }
    }
    func Init(){
        SO.setStartMain(fStartMain: self)
        productCollectionView.delegate = self;
        productCollectionView.dataSource = self;
        
        uiLoginBtn.setTitle("로그인".localized, for: .normal)
        uiBoxBuyBtn.setTitle("랜덤박스 구매하기".localized, for: .normal)
        
        let nib = UINib(nibName: "MainProductCellCollectionViewCell", bundle: nil)
        productCollectionView?.register(nib, forCellWithReuseIdentifier: "mainproductcell")
        let headernib = UINib(nibName: "MainProductCollectionHeader", bundle: nil)
        productCollectionView?.register(headernib,
                                       forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier:"MainProductCollectionHeader")
        
        //productCollectionView.backgroundColor = UIColor(rgb: 0xc5c5c5)
        
        
        //리프레쉬
        if #available(iOS 10.0, *) {
          self.productCollectionView.refreshControl = refreshControl
        } else {
          self.productCollectionView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)//리프레시 이벤트
        //refreshControl.attributedTitle = NSAttributedString(string: "")
        
        let Logingradi = CAGradientLayer()
        let Boxgradi = CAGradientLayer()
        Logingradi.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: uiBoxBuyVIew.frame.height);
        Logingradi.colors = [UIColor(rgb: 0x00BA87).cgColor, UIColor(rgb: 0x00BA87).cgColor]
        Logingradi.startPoint = CGPoint(x: 0, y: 0.5)
        Logingradi.endPoint = CGPoint(x: 1, y: 0.5)
        
        Boxgradi.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: uiBoxBuyVIew.frame.height);
        Boxgradi.colors = [UIColor(rgb: 0x00BA87).cgColor, UIColor(rgb: 0x00BA87).cgColor]
        Boxgradi.startPoint = CGPoint(x: 0, y: 0.5)
        Boxgradi.endPoint = CGPoint(x: 1, y: 0.5)
        
        uiBoxBuyVIew.layer.addSublayer(Boxgradi)
        uiBoxBuyBtn.layer.zPosition = 9999;
        uiBoxBuyImg.layer.zPosition = 9998;
        uiLoginVIew.layer.addSublayer(Logingradi)
        uiLoginBtn.layer.zPosition = 9999;
        
        if let timer = mTimer {
            //timer 객체가 nil 이 아닌경우에는 invalid 상태에만 시작한다
            if !timer.isValid {
                /** 1초마다 timerCallback함수를 호출하는 타이머 */
                mTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
            }
        }else{
            //timer 객체가 nil 인 경우에 객체를 생성하고 타이머를 시작한다
            /** 1초마다 timerCallback함수를 호출하는 타이머 */
            mTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
        }
        
        
    }
    @objc func timerCallback(){
        let fm_sType = SO.getPushType()
        let fm_sSubType = SO.getPushSubType()
        let fm_sSeq = SO.getPushSeq()
        MoveDetailView(type: fm_sType, subtype: fm_sSubType, seq: fm_sSeq)//푸시 클릭해서 값이 들어왔을경우
        DeepMoveView()//딥링크로 값이 들어왔을경우
        
    }
    func setContentsView(uiView : UIView){
        self.uiBtnContentsView.addSubview(uiView)
        
        uiView.translatesAutoresizingMaskIntoConstraints = false
        uiView.topAnchor.constraint(equalTo: uiBtnContentsView.topAnchor,constant: 0).isActive = true
        uiView.leftAnchor.constraint(equalTo:uiBtnContentsView.leftAnchor,constant: 0).isActive = true
        uiView.rightAnchor.constraint(equalTo: uiBtnContentsView.rightAnchor, constant: 0).isActive = true
        uiView.bottomAnchor.constraint(equalTo: uiBtnContentsView.bottomAnchor, constant: 0).isActive = true
        
        uiView.layoutIfNeeded()
        
        uiView.layer.roundedLaout(corneridx : 15, points: [.topLeft, .topRight]);
    }
    @objc func refresh(){
        self.SelProductCategory = SO.getSelPCategory();
        m_isBannerget = false;
        m_nPageNum = 0;
        m_nNextNum = 0;
        m_nDataCnt = 0;
        m_ListData.removeAll();
        m_TopBanner.removeAll();
        m_BottomBanner.removeAll();
        LoadItem();
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.tabBarController?.tabBar.isTranslucent = false;
        if super.getUserSeq() == "" {
            setContentsView(uiView: uiLoginVIew)
            MainPopup();//로그인이 안되어있으면 튜토리얼은 못봄 그래서 팝업먼저
        }else  {
            if SO.getUserInfoKey(key: "type_changed") == "1"{
                MessagePop(title : "로그인 방식 전환 안내".localized, msg: "동일한 이메일을 사용하는 기존 계정이 확인되어 해당 계정의 로그인 방식이 애플 로그인으로 전환되었습니다.".localized,btntype: 2, lbtn: "취소".localized, rbtn: "확인".localized,succallbackf: { ()-> Void in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.SO.setUserInfoKey(key: "type_changed", value: "0")
                        self.BannerCalc()
                    }
                    
                }, closecallbackf: { ()-> Void in
                    
                })
            }else{
                self.BannerCalc()
            }
            
        }
        
        JSToken.UserUpdateToken(param: ["seq":super.getUserSeq(), "token":SO.getPushToken()], callbackf: UserUpdateTokenCallback)
    }
    func BannerCalc(){
        setContentsView(uiView: uiBoxBuyVIew)
        if SO.getUserInfoKey(key: Single.DE_NEEDPASSCHANGE) == "1" {
            //비밀번호 찾기후 임시 비밀번호를 발급 받은 회원은 무조건 비밀번호 변경을 유도 하기위해
            //비밀번호 변경 페이지를 띄움
            super.PassChangeMove()
        }else{
            if SO.getSystemInfoKey(key: "tutorial") == "1" {
                TutorialMain();//로그인이되어있으면 튜토리얼먼저띄우고 닫으면 내부함수에서 팝업띄움
            }
        }
    }
    func TutorialMain(){
        if let userseq = UserDefaults.standard.value(forKey: Single.DE_TUTORIALMAIN){
            MainPopup();//튜토리얼 닫으면 메인 화면 함수 호출되고 다음 팝업 실행
        }else{
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "TutorialMain", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "TutorialMainidx") as! TutorialMain
            viewController.closeHandler = { ()-> Void in
                let Storyboard: UIStoryboard = UIStoryboard(name: "BoxBuy", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "BoxBuyidx") as! BoxBuy
                viewController.m_tClickEvent = self;
                self.navigationController?.pushViewController(viewController, animated: true)
            }
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true, completion: nil)
        }
    }
    func UserUpdateTokenCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
        }
    }
    func MainPopup(){
        if m_isMainPopNotice {
            return;
        }
        if SO.getMainPop().count > 0 {
            if let mainpopdate = UserDefaults.standard.value(forKey: Single.DE_MAINPOPUP){
                //let now = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                dateFormatter.timeZone = NSTimeZone(name: "KST") as TimeZone?
                let date:Date = dateFormatter.date(from: (mainpopdate as! String))!
//                let calcday = now.timeIntervalSince(date)
//                if Int(calcday / 60) >= Single.DE_LIMITMAINPOPUP{
//                    MainPopupShow();
//                }else{
//
//                }
                let calendar = Calendar.current
                
                let isToday = calendar.isDateInToday(date)
                if isToday {
                    //MainPopupShow();
                }else{
                    MainPopupShow();
                }
                
//                let today = Date()
//                let localDate = Date(timeInterval: TimeInterval(calendar.timeZone.secondsFromGMT()), since: date)
//                if calendar.compare(today, to: localDate, toGranularity: .day) == .orderedSame {
//                   //오늘날짜와 같음
//                } else {
//                    MainPopupShow();
//                }
            }else{
                MainPopupShow();
            }
        }
    }
     

    func MainPopupShow(){
        let m_tWRP = MainPopupNotice.instantiate()
        guard let customAlertVC = m_tWRP else { return }
        customAlertVC.m_tClickEvent = self;
        let popupVC = PopupViewController(contentController: customAlertVC, popupWidth: 335, popupHeight: 450)
        //print(self.view.frame.width - 40)//(self.view.frame.width - 40)
        popupVC.backgroundAlpha = 0.3
        popupVC.backgroundColor = .black
        popupVC.canTapOutsideToDismiss = false
        popupVC.cornerRadius = 10
        popupVC.shadowEnabled = false
        present(popupVC, animated: true, completion: nil)
    }
    
    private func setupCollectionViewItemSize() {
        let flow = UICollectionViewFlowLayout()
        flow.sectionInset = UIEdgeInsets(top: 3, left: 13, bottom: 3, right:13)
        flow.scrollDirection = .vertical;
        flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
        //flow.sectionHeadersPinToVisibleBounds = true;//헤더 고정
        productCollectionView.collectionViewLayout = flow
    }
    func LoadItem(){
        LoadingHUD.show()
        m_isPagging = true;
        m_nPageNum += 1;
        JS.getMainProductList(param: ["pagenum":"\(m_nPageNum)", "category_seqs":SelProductCategory, "order_type":m_sSortSeq, "type":"\(SO.getSelPCategoryTab())"], callbackf: MainProductListCallback)
    }
    func MainProductListCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            if let val = alldata["nextpage"].string{
                m_nNextNum = Int(val)!;
            }
            if let val = alldata["datacnt"].string{
                m_nDataCnt = Int(val)!;
            }
            for (_, object) in alldata["data"] {
                var item = [String:String]()
                item["seq"] = object["seq"].stringValue;
                item["category_seq"] = object["category_seq"].stringValue;
                item["category_name"] = object["category_name"].stringValue;
                item["name"] = object["name"].stringValue;
                item["thumbnail"] = object["thumbnail"].stringValue;
                item["brand"] = object["brand"].stringValue;
                item["price"] = object["price"].stringValue;
                item["event_active"] = object["event_active"].stringValue;
                item["box_price"] = object["box_price"].stringValue;
                item["shipping_location"] = object["shipping_location"].stringValue;
                m_ListData.append(item)
                
                
            }
        }
        if !m_isBannerget{
            m_isBannerget = true;
            LoadBanner();
        }else{
            DispatchQueue.main.async {
                self.productCollectionView.reloadData()
                self.refreshControl.endRefreshing();//테이블뷰 리프레쉬 종료( 종료는 비동기로 해주어야함)
            }
        }
        m_isPagging = false;
        LoadingHUD.hide()
    }
    func LoadBanner(){
        JS.getMainBanner(param: ["type":""], callbackf: MainBannerListCallback)
    }
    func MainBannerListCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            for (_, object) in alldata["data"] {
                var item = [String:String]()
                item["seq"] = object["seq"].stringValue;
                item["title"] = object["title"].stringValue;
                item["type"] = object["type"].stringValue;
                item["image_url"] = object["image_url"].stringValue;
                item["landing"] = object["landing"].stringValue;
                
                item["out_link"] = object["out_link"].stringValue;
                item["in_link_type"] = object["in_link_type"].stringValue;
                item["in_link_seq"] = object["in_link_seq"].stringValue;
                
                if item["type"] == "0" {
                    m_TopBanner.append(item)
                }else if item["type"] == "1" {
                    m_BottomBanner.append(item)
                }
            }
        }
        DispatchQueue.main.async {
            self.productCollectionView.reloadData()
            self.refreshControl.endRefreshing();//테이블뷰 리프레쉬 종료( 종료는 비동기로 해주어야함)
        }
    }
    @IBAction func onBoxBuy(_ sender: Any) {
        let Storyboard: UIStoryboard = UIStoryboard(name: "BoxBuy", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "BoxBuyidx") as! BoxBuy
        viewController.m_tClickEvent = self;
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func onLoginBtn(_ sender: Any) {
        LoginMove();
    }
    //MARK: 백그라운드에서 포그라운드로 왔을때
    func setForeground(){
        if super.getUserSeq() != "" {
            self.JSBackFore.getWakeUpInfo(param: ["seq":super.getUserSeq()], callbackf: getWakeUpInfoCallback)
        }
    }
    func getWakeUpInfoCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            for (k, v) in alldata["data"]{
                if k == "point" {
                    setPushUserClover(clover: v.stringValue)
                }else if k == "is_status" {
                    if v.stringValue == "2" {
                        //재재 회원일경우
                        SO.setPushData(type: "10", subtype: "", seq: "")
                    }
                }
            }
        }
    }
    //MARK: 푸시 알림만 왔을때 이벤트
    func setPushUserClover(clover : String){
        SO.setUserInfoKey(key: Single.DE_USERCLOVER, value: clover)
    }
    //MARK: 딥링크 값이 들어왔을경우
    func DeepMoveView(){
        let type = SO.m_nDeepLinkType
        let seq = SO.m_nDeepLinkSeq
        if type == 0{
            return;
        }
        let LastVController = UIWindow.key!.rootViewController!.topMostViewController()
        if type == 1{
            //메인
            let fm_Contrllers = self.navigationController?.viewControllers
            if let val = fm_Contrllers{
                for VC in val{
                    if VC is StartMain {
                        self.tabBarController?.selectedIndex = 0;
                        self.navigationController?.popToViewController(VC, animated: true)
                        break;
                    }else if VC is TradeMain {
                        self.tabBarController?.selectedIndex = 0;
                        self.navigationController?.popToViewController(VC, animated: true)
                        break;
                    }else if VC is CommunityMain {
                        self.tabBarController?.selectedIndex = 0;
                        self.navigationController?.popToViewController(VC, animated: true)
                        break;
                    }else if VC is InventoryMain {
                        self.tabBarController?.selectedIndex = 0;
                        self.navigationController?.popToViewController(VC, animated: true)
                        break;
                    }
                }
            }
        }else if type == 2{
            //트레이드 > 상품
            let fm_Contrllers = self.navigationController?.viewControllers
            if let val = fm_Contrllers{
                for VC in val{
                    if VC is StartMain {
                        SO.setTradeTabIdx(TabbarIndex: 0)
                        self.tabBarController?.selectedIndex = 1;
                        self.navigationController?.popToViewController(VC, animated: true)
                        break;
                    }else if VC is TradeMain {
                        SO.setTradeTabIdx(TabbarIndex: 0)
                        self.tabBarController?.selectedIndex = 1;
                        self.navigationController?.popToViewController(VC, animated: true)
                        break;
                    }else if VC is CommunityMain {
                        SO.setTradeTabIdx(TabbarIndex: 0)
                        self.tabBarController?.selectedIndex = 1;
                        self.navigationController?.popToViewController(VC, animated: true)
                        break;
                    }else if VC is InventoryMain {
                        SO.setTradeTabIdx(TabbarIndex: 0)
                        self.tabBarController?.selectedIndex = 1;
                        self.navigationController?.popToViewController(VC, animated: true)
                        break;
                    }
                }
            }
        }else if type == 3{
            //커뮤니티 > 뉴스룸
            let fm_Contrllers = self.navigationController?.viewControllers
            if let val = fm_Contrllers{
                for VC in val{
                    if VC is StartMain {
                        SO.setComueTabIdx(TabbarIndex: 0)
                        self.tabBarController?.selectedIndex = 2;
                        self.navigationController?.popToViewController(VC, animated: true)
                        break;
                    }else if VC is TradeMain {
                        SO.setComueTabIdx(TabbarIndex: 0)
                        self.tabBarController?.selectedIndex = 2;
                        self.navigationController?.popToViewController(VC, animated: true)
                        break;
                    }else if VC is CommunityMain {
                        SO.setComueTabIdx(TabbarIndex: 0)
                        self.tabBarController?.selectedIndex = 2;
                        self.navigationController?.popToViewController(VC, animated: true)
                        break;
                    }else if VC is InventoryMain {
                        SO.setComueTabIdx(TabbarIndex: 0)
                        self.tabBarController?.selectedIndex = 2;
                        self.navigationController?.popToViewController(VC, animated: true)
                        break;
                    }
                }
            }
        }else if type == 4{
            //햄버거 > 고객센터 > 이벤트
            let Storyboard: UIStoryboard = UIStoryboard(name: "EventInfo", bundle: nil)
            let viewController = Storyboard.instantiateViewController(withIdentifier: "EventInfoidx") as! EventInfo
            LastVController.navigationController?.pushViewController(viewController, animated: true)
        }else if type == 5{
            //인벤토리 > 상품보관함
            if super.getUserSeq() == "" {
                LoginMove()
            }else{
                let fm_Contrllers = self.navigationController?.viewControllers
                if let val = fm_Contrllers{
                    for VC in val{
                        if VC is StartMain {
                            SO.setInventoryTabIdx(TabbarIndex: 1)
                            self.tabBarController?.selectedIndex = 3;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }else if VC is TradeMain {
                            SO.setInventoryTabIdx(TabbarIndex: 1)
                            self.tabBarController?.selectedIndex = 3;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }else if VC is CommunityMain {
                            SO.setInventoryTabIdx(TabbarIndex: 1)
                            self.tabBarController?.selectedIndex = 3;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }else if VC is InventoryMain {
                            SO.setInventoryTabIdx(TabbarIndex: 1)
                            self.tabBarController?.selectedIndex = 3;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }
                    }
                }
            }
        }else if type == 6{
            //햄버거 > 획득가능쿠폰 > 지류쿠폰 등록하기 > 지류쿠폰 등록
            if super.getUserSeq() == "" {
                LoginMove()
            }else{
                let Storyboard: UIStoryboard = UIStoryboard(name: "CuponInfoPaper", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "CuponInfoPaperidx") as! CuponInfoPaper
                LastVController.navigationController?.pushViewController(viewController, animated: true)
            }
        }else if type == 7{
            //햄버거 > 쿠폰함 > 획득가능쿠폰
            if super.getUserSeq() == "" {
                LoginMove()
            }else{
                let Storyboard: UIStoryboard = UIStoryboard(name: "CuponInfo", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "CuponInfoidx") as! CuponInfo
                LastVController.navigationController?.pushViewController(viewController, animated: true)
            }
        }else if type == 8{
            //상품 상세
            if seq != ""{
                let Storyboard: UIStoryboard = UIStoryboard(name: "ProductDetail", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "productdetailide") as! ProductDetailNew
                viewController.InitSetting(seq: seq);
                LastVController.navigationController?.pushViewController(viewController, animated: true)
            }
        }else if type == 9{
            //랜투샵> 랜덤박스 구매하기> 랜덤박스구매
            if super.getUserSeq() == "" {
                LoginMove()
            }else {
                let Storyboard: UIStoryboard = UIStoryboard(name: "BoxBuy", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "BoxBuyidx") as! BoxBuy
                viewController.m_tClickEvent = self;
                LastVController.navigationController?.pushViewController(viewController, animated: true)
            }
        }else if type == 10{
            //"랜투샵> 랜덤박스 구매하기> 랜덤박스 상품보기 *현재 당첨 가능한 상품 썸네일 노출되는 페이지"
            let m_tWRP = BoxProductListPop.instantiate()
            guard let customAlertVC = m_tWRP else { return }
            m_tWRP?.setData(type: "1")
            m_tWRP?.ClickCellHandler = { (seq)-> Void in
                let Storyboard: UIStoryboard = UIStoryboard(name: "ProductDetail", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "productdetailide") as! ProductDetailNew
                viewController.InitSetting(seq: seq);
                self.navigationController?.pushViewController(viewController, animated: true)
            }
            let popupVC = PopupViewController(contentController: customAlertVC, popupWidth: (self.view.frame.width - 40), popupHeight: 520)
            popupVC.backgroundAlpha = 0.3
            popupVC.backgroundColor = .black
            popupVC.canTapOutsideToDismiss = true
            popupVC.cornerRadius = 10
            popupVC.shadowEnabled = false
            
            LastVController.present(popupVC, animated: true, completion: nil)
        }
        SO.m_nDeepLinkType = 0
        SO.m_nDeepLinkSeq = "";
    }
    //MARK: 푸시 클릭시 화면이동
    func MoveDetailView(type : String, subtype : String, seq : String){
//        let type = SO.getPushType()
//        let subtype = SO.getPushSubType()
//        let seq = SO.getPushSeq()
        if type == "-1" || subtype == "-1" || seq == "-1" {
            return;
        }
        if (type == "8" || type == "9") && subtype == "0" {
            
        }else{
            if super.getUserSeq() == "" {
                LoginMove()
                return;
            }else {
                
            }
        }
        SO.setPushData(type: "-1", subtype: "-1", seq: "-1")
        //알림이와서 클릭 할때 메인이 아닐수도있기 때문에 현재 보고있는 최상위 뷰 를 가져와 그위에 화면을 띄운다
        let LastVController = UIWindow.key!.rootViewController!.topMostViewController()
        
        if type == "0" {
            if subtype == "0" {
                //트레이드 신청 받은거
//                let Storyboard: UIStoryboard = UIStoryboard(name: "TradeApplyTry", bundle: nil)
//                let viewController = Storyboard.instantiateViewController(withIdentifier: "tradeapplytryidx") as! TradeApplyTry
//                viewController.setData(viewType: 4, TradeSeq: seq);
//                //self.navigationController?.pushViewController(viewController, animated: true)
//                LastVController.navigationController?.pushViewController(viewController, animated: true)
                self.JS.Notificationrestore(param: ["account_seq":super.getUserSeq(),"target_seq" : seq,"type" : type,"subtype" : subtype], callbackf: self.NotificationrestoreCallback)
             }else if subtype == "1" {
//                let Storyboard: UIStoryboard = UIStoryboard(name: "TradeApplyTry", bundle: nil)
//                let viewController = Storyboard.instantiateViewController(withIdentifier: "tradeapplytryidx") as! TradeApplyTry
//                viewController.setData(viewType: 3, TradeSeq: seq);
//                LastVController.navigationController?.pushViewController(viewController, animated: true)
                self.JS.Notificationrestore(param: ["account_seq":super.getUserSeq(),"target_seq" : seq,"type" : type,"subtype" : subtype], callbackf: self.NotificationrestoreCallback)
            }else if subtype == "2" {
                let fm_Contrllers = self.navigationController?.viewControllers
                if let val = fm_Contrllers{
                    for VC in val{
                        if VC is StartMain {
                            SO.setInventoryTabIdx(TabbarIndex: 1)
                            self.tabBarController?.selectedIndex = 3;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }else if VC is TradeMain {
                            SO.setInventoryTabIdx(TabbarIndex: 1)
                            self.tabBarController?.selectedIndex = 3;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }else if VC is CommunityMain {
                            SO.setInventoryTabIdx(TabbarIndex: 1)
                            self.tabBarController?.selectedIndex = 3;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }else if VC is InventoryMain {
                            SO.setInventoryTabIdx(TabbarIndex: 1)
                            self.tabBarController?.selectedIndex = 3;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }
                    }
                }
            }else if subtype == "3" {
//                let Storyboard: UIStoryboard = UIStoryboard(name: "TradeApplyTry", bundle: nil)
//                let viewController = Storyboard.instantiateViewController(withIdentifier: "tradeapplytryidx") as! TradeApplyTry
//                viewController.setData(viewType: 3, TradeSeq: seq);
//                LastVController.navigationController?.pushViewController(viewController, animated: true)
                self.JS.Notificationrestore(param: ["account_seq":super.getUserSeq(),"target_seq" : seq,"type" : type,"subtype" : subtype], callbackf: self.NotificationrestoreCallback)
            }else if subtype == "5" {
//                let Storyboard: UIStoryboard = UIStoryboard(name: "TradeApplyTry", bundle: nil)
//                let viewController = Storyboard.instantiateViewController(withIdentifier: "tradeapplytryidx") as! TradeApplyTry
//                viewController.setData(viewType: 2, TradeSeq: seq);
//                self.navigationController?.pushViewController(viewController, animated: true)
                self.JS.Notificationrestore(param: ["account_seq":super.getUserSeq(),"target_seq" : seq,"type" : type,"subtype" : subtype], callbackf: self.NotificationrestoreCallback)
            }
        }else if type == "1" {
            if subtype == "0" || subtype == "1" {
                let fm_Contrllers = self.navigationController?.viewControllers
                if let val = fm_Contrllers{
                    for VC in val{
                        if VC is StartMain {
                            self.tabBarController?.selectedIndex = 3;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }else if VC is TradeMain {
                            self.tabBarController?.selectedIndex = 3;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }else if VC is CommunityMain {
                            self.tabBarController?.selectedIndex = 3;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }else if VC is InventoryMain {
                            self.tabBarController?.selectedIndex = 3;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }
                        
                    }
                }
            }
        }else if type == "2" {
            if subtype == "0" {
                let fm_Contrllers = self.navigationController?.viewControllers
                if let val = fm_Contrllers{
                    for VC in val{
                        if VC is StartMain {
                            SO.setInventoryTabIdx(TabbarIndex: 1)
                            self.tabBarController?.selectedIndex = 3;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }else if VC is TradeMain {
                            SO.setInventoryTabIdx(TabbarIndex: 1)
                            self.tabBarController?.selectedIndex = 3;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }else if VC is CommunityMain {
                            SO.setInventoryTabIdx(TabbarIndex: 1)
                            self.tabBarController?.selectedIndex = 3;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }else if VC is InventoryMain {
                            SO.setInventoryTabIdx(TabbarIndex: 1)
                            self.tabBarController?.selectedIndex = 3;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }
                        
                    }
                }
            }
        }else if type == "3" {
            if subtype == "0" || subtype == "1" || subtype == "2" {
                let Storyboard: UIStoryboard = UIStoryboard(name: "DeliveryInfo", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "DeliveryInfoidx") as! DeliveryInfo
                LastVController.navigationController?.pushViewController(viewController, animated: true)
            }
        }else if type == "4" {
            if subtype == "0" {
                let Storyboard: UIStoryboard = UIStoryboard(name: "FriendMain", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "FriendMainidx") as! FriendMain
                viewController.setMenu(selmenu: 0)
                LastVController.navigationController?.pushViewController(viewController, animated: true)
            }else if subtype == "1" {
                let Storyboard: UIStoryboard = UIStoryboard(name: "FriendMain", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "FriendMainidx") as! FriendMain
                viewController.setMenu(selmenu: 1)
                LastVController.navigationController?.pushViewController(viewController, animated: true)
            }
        }else if type == "5" {
            if subtype == "0" {
                let Storyboard: UIStoryboard = UIStoryboard(name: "CloverInfo", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "CloverInfoidx") as! CloverInfo
                LastVController.navigationController?.pushViewController(viewController, animated: true)
            }
        }else if type == "6" {
            if subtype == "0" {
                let fm_Contrllers = self.navigationController?.viewControllers
                if let val = fm_Contrllers{
                    for VC in val{
                        if VC is StartMain {
                            SO.setInventoryTabIdx(TabbarIndex: 2)
                            self.tabBarController?.selectedIndex = 3;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }else if VC is TradeMain {
                            SO.setInventoryTabIdx(TabbarIndex: 2)
                            self.tabBarController?.selectedIndex = 3;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }else if VC is CommunityMain {
                            SO.setInventoryTabIdx(TabbarIndex: 2)
                            self.tabBarController?.selectedIndex = 3;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }else if VC is InventoryMain {
                            SO.setInventoryTabIdx(TabbarIndex: 2)
                            self.tabBarController?.selectedIndex = 3;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }
                        
                    }
                }
            }
        }else if type == "7" {
            if subtype == "0" {
                let Storyboard: UIStoryboard = UIStoryboard(name: "UserConDetail", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "UserConDetailidx") as! UserConDetail
                viewController.setData(data: ["seq" : seq])
                LastVController.navigationController?.pushViewController(viewController, animated: true)
            }
        }else if type == "8" {
            if subtype == "0" {
                let fm_Contrllers = self.navigationController?.viewControllers
                if let val = fm_Contrllers{
                    for VC in val{
                        if VC is StartMain {
                            self.tabBarController?.selectedIndex = 0;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }else if VC is TradeMain {
                            self.tabBarController?.selectedIndex = 0;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }else if VC is CommunityMain {
                            self.tabBarController?.selectedIndex = 0;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }else if VC is InventoryMain {
                            self.tabBarController?.selectedIndex = 0;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }
                        
                    }
                }
            }
        }else if type == "9" {
            if subtype == "0" {
                let fm_Contrllers = self.navigationController?.viewControllers
                if let val = fm_Contrllers{
                    for VC in val{
                        if VC is StartMain {
                            self.tabBarController?.selectedIndex = 0;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }else if VC is TradeMain {
                            self.tabBarController?.selectedIndex = 0;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }else if VC is CommunityMain {
                            self.tabBarController?.selectedIndex = 0;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }else if VC is InventoryMain {
                            self.tabBarController?.selectedIndex = 0;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }
                        
                    }
                }
            }else if subtype == "1" {
                let Storyboard: UIStoryboard = UIStoryboard(name: "CuponInfo", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "CuponInfoidx") as! CuponInfo
                LastVController.navigationController?.pushViewController(viewController, animated: true)
            }else if subtype == "2" {
                let Storyboard: UIStoryboard = UIStoryboard(name: "CloverInfo", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "CloverInfoidx") as! CloverInfo
                LastVController.navigationController?.pushViewController(viewController, animated: true)
            }else if subtype == "3" {
                let Storyboard: UIStoryboard = UIStoryboard(name: "EventInfoDetail", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "EventInfoDetailidx") as! EventInfoDetail
                viewController.setData(seq: seq)
                LastVController.navigationController?.pushViewController(viewController, animated: true)
            }
        }else if type == "10" {
            if super.getUserSeq() != "" {
                self.JS.logout(param: ["seq":super.getUserSeq()], callbackf: self.logoutCallback)
            }
        }
    }
    func BlackListMemberPush(){
        if super.getUserSeq() != "" {
            self.JS.logout(param: ["seq":super.getUserSeq()], callbackf: self.logoutCallback)
        }
    }
    func logoutCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            //MessagePop(msg: alldata["errormessage"].stringValue, btntype:2)
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
            
            //self.dismiss(animated: true, completion: nil)
        }
    }
    func NotificationrestoreCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            MessagePop(msg: alldata["errormessage"].stringValue, btntype:2)
        }else{
            print( alldata["data"]["type"], alldata["data"]["subtype"], alldata["data"]["target_seq"]);
            if alldata["data"]["type"] == "0" {
                //알림이와서 클릭 할때 메인이 아닐수도있기 때문에 현재 보고있는 최상위 뷰 를 가져와 그위에 화면을 띄운다
                let LastVController = UIWindow.key!.rootViewController!.topMostViewController()
                let seq = alldata["data"]["target_seq"].stringValue;
                if alldata["data"]["subtype"] == "0" {
                    //트레이드 신청 받은거
                    let Storyboard: UIStoryboard = UIStoryboard(name: "TradeApplyTry", bundle: nil)
                    let viewController = Storyboard.instantiateViewController(withIdentifier: "tradeapplytryidx") as! TradeApplyTry
                    viewController.setData(viewType: 4, TradeSeq: seq);
                    //self.navigationController?.pushViewController(viewController, animated: true)
                    LastVController.navigationController?.pushViewController(viewController, animated: true)
                }else if alldata["data"]["subtype"] == "1" {
                    let Storyboard: UIStoryboard = UIStoryboard(name: "TradeApplyTry", bundle: nil)
                    let viewController = Storyboard.instantiateViewController(withIdentifier: "tradeapplytryidx") as! TradeApplyTry
                    viewController.setData(viewType: 3, TradeSeq: seq);
                    LastVController.navigationController?.pushViewController(viewController, animated: true)
                }else if alldata["data"]["subtype"] == "3" {
                    let Storyboard: UIStoryboard = UIStoryboard(name: "TradeApplyTry", bundle: nil)
                    let viewController = Storyboard.instantiateViewController(withIdentifier: "tradeapplytryidx") as! TradeApplyTry
                    viewController.setData(viewType: 3, TradeSeq: seq);
                    LastVController.navigationController?.pushViewController(viewController, animated: true)
                }else if alldata["data"]["subtype"] == "5" {
                    let Storyboard: UIStoryboard = UIStoryboard(name: "TradeApplyTry", bundle: nil)
                    let viewController = Storyboard.instantiateViewController(withIdentifier: "tradeapplytryidx") as! TradeApplyTry
                    viewController.setData(viewType: 2, TradeSeq: seq);
                    LastVController.navigationController?.pushViewController(viewController, animated: true)
                }
            }
        }
    }
}



extension StartMain:  UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if m_ListData.count > 0 {
            productCollectionView.backgroundView = nil;
            return m_ListData.count;
        } else {
            ListViewHelper.CollectionViewEmptyMessage(message: "데이터가 없습니다.".localized, viewController: self, tableviewController: productCollectionView)
            return 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mainproductcell", for: indexPath) as! MainProductCellCollectionViewCell
        if m_ListData.count > indexPath.row{
            cell.setData(data: m_ListData[indexPath.row]);
        }else{
        }
        return cell;
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let Storyboard: UIStoryboard = UIStoryboard(name: "ProductDetail", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "productdetailide") as! ProductDetailNew
        viewController.InitSetting(seq: m_ListData[indexPath.row]["seq"]!);
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (m_ListData.count - 1) <= indexPath.row && m_nNextNum > 0 && !m_isPagging{
           
           self.LoadItem();
        }
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MainProductCollectionHeader", for: indexPath) as! MainProductCollectionHeader;
        header.setBanner(f_TopBanner: m_TopBanner, f_BottomBanner: m_BottomBanner)
        header.dataCount(cnt: m_nDataCnt)
        header.m_tClickEvent = self;
        self.m_tHeaderMCH = header;
        return header;
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.view.frame.size.width, height: 360)
    }
    
}
extension StartMain: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        return CGSize(width: width, height: width + 65)
    }
    
    func calculateWith() -> CGFloat {
//        let estimatedWidth = CGFloat(estimateWidth)
//        let cellCount = floor(CGFloat(self.productCollectionView.frame.size.width / estimatedWidth))
//        
//        let margin = CGFloat(cellMarginSize * 2)
//        let width = (self.productCollectionView.frame.size.width - CGFloat(cellMarginSize) * (cellCount - 1) - margin) / cellCount
        
        return (self.productCollectionView.frame.size.width / 2 - 18)
    }
}

extension StartMain: ClickBannerDelegate {
    func ClickEventMainPopNotice(type : Int, data: [String : String]) {
        //MARK: 메인 배너 팝업 클릭
        if type == 0{
            var fm_sOutLink = data["out_link"] ?? "";
            var fm_sIsOutLink = data["in_link_type"] ?? "";
            let fm_sSeq = data["in_link_seq"] ?? "";
//            #if DEBUG
//                fm_sOutLink = ""
//                fm_sIsOutLink = "invitation"
//            #endif
            if fm_sOutLink.contains("youtube.com") {
                //유튜브 일경우 유튜브 앱으로 이동 없으면 스토어
                let kakaoStoryURL = NSURL(string: "youtube://watch?v=\(fm_sSeq)")
                if let urlY = kakaoStoryURL{
                    if UIApplication.shared.canOpenURL(urlY as URL) {
                        UIApplication.shared.open(urlY as URL)
                    }else{
                        if let urlY = URL(string: Single.DE_YOUTUBESTOERURL){
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(urlY as URL, options: [:], completionHandler: nil)
                            } else {
                                UIApplication.shared.openURL(urlY as URL)
                            }
                        }
                    }
                }
                else if let urlY = URL(string: Single.DE_YOUTUBESTOERURL){
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(urlY as URL, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(urlY as URL)
                    }
                }
            }else if fm_sOutLink != ""{
                guard let urlS = URL(string: fm_sOutLink) else { return }
                let safariViewController = SFSafariViewController(url: urlS)
                present(safariViewController, animated: true, completion: nil)
            }else if fm_sOutLink == "" && fm_sIsOutLink != ""{
                if fm_sIsOutLink == "event" && fm_sSeq != ""{
                    let Storyboard: UIStoryboard = UIStoryboard(name: "EventInfoDetail", bundle: nil)
                    let viewController = Storyboard.instantiateViewController(withIdentifier: "EventInfoDetailidx") as! EventInfoDetail
                    viewController.setData(seq: fm_sSeq)
                    self.navigationController?.pushViewController(viewController, animated: true)
                }else if fm_sIsOutLink == "notice" && fm_sSeq != ""{
                    let Storyboard: UIStoryboard = UIStoryboard(name: "NoticeInfoDetail", bundle: nil)
                    let viewController = Storyboard.instantiateViewController(withIdentifier: "NoticeInfoDetailidx") as! NoticeInfoDetail
                    viewController.setData(data: fm_sSeq)
                    self.navigationController?.pushViewController(viewController, animated: true)
                }else if fm_sIsOutLink == "product" && fm_sSeq != ""{
                    let Storyboard: UIStoryboard = UIStoryboard(name: "ProductDetail", bundle: nil)
                    let viewController = Storyboard.instantiateViewController(withIdentifier: "productdetailide") as! ProductDetailNew
                    viewController.InitSetting(seq: fm_sSeq);
                    self.navigationController?.pushViewController(viewController, animated: true)
                }else if fm_sIsOutLink == "invitation"{
                    if super.getUserSeq() == "" {
                        //친구 초대 로그인이 아니라면 접근불가
                        LoginMove();
                        return;
                    }
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
                        let Storyboard: UIStoryboard = UIStoryboard(name: "FriendInvation", bundle: nil)
                        let viewController = Storyboard.instantiateViewController(withIdentifier: "FriendInvationidx") as! FriendInvation
                        self.navigationController?.pushViewController(viewController, animated: true)
                    }
                    
                }
            }
        }else if type == 1{
            //메인팝업 비호출은 팝업 배너를 통해 클릭해서 이전으로 다시올경우 팝업을다시띄움
            //버튼을 통해 팝업을 닫은경우는 띄우지 않음
            m_isMainPopNotice = true;
        }
    }
    func ClickEvent(type: Int, BannerCurrent : Int){
        //MARK: 메인 배너 클릭
        var fm_sOutLink = "";
        var fm_sIsOutLink = "";
        var fm_sSeq = "";
        if type == 0{
            fm_sOutLink = m_TopBanner[BannerCurrent]["out_link"] ?? "";
            fm_sIsOutLink = m_TopBanner[BannerCurrent]["in_link_type"] ?? "";
            fm_sSeq = m_TopBanner[BannerCurrent]["in_link_seq"] ?? "";
        }else  if type == 1{
            fm_sOutLink = m_BottomBanner[BannerCurrent]["out_link"] ?? "";
            fm_sIsOutLink = m_BottomBanner[BannerCurrent]["in_link_type"] ?? "";
            fm_sSeq = m_BottomBanner[BannerCurrent]["in_link_seq"] ?? "";
        }
        if fm_sOutLink.contains("youtube.com") {
            //유튜브 일경우 유튜브 앱으로 이동 없으면 스토어
            let YoutubeURL = NSURL(string: "youtube://watch?v=\(fm_sSeq)")
            if let urlY = YoutubeURL{
                if UIApplication.shared.canOpenURL(urlY as URL) {
                    UIApplication.shared.open(urlY as URL)
                }else{
                    if let urlY = URL(string: Single.DE_YOUTUBESTOERURL){
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(urlY as URL, options: [:], completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(urlY as URL)
                        }
                    }
                }
            }else if let urlY = URL(string: Single.DE_YOUTUBESTOERURL){
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(urlY as URL, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(urlY as URL)
                }
            }
        }else if fm_sOutLink != ""{
            if !fm_sOutLink.contains("http") {
                return;
            }
            guard let urlS = URL(string: fm_sOutLink) else { return }
            let safariViewController = SFSafariViewController(url: urlS)
            present(safariViewController, animated: true, completion: nil)
        }else if fm_sOutLink == "" && fm_sIsOutLink != ""{
            if fm_sIsOutLink == "event" && fm_sSeq != ""{
                let Storyboard: UIStoryboard = UIStoryboard(name: "EventInfoDetail", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "EventInfoDetailidx") as! EventInfoDetail
                viewController.setData(seq: fm_sSeq)
                self.navigationController?.pushViewController(viewController, animated: true)
            }else if fm_sIsOutLink == "notice" && fm_sSeq != ""{
                let Storyboard: UIStoryboard = UIStoryboard(name: "NoticeInfoDetail", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "NoticeInfoDetailidx") as! NoticeInfoDetail
                viewController.setData(data: fm_sSeq)
                self.navigationController?.pushViewController(viewController, animated: true)
            }else if fm_sIsOutLink == "product" && fm_sSeq != ""{
                let Storyboard: UIStoryboard = UIStoryboard(name: "ProductDetail", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "productdetailide") as! ProductDetailNew
                viewController.InitSetting(seq: fm_sSeq);
                self.navigationController?.pushViewController(viewController, animated: true)
            }else if fm_sIsOutLink == "invitation"{
                if super.getUserSeq() == "" {
                    //친구 초대 로그인이 아니라면 접근불가
                    LoginMove();
                    return;
                }
                let Storyboard: UIStoryboard = UIStoryboard(name: "FriendInvation", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "FriendInvationidx") as! FriendInvation
                self.navigationController?.pushViewController(viewController, animated: true)
//                if SO.getUserInfoKey(key: Single.DE_USERVERIFIED) == "0" {
//                    MessagePop(title : "본인인증".localized, msg: "본인인증 하시겠습니까?".localized, ostuch:false, lbtn: "취소".localized, rbtn: "본인인증".localized,succallbackf: { ()-> Void in
//                        //self.navigationController?.popViewController(animated: true);
//                        let Storyboard: UIStoryboard = UIStoryboard(name: "UserVerification", bundle: nil)
//                        let viewController = Storyboard.instantiateViewController(withIdentifier: "UserVerificationidx") as! UserVerification
//                        viewController.setData(data: ["os_type":Single.DE_PLATFORMIDX, "account_seq":super.getUserSeq()])
//                        self.navigationController?.pushViewController(viewController, animated: true)
//                    }, closecallbackf: { ()-> Void in
//                        //self.navigationController?.popViewController(animated: true);
//                    })
//
//                }else{
//                    let Storyboard: UIStoryboard = UIStoryboard(name: "FriendInvation", bundle: nil)
//                    let viewController = Storyboard.instantiateViewController(withIdentifier: "FriendInvationidx") as! FriendInvation
//                    self.navigationController?.pushViewController(viewController, animated: true)
//                }
                
            }
        }
        
    }
    func ClickFiltter(type: Int) {
        if type == 1{
            let optionMenu = UIAlertController(title: nil, message: "정렬".localized, preferredStyle: .actionSheet)
            //옵션 초기화
            let alertacop1 = UIAlertAction(title: "브랜드순".localized, style: .default, handler: alertHandleOp1)
            let alertacop2 = UIAlertAction(title: "최신순".localized, style: .default, handler: alertHandleOp1)
            let alertacop3 = UIAlertAction(title: "가격순".localized, style: .default, handler: alertHandleOp1)
            let cancelAction = UIAlertAction(title: "닫기".localized, style: .cancel, handler: {
                (alert: UIAlertAction!) -> Void in
            })
            optionMenu.addAction(alertacop1)
            optionMenu.addAction(alertacop2)
            optionMenu.addAction(alertacop3)
            optionMenu.addAction(cancelAction)
            self.present(optionMenu, animated: true, completion: nil)
        }else if type == 2{
            FiltterPopupOpen();
        }
    }
    func alertHandleOp1(alertAction: UIAlertAction!) -> Void {
        var title = "";
        if alertAction.title! == "브랜드순".localized {
            title = "브랜드순".localized;
            m_sSortSeq = "0";
        }else if alertAction.title! == "최신순".localized {
            title = "최신순".localized;
            m_sSortSeq = "1";
        }else if alertAction.title! == "가격순".localized {
            title = "가격순".localized;
            m_sSortSeq = "2";
        }
        if let it = self.m_tHeaderMCH{
            it.setSortBtnTxt(msg: title)
            refresh();
        }
    }
    func FiltterPopupOpen(){
        let m_tWRP = FiltterPopup.instantiate()
        guard let customAlertVC = m_tWRP else { return }
        customAlertVC.SaveHandler = {
            self.refresh();
        }
        let popupVC = PopupViewController(contentController: customAlertVC, popupWidth: 340, popupHeight: 484)
        popupVC.backgroundAlpha = 0.3
        popupVC.backgroundColor = .black
        popupVC.canTapOutsideToDismiss = true
        popupVC.cornerRadius = 10
        popupVC.shadowEnabled = false
        present(popupVC, animated: true, completion: nil)
    }
    
    
}
extension StartMain:  BoxBuyClickCellBtnDelegate{
    func HeaderSliderEvent(pageidx : Int) {}
    func getMainCuponMaxPrice() -> Int {
        return 0;
    }
    
    func getMainAllCloverMaxPrice() -> Int {
        return 0;
    }
    func ClickEvent(type: Int, data: [String : String]) {
        
    }
    
}
