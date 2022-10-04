/*
 스토어 정식 등록 대기 중 추가 요건 사항 처리중인 프로젝트
 
 V2-2021-03-23 트레이드 상세에서 흥정 눌렀을경우에 내것도 선택하기위함 디버깅 모드에서만동작 - 2021-03-30 실서버 적용완료
 
 
 apple app id
 1237544150
 
 앱서플라이 AF_DEV_KEY
 bpyxadhpjyt8yFX5p2HqMf
 */

import CoreLocation
import UIKit
import SwiftyJSON
import TAKUUID
import AppsFlyerLib

protocol SingleToneDelegate: AnyObject {
    func _gpscontroll(type : Int)
}

class Single{
    
    
    private static let shared = Single()
    
    private init(){}
    public static func getSO()->Single{
        return shared
    }
    // App Service
    
    static let DE_ISDEBUG = false;
    //static let DE_URLSERVER = "api.random2u.com";//live server
    static let DE_URLSERVER = "\(DE_ISDEBUG == false ? "api.golf2u.kr" : "st.api.golf2u.kr")";//live, test server
    static let DE_URLIMGSERVER = "\(DE_ISDEBUG == false ? "https://d2tcu1hwf4enrb.cloudfront.net" : "https://dc037701a0voi.cloudfront.net")";//live, test server
    
    
    static let DE_PLATFORM = "ios";
    static let DE_PLATFORMIDX = "1";
    static let DE_LIMITREPORTSENDMIN = 2;//2분 이내 연속된 이메일 비번찾기 메일전송 불가능
    static let DE_MARKETADDLIMITEDMIN = 5//마켓등록 연속 제한 분 단위
    static let DE_LIMITMAINPOPUP = 1440;//메인 팝업 24시간 동안 안띄우기
    static let DE_WEBAPIPROTOCOL = "https";//live : https
    
    
    //view controller type
    static let DE_INITNAVISUB = 1;//sub view navi
    static let DE_INITNAVIMAIN = 2;//main view navi
    static let DE_INITNAVIMAINNONELOGOINTITLE = 3;//main view navi none logo image on text title
    
    //Text PopSize
    static let DE_TEXTPOPSIZEW : CGFloat = -80.0;
    static let DE_TEXTPOPSIZEH : CGFloat = 400.0;
    
    //랭킹전 로컬에 저장된 이전 값이 없다면
    static let DE_DEFAULTRANK : Int = 9999999
    
    
    //나라 화패(페이스북 로그 찍을때)
    static let DE_CURRENCY = "KRW";
    
    
    
    //UserDefaults.standard Key
    static let DE_AUTOLOGIN = "autologinuserseq";
    static let DE_USERVERIFIED = "is_verified";
    static let DE_TUTORIALMAIN = "tutorialmain";
    static let DE_MAINPOPUP = "mainpopup";
    static let DE_USERCLOVER = "point_total";
    static let DE_NEEDPASSCHANGE = "need_pass_exchange";
    static let DE_PUSHLOCALSAVESEQ = "pushseqlocalsave"
    static let DE_APPSTROEURL = "itms-apps://itunes.apple.com/app/1591376686"
    static let DE_APPREVIEW = "appreviewis";
    static let DE_USERRANK = "userrank";
    static let DE_MARKETLIMITMINKEY = "marketaddtime";
    static let DE_PASSFINDEMAILMINKEY = "passfindtime";
    static let DE_APPSTOREKRURL = "https://apps.apple.com/kr/app/%EB%9E%9C%EB%8D%A4%ED%88%AC%EC%9C%A0-%EB%93%9D%ED%85%9C%EC%9D%98-%EC%8B%9C%EC%9E%91/id1591376686";
    static let DE_YOUTUBESTOERURL = "https://apps.apple.com/kr/app/youtube/id544007664"
    
    
    
    
    //딥링크로 들어온 값
    private var _nDeepLinkType: Int = 0;
    var m_nDeepLinkType: Int {
       get {
          return _nDeepLinkType
       }
       set(data) {
        _nDeepLinkType = data
       }
    }
    private var _nDeepLinkSeq: String = "";
    var m_nDeepLinkSeq: String {
       get {
          return _nDeepLinkSeq
       }
       set(data) {
        _nDeepLinkSeq = data
       }
    }

    
    //login user
    private var UserInfo: Dictionary<String, String> = Dictionary<String, String>()
    func setUserInfoKey(key : String, value : String) {
        if key == "seq" {
            AppsFlyerLib.shared().customerUserID = value
        }
        print(key, value);
        UserInfo[key] = value;
    }
    func getUserInfo() -> [String : String] {
        return UserInfo;
    }
    func UserLogout(){
        UserInfo = [String : String]();
    }
    func getUserInfoKey(key : String) -> String{
        if let val = UserInfo[key] {
            return val
        }
        else {
            return "";
        }
    }
    
