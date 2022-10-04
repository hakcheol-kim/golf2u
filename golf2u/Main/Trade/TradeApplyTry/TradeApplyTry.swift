//
//  TradeApplyTry.swift
//  golf2u
//
//  Created by 이원영 on 2020/10/19.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON
import EzPopup
import AppsFlyerLib

class TradeApplyTry: VariousViewController {
    private var SO:Single = Single.getSO();
    private let JS = JsonC();
    private let UserInfoJS = JsonC();
    private let TopoJS = JsonC();
    private let BottomJS = JsonC();
    
    private var m_TopSelListData: Dictionary<String, [String:String]> = Dictionary<String, [String:String]>()
    private var m_BottomSelListData: Dictionary<String, [String:String]> = Dictionary<String, [String:String]>()
    private var m_TopListData = Array<[String:String]>();
    private var m_BottomListData = Array<[String:String]>();

    
    @IBOutlet weak var uiTopView: UIView!
    @IBOutlet weak var uiUserNameLabel: UILabel!
    @IBOutlet weak var uiUserPImg: UIImageView!
    @IBOutlet weak var uiTopInfoLabel: UILabel!
    @IBOutlet weak var uiTopCollectionView: UICollectionView!
    
    @IBOutlet weak var uiBottomView: UIView!
    @IBOutlet weak var uiBottomInfoLabel: UILabel!
    @IBOutlet weak var uiBottomCollectionView: UICollectionView!
    
    private var m_nTopPageNum = 0;
    private var m_nTopNextNum = 0;
    private var m_nTopDataCnt = 0;
    private var m_nBottomPageNum = 0;
    private var m_nBottomNextNum = 0;
    private var m_nBottomDataCnt = 0;
    private var estimateWidth = 160.0
    private var cellMarginSize = 11.0
    
    private var m_sSelUSeq : String = "";
    private var m_nViewType : Int = 0;
    @IBOutlet weak var uiBottomBtnView: UIView!
    
    @IBOutlet weak var uiMyTitlelb: UILabel!
    
    @IBOutlet var uiTradeApplyTryBtn: UIView!
    @IBOutlet var uiTradeApplyTryCancelBtn: UIView!
    @IBOutlet var uiTradeDeleteBtn: UIView!
    @IBOutlet var uiTradeDelAndDealBtn: UIView!
    @IBOutlet var uiTradeRejADealASucBtn: UIView!
    @IBOutlet var uiTradeDealAcceptBtn: UIView!
    
    @IBOutlet weak var uiTradeSendBtn: UIButton!
    @IBOutlet weak var uiTradeCancelBtn: UIButton!
    @IBOutlet weak var uiTradeDelBtn: UIButton!
    @IBOutlet weak var uiTradeDel2Btn: UIButton!
    @IBOutlet weak var uiTradeDealBtn: UIButton!
    @IBOutlet weak var uiRejectBtn: UIButton!
    @IBOutlet weak var uiDeal2Btn: UIButton!
    @IBOutlet weak var uiAcceptBtn: UIButton!
    @IBOutlet weak var uiDeal3Btn: UIButton!
    
    
    
    private var m_sUserProfileUrl = "";
    private var m_sUserName = "";
    private var m_sTradeSeq = "";
    private var m_sDirection = "0";
    private var m_sTradeState = "1";
    private var m_sRejComment = "";
    private var m_sIsRetry = "";
    private var m_sTopUserSeq = "";
    private var m_sisBalck = "";
    private var m_sSelTopPrice = "";
    private var m_sSelBottomPrice = "";
    
    @IBOutlet weak var uiIconBtn: UIButton!
    @IBOutlet weak var uiBlackListBtn: UIButton!
    
    
    @IBOutlet weak var uiTradeDealBorderBtn: UIButton!
    @IBOutlet weak var uiTradeDelBorderBtn: UIButton!
    @IBOutlet weak var uiBottomHelpLabel: UILabel!
    
    private var m_isAccBtn = false;
    
