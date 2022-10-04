//
//  BoxBuy.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/19.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import EzPopup
import SwiftyJSON
import FirebaseAnalytics
import AppsFlyerLib
protocol BoxBuyClickCellBtnDelegate: class {
    func ClickEvent(type:Int, data : [String:String])
    func getMainAllCloverMaxPrice() -> Int
    func getMainCuponMaxPrice() -> Int
    func HeaderSliderEvent(pageidx : Int)
}

class BoxBuy: VariousViewController {
    weak var m_tClickEvent: BoxBuyClickCellBtnDelegate? = nil;
    
    private let SO = Single.getSO();
    private let JS = JsonC();
    

    @IBOutlet weak var uiCollectionView: UICollectionView!
    @IBOutlet weak var uiBottomView: UIView!
    @IBOutlet weak var uiPriceTitlelb: UILabel!
    @IBOutlet weak var uiLastPrice: UILabel!
    @IBOutlet weak var uiPayBtn: UIButton!
    @IBOutlet weak var uiCheck: CircleCheckBoxBtn!
    @IBOutlet weak var uilb1: UILabel!
    @IBOutlet weak var uiBottomAgreeView: UIView!
    
    private var estimateWidth = 160.0
    private var cellMarginSize = 0.0
    
    private var m_sUserSeq : String = "";
    
    private var m_BoxBuyInfo = [String:String]();
    private var m_CuponListData = Array<[String:String]>();
    
    private var m_nStep2Height : CGFloat = 118;
    private var m_nStep3Height : CGFloat = 466;
    private var m_nStep4Height : CGFloat = 307;
    private var m_nStep5Height : CGFloat = 125;
    private var m_nStep6Height : CGFloat = 171;
    
    private var m_nStep2MaxPrice = 0;
    private var m_nRanCnt = 0;
    private var m_nEvenCnt = 0;
    private var m_nSelCuponPrice = 0;
    private var m_nSelCuponSeq = "";
    private var m_nUseClover = 0;
    private var m_sIsAgree = "0";
    private var m_isPayType = 0;
    
    private var m_nMaxLastPrice = 0;
    
    private var m_isStep4Slider = false;
    private var m_isStep5Slider = false;
    private var m_isStep6Slider = false;
    
    private var m_BoxBuy_Step1 : BoxBuy_Step1?
    private var m_BoxBuy_Step2 : BoxBuy_Step2?
    private var m_BoxBuy_Step3 : BoxBuy_Step3?
    
