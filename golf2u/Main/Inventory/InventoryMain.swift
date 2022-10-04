//
//  InventoryMain.swift
//  golf2u
//
//  Created by 이원영 on 2020/10/21.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import EzPopup
import SwiftyJSON
import AppsFlyerLib

protocol InventoryMainClickCellBtnDelegate: class {
    func ClickEvent(viewtype : Int, type:Int, data : [String:String])
    func ClickEvent(viewtype : Int, type:Int, data : [String:Any])
    func ClickEvent(viewtype : Int, type:Int, data : [String])
    func ClickEvent(viewtype : Int, type:Int, data : [String:String], indexpath : IndexPath)
}

class InventoryMain: VariousViewController {
    private let SO = Single.getSO();
    private let JS = JsonC();
    
    @IBOutlet weak var uiToptabView: ReportCustomSegmentedControl!{
        didSet{
            uiToptabView.setButtonTitles(buttonTitles: ["박스 보관함".localized,"상품 보관함".localized, "선물함".localized])
            uiToptabView.selectorViewColor = UIColor(rgb: 0x00BA87)
            uiToptabView.selectorTextColor = UIColor(rgb: 0x00BA87)
            uiToptabView.textColor = .black
            uiToptabView.backgroundColor = .white
        }
    }
    @IBOutlet weak var uiContentsView: UIView!
    @IBOutlet weak var uiBoxBuyView: UIView!
    @IBOutlet weak var uiBoxBuyBtn: UIButton!
    @IBOutlet weak var uiBoxBuyImg: UIImageView!
    
    private var m_nSelMenu = 0;
    
    private var m_BoxInvenView : BoxInven?;
    private var m_ProductInvenView : ProductInven?;
    private var m_GiftInvenView : GiftInven?;
    
    private var m_CViewLayout = [NSLayoutConstraint]();
    
    private var m_GiftInvenCode : GiftInvenCode?
    
    private var m_IndexPath : IndexPath?
    