    //푸시 토큰
    private var m_sPushToken = "";
    func setPushToken(key : String) {
        m_sPushToken = key;
    }
    func getPushToken() -> String {
        return m_sPushToken;
    }
    //현재 랭킹
    private var m_nNowRank = 0;
    func setNowRank(rank : Int) {
        m_nNowRank = rank;
    }
    func getNowRank() -> Int {
        return m_nNowRank;
    }
    //푸시클릭 데이터
    private var m_sPushType = "-1";
    private var m_sPushSubType = "-1";
    private var m_sPushSeq = "-1";
    func setPushData(type : String, subtype : String, seq : String) {
        m_sPushType = type;
        m_sPushSubType = subtype;
        m_sPushSeq = seq;
    }
    func getPushType() -> String {
        return m_sPushType;
    }
    func getPushSubType() -> String {
        return m_sPushSubType;
    }
    func getPushSeq() -> String {
        return m_sPushSeq;
    }
    //푸시알림 왔을때
    private var m_sPushClover = "-1";
    func setPushClover(clover : String) {
        m_sPushClover = clover;
    }
    func getPushClover() -> String {
        return m_sPushClover;
    }
    
    //System Info
    private var SystemInfo: Dictionary<String, String> = Dictionary<String, String>()
    func setSystemInfoKey(key : String, value : String) {
        SystemInfo[key] = value;
    }
    func getSystemInfo() -> [String : String] {
        return SystemInfo;
    }
    func getSystemInfoKey(key : String) -> String{
        if let val = SystemInfo[key] {
            return val
        }
        else {
            return "";
        }
    }
    
    //메인 팝업
    private var MainPop = Array<[String : String]>()
    func setMainPopKey(value : [String : String]) {
        MainPop.append(value);
    }
    func getMainPop() -> Array<[String : String]> {
        return MainPop;
    }
    
    
    //trade search product list category
    private var m_sTradePSearchKeyword : String = "";
    func setTradePSearchKeyword(keyword : String){
        m_sTradePSearchKeyword = keyword;
    }
    func getTradePSearchKeyword() -> String{
        return m_sTradePSearchKeyword;
    }
    private var m_sTradeMSearchKeyword : String = "";
    func setTradeMSearchKeyword(keyword : String){
        m_sTradeMSearchKeyword = keyword;
    }
    func getTradeMSearchKeyword() -> String{
        return m_sTradeMSearchKeyword;
    }
    private var m_nTradeSearchMemberMin : Int = 1;
    private var m_nTradeSearchMemberMax : Int = 100;
    func setTradeSearchMemberMinAndMax(f_nTradeSearchMemberMin : Int, f_nTradeSearchMemberMax : Int){
        self.m_nTradeSearchMemberMin = f_nTradeSearchMemberMin
        self.m_nTradeSearchMemberMax = f_nTradeSearchMemberMax
    }
    func getTradeSearchMemberMin() -> Int{
        return self.m_nTradeSearchMemberMin;
    }
    func getTradeSearchMemberMax() -> Int{
        return self.m_nTradeSearchMemberMax;
    }
    private var m_nTradeSearchMemberCheck : Bool = true;
    func setTradeSearchMemberCheck(f_nTradeSearchMemberCheck : Bool){
        self.m_nTradeSearchMemberCheck = f_nTradeSearchMemberCheck
    }
    func getTradeSearchMemberCheck() -> Bool{
        return self.m_nTradeSearchMemberCheck;
    }
    func TradeMSearchReset(){
        m_sTradeMSearchKeyword = "";
        m_nTradeSearchMemberMin = 1;
        m_nTradeSearchMemberMax = 100;
        m_nTradeSearchMemberCheck = true;
    }
    
    private var m_nTradeSearchProductMin : Int = 0;
    private var m_nTradeSearchProductMax : Int = 7;
    func setTradeSearchProductMinAndMax(f_nTradeSearchMemberMin : Int, f_nTradeSearchMemberMax : Int){
        self.m_nTradeSearchProductMin = f_nTradeSearchMemberMin
        self.m_nTradeSearchProductMax = f_nTradeSearchMemberMax
    }
    func getTradeSearchProductMin() -> Int{
        return self.m_nTradeSearchProductMin;
    }
    func getTradeSearchProductMax() -> Int{
        return self.m_nTradeSearchProductMax;
    }
    private var TradeSelProductCategory = Array<String>();
    func getTradeSelPCategory() -> Array<String>{
        return TradeSelProductCategory;
    }
    func setTradeSelPCategory(data : Array<String>){
        TradeSelProductCategory = data;
    }
    func TradePSearchReset(){
        m_sTradePSearchKeyword = "";
        m_nTradeSearchProductMin = 0;
        m_nTradeSearchProductMax = 7;
        TradeSelProductCategory = Array<String>();
    }
    