    private var m_Step3IndexPath : IndexPath?
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "랜덤박스 구매".localized)
        super.viewDidLoad()
        
        self.uiBottomAgreeView.layer.addBorder([.top,.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
        uilb1.text = "구매 조건 확인 및 결제 진행 동의".localized
        
        uiPriceTitlelb.text = "총 결제금액".localized;
        uiPayBtn.setTitle("박스결제하기".localized, for: .normal)
        
        m_sUserSeq = super.getUserSeq()
        
        self.uiBottomView.layer.addBorder([.top], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
        uiCollectionView.delegate = self;
        uiCollectionView.dataSource = self;
        
        let nib1 = UINib(nibName: "BoxBuy_Step1", bundle: nil)
        let nib2 = UINib(nibName: "BoxBuy_Step2", bundle: nil)
        let nib3 = UINib(nibName: "BoxBuy_Step3", bundle: nil)
        let nib4 = UINib(nibName: "BoxBuy_Step4", bundle: nil)
        let nib5 = UINib(nibName: "BoxBuy_Step5", bundle: nil)
        let nib6 = UINib(nibName: "BoxBuy_Step6", bundle: nil)
        let nib7 = UINib(nibName: "BoxBuy_Step7", bundle: nil)
        uiCollectionView.register(nib1, forCellWithReuseIdentifier: "BoxBuy_Step1idx")
        uiCollectionView.register(nib2, forCellWithReuseIdentifier: "BoxBuy_Step2idx")
        uiCollectionView.register(nib3, forCellWithReuseIdentifier: "BoxBuy_Step3idx")
        uiCollectionView.register(nib4, forCellWithReuseIdentifier: "BoxBuy_Step4idx")
        uiCollectionView.register(nib5, forCellWithReuseIdentifier: "BoxBuy_Step5idx")
        uiCollectionView.register(nib6, forCellWithReuseIdentifier: "BoxBuy_Step6idx")
        uiCollectionView.register(nib7, forCellWithReuseIdentifier: "BoxBuy_Step7idx")
        
        
        let flow = UICollectionViewFlowLayout()
        flow.sectionInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right:0)
        flow.scrollDirection = .vertical;
        flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
        
        uiCollectionView.collectionViewLayout = flow

        BoxbuyInfo();
        //FacebbokBoxBuyAnalytics(params: [:])
    }
    func BoxbuyInfo(){
        LoadingHUD.show()
        JS.getUserPurchaseSummary(param: ["account_seq":m_sUserSeq], callbackf: getUserPurchaseSummaryCallback)
    }
    func getUserPurchaseSummaryCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            m_BoxBuyInfo["eventbox_open"] = alldata["data"]["eventbox_open"].stringValue
            m_BoxBuyInfo["eventbox_price"] = alldata["data"]["eventbox_price"].stringValue
            m_BoxBuyInfo["eventbox_remain_cnt"] = alldata["data"]["eventbox_remain_cnt"].stringValue
            m_BoxBuyInfo["point"] = alldata["data"]["point"].stringValue
            m_BoxBuyInfo["randombox_remain_cnt"] = alldata["data"]["randombox_remain_cnt"].stringValue
            
            for subd in alldata["data"]["data_arr"].arrayValue {
                var cuponitem = [String:String]()
                cuponitem["title"] = subd["title"].stringValue;
                cuponitem["discount_price"] = subd["discount_price"].stringValue;
                cuponitem["usage_start_date"] = subd["usage_start_date"].stringValue;
                cuponitem["usage_end_date"] = subd["usage_end_date"].stringValue;
                cuponitem["coupon_seq"] = subd["coupon_seq"].stringValue;
                cuponitem["account_coupon_seq"] = subd["account_coupon_seq"].stringValue;
                m_CuponListData.append(cuponitem)
            }
            if m_BoxBuyInfo["eventbox_open"] == "0" {
                m_nStep2Height = 118;
            }else{
                m_nStep2Height = 118;
            }
            
            uiCollectionView.reloadData();
        }
        LoadingHUD.hide()
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
                uiPayBtn.frame = CGRect(x: 0, y: Int(uiPayBtn.frame.minY), width: Int(uiPayBtn.frame.size.width), height: Int(uiPayBtn.frame.size.height + bottomPadding))
                uiPayBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
            }

        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    @IBAction func onAcc(_ sender: Any) {
        m_sIsAgree = (!uiCheck.isChecked ? "0" : "1")
        if m_isPayType == 3 && SO.getUserInfoKey(key: Single.DE_USERVERIFIED) == "0"{
            MessagePop(title : "본인인증".localized, msg: "본인인증 하시겠습니까?".localized, ostuch:false, lbtn: "취소".localized, rbtn: "본인인증".localized,succallbackf: { ()-> Void in
                //self.navigationController?.popViewController(animated: true);
                let Storyboard: UIStoryboard = UIStoryboard(name: "UserVerification", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "UserVerificationidx") as! UserVerification
                viewController.setData(data: ["os_type":Single.DE_PLATFORMIDX, "account_seq":super.getUserSeq()])
                self.navigationController?.pushViewController(viewController, animated: true)
            }, closecallbackf: { ()-> Void in
                //self.navigationController?.popViewController(animated: true);
            })
            return;
        }else if m_sIsAgree == "0" {
            MessagePop(title : "안내".localized, msg: "동의후 박스구매 해주세요.".localized, btntype: 2)
            return;
        }else if m_nRanCnt == 0 && m_nEvenCnt == 0 {
            MessagePop(title : "안내".localized, msg: "박스 수량을 선택해주세요.".localized, btntype: 2)
            return;
        }else if m_nMaxLastPrice < 0 {
            MessagePop(title : "안내".localized, msg: "결제금액 보다 많은 쿠폰 또는 클로버를 사용할수없습니다.".localized, btntype: 2)
            return;
        }
        let Storyboard: UIStoryboard = UIStoryboard(name: "BoxBuyPayWeb", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "BoxBuyPayWebidx") as! BoxBuyPayWeb
        viewController.m_tClickEvent = self;
        var data = [String : String]()
        data["account_seq"] = m_sUserSeq
        data["total_price"] = String(m_nMaxLastPrice)
        data["total_price_origin"] = String(m_nStep2MaxPrice)
        data["point"] = String(m_nUseClover)
        data["payment_method"] = String(m_isPayType + 1)
        data["coupon"] = String(m_nSelCuponPrice)
        data["account_coupon_seq"] = m_nSelCuponSeq
        data["random_box_cnt"] = String(m_nRanCnt)
        data["event_box_cnt"] = String(m_nEvenCnt)
        viewController.setData(data: data)
        viewController.modalPresentationStyle = .fullScreen
        //viewController.m_tClickEvent = m_tClickEvent
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
extension BoxBuy:  UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BoxBuy_Step1idx", for: indexPath) as!
                BoxBuy_Step1;
            cell.m_tClickEvent = self;
            cell.setData(data: m_BoxBuyInfo);
            m_BoxBuy_Step1 = cell;
            return cell;
        }else if indexPath.row == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BoxBuy_Step2idx", for: indexPath) as! BoxBuy_Step2;
            cell.m_tClickEvent = self;
            cell.setData(data: m_BoxBuyInfo)
            m_BoxBuy_Step2 = cell;
            return cell;
        }else if indexPath.row == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BoxBuy_Step3idx", for: indexPath) as! BoxBuy_Step3;
            cell.m_tClickEvent = self;
            cell.setData(data: m_BoxBuyInfo, cupons: m_CuponListData)
            m_BoxBuy_Step3 = cell;
            m_Step3IndexPath = indexPath
            return cell;
        }else if indexPath.row == 3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BoxBuy_Step4idx", for: indexPath) as! BoxBuy_Step4;
            cell.m_tClickEvent = self;
            cell.setData(isSlider: m_isStep4Slider)
            return cell;
        }else if indexPath.row == 4 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BoxBuy_Step5idx", for: indexPath) as! BoxBuy_Step5;
            cell.m_tClickEvent = self;
            cell.setData(isSlider: m_isStep5Slider)
            return cell;
        }else if indexPath.row == 5 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BoxBuy_Step6idx", for: indexPath) as! BoxBuy_Step6;
            cell.m_tClickEvent = self;
            cell.setData(isSlider: m_isStep6Slider)
            return cell;
        }