    private var m_PayCancelData : [String:String]?
    private var m_CloverReturnData : [String: String]?
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVIMAINNONELOGOINTITLE, title: "인벤토리".localized)
        super.viewDidLoad()
        
        SO.setInventoryMain(fInventoryMain: self)
        
        uiToptabView.delegate = self;
                
        let Boxgradi = CAGradientLayer()
        Boxgradi.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: uiBoxBuyView.frame.height);
        Boxgradi.colors = [UIColor(rgb: 0x00BA87).cgColor, UIColor(rgb: 0x00BA87).cgColor]
        Boxgradi.startPoint = CGPoint(x: 0, y: 0.5)
        Boxgradi.endPoint = CGPoint(x: 1, y: 0.5)
        
        uiBoxBuyView.layer.addSublayer(Boxgradi)
        uiBoxBuyBtn.layer.zPosition = 9999;
        uiBoxBuyImg.layer.zPosition = 9998;
        uiBoxBuyBtn.setTitle("랜덤박스 구매하기".localized, for: .normal)
        
        uiBoxBuyView.layoutIfNeeded()
        uiBoxBuyView.layer.roundedLaout(corneridx : 15, points: [.topLeft, .topRight]);
        
        
        InitInventoryMainSubView()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if super.getUserSeq() == "" {
            self.tabBarController?.selectedIndex = 0;
            SO.setTabbarIndex(TabbarIndex: 0)
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                //탭 인덱스가 화면 로딩후 바로 안떠서 0.3초 정도 딜레이 주고 바꿈
                //앱 첫시작하고 인벤토리를 한번도 안누르면 탭 객체가 없기때문에 인벤토리 이동후
                //해당 생명주기 함수에서 0.3초 정도있다가 싱글톤에 값을 보고 탭을 바꿔줌
                self.goTabIndexCalc();
            }
            
        }
    }
    func setContentsView(uiView : UIView){
        if m_CViewLayout.count > 0 {
            //기존에 적용되어있던 레이아웃이 있으면 삭제
            NSLayoutConstraint.deactivate(m_CViewLayout)
        }
        uiContentsView.translatesAutoresizingMaskIntoConstraints = false
        
        let leadingCons = uiContentsView.topAnchor.constraint(equalTo: uiToptabView.bottomAnchor,constant: 2)
        let trailingCons = uiContentsView.leftAnchor.constraint(equalTo:self.view.leftAnchor,constant: 0)
        let topCons = uiContentsView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0)
        var bottomCons : NSLayoutConstraint?
        if m_nSelMenu == 0 {
            bottomCons = uiContentsView.bottomAnchor.constraint(equalTo: self.uiBoxBuyView.topAnchor, constant: 0)
        }else{
            bottomCons = uiContentsView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        }
        m_CViewLayout = [leadingCons, trailingCons, topCons, bottomCons!]
        //새로운 레이아웃 적용
        NSLayoutConstraint.activate(m_CViewLayout)
        
        self.uiContentsView.addSubview(uiView)
        
        uiView.translatesAutoresizingMaskIntoConstraints = false
        uiView.topAnchor.constraint(equalTo: uiContentsView.topAnchor,constant: 0).isActive = true
        uiView.leftAnchor.constraint(equalTo:uiContentsView.leftAnchor,constant: 0).isActive = true
        uiView.rightAnchor.constraint(equalTo: uiContentsView.rightAnchor, constant: 0).isActive = true
        uiView.bottomAnchor.constraint(equalTo: uiContentsView.bottomAnchor, constant: 0).isActive = true
    }
    @IBAction func onBoxBuyBtn(_ sender: Any) {
        BoxBuyView ()
    }
    func BoxBuyView (){
        let Storyboard: UIStoryboard = UIStoryboard(name: "BoxBuy", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "BoxBuyidx") as! BoxBuy
        viewController.m_tClickEvent = self;
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    func InitInventoryMainSubView(){
        for v in uiContentsView.subviews{
            v.removeFromSuperview()
        }
        m_BoxInvenView = BoxInven(frame: self.uiContentsView.bounds)
        m_ProductInvenView = ProductInven(frame: self.uiContentsView.bounds)
        m_GiftInvenView = GiftInven(frame: self.uiContentsView.bounds)
        
        m_BoxInvenView?.m_tClickEvent = self;
        m_ProductInvenView?.m_tClickEvent = self;
        m_GiftInvenView?.m_tClickEvent = self;
        
        
        setContentsView(uiView: m_BoxInvenView!);
    }
    func ViewRefrashEvent(){
        if m_nSelMenu == 0 {
            m_BoxInvenView?.refresh();
        }else if m_nSelMenu == 1 {
            m_ProductInvenView?.refresh();
        }else if m_nSelMenu == 2 {
            m_GiftInvenView?.refresh();
        }
    }
    func goTabIndexCalc(){
        if SO.getInventoryTabIdx() == 0 {
            goToBoxInven()
        }else if SO.getInventoryTabIdx() == 1 {
            goToProductInven()
        }else if SO.getInventoryTabIdx() == 2 {
            goToGiftInven()
        }
        SO.setInventoryTabIdx(TabbarIndex: -1)
    }
    func goToBoxInven(){
        m_nSelMenu = 0;
        m_BoxInvenView?.refresh();
        self.uiToptabView.setIndex(index: m_nSelMenu)
        ChnageView()
    }
    func goToProductInven(){
        m_nSelMenu = 1;
        m_ProductInvenView?.refresh();
        self.uiToptabView.setIndex(index: m_nSelMenu)
        ChnageView()
    }
    func goToGiftInven(){
        m_nSelMenu = 2;
        m_GiftInvenView?.refresh();
        self.uiToptabView.setIndex(index: m_nSelMenu)
        ChnageView()
    }
    func ChnageView(){
        for v in uiContentsView.subviews{
            v.removeFromSuperview()
        }
        if m_nSelMenu == 0 {
            uiBoxBuyView.isHidden = false
            setContentsView(uiView: m_BoxInvenView!);
            m_BoxInvenView?.refresh()
        }else if m_nSelMenu == 1 {
            uiBoxBuyView.isHidden = true
            setContentsView(uiView: m_ProductInvenView!);
            m_ProductInvenView?.refresh()
        }else if m_nSelMenu == 2 {
            uiBoxBuyView.isHidden = true
            setContentsView(uiView: m_GiftInvenView!);
            m_GiftInvenView?.refresh()
            self.UserVerify();
        }
    }
    func UserVerify(){
        if SO.getUserInfoKey(key: Single.DE_USERVERIFIED) == "0" {
            MessagePop(title : "본인인증".localized, msg: "본인인증 후 사용하실수있습니다.".localized, ostuch:false, lbtn: "취소".localized, rbtn: "본인인증".localized,succallbackf: { ()-> Void in
                self.m_nSelMenu = 0;
                self.uiToptabView.setIndex(index: self.m_nSelMenu)
                self.ChnageView()
                let Storyboard: UIStoryboard = UIStoryboard(name: "UserVerification", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "UserVerificationidx") as! UserVerification
                viewController.setData(data: ["os_type":Single.DE_PLATFORMIDX, "account_seq":super.getUserSeq()])
                self.navigationController?.pushViewController(viewController, animated: true)
            }, closecallbackf: { ()-> Void in
                self.m_nSelMenu = 0;
                self.uiToptabView.setIndex(index: self.m_nSelMenu)
                self.ChnageView()
            })
            
        }
    }
    func ProductFiltterPopupOpen(){
        let m_tWRP = ProductFilterPop.instantiate()
        guard let customAlertVC = m_tWRP else { return }
        customAlertVC.SaveHandler = {
            self.ViewRefrashEvent();
        }
        let popupVC = PopupViewController(contentController: customAlertVC, popupWidth: 340, popupHeight: 276)
        popupVC.backgroundAlpha = 0.3
        popupVC.backgroundColor = .black
        popupVC.canTapOutsideToDismiss = true
        popupVC.cornerRadius = 10
        popupVC.shadowEnabled = false
        present(popupVC, animated: true, completion: nil)
    }
}
extension InventoryMain : ReportCustomSegmentedControlDelegate{
    func changeToIndex(index: Int) {
        if m_nSelMenu == index{
            return;
        }
        m_nSelMenu = index;
        ChnageView();
    }
    
}
extension InventoryMain: InventoryMainClickCellBtnDelegate {
    func ClickEvent(viewtype: Int, type: Int, data: [String : Any]) {
        if type == 10 {
            //배송신청 결제 완료됬을경우만 이쪽으로 콜백
            let params : [String: Any] = [
                "userseq":super.getUserSeq()
                ,"payInfos":data
                
            ];
            Analytics(eventname: "deliverysucc", params: params)
            
            
            let paramsAF : [String: Any] = [
                AFEventParamReceiptId : data["deliseq"] ?? "",
                "af_product_id" : data["my_product_seqs"] ?? "",
                "af_delivery_fee" : data["delivery_price_origin"] ?? "0"
            ];
            AppsflyerLog(AFTitle: "af_delivery_order", params: paramsAF)
            
            //m_ProductInvenView?.DeliveryPayAcc(indexpath : m_IndexPath!);
            m_ProductInvenView?.refresh()
        }
    }
    