    //product list category
    private var SelProductCategoryTab = 0;
    func getSelPCategoryTab() -> Int{
        return SelProductCategoryTab;
    }
    func setSelPCategoryTab(tab : Int){
        SelProductCategoryTab = tab;
    }
    private var SelProductCategory = Array<String>();
    func getSelPCategory() -> Array<String>{
        return SelProductCategory;
    }
    func setSelPCategory(data : Array<String>){
        SelProductCategory = data;
    }
    
    private var ProductCategory = Array<[String]>();
    func setProductCategory(fProductCategory : [String]) {
        ProductCategory.append(fProductCategory);
    }
    func getProductCategory() -> Array<[String]>{
        return ProductCategory
    }
    
    private var BankList = Array<[String]>();
    func setBankList(fProductCategory : [String]) {
        BankList.append(fProductCategory);
    }
    func getBankList() -> Array<[String]>{
        return BankList
    }
    
    //inventory product filter
    private var SelInvenProductCategory = Array<String>();
    func getSelInvenPCategory() -> Array<String>{
        return SelInvenProductCategory;
    }
    func setSelInvenPCategory(data : Array<String>){
        SelInvenProductCategory = data;
    }
    
    var versionbuild: String? {
        guard let dictionary = Bundle.main.infoDictionary,
            let version = dictionary["CFBundleShortVersionString"] as? String,
            let build = dictionary["CFBundleVersion"] as? String else {return nil}
        
        let versionAndBuild: String = "\(version)(\(build))"
        return versionAndBuild
    }
    var version: String? {
        guard let dictionary = Bundle.main.infoDictionary,
            let version = dictionary["CFBundleShortVersionString"] as? String else {return nil}
            //let build = dictionary["CFBundleVersion"] as? String else {return nil}
        
        let versionAndBuild: String = "\(version)"
        return versionAndBuild
    }
    private var m_sFixUUID = "";
    func TAKUUIDKeyChainUUID(){
        //TAKUUID 라이브 러리를 사용 하여 키체인을 이용해 uuid 고정값으로 만들어서 쓰기
        //TAKUUIDStorage.sharedInstance().accessGroup = "com.random2u.app.ios"
        TAKUUIDStorage.sharedInstance().migrate()
        m_sFixUUID = TAKUUIDStorage.sharedInstance().findOrCreate() ?? ""
        print("TAKUUID : ",m_sFixUUID);
    }
    var deviceUUID: String? {
//        var fm_sUUID = "NONE";
//        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
//            fm_sUUID = uuid;
//        }
        //print("key : ", m_sFixUUID);
        return m_sFixUUID
    }
    
    private var g_TabbarIndex: Int = 0;
    func setTabbarIndex(TabbarIndex : Int){
        g_TabbarIndex = TabbarIndex;
    }
    func getTabbarIndex() -> Int{
        return g_TabbarIndex;
    }
    private var g_StartMain : StartMain?;
    func setStartMain(fStartMain : StartMain){
        g_StartMain = fStartMain
    }
    func getStartMain() -> StartMain?{
        return g_StartMain
    }
    
    private var g_TradeMain : TradeMain?;
    func setTradeMain(fTradeMain : TradeMain){
        g_TradeMain = fTradeMain
    }
    func getTradeMain() -> TradeMain?{
        return g_TradeMain
    }
    
    private var g_InventoryMain : InventoryMain?;
    func setInventoryMain(fInventoryMain : InventoryMain){
        g_InventoryMain = fInventoryMain
    }
    func getInventoryMain() -> InventoryMain?{
        return g_InventoryMain
    }
    
    private var g_CommunityMain : CommunityMain?;
    func setCommunityMain(fCommunityMain : CommunityMain){
        g_CommunityMain = fCommunityMain
    }
    func getCommunityMain() -> CommunityMain?{
        return g_CommunityMain
    }
    
    private var g_InventoryTabIdx: Int = -1;
    func setInventoryTabIdx(TabbarIndex : Int){
        g_InventoryTabIdx = TabbarIndex;
    }
    func getInventoryTabIdx() -> Int{
        return g_InventoryTabIdx;
    }
    