//        else if indexPath.row == 6 {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BoxBuy_Step7idx", for: indexPath) as! BoxBuy_Step7;
//            cell.m_tClickEvent = self;
//            return cell;
//        }
        return collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCellidx", for: indexPath) as! ProductCell;
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.view.endEditing(true)
    }
    
}
extension BoxBuy: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        var fm_nHeight : CGFloat = 100;
        if indexPath.row == 0 {
            let bounds = UIScreen.main.bounds
            let profilewidth = bounds.size.width
            let fm_nHeaderH = (profilewidth * (1440/1440));
            fm_nHeight = fm_nHeaderH;
        }else if indexPath.row == 1 {
            fm_nHeight = m_nStep2Height;
        }else if indexPath.row == 2 {
            fm_nHeight = m_nStep3Height;
        }else if indexPath.row == 3 {//slide
            fm_nHeight = m_nStep4Height;
        }else if indexPath.row == 4 {//slide
            fm_nHeight = m_nStep5Height;
        }else if indexPath.row == 5 {//slide
            fm_nHeight = m_nStep6Height;
        }else if indexPath.row == 6 {
            fm_nHeight = 61;
        }
        return CGSize(width: width, height: fm_nHeight)
        
    }
    func calculateWith() -> CGFloat {
        let estimatedWidth = CGFloat(self.view.frame.size.width)
        let cellCount = floor(CGFloat(self.view.frame.size.width / estimatedWidth))
        
        let margin = CGFloat(cellMarginSize * 2)
        let width = (self.view.frame.size.width - CGFloat(cellMarginSize) * (cellCount - 1) - margin) / cellCount
        
        return width
    }
}
extension BoxBuy : BoxBuyClickCellBtnDelegate{
    func HeaderSliderEvent(pageidx : Int) {
        //MARK: 헤더에서 슬라이드 했을경우 페이지 번호를 일로 전달 하게 했음
        if pageidx == 0 {
            m_nStep3Height = 466;
        }else if pageidx == 1 {
            m_nStep3Height = 110;
        }
        m_BoxBuy_Step2?.PageSlideChanged(pageidx: pageidx)
        m_BoxBuy_Step3?.PageSlideChanged(pageidx: pageidx)
        if m_BoxBuyInfo.count == 0 {
            uiCollectionView.reloadData();
        }else{
            if let indexpath = m_Step3IndexPath{
                //reloadData 를 할경우 메모리낭비가 심하지만 reloadItems 이 걸로 업데이트 하고싶은 셀만 업데이트 하면 메모리 누수를 잡을수있음
                uiCollectionView.reloadItems(at: [IndexPath(item: indexpath.item, section: indexpath.section)])
            }
        }
    }
    func getMainCuponMaxPrice() -> Int {
        return m_nStep2MaxPrice;
    }
    