    private var m_isTPagging = false;
    private var m_isBPagging = false;
    
    override func viewDidLoad() {
        if m_nViewType == 5{
            super.InitVC(type: Single.DE_INITNAVISUB, title: "흥정신청".localized)
        }else{
            super.InitVC(type: Single.DE_INITNAVISUB, title: "트레이드확인".localized)
        }
        super.viewDidLoad()
        
        uiMyTitlelb.text = "내 교환 상품".localized;
        uiTradeSendBtn.setTitle("트레이드 신청".localized, for: .normal)
        uiTradeCancelBtn.setTitle("트레이드 신청취소".localized, for: .normal)
        uiTradeDelBtn.setTitle("트레이드 내역삭제".localized, for: .normal)
        uiTradeDel2Btn.setTitle("트레이드 내역삭제".localized, for: .normal)
        uiTradeDealBtn.setTitle("흥정하기".localized, for: .normal)
        uiRejectBtn.setTitle("거절".localized, for: .normal)
        uiDeal2Btn.setTitle("흥정".localized, for: .normal)
        uiAcceptBtn.setTitle("수락".localized, for: .normal)
        uiDeal3Btn.setTitle("흥정 신청".localized, for: .normal)
        
        
        self.uiTopView.layer.addBorder([.top,.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        self.uiBottomView.layer.addBorder([.top,.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        uiUserPImg.layer.cornerRadius = uiUserPImg.frame.height/2
        
        //uiTradeDealBorderBtn.layer.addSperater([.right,.left], color: UIColor.white, width: 1.0, heipl: -18.0)
        //uiTradeDelBorderBtn.layer.addSperater([.right], color: UIColor.white, width: 1.0, heipl: -18.0)
        
        uiTopCollectionView.delegate = self;
        uiTopCollectionView.dataSource = self;
        let nib = UINib(nibName: "TradeApplyTryCell", bundle: nil)
        uiTopCollectionView.register(nib, forCellWithReuseIdentifier: "tradeapplytrycellidx")
        let Topflow = UICollectionViewFlowLayout()
        Topflow.sectionInset = UIEdgeInsets(top: 3, left: 13, bottom: 3, right:13)
        Topflow.scrollDirection = .horizontal;
        Topflow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        Topflow.minimumLineSpacing = CGFloat(self.cellMarginSize)
        uiTopCollectionView.collectionViewLayout = Topflow
        
        
        uiBottomCollectionView.delegate = self;
        uiBottomCollectionView.dataSource = self;
        uiBottomCollectionView.register(nib, forCellWithReuseIdentifier: "tradeapplytrycellidx")
        let Bottomflow = UICollectionViewFlowLayout()
        Bottomflow.sectionInset = UIEdgeInsets(top: 3, left: 13, bottom: 3, right:13)
        Bottomflow.scrollDirection = .horizontal;
        Bottomflow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        Bottomflow.minimumLineSpacing = CGFloat(self.cellMarginSize)
        uiBottomCollectionView.collectionViewLayout = Bottomflow
        
        
        uiBottomHelpLabel.text = "신청 이후 트레이드 진행 현황은\n트레이드 현황에서 확인하세요".localized
        
        if m_nViewType == 0{//트레이드신청
            setDefaultSet();
            setContentsView(uiView: uiTradeApplyTryBtn);
        }else if m_nViewType == 1{//트레이트 취소
            setNetwortSet();
            setContentsView(uiView: uiTradeApplyTryCancelBtn);
        }else if m_nViewType == 2{//내역삭제
            setNetwortSet();
            setContentsView(uiView: uiTradeDeleteBtn);
        }else if m_nViewType == 3{//내역삭제, 흥정
            setNetwortSet();
            setContentsView(uiView: uiTradeDelAndDealBtn);
        }else if m_nViewType == 4{//거절 흥정 수락
            setNetwortSet();
            setContentsView(uiView: uiTradeRejADealASucBtn);
            uiBottomHelpLabel.text = "트레이드 수락시 상품보관함에서\n수락된 트레이드 상품을 확인하실 수 있습니다.".localized
        }else if m_nViewType == 5{//흥정신청
            setDefaultSet();
            setContentsView(uiView: uiTradeDealAcceptBtn);
        }
        
        
    }
    func setContentsView(uiView : UIView){
        uiBottomBtnView.addSubview(uiView)
        
        uiView.translatesAutoresizingMaskIntoConstraints = false
        uiView.topAnchor.constraint(equalTo: uiBottomBtnView.topAnchor,constant: 0).isActive = true
        uiView.leftAnchor.constraint(equalTo:uiBottomBtnView.leftAnchor,constant: 0).isActive = true
        uiView.rightAnchor.constraint(equalTo: uiBottomBtnView.rightAnchor, constant: 0).isActive = true
        uiView.bottomAnchor.constraint(equalTo: uiBottomBtnView  .bottomAnchor, constant: 0).isActive = true
        
    }
    func setDefaultSet(){
        uiIconBtn.isHidden = true;
        uiUserPImg.setImage(with: m_sUserProfileUrl)
        uiUserNameLabel.text = m_sUserName;
        
        var m_nSelPrice = 0;
        for (_, value) in m_TopSelListData{
            m_TopListData.append(value)
            m_nSelPrice += Int(value["price"]!)!
            
            let fm_sSub1 = "건 선택됨".localized(txt: "\(m_TopSelListData.count)");
            let fm_sSub2 = "총 원".localized(txt: "\(String(m_nSelPrice).DecimalWon())");
            uiTopInfoLabel.text = "\(fm_sSub1) | \(fm_sSub2)";
            
            //uiTopInfoLabel.text = "\(m_TopSelListData.count)건 선택됨 | 총 \(String(m_nSelPrice).DecimalWon())원";
        }
        uiTopInfoLabel.TextPartColor(partstr: String(m_TopSelListData.count), Color: UIColor(rgb: 0x00BA87))
        m_nSelPrice = 0;
        for (_, value) in m_BottomSelListData{
            m_BottomListData.append(value)
            m_nSelPrice += Int(value["price"]!)!
            
            let fm_sSub1 = "건 선택됨".localized(txt: "\(m_BottomSelListData.count)");
            let fm_sSub2 = "총 원".localized(txt: "\(String(m_nSelPrice).DecimalWon())");
            uiBottomInfoLabel.text = "\(fm_sSub1) | \(fm_sSub2)";
            
            //uiBottomInfoLabel.text = "\(m_BottomSelListData.count)건 선택됨 | 총 \(String(m_nSelPrice).DecimalWon())원";
        }
        uiBottomInfoLabel.TextPartColor(partstr: String(m_BottomSelListData.count), Color: UIColor(rgb: 0x00BA87))
    }
    func setNetwortSet(){
        LoadingHUD.show()
        UserInfoJS.TradeUserInfoGet(param: ["account_seq":getUserSeq(), "trade_seq":m_sTradeSeq], callbackf: TradeUserInfoGetCallback)
        TopLoadItem();
        BottomLoadItem();
    }
    func TradeUserInfoGetCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            if alldata["errorcode"] == "3" {
                //푸시 알림 목록 또는 푸시 클릭해서 들어올때 이미 삭제된 내역이면 팝업띄우고 확인누르면 이전페이지로 이동
                MessagePop(msg: alldata["errormessage"].string!.localized, btntype: 2, ostuch:false, lbtn: "취소".localized, rbtn: "확인".localized,succallbackf: { ()-> Void in
                    self.navigationController?.popViewController(animated: true);
                }, closecallbackf: { ()-> Void in
                })
                
            }else{
                self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
            }
        }else{
            uiIconBtn.isHidden = false;
            uiUserNameLabel.text = alldata["data"]["name"].stringValue;
            uiUserPImg.setImage(with: "\(Single.DE_URLIMGSERVER)\(alldata["data"]["profile_image_url"])")
            m_sDirection = alldata["data"]["direction"].stringValue;
            m_sTradeState = alldata["data"]["state"].stringValue;
            m_sRejComment = alldata["data"]["comment"].stringValue;
            m_sIsRetry = alldata["data"]["is_retry"].stringValue;//0.일반, 1.흥정
            
            m_sTopUserSeq = alldata["data"]["top_account_seq"].stringValue;
            m_sisBalck = alldata["data"]["top_account_is_blocked"].stringValue;
            
            if m_sTradeState == "1"{
                //if m_sIsRetry == "1" && m_sDirection == "1" {
                if m_sDirection == "1" {
                    uiBlackListBtn.isHidden = false;
                }
                uiIconBtn.setImage(UIImage(named: "tradeicon_state_02"), for: .normal)
            }else if m_sTradeState == "2"{
                uiIconBtn.setImage(UIImage(named: "tradeicon_state_03_bnt"), for: .normal)
            }else if m_sTradeState == "3"{
                uiIconBtn.setImage(UIImage(named: "tradeicon_state_05"), for: .normal)
            }else if m_sTradeState == "5"{
                uiIconBtn.setImage(UIImage(named: "tradeicon_state_01in"), for: .normal)
            }else if m_sTradeState == "6"{
                uiIconBtn.setImage(UIImage(named: "tradeicon_state_04_bnt"), for: .normal)
            }
            
            self.m_sSelTopPrice = alldata["data"]["y_amount"].stringValue;
            var fm_sSub1 = "건 선택됨".localized(txt: "\(alldata["data"]["y_count"].stringValue)");
            var fm_sSub2 = "총 원".localized(txt: "\(m_sSelTopPrice.DecimalWon())");
            uiTopInfoLabel.text = "\(fm_sSub1) | \(fm_sSub2)";
            //uiTopInfoLabel.text = "\(alldata["data"]["y_count"].stringValue)건 선택됨 | 총 \(m_sSelTopPrice.DecimalWon())원";
            uiTopInfoLabel.TextPartColor(partstr: alldata["data"]["y_count"].stringValue, Color: UIColor(rgb: 0x00BA87))
            
            self.m_sSelBottomPrice = alldata["data"]["m_amount"].stringValue;
            fm_sSub1 = "건 선택됨".localized(txt: "\(alldata["data"]["m_count"].stringValue)");
            fm_sSub2 = "총 원".localized(txt: "\(m_sSelBottomPrice.DecimalWon())");
           // uiBottomInfoLabel.text = "\(fm_sSub1) | \(fm_sSub2)";
            uiBottomInfoLabel.text = "\(alldata["data"]["m_count"].stringValue)건 선택됨 | 총 \(alldata["data"]["m_amount"].stringValue.DecimalWon())원";
            uiBottomInfoLabel.TextPartColor(partstr: alldata["data"]["m_count"].stringValue, Color: UIColor(rgb: 0x00BA87))
        }
        LoadingHUD.hide()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 11.0, *) {
            if (UIDevice.current.hasNotch) {
                
                let bottomPadding = self.view.safeAreaInsets.bottom;
                uiBottomBtnView.frame = CGRect(x: 0, y: Int(uiBottomBtnView.frame.minY), width: Int(uiBottomBtnView.frame.size.width), height: Int(uiBottomBtnView.frame.size.height + bottomPadding))
                //uiBottomBtnView.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
            }

        }
    }
    func setData(TopUserSeq : String, topData : Dictionary<String, [String:String]>, bottomData : Dictionary<String, [String:String]>, viewType : Int = 0, UPUrl : String, UName : String, TradeSeq : String = ""){
        self.m_sSelUSeq = TopUserSeq;
        self.m_TopSelListData = topData;
        self.m_BottomSelListData = bottomData;
        self.m_nViewType = viewType
        self.m_sUserProfileUrl = UPUrl;
        self.m_sUserName = UName;
        self.m_sTradeSeq = TradeSeq;
    }
    func setData(viewType : Int = 0, TradeSeq : String){
        self.m_nViewType = viewType
        self.m_sTradeSeq = TradeSeq;
    }

    @IBAction func onTradeApplyBtn(_ sender: Any) {
        if m_isAccBtn {
            return;
        }
        MessagePop(title : "트레이드 신청".localized, msg: "트레이드 신청 하시겠습니까?".localized, lbtn: "취소".localized, rbtn: "확인".localized,succallbackf: { [self] ()-> Void in
            LoadingHUD.show()
            let TopKeys = Array(m_TopSelListData.keys);
            let BottomKeys = Array(m_BottomSelListData.keys);
            m_isAccBtn = true;
            JS.TradeApplyTry(param: ["trade_seq":"", "account_seq":getUserSeq(),
                                     "target_account_seq":m_sSelUSeq,"my_product_seqs":BottomKeys,"target_my_product_seqs":TopKeys], callbackf: TradeApplyTryCallback)
        }, closecallbackf: { ()-> Void in
            
        })
    }
    @IBAction func onTradeCancelBtn(_ sender: Any) {
        if m_isAccBtn {
            return;
        }
        MessagePop(title : "트레이드 신청 취소".localized, msg: "트레이드 신청을 취소 하시겠습니까?".localized, lbtn: "취소".localized, rbtn: "확인".localized,succallbackf: { [self] ()-> Void in
            LoadingHUD.show()
            m_isAccBtn = true;
            JS.TradeTryCtrl(param: ["comment":"", "trade_seq":m_sTradeSeq, "account_seq":getUserSeq(), "state":"3"], callbackf: TradeStatusListDeleteCallback)
        }, closecallbackf: { ()-> Void in
            
        })
        
    }
    @IBAction func onTradeDeleteBtn(_ sender: Any) {
        if m_isAccBtn {
            return;
        }
        MessagePop(title : "트레이드 내역 삭제".localized, msg: "트레이드 내역을 삭제 하시겠습니까?".localized, lbtn: "취소".localized, rbtn: "확인".localized,succallbackf: { [self] ()-> Void in
            LoadingHUD.show()
            m_isAccBtn = true;
            JS.TradeStatusListDelete(param: ["trade_seq":m_sTradeSeq, "account_seq":getUserSeq()], callbackf: TradeStatusListDeleteCallback)
        }, closecallbackf: { ()-> Void in
            
        })
        
    }
    
    @IBAction func onTradeDealBtn(_ sender: Any) {
        if m_isAccBtn {
            return;
        }
        MessagePop(title : "트레이드 흥정".localized, msg: "트레이드 흥정 하시겠습니까?".localized, lbtn: "취소".localized, rbtn: "확인".localized,succallbackf: { [self] ()-> Void in
            LoadingHUD.show()
            m_isAccBtn = true;
            
            //MARK: V2-2020-03-23 트레이드 상세에서 흥정 눌렀을경우에 내것도 선택하기위함, 지금은 테스트서버만되어있어서 이렇게 해놓음
//            if Single.DE_ISDEBUG{
                JS.TradeDealTopUserProductsGetV2(param: ["trade_seq":m_sTradeSeq, "account_seq":getUserSeq()], callbackf: TradeDealTopUserProductsGetCallback)
//            }else{
//                JS.TradeDealTopUserProductsGet(param: ["trade_seq":m_sTradeSeq, "account_seq":getUserSeq()], callbackf: TradeDealTopUserProductsGetCallback)
//            }
        }, closecallbackf: { ()-> Void in
            
        })
        
    }
    @IBAction func onRejecBtn(_ sender: Any) {
        let m_tWRP = TradeDealAndRejecPop.instantiate()
        m_tWRP?.closeHandler = { (issu : String)-> Void in
            self.RejecSubmit(issu: issu);
        }
        guard let customAlertVC = m_tWRP else { return; }
        let popupVC =  PopupViewController(contentController: customAlertVC, popupWidth: (self.view.frame.width + Single.DE_TEXTPOPSIZEW), popupHeight: 220)

        popupVC.backgroundAlpha = 0.3
        popupVC.backgroundColor = .black
        popupVC.canTapOutsideToDismiss = true
        popupVC.cornerRadius = 10
        popupVC.shadowEnabled = false
        present(popupVC, animated: true, completion: nil)
        
        
    }
    func RejecSubmit(issu : String){
        LoadingHUD.show()
        JS.TradeTryCtrl(param: ["comment":issu, "trade_seq":m_sTradeSeq, "account_seq":getUserSeq(), "state":"2"], callbackf: TradeStatusListDeleteCallback)
    }
    @IBAction func onAcceptBtn(_ sender: Any) {
        if m_isAccBtn {
            return;
        }
        MessagePop(title : "트레이드 수락".localized, msg: "트레이드 수락 하시겠습니까?".localized, lbtn: "취소".localized, rbtn: "확인".localized,succallbackf: { [self] ()-> Void in
            LoadingHUD.show()
            m_isAccBtn = true;
            JS.TradeTryCtrl(param: ["comment":"", "trade_seq":m_sTradeSeq, "account_seq":getUserSeq(), "state":"5"], callbackf: TradeSuccCallback)
        }, closecallbackf: { ()-> Void in
            
        })
        
    }
    func TradeDealTopUserProductsGetCallback(alldata: JSON)->Void {
        m_isAccBtn = false;
        if alldata["errorcode"] != "0"{
            print("TradeDealTopUserProductsGetCallback Error : ", alldata["errormessage"]);
        }else{
            //MARK: V2-2020-03-23 트레이드 상세에서 흥정 눌렀을경우에 내것도 선택하기위함, 지금은 테스트서버만되어있어서 이렇게 해놓음
            var TopSelItem = [String]()
            var BottomSelItem = [String]()
//            if Single.DE_ISDEBUG{
                for (_, object) in alldata["data"]["prds_top"] {
                    TopSelItem.append(object.stringValue)
                }
                for (_, object) in alldata["data"]["prds_bottom"] {
                    BottomSelItem.append(object.stringValue)
                }
//            }else {
//                for (_, object) in alldata["data"] {
//                    TopSelItem.append(object.stringValue)
//                }
//            }
            if TopSelItem.count > 0 {
                let Storyboard: UIStoryboard = UIStoryboard(name: "TradeApply", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "tradeapplyidx") as! TradeApply
                viewController.setData(selUSeq: m_sTopUserSeq, selPSeq: "", viewType: 1, selPseqS: TopSelItem, tradeseq: m_sTradeSeq, SelTopPrice: m_sSelTopPrice, selMyPseqS: BottomSelItem, SelBottomPrice: m_sSelBottomPrice);
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
        LoadingHUD.hide()
    }
    @IBAction func onTradeDealAcceptBtn(_ sender: Any) {
        if m_isAccBtn {
            return;
        }
        MessagePop(title : "트레이드 흥정 신청".localized, msg: "트레이드 흥정 신청을 하시겠습니까?".localized, lbtn: "취소".localized, rbtn: "확인".localized,succallbackf: { [self] ()-> Void in
            LoadingHUD.show()
            let TopKeys = Array(m_TopSelListData.keys);
            let BottomKeys = Array(m_BottomSelListData.keys);
            m_isAccBtn = true;
            JS.TradeApplyTry(param: ["trade_seq":m_sTradeSeq, "account_seq":getUserSeq(),
                                     "target_account_seq":m_sSelUSeq,"my_product_seqs":BottomKeys,"target_my_product_seqs":TopKeys], callbackf: TradeDealAcceptCallback)
        }, closecallbackf: { ()-> Void in
            
        })
        
    }
    @IBAction func onIconBtn(_ sender: Any) {
        var m_sTitle = "";
        if m_sTradeState == "2"{
            m_sTitle = "거절 사유".localized;
        }else if m_sTradeState == "6"{
            m_sTitle = "흥정 사유".localized;
        }else{
            return;
        }
        
        MessagePop(title : m_sTitle, msg: m_sRejComment, btntype: 2)
    }
    @IBAction func onBlackListBtn(_ sender: Any) {
        let msg = UIAlertController(title: "확인".localized, message: "블랙리스트 추가 시 해당 회원과는 트레이드, 선물하기가 불가능합니다. 추가하시겠습니까?".localized, preferredStyle: .alert)
        
        let YES = UIAlertAction(title: "추가".localized, style: .destructive, handler: { (action) -> Void in
            self.BlackList()
            
        })
        
        let NO = UIAlertAction(title: "취소".localized, style: .cancel) { (action) -> Void in
        }
        msg.addAction(NO)
        msg.addAction(YES)
        
        self.present(msg, animated: true, completion: nil)
    }
    func BlackList(){
        LoadingHUD.show()
        JS.FriendORBlackListToggle(param: ["type":"0", "account_seq":super.getUserSeq(), "target_account_seq":self.m_sTopUserSeq], callbackf: FriendORBlackListToggleCallback)
        
    }
    func TradeApplyTryCallback(alldata: JSON)->Void {
        m_isAccBtn = false;
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            
            
            //루트 메인화면 빼고 스택 다 없애기
            self.navigationController?.popToRootViewController( animated: true )
            
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            window?.rootViewController?.presentedViewController?.view.makeToast("트레이드 신청 완료".localized)
            
            
        }
        LoadingHUD.hide()
    }
    func TradeDealAcceptCallback(alldata: JSON)->Void {
        m_isAccBtn = false;
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            //루트 메인화면 빼고 스택 다 없애기
            goToTradeStatusList()
        }
        LoadingHUD.hide()
        
    }
    func FriendORBlackListToggleCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            self.navigationController?.popViewController(animated: true);
        }
        LoadingHUD.hide()
    }
    func TradeStatusListDeleteCallback(alldata: JSON)->Void {
        m_isAccBtn = false;
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            goToTradeStatusList()
        }
        LoadingHUD.hide()
    }
    func TradeSuccCallback(alldata: JSON)->Void {
        m_isAccBtn = false;
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            let params : [String: Any] = [
                "fba_request_user_id":m_sTopUserSeq
                ,"fba_accept_user_id":super.getUserSeq()
                ,"fba_trade_id":m_sTradeSeq
                
            ];
            Analytics(eventname: "tradesucc", params: params)
            
            let paramsAF : [String: Any] = [
                "af_request_user_id" : m_sTopUserSeq,
                "af_accept_user_id" : super.getUserSeq(),
                "af_trade_id" : m_sTradeSeq
            ];
            AppsflyerLog(AFTitle: "af_trade_succeed", params: paramsAF)
            
            goToTradeStatusList()
        }
        LoadingHUD.hide()
    }
    func goToTradeStatusList(){
        let fm_Contrllers = self.navigationController?.viewControllers
        if let val = fm_Contrllers{
            for VC in val{
                if VC is TradeStatusList {
                    let VCC = VC as! TradeStatusList
                    self.navigationController?.popToViewController(VC, animated: true)
                    VCC.refresh();
                    break;
                }else if VC is PushLIst {
                    let VCC = VC as! PushLIst
                    self.navigationController?.popToViewController(VC, animated: true)
                    VCC.refresh()
                    break;
                }
                else if VC is StartMain {
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
    //MARK: Get Network Data
    func TopLoadItem(){
        LoadingHUD.show()
        m_isTPagging = true;
        m_nTopPageNum += 1;
        TopoJS.TradeTryProductsGet(param: ["pagenum":"\(m_nTopPageNum)", "trade_seq":m_sTradeSeq,
                              "account_seq":getUserSeq(),"is_target":"1"], callbackf: TopTradeApplyCallback)
    }
    func TopTradeApplyCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            if let val = alldata["nextpage"].string{
                m_nTopNextNum = Int(val)!;
            }
            if let val = alldata["datacnt"].string{
                m_nTopDataCnt = Int(val)!;
            }
            for (_, object) in alldata["data"] {
                var item = [String:String]()
                item["my_product_seq"] = object["my_product_seq"].stringValue;
                item["product_seq"] = object["product_seq"].stringValue;
                item["name"] = object["name"].stringValue;
                item["thumbnail"] = object["thumbnail"].stringValue;
                item["brand"] = object["brand"].stringValue;
                item["price"] = object["price"].stringValue;
                item["delivery_gauge"] = object["delivery_gauge"].stringValue;
                item["expired_at"] = object["expired_at"].stringValue;
                item["is_refresh_on_trade"] = object["is_refresh_on_trade"].stringValue;
                item["box_type"] = object["box_type"].stringValue;
                m_TopListData.append(item)
            }
        }
        self.uiTopCollectionView.reloadData()
        m_isTPagging = false;
        LoadingHUD.hide()
    }
    func BottomLoadItem(){
        LoadingHUD.show()
        m_isBPagging = true;
        m_nBottomPageNum += 1;
        BottomJS.TradeTryProductsGet(param: ["pagenum":"\(m_nBottomPageNum)", "trade_seq":m_sTradeSeq,
                                             "account_seq":getUserSeq(),"is_target":"0"], callbackf: BottomTradeApplyCallback)
    }
    func BottomTradeApplyCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            if let val = alldata["nextpage"].string{
                m_nBottomNextNum = Int(val)!;
            }
            if let val = alldata["datacnt"].string{
                m_nBottomDataCnt = Int(val)!;
            }
            for (_, object) in alldata["data"]{
                var item = [String:String]()
                item["my_product_seq"] = object["my_product_seq"].stringValue;
                item["product_seq"] = object["product_seq"].stringValue;
                item["name"] = object["name"].stringValue;
                item["thumbnail"] = object["thumbnail"].stringValue;
                item["brand"] = object["brand"].stringValue;
                item["price"] = object["price"].stringValue;
                item["delivery_gauge"] = object["delivery_gauge"].stringValue;
                item["expired_at"] = object["expired_at"].stringValue;
                item["is_refresh_on_trade"] = object["is_refresh_on_trade"].stringValue;
                item["box_type"] = object["box_type"].stringValue;
                m_BottomListData.append(item)
            }
        }
        self.uiBottomCollectionView.reloadData()
        m_isBPagging = false;
        LoadingHUD.hide()
    }
}
extension TradeApplyTry:  UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == uiTopCollectionView {
            return m_TopListData.count;
        }else if collectionView == uiBottomCollectionView {
            return m_BottomListData.count;
        }
        return 0;
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tradeapplytrycellidx", for: indexPath) as! TradeApplyTryCell
        if collectionView == uiTopCollectionView {
            if m_TopListData.count > indexPath.row{
                cell.setData(data: m_TopListData[indexPath.row]);
            }else{
            }
        }else if collectionView == uiBottomCollectionView {
            if m_BottomListData.count > indexPath.row{
                cell.setData(data: m_BottomListData[indexPath.row]);
            }else{
            }
        }
        return cell;
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if m_nViewType != 0{
            if collectionView == uiTopCollectionView {
                if (m_TopListData.count - 1) <= indexPath.row && m_nTopNextNum > 0 && !m_isTPagging{
                    self.TopLoadItem();
                }
            }else if collectionView == uiBottomCollectionView {
                if (m_BottomListData.count - 1) <= indexPath.row && m_nBottomNextNum > 0 && !m_isBPagging{
                    self.BottomLoadItem();
                }
            }
        }
    }
    
}
extension TradeApplyTry: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        return CGSize(width: 150, height: 244)
    }
    
    func calculateWith() -> CGFloat {
        let estimatedWidth = CGFloat(estimateWidth)
        let cellCount = floor(CGFloat(self.view.frame.size.width / estimatedWidth))
        
        let margin = CGFloat(cellMarginSize * 2)
        let width = (self.view.frame.size.width - CGFloat(cellMarginSize) * (cellCount - 1) - margin) / cellCount
        
        return width
    }
}