    private var g_TradeTabIdx: Int = -1;
    func setTradeTabIdx(TabbarIndex : Int){
        g_TradeTabIdx = TabbarIndex;
    }
    func getTradeTabIdx() -> Int{
        return g_TradeTabIdx;
    }
    
    private var g_ComueTabIdx: Int = -1;
    func setComueTabIdx(TabbarIndex : Int){
        g_ComueTabIdx = TabbarIndex;
    }
    func getComueTabIdx() -> Int{
        return g_ComueTabIdx;
    }
    
    //상품보관합에서 상품 선물하기 클릭한 seq 값 저장해놓고 친구한테 선물하기 했을때 미리 선택해주기
    private var _sProductGiftSeq: String = "";
    var m_sProductGiftSeq: String {
       get {
          return _sProductGiftSeq
       }
       set(data) {
        _sProductGiftSeq = data
       }
    }
        
}
//자주 쓰는거 복사 해서 쓸꺼
/*
 210 - 싱글톤 사용법 정리
 let location = Single.getSO()
 location.requestForLocation()
 */


/*
 //루트 메인화면 빼고 스택 다 없애기
 self.navigationController?.popToRootViewController( animated: true )
 
 //cell 내부에 textview 로 인해 클릭 이벤트가 안먹힐경우 textview 에 해당 처리를 해주면된다
 textview.isUserInteractionEnabled = false;
 
 
 //클로저
 vc1
 public var closeHandler: (()->())?//클로저
 
 vc2
 viewController.closeHandler = { ()-> Void in
     self.refresh();
 }
 
 //네비게이션 뒤로
 self.navigationController?.popViewController(animated: true);
 
 //화면 스택에 원하는곳으로 이동
 let fm_Contrllers = self.navigationController?.viewControllers
 if let val = fm_Contrllers{
     for VC in val{
         if VC is TradeStatusList {
             self.navigationController?.popToViewController(VC, animated: true)
         }
         
     }
 }
 
 //toast
 self.view.makeToast("회원가입 후 이용해주세요.")
 
 
 //텍스트 부분 색 변경
 uiUserLabel.TextPartColor(partstr: "아", Color: UIColor(rgb: 0x00BA87))
 
 //뷰 보더 처리
 self.uiUserProfileVIew.layer.addBorder([.top,.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
 
 //부분 라운드 치기
 uiCodeBtnPre.layer.roundCorners(corners: [.topLeft, .bottomLeft
 ], radius: 8.0)
 
 //버튼 밑줄긋기
 let attributedString = NSAttributedString(string: NSLocalizedString("자세히", comment: ""), attributes:[
     NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14.0),
     NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x999999),
     NSAttributedString.Key.underlineStyle:1.0
 ])
 servicebtn.setAttributedTitle(attributedString, for: .normal)
 
 //특정 부분만 밑줄
 let rangeToUnderLine = (원본텍스트 as NSString).range(of: "밑줄 그을부분")
 let underLineTxt = NSMutableAttributedString(string: alldata["data"]["state_txt"].stringValue, attributes: [:])
 underLineTxt.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: rangeToUnderLine)
 uiDeliStatus.attributedText = underLineTxt
 //특정부분에 색을 같이 넣고싶으면
 underLineTxt.addAttribute(.foregroundColor, value: UIColor.blue, range: (원본텍스트 as NSString).range(of: "색 변경할 부분 텍스트"))
 
 
 //버튼 라운드 보더
 uiOneMoreBtn.layer.cornerRadius = 20.0;
 uiCommBtn.layer.borderWidth = 1.0
 uiCommBtn.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
 
 //딜리게이트
 call
 protocol ClickBannerDelegate: class {
     func ClickEvent(type:Int, BannerCurrent:Int)
     func ClickFiltter(type:Int)
 }
 weak var m_tClickEvent: ClickBannerDelegate? = nil;
 if let event = m_tClickEvent{
     event.ClickFiltter(type: 2)
 }
 recv
 header.m_tClickEvent = self;
 extension StartMain: ClickBannerDelegate {
     func ClickEvent(type:Int, BannerCurrent:Int){
     
     }
 }
 
 //캐스팅
 m_saPushSeqs = UserDefaults.standard.array(forKey: Single.DE_PUSHLOCALSAVESEQ) as? [String] ?? [String]() //캐스팅및 예외처리 한꺼번에
 
 //뷰 의 높이를 줄이고 밑에 컴포넌트를 위로 자동으로 올리기
 private var uiPassChangeViewConstraint: NSLayoutConstraint?
 uiPassChangeViewConstraint = 높이 줄일 뷰.heightConstraint
 self.uiPassChangeViewConstraint?.constant = 0
 self.view.layoutIfNeeded()
//            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
//                        self.uiPassChangeViewConstraint?.constant = 0
//                        self.view.layoutIfNeeded()
//                    }, completion: nil).heightConstraint;
 
 //오토 레이아웃 코드로 높이 고정
 높이고정뷰.heightAnchor.constraint(equalToConstant:40).isActive = true;//40높이로 고정
 
 if let parentVC = self.parentViewController {
     parentVC.navigationController?.pushViewController(viewController, animated: true)
 }
 
 //현재 보고 있는 최상위 뷰 컨트롤러 가져오기
 //extentionC 에 정의 해놓음
 //UIWindow.key! 이것도 extentionC 에 정의
 let LastVController = UIWindow.key!.rootViewController!.topMostViewController()
 
 //gif
 //extention 에 UIImage 와 UIImageView 정의
 // An animated UIImage
 let Gif = UIImage.gif(name: "jerry")

 // A UIImageView with async loading
 let imageView = UIImageView()
 imageView.loadGif(name: "tom")]
 
 
 //현재 창닫고 바로 다른창 열기
 self.view.window?.rootViewController?.dismiss(animated: false, completion: {
 //                let Storyboard: UIStoryboard = UIStoryboard(name: "BoxOpenStep2", bundle: nil)
 //                let viewController = Storyboard.instantiateViewController(withIdentifier: "boxopenstep2idx") as! BoxOpenStep2
 //                viewController.setDate(boxtype: self.m_sBoxType, data: fm_ListData, subdata:fm_sSubData)
 //                //self.navigationController?.pushViewController(viewController, animated: true)
 //                viewController.modalPresentationStyle = .fullScreen
 //
 //              let appDelegate = UIApplication.shared.delegate as! AppDelegate
 //              appDelegate.window?.rootViewController?.present(viewController, animated: true, completion: nil)
 //            })
             
             guard let pvc = self.presentingViewController else { return }

             self.dismiss(animated: false) {
                 let Storyboard: UIStoryboard = UIStoryboard(name: "BoxOpenStep2", bundle: nil)
                 let viewController = Storyboard.instantiateViewController(withIdentifier: "boxopenstep2idx") as! BoxOpenStep2
                 viewController.setDate(boxtype: self.m_sBoxType, data: fm_ListData, subdata:fm_sSubData)
                 //self.navigationController?.pushViewController(viewController, animated: true)
                 viewController.modalPresentationStyle = .fullScreen
                 pvc.present(viewController, animated: false, completion: nil)
             }
 
 //레이블 이 텍스트 길이 에 맞게 사이즈를 자동 조절
 var label = UILabel()
 label.text = “It is test.”
 // 사이즈가 텍스트에 맞게 조절.
 label.sizeToFit()
 // 텍스트에 맞게 조절된 사이즈를 가져와 height만 fit하게 값을 조절.
 let newSize = label.sizeThatFits( CGSize(width: label.frame.width, height: CGFloat.greatestFiniteMagnitude))
 label.frame.height = newSize.height
 
 
 //넘버릭 키보드에 리턴,확인값넣기
 extentionC.swift -> textfield 에addDoneCancelToolbar 만들어놓음 
 @IBOutlet weak var myNumericTextField: UITextField! {
     didSet {
         myNumericTextField?.addDoneCancelToolbar(onDone: (target: self, action: #selector(doneButtonTappedForMyNumericTextField)))
     }
 }

 func doneButtonTappedForMyNumericTextField() {
     print("Done");
     myNumericTextField.resignFirstResponder()
 }
 
 //컴포넌트에 오토레이아웃이 잡혀있어서 frame 을 수정해도 위치나 크기가 수정되지 아닣을때
 //translatesAutoresizingMaskIntoConstraints 이걸 해주면 변경됨
 uiBodyView.translatesAutoresizingMaskIntoConstraints =  true;
 uiBodyView.frame = CGRect(x: uiBodyView.frame.minX, y: 29, width: uiBodyView.frame.width, height: uiBodyView.frame.height)

 
 //로딩
 LoadingHUD.show()
 LoadingHUD.hide()
 
 //해상도 넓이에맞게 배너 이미지같은 것들 높이도 유동적으로 넓이에 맞는 높이 계산
 let bounds = UIScreen.main.bounds
 let profilewidth = bounds.size.width
 m_nHeaderH = (profilewidth * (720/1440)
 720 = 실재 이미지 높이사이즈
 1440 = 실재 이미지 넓이 사이즈
 */