    func getMainAllCloverMaxPrice() -> Int {
        return m_nStep2MaxPrice - m_nSelCuponPrice;
    }
    
    func ClickEvent(type:Int, data : [String:String]){
        if type == 1 {
            //랜덤박스 리스트
            BoxList(type: "1")
        }else if type == 2 {
            //이벤트박스 리스트
            BoxList(type: "2")
        }else if type == 3 {
            //스탭2 에서 계산된 금액
            m_nRanCnt = Int(data["rancnt"] ?? "0") ?? 0
            m_nEvenCnt = Int(data["evencnt"] ?? "0") ?? 0
            m_nStep2MaxPrice = Int(data["cntprice"] ?? "0") ?? 0
            CalcMaxPrice();
        }else if type == 4 {
            MessagePop(title : "클로버 사용".localized, msg: "클로버는 1개당 1원 가치의 랜덤투유 포인트입니다.\n랜덤박스 및 배송비 결제 시 사용가능합니다.".localized, btntype: 2)
        }else if type == 5 {
            //쿠폰, 클로버 사용
            m_nUseClover = Int(data["usepoint"] ?? "0") ?? 0
            m_nSelCuponSeq = data["cuponseq"] ?? "";
            m_nSelCuponPrice = Int(data["cuponprice"] ?? "0") ?? 0
            m_isPayType = Int(data["PayType"] ?? "0") ?? 0
            CalcMaxPrice();
        }else if type == 6 {
            //스탭4 슬라이드
            if m_isStep4Slider {
                m_nStep4Height = 307
                m_isStep4Slider = false;
            }else{
                m_nStep4Height = 140
                m_isStep4Slider = true;
            }
            uiCollectionView.reloadData();
        }else if type == 7 {
            //스탭5 슬라이드
            if m_isStep5Slider {
                m_nStep5Height = 125;
                m_isStep5Slider = false;
            }else{
                m_nStep5Height = 50;
                m_isStep5Slider = true;
            }
            uiCollectionView.reloadData();
        }else if type == 8 {
            //스탭6 슬라이드
            if m_isStep6Slider {
                m_nStep6Height = 171;
                m_isStep6Slider = false;
            }else{
                m_nStep6Height = 55;
                m_isStep6Slider = true;
            }
            uiCollectionView.reloadData();
        }else if type == 9 {
            //동의
            m_sIsAgree = data["isAgree"] ?? "0"
        }else if type == 10 {
            //결제 완료
            let fm_nRPrice = (Int(data["random_box_cnt"] ?? "0") ?? 0) * 10000;
            let fm_nEPrice = (Int(data["event_box_cnt"] ?? "0") ?? 0) * (Int(m_BoxBuyInfo["eventbox_price"] ?? "0") ?? 0);
            let fm_nRCnt = (Int(data["random_box_cnt"] ?? "0") ?? 0)
            let fm_nECnt = (Int(data["event_box_cnt"] ?? "0") ?? 0)
            //MARK: 파이어 베이스 구매 추적
            let paramsgB : [String: Any] = [
                FirebaseAnalytics.AnalyticsParameterValue : Double((fm_nRPrice + fm_nEPrice))
                //,FirebaseAnalytics.AnalyticsParameterItems : "\((fm_nRCnt + fm_nECnt))"
                ,FirebaseAnalytics.AnalyticsParameterCurrency : Single.DE_CURRENCY
                //,FirebaseAnalytics.AnalyticsParameterQuantity : "\((fm_nRCnt + fm_nECnt))"
                ,FirebaseAnalytics.AnalyticsParameterTransactionID : "\(data["purchase_seq"] ?? "0")"
                ,FirebaseAnalytics.AnalyticsParameterCoupon : "\(data["account_coupon_seq"] ?? "0")"
                
            ];
            var paramsgfP : [String: Any] = [
                FirebaseAnalytics.AnalyticsParameterValue : Double((fm_nRPrice + fm_nEPrice))
                //,FirebaseAnalytics.AnalyticsParameterItems : "\((fm_nRCnt + fm_nECnt))"
                ,FirebaseAnalytics.AnalyticsParameterCurrency : Single.DE_CURRENCY
                //,FirebaseAnalytics.AnalyticsParameterQuantity : "\((fm_nRCnt + fm_nECnt))"
                ,FirebaseAnalytics.AnalyticsParameterTransactionID : "\(data["purchase_seq"] ?? "0")"
                ,FirebaseAnalytics.AnalyticsParameterCoupon : "\(data["account_coupon_seq"] ?? "0")"
                
            ];
            let boxItem: [String: Any] = [
              AnalyticsParameterItemID: "\(data["purchase_seq"] ?? "0")-\(data["account_seq"] ?? "0")",
              AnalyticsParameterItemName: "box",
              AnalyticsParameterItemCategory: "box",
              AnalyticsParameterItemVariant: "black",
              AnalyticsParameterItemBrand: "ran2u",
              AnalyticsParameterPrice: Double((fm_nRPrice + fm_nEPrice)),
            ]
            paramsgfP[AnalyticsParameterItems] = [boxItem]
            FirebaseBoxBuyAnalytics(paramsP: paramsgfP, paramsB: paramsgB)
            
            //MARK: 페이스북 구매 추적
            let paramsFb : [String: Any] = [
                "randomboxcnt":data["random_box_cnt"] ?? "0"
                ,"eventboxcnt":data["event_box_cnt"] ?? "0"
                ,"randomboxprice":"\(fm_nRPrice)"
                ,"eventboxprice":"\(fm_nEPrice)"
                ,"totalboxprice":"\((fm_nRPrice + fm_nEPrice))"
                ,"totalboxcnt":"\((fm_nRCnt + fm_nECnt))"
                ,"clover":data["point"] ?? "0"
                ,"cuponprice":data["coupon"] ?? "0"
                ,"cuponseq":data["account_coupon_seq"] ?? "0"
                ,"userseq":data["account_seq"] ?? "0"
                ,"payseq":data["purchase_seq"] ?? "0"
                ,"paymethod":data["payment_method"] ?? "0"
                
            ];
            FacebbokBoxBuyAnalytics(params: paramsFb)
            
            let fm_nAFPGPrice = Int(fm_nRPrice + fm_nEPrice) - (Int(data["point"] ?? "0") ?? 0) - (Int(data["coupon"] ?? "0") ?? 0);
            let paramsAF : [String: Any] = [
                AFEventParamReceiptId:data["purchase_seq"] ?? "0",
                AFEventParamContentType : fm_nRCnt > 0 ? "random_box" : "event_box",
                AFEventParamRevenue: "\(fm_nAFPGPrice)",
                AFEventParamCurrency:Single.DE_CURRENCY,
                AFEventParamQuantity:"\((fm_nRCnt + fm_nECnt))",
                AFEventParamPrice:fm_nRCnt > 0 ? "10000" : m_BoxBuyInfo["eventbox_price"] ?? "0",
                "af_clover_used" : data["point"] ?? "0",
                "af_coupon_used" : data["coupon"] ?? "0"
            ];
            AppsflyerLog(AFTitle: "purchase", params: paramsAF)
            AppsFlyerLib.shared().logEvent(AFEventPurchase , withValues: paramsAF)
        }else if type == 11 {
            MessagePop(title : "안내".localized, msg: "이벤트박스는 클로버로만 구입 가능 합니다.".localized, btntype: 2)
        }
        
    }
    func CalcMaxPrice(){
        m_nMaxLastPrice = m_nStep2MaxPrice - m_nSelCuponPrice - m_nUseClover;
        uiLastPrice.text = "원".localized(txt: "\(String(m_nMaxLastPrice).DecimalWon())");
        if m_nMaxLastPrice <= 0 {
            m_BoxBuy_Step3?.PayBtnEnabel(isB: false)
        }else{
            m_BoxBuy_Step3?.PayBtnEnabel(isB: true)
        }
    }
    func BoxList(type : String){
        let m_tWRP = BoxProductListPop.instantiate()
        guard let customAlertVC = m_tWRP else { return }
        m_tWRP?.setData(type: type)
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
        
        self.present(popupVC, animated: true, completion: nil)
    }
}