    func ClickEvent(viewtype : Int, type:Int, data : [String:String], indexpath : IndexPath){
        if viewtype == 1{
            if type == 2{
                //상품보관함 에서 선물하기
                SO.m_sProductGiftSeq = data["my_product_seq"]!;
                m_IndexPath = indexpath;
                let Storyboard: UIStoryboard = UIStoryboard(name: "GiftCode", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "GiftCodeidx") as! GiftCode
                viewController.setData(type: 3, data: data)
                self.navigationController?.pushViewController(viewController, animated: true)
            }else if type == 3{
                //마켓 등록 페이지로
                m_IndexPath = indexpath;
                if data["is_market_reged"] == "1" {
                    MessagePop(title : "마켓등록 취소".localized, msg: "마켓등록을 취소 하시겠습니까?".localized, lbtn: "취소".localized, rbtn: "확인".localized,succallbackf: { ()-> Void in
                        LoadingHUD.show()
                        self.JS.ProductMarketDel(param: ["my_product_seq":data["my_product_seq"]!,"account_seq":super.getUserSeq()], callbackf: self.ProductMarketDelCallback)
                    }, closecallbackf: { ()-> Void in
                        
                    })
                }else{
//                    let Storyboard: UIStoryboard = UIStoryboard(name: "MarketAdd", bundle: nil)
//                    let viewController = Storyboard.instantiateViewController(withIdentifier: "MarketAddidx") as! MarketAdd
//                    viewController.setData(data: data)
//                    viewController.m_tClickEvent = self;
//                    self.navigationController?.pushViewController(viewController, animated: true)
                    
                    MessagePop(title : "마켓 등록".localized, msg: "해당 상품을 마켓에 등록하시겠습니까?".localized, lbtn: "취소".localized, rbtn: "등록".localized,succallbackf: { ()-> Void in
                        LoadingHUD.show();
                        self.JS.ProductMarketAdd(param: ["my_product_seq":data["my_product_seq"] ?? "","account_seq":super.getUserSeq(),"comment":""], callbackf: self.ProductMarketAddCallback);
                    }, closecallbackf: { ()-> Void in
                        
                    })
                }
            }else if type == 4{
                //클로버 환급
                m_IndexPath = indexpath;
                MessagePop(title : "클로버 환급".localized, msg: "선택하신 상품이 클로버로\n환급 됩니다. 환급하시겠습니까?".localized(txt: "\(data["point_payback_current"]!)"), lbtn: "취소".localized, rbtn: "확인".localized,succallbackf: { ()-> Void in
                    LoadingHUD.show()
                    self.m_CloverReturnData = data
                    self.JS.CloverReturn(param: ["my_product_seq":data["my_product_seq"]!,"account_seq":super.getUserSeq()], callbackf: self.CloverReturnCallback)
                }, closecallbackf: { ()-> Void in
                    
                })
            }else if type == 5{
                //배송 신청 화면으로
                m_IndexPath = indexpath;
                if data["delivery_possible"] == "0" {
                    MessagePop(title : "안내".localized, msg: "배송신청이 불가능한 상품입니다. 고객센터로 문의주시기 바랍니다.".localized, btntype: 2)
                    return;
                }
                if data["is_digital_item"] == "1" {
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
                        MessagePop(title : "디지털 상품 안내".localized, msg: "디지털 상품은 SMS로 전송됩니다.".localized, lbtn: "취소".localized, rbtn: "확인".localized,succallbackf: { ()-> Void in
                            LoadingHUD.show()
                            self.JS.getMyProductGifticon(param: ["my_product_seq":data["my_product_seq"]!,"account_seq":super.getUserSeq()], callbackf: self.getMyProductGifticonCallback)
                        }, closecallbackf: { ()-> Void in
                            
                        })
                    }
                }else{
                    let Storyboard: UIStoryboard = UIStoryboard(name: "DeliveryApply", bundle: nil)
                    let viewController = Storyboard.instantiateViewController(withIdentifier: "DeliveryApplyidx") as! DeliveryApply
                    viewController.setData(data: data)
                    viewController.m_tClickEvent = self;
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
            }
        }
    }
    func ClickEvent(viewtype : Int, type:Int, data : [String:String]){
        if viewtype == 1{
            if type == 1{
                //상품 상세보기
                let Storyboard: UIStoryboard = UIStoryboard(name: "ProductDetail", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "productdetailide") as! ProductDetailNew
                viewController.InitSetting(seq: data["product_seq"]!);
                self.navigationController?.pushViewController(viewController, animated: true)
            }else if type == 7 {
                //코드입력 화면으로
                let Storyboard: UIStoryboard = UIStoryboard(name: "GiftInvenCode", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "GiftInvenCodeidx") as! GiftInvenCode
                viewController.m_tClickEvent = self;
                m_GiftInvenCode = viewController
                self.navigationController?.pushViewController(viewController, animated: true)
            }else if type == 11 {
                //상품상세
                
                if data["seq"] == "0" {
                    return;
                }
                let Storyboard: UIStoryboard = UIStoryboard(name: "ProductDetail", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "productdetailide") as! ProductDetailNew
                viewController.InitSetting(seq: data["seq"] ?? "0");
                self.navigationController?.pushViewController(viewController, animated: true)
            }else if type == 12 {
                //박스 취소
                MessagePop(title : "결제취소".localized, msg: "결제 취소 하시겠습니까?".localized, lbtn: "취소".localized, rbtn: "확인".localized,succallbackf: { ()-> Void in
                    LoadingHUD.show()
                    self.m_PayCancelData = data
                    self.JS.BoxBuyCancel(param: ["account_seq":super.getUserSeq(), "random_box_seq":data["seq"]!], callbackf: self.BoxBuyCancelCallback)
                }, closecallbackf: { ()-> Void in
                    
                })
            }else if type == 13 {
                //선물함 에서 선택 이아닌 클릭시 
                if data["TabIndex"] == "0" && data["recv_state"] == "2"{
                    //받은 선물 탭에서 수령인 박스 또는 상품일 경우 클릭시 해당 보관함으로 이동
                    if data["random_box_seq"] != "0"{
                        goToBoxInven()
                    }else{
                        goToProductInven()
                    }
                }else if (data["code"] ?? "") != ""{
                    if data["random_box_seq"] != "0"{
                        let Storyboard: UIStoryboard = UIStoryboard(name: "GiftCode", bundle: nil)
                        let viewController = Storyboard.instantiateViewController(withIdentifier: "GiftCodeidx") as! GiftCode
                        viewController.setData(type: Int(data["type"] ?? "0") ?? 0, data: data, code: data["code"] ?? "")
                        self.navigationController?.pushViewController(viewController, animated: true)
                    }else{
                        let Storyboard: UIStoryboard = UIStoryboard(name: "GiftCode", bundle: nil)
                        let viewController = Storyboard.instantiateViewController(withIdentifier: "GiftCodeidx") as! GiftCode
                        viewController.setData(type: 3, data: data, code: data["code"] ?? "")
                        self.navigationController?.pushViewController(viewController, animated: true)
                    }
                }
            }else if type == 14 {
                ProductFiltterPopupOpen()
            }
        }
    }
    func ClickEvent(viewtype : Int, type:Int, data : [String]){
        if viewtype == 1 {
            if type == 6{
                //선물수령
                MessagePop(title : "선물 수령".localized, msg: "총 개의 선물을 선택하셨습니다.\n보관함으로 이동시키겠습니까?".localized(txt: "\(data.count)"), lbtn: "취소".localized, rbtn: "확인".localized,succallbackf: { ()-> Void in
                    LoadingHUD.show()
                    self.JS.takeGift(param: ["account_seq":super.getUserSeq(),"gift_seqs":data], callbackf: self.takeGiftCallback)
                }, closecallbackf: { ()-> Void in
                    self.m_GiftInvenView?.GiftRecvFinish()
                })
            }else if type == 8 {
                //코드입력완료
                LoadingHUD.show()
                self.JS.takeCodeGift(param: ["code":data[0],"account_seq":super.getUserSeq()], callbackf: self.takeCodeGiftCallback)
            }else if type == 9 {
                //마켓등록 완료
                LoadingHUD.show()
                self.JS.ProductMarketAdd(param: ["my_product_seq":data[0],"account_seq":super.getUserSeq(),"comment":data[1]], callbackf: ProductMarketAddCallback)
            }
        }
    }
    func BoxBuyCancelCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            super.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            MessagePop(msg: "결제가 취소되었습니다. (환불완료까지 최대 5 영업일이 소요됩니다.)".localized, btntype: 2)
            if let data = m_PayCancelData {
                let params : [String: Any] = [
                    "userseq":super.getUserSeq()
                    ,"payseq":data["purchase_seq"] ?? "0"
                    ,"paymethod":data["payment_method"] ?? "0"
                    ,"cancelprice":data["price"] ?? "0"
                    ,"cancelcupon":data["coupon"] ?? "0"
                    ,"cancelclover":data["point"] ?? "0"
                    ,"boxtype":data["type"] ?? "0"
                    
                ];
                SO.setUserInfoKey(key: Single.DE_USERCLOVER, value: alldata["data"]["point"].stringValue )
                Analytics(eventname: "boxbuycancel", params: params)
                
                let paramsAF : [String: Any] = [
                    AFEventParamReceiptId:data["purchase_seq"] ?? "0",
                    AFEventParamContentType : data["type"] == "1" ? "random_box" : "event_box",
                    AFEventParamRevenue: (Int(data["price"] ?? "0") ?? 0) * -1,
                    AFEventParamCurrency:Single.DE_CURRENCY,
                    //AFEventParamQuantity:"\((fm_nRCnt + fm_nECnt))",
                    //AFEventParamPrice:fm_nRCnt > 0 ? "10000" : m_BoxBuyInfo["eventbox_price"] ?? "0",
                    "af_clover_used" : data["point"] ?? "0",
                    "af_coupon_used" : data["coupon"] ?? "0"
                ];
                AppsflyerLog(AFTitle: "cancel_purchase", params: paramsAF)
            }
            ViewRefrashEvent();
        }
        LoadingHUD.hide()
    }
    func getMyProductGifticonCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            MessagePop(msg: alldata["errormessage"].stringValue, btntype : 2)
        }else{
            m_ProductInvenView?.DigiterDelivery(indexpath : m_IndexPath!);
        }
        LoadingHUD.hide()
    }
    func takeCodeGiftCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            MessagePop(msg: alldata["errormessage"].stringValue, btntype : 2)
        }else{
            MessagePop(title : "안내".localized, msg: "선물받기 완료.\n받으신 선물은 상품 or 박스 보관함에서\n확인바랍니다.".localized, lbtn: "확인".localized, rbtn: "보관함보기".localized,succallbackf: { [self] ()-> Void in
                m_GiftInvenCode?.AccViewDiss();
                if alldata["data"] == "0" {
                    goToBoxInven()
                }else if alldata["data"] == "1" {
                    goToProductInven()
                }
                
            }, closecallbackf: { [self] ()-> Void in
                m_GiftInvenCode?.AccViewDiss();
            })
        }
        m_GiftInvenCode?.GiftRecvFinish();
        LoadingHUD.hide()
    }
    func takeGiftCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
        }else{
            ViewRefrashEvent();
        }
        m_GiftInvenView?.GiftRecvFinish()
        LoadingHUD.hide()
    }
    func CloverReturnCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            MessagePop(msg: alldata["errormessage"].stringValue, btntype : 2)
        }else{
            if let data = m_CloverReturnData {
                let params : [String: Any] = [
                    "userseq":super.getUserSeq()
                    ,"payInfos":data
                    
                ];
                Analytics(eventname: "cloverreturnsucc", params: params)
                
                let paramsAF : [String: Any] = [
                    "af_clover_get" : alldata["data"]["refund_point"].stringValue,
                    "af_product_id" : data["product_seq"] ?? ""
                    //"af_product_category" : alldata["data"]["product_cnt"]
                ];
                AppsflyerLog(AFTitle: "af_clover_payback", params: paramsAF)
                
            }
            SO.setUserInfoKey(key: Single.DE_USERCLOVER, value: alldata["data"]["point"].stringValue )
            m_ProductInvenView?.CloverReturn(indexpath : m_IndexPath!);
            self.view.makeToast("클로버 환급이 완료되었습니다.".localized)
        }
        LoadingHUD.hide()
    }
    func ProductMarketDelCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            MessagePop(msg: alldata["errormessage"].stringValue, btntype : 2)
        }else{
            m_ProductInvenView?.MarketDel(indexpath : m_IndexPath!);
            
//            let date:Date = Date()
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//            let dateString:String = dateFormatter.string(from: date)
//            UserDefaults.standard.set(dateString, forKey: Single.DE_MARKETLIMITMINKEY)
        }
        LoadingHUD.hide()
    }
    func GiftFinishCallback(){
        m_ProductInvenView?.GiftReturn(indexpath : m_IndexPath!);
    }
    func DeliveryFinishCallback(){
        m_ProductInvenView?.DeliveryReturn(indexpath : m_IndexPath!);
    }
    func ProductMarketAddCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            MessagePop(msg: alldata["errormessage"].stringValue, btntype : 2)
        }else{
            m_ProductInvenView?.MarketAdd(indexpath : m_IndexPath!);
            
           
        }
        LoadingHUD.hide()
    }
}
extension InventoryMain:  BoxBuyClickCellBtnDelegate{
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
