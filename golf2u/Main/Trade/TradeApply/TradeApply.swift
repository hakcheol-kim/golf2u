//
//  TradeApply.swift
//  golf2u
//
//  Created by 이원영 on 2020/10/19.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import EzPopup
import SwiftyJSON

class TradeApply: VariousViewController {
    private var SO:Single = Single.getSO();
    private let TopoJS = JsonC();
    private let BottomJS = JsonC();
    
    @IBOutlet weak var uiUserProfileVIew: UIView!
    @IBOutlet weak var uiUPImg: UIImageView!
    @IBOutlet weak var uiUName: UILabel!
    @IBOutlet weak var uiMarketCnt: UILabel!
    @IBOutlet weak var uiDealDate: UILabel!
    
    @IBOutlet weak var uiYProducts: UICollectionView!
    @IBOutlet weak var uiMProducts: UICollectionView!
    
    @IBOutlet weak var uiTopInfoLabel: UILabel!
    @IBOutlet weak var uiBottomInfoLabel: UILabel!
    
    private var m_sSelUSeq : String = "";
    private var m_sSelPSeq : String = "";
    private var m_isInitListPSeqSell : Bool = false;//트레이드 교환시 처음 화면들어와 선택된 상품선택에 product_seq 가 중복이여서 한번만 선택되게 viewtype == 0일때만
    private var m_selPseqS = [String]()
    private var m_selMyPseqS = [String]()
    
    private var m_nTopPageNum = 0;
    private var m_nTopNextNum = 0;
    private var m_nTopDataCnt = 0;
    private var m_nBottomPageNum = 0;
    private var m_nBottomNextNum = 0;
    private var m_nBottomDataCnt = 0;
    private var estimateWidth = 160.0
    private var cellMarginSize = 11.0
    
    private var m_isPSet : Bool = false;
    
    private var m_TopListData = Array<[String:String]>();
    private var m_BottomListData = Array<[String:String]>();
    
    private var m_TopSelListData: Dictionary<String, [String:String]> = Dictionary<String, [String:String]>()
    private var m_BottomSelListData: Dictionary<String, [String:String]> = Dictionary<String, [String:String]>()
    
    @IBOutlet weak var ApplyBtn: UIButton!
    
    private var m_nSelTopPrice : Int = 0;
    private var m_nSelBottomPrice : Int = 0;
    
    private var m_nViewType : Int = 0;
    
    @IBOutlet weak var uiBottomBtnView: UIView!
    @IBOutlet var uiTradeDealBtn: UIView!
    
    @IBOutlet var uiTradeApplyBtn: UIView!
    
    
    @IBOutlet weak var uiTopTitlelb: UILabel!
    @IBOutlet weak var uiBottomTitlelb: UILabel!
    @IBOutlet weak var uiTradeSendBtn: UIButton!
    @IBOutlet weak var uiDealBtn: UIButton!
    
    private var m_sUserProfileUrl = "";
    private var m_sUserName = "";
    private var m_sTradeSeq = "";
    
    private var m_isTPagging = false;
    private var m_isBPagging = false;
    
    
    
    override func viewDidLoad() {
        if m_nViewType == 0{//트레이드 신청
            super.InitVC(type: Single.DE_INITNAVISUB, title: "트레이드신청".localized)
        }else if m_nViewType == 1{//흥정신청
            super.InitVC(type: Single.DE_INITNAVISUB, title: "흥정신청".localized)
        }
        super.viewDidLoad()
        
        uiTopTitlelb.text = "교환 가능 상품".localized;
        uiBottomTitlelb.text = "나의 상품 선택".localized;
        uiTradeSendBtn.setTitle("트레이드 신청".localized, for: .normal)
        uiDealBtn.setTitle("흥정 신청".localized, for: .normal)
        
        self.uiUserProfileVIew.layer.addBorder([.top,.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
        uiYProducts.delegate = self;
        uiYProducts.dataSource = self;
        let nib = UINib(nibName: "TradeApplyCell", bundle: nil)
        uiYProducts.register(nib, forCellWithReuseIdentifier: "tradeapplycellidx")
        let Topflow = UICollectionViewFlowLayout()
        Topflow.sectionInset = UIEdgeInsets(top: 3, left: 13, bottom: 3, right:13)
        Topflow.scrollDirection = .horizontal;
        Topflow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        Topflow.minimumLineSpacing = CGFloat(self.cellMarginSize)
        uiYProducts.collectionViewLayout = Topflow
        
        
        uiMProducts.delegate = self;
        uiMProducts.dataSource = self;
        uiMProducts.register(nib, forCellWithReuseIdentifier: "tradeapplycellidx")
        let Bottomflow = UICollectionViewFlowLayout()
        Bottomflow.sectionInset = UIEdgeInsets(top: 3, left: 13, bottom: 3, right:13)
        Bottomflow.scrollDirection = .horizontal;
        Bottomflow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        Bottomflow.minimumLineSpacing = CGFloat(self.cellMarginSize)
        uiMProducts.collectionViewLayout = Bottomflow
        
        uiUPImg.layer.cornerRadius = uiUPImg.frame.height/2
        
        uiTopInfoLabel.TextPartColor(partstr: "0", Color: UIColor(rgb: 0x00BA87))
        uiBottomInfoLabel.TextPartColor(partstr: "0", Color: UIColor(rgb: 0x00BA87))
        
        
        if m_nViewType == 0{//트레이드 신청
            setContentsView(uiView: uiTradeApplyBtn);
        }else if m_nViewType == 1{//흥정신청
            let fm_sSub1 = "건 선택됨".localized(txt: "\(m_selPseqS.count)");
            let fm_sSub2 = "총 원".localized(txt: "\(String(m_nSelTopPrice).DecimalWon())");
            uiTopInfoLabel.text = "\(fm_sSub1) | \(fm_sSub2)";
            uiTopInfoLabel.TextPartColor(partstr: String(m_selPseqS.count), Color: UIColor(rgb: 0x00BA87))
            setContentsView(uiView: uiTradeDealBtn);
        }
        
        TopLoadItem();
        BottomLoadItem();
    }
    func setContentsView(uiView : UIView){
        uiBottomBtnView.addSubview(uiView)
        
        uiView.translatesAutoresizingMaskIntoConstraints = false
        uiView.topAnchor.constraint(equalTo: uiBottomBtnView.topAnchor,constant: 0).isActive = true
        uiView.leftAnchor.constraint(equalTo:uiBottomBtnView.leftAnchor,constant: 0).isActive = true
        uiView.rightAnchor.constraint(equalTo: uiBottomBtnView.rightAnchor, constant: 0).isActive = true
        uiView.bottomAnchor.constraint(equalTo: uiBottomBtnView  .bottomAnchor, constant: 0).isActive = true
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
                uiBottomBtnView.frame = CGRect(x: 0, y: Int(uiBottomBtnView.frame.minY), width: Int(uiBottomBtnView.frame.size.width), height: Int(uiBottomBtnView.frame.size.height + bottomPadding))
            }

        }
    }
    func setData(selUSeq : String, selPSeq : String){
        self.m_sSelUSeq = selUSeq;
        self.m_sSelPSeq = selPSeq;
        self.m_nViewType = 0;
        self.m_selPseqS = [String]();
        self.m_sTradeSeq = "";
    }
    func setData(selUSeq : String, selPSeq : String, viewType : Int, selPseqS : [String], tradeseq : String, SelTopPrice : String, selMyPseqS : [String], SelBottomPrice : String){
        self.m_sSelUSeq = selUSeq;
        self.m_sSelPSeq = selPSeq;
        self.m_nViewType = viewType;
        self.m_selPseqS = selPseqS;
        self.m_sTradeSeq = tradeseq;
        self.m_nSelTopPrice = Int(SelTopPrice) ?? 0
        self.m_selMyPseqS = selMyPseqS;
        self.m_nSelBottomPrice = Int(SelBottomPrice) ?? 0
    }
    
    @IBAction func onTradeApplyBtn(_ sender: Any) {
        if m_TopSelListData.count <= 0 || m_BottomSelListData.count <= 0 {
            MessagePop(msg: "상품선택을 확인해주세요.".localized, btntype : 2);
            
            return;
        }
        let Storyboard: UIStoryboard = UIStoryboard(name: "TradeApplyTry", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "tradeapplytryidx") as! TradeApplyTry
        viewController.setData(TopUserSeq : m_sSelUSeq, topData: m_TopSelListData, bottomData: m_BottomSelListData, UPUrl: m_sUserProfileUrl, UName: m_sUserName);
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    @IBAction func onTradeDealBtn(_ sender: Any) {
        if m_TopSelListData.count <= 0 || m_BottomSelListData.count <= 0 {
            MessagePop(msg: "상품선택을 확인해주세요.".localized, btntype : 2);
            return;
        }
        let Storyboard: UIStoryboard = UIStoryboard(name: "TradeApplyTry", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "tradeapplytryidx") as! TradeApplyTry
        viewController.setData(TopUserSeq : m_sSelUSeq, topData: m_TopSelListData, bottomData: m_BottomSelListData, viewType: 5, UPUrl: m_sUserProfileUrl, UName: m_sUserName, TradeSeq: m_sTradeSeq);
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func TopLoadItem(){
        LoadingHUD.show()
        m_isTPagging = true;
        m_nTopPageNum += 1;
        TopoJS.TradeApply(param: ["pagenum":"\(m_nTopPageNum)", "banner_account_seq":m_sSelUSeq,
                                  "top_account_seq":m_sSelUSeq,"bottom_account_seq":getUserSeq(),"product_seq":m_sSelPSeq,"is_target":"1", "trade_seq":m_sTradeSeq], callbackf: TopTradeApplyCallback)
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
            for (_, object) in alldata["data"]["data_arr"] {
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
                item["accept_cnt"] = object["accept_cnt"].stringValue;
                m_TopListData.append(item)
                
                if m_nViewType == 0 && item["product_seq"] == m_sSelPSeq && !m_isInitListPSeqSell {
                    m_TopSelListData[item["my_product_seq"]!] = item;
                    m_isInitListPSeqSell = true;
                }
                else if m_nViewType == 1 && m_selPseqS.contains(item["my_product_seq"]!){
                    m_TopSelListData[item["my_product_seq"]!] = item;
                }
            }
            setTopCntPriceInfo();
            if !m_isPSet {
                m_isPSet = true;
                m_sUserProfileUrl = "\(Single.DE_URLIMGSERVER)\(alldata["data"]["profile_image_url"])"
                m_sUserName = alldata["data"]["name"].stringValue;
                uiUPImg.setImage(with: m_sUserProfileUrl)
                uiUName.text = m_sUserName
                uiDealDate.text = "최근거래".localized(txt: "\(alldata["data"]["last_reged_at"].stringValue)")
                if m_nViewType == 0{//트레이드 신청
                    uiMarketCnt.text = "마켓 등록 상품 개".localized(txt: "\(alldata["data"]["reg_count"].stringValue)")
                    uiMarketCnt.TextPartColor(partstr: alldata["data"]["reg_count"].stringValue, Color: UIColor(rgb: 0x00BA87))
                }else if m_nViewType == 1{//흥정신청
                    let fm_sPACntTxt = "상품 개".localized(txt: "\(alldata["data"]["reg_count"].stringValue)")
                    let fm_sTradeCntTxt = "누적 성사 건".localized(txt: "\(alldata["data"]["accept_cnt"].stringValue)")
                    uiMarketCnt.text = "\(fm_sPACntTxt) | \(fm_sTradeCntTxt)"
                    uiMarketCnt.TextPartColor(partstr: alldata["data"]["reg_count"].stringValue, Color: UIColor(rgb: 0x00BA87))
                    uiMarketCnt.TextPartColor(partstr: alldata["data"]["accept_cnt"].stringValue, Color: UIColor(rgb: 0x00BA87))
                }
            }
        }
        self.uiYProducts.reloadData()
        m_isTPagging = false;
        LoadingHUD.hide()
    }
    func setTopCntPriceInfo(){
        m_nSelTopPrice = 0;
        for (_, val) in m_TopSelListData{
            m_nSelTopPrice += Int(val["price"]!)!
        }
        let fm_sSub1 = "건 선택됨".localized(txt: "\(m_TopSelListData.count)");
        let fm_sSub2 = "총 원".localized(txt: "\(String(m_nSelTopPrice).DecimalWon())");
        uiTopInfoLabel.text = "\(fm_sSub1) | \(fm_sSub2)";
        
        //uiTopInfoLabel.text = "\(m_TopSelListData.count)건 선택됨 | 총 \(String(m_nSelTopPrice).DecimalWon())원";
        uiTopInfoLabel.TextPartColor(partstr: String(m_TopSelListData.count), Color: UIColor(rgb: 0x00BA87))
    }
    func BottomLoadItem(){
        LoadingHUD.show()
        m_isBPagging = true;
        m_nBottomPageNum += 1;
        BottomJS.TradeApply(param: ["pagenum":"\(m_nBottomPageNum)", "banner_account_seq":m_sSelUSeq,
                              "top_account_seq":m_sSelUSeq,"bottom_account_seq":getUserSeq(),"product_seq":m_sSelPSeq,"is_target":"0", "trade_seq":m_sTradeSeq], callbackf: BottomTradeApplyCallback)
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
            for (_, object) in alldata["data"]["data_arr"] {
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
                
                if m_nViewType == 1 && m_selMyPseqS.contains(item["my_product_seq"]!){
                    m_BottomSelListData[item["my_product_seq"]!] = item;
                }
            }
            setBottomCntPriceInfo()
        }
        self.uiMProducts.reloadData()
        m_isBPagging = false;
        LoadingHUD.hide()
    }
    func setBottomCntPriceInfo(){
        m_nSelBottomPrice = 0;
        for (_, val) in m_BottomSelListData{
            m_nSelBottomPrice += Int(val["price"]!)!
        }
        let fm_sSub1 = "건 선택됨".localized(txt: "\(m_BottomSelListData.count)");
        let fm_sSub2 = "총 원".localized(txt: "\(String(m_nSelBottomPrice).DecimalWon())");
        uiBottomInfoLabel.text = "\(fm_sSub1) | \(fm_sSub2)";
        
        //uiTopInfoLabel.text = "\(m_TopSelListData.count)건 선택됨 | 총 \(String(m_nSelTopPrice).DecimalWon())원";
        uiBottomInfoLabel.TextPartColor(partstr: String(m_BottomSelListData.count), Color: UIColor(rgb: 0x00BA87))
    }
}
extension TradeApply:  UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == uiYProducts {
            return m_TopListData.count;
        }else if collectionView == uiMProducts {
            return m_BottomListData.count;
        }
        return 0;
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tradeapplycellidx", for: indexPath) as! TradeApplyCell
        if collectionView == uiYProducts {
            if m_TopListData.count > indexPath.row{
                cell.setData(data: m_TopListData[indexPath.row]);
                if let mypseq = m_TopListData[indexPath.row]["my_product_seq"]{
                    if !m_TopSelListData.keys.contains(mypseq) {
                        cell.setChoise(type: false)
                    }else{
                        cell.setChoise(type: true)
                    }
                }
            }else{
            }
        }else if collectionView == uiMProducts {
            if m_BottomListData.count > indexPath.row{
                cell.setData(data: m_BottomListData[indexPath.row]);
                if let mypseq = m_BottomListData[indexPath.row]["my_product_seq"]{
                    if !m_BottomSelListData.keys.contains(mypseq) {
                        cell.setChoise(type: false)
                    }else{
                        cell.setChoise(type: true)
                    }
                }
            }else{
            }
        }
        return cell;
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == uiYProducts {
            if let mypseq = m_TopListData[indexPath.row]["my_product_seq"]{
                if !m_TopSelListData.keys.contains(mypseq) {
                    m_TopSelListData[mypseq] = m_TopListData[indexPath.row]
                    let cell = (collectionView.cellForItem(at: indexPath) as! TradeApplyCell)
                    cell.setChoise(type: true)
                    m_nSelTopPrice += Int(m_TopListData[indexPath.row]["price"]!)!
                    
                    let fm_sSub1 = "건 선택됨".localized(txt: "\(m_TopSelListData.count)");
                    let fm_sSub2 = "총 원".localized(txt: "\(String(m_nSelTopPrice).DecimalWon())");
                    uiTopInfoLabel.text = "\(fm_sSub1) | \(fm_sSub2)";
                    //uiTopInfoLabel.text = "\(m_TopSelListData.count)건 선택됨 | 총 \(String(m_nSelTopPrice).DecimalWon())원";
                    uiTopInfoLabel.TextPartColor(partstr: String(m_TopSelListData.count), Color: UIColor(rgb: 0x00BA87))
                }else{
                    m_TopSelListData.removeValue(forKey: mypseq)
                    let cell = (collectionView.cellForItem(at: indexPath) as! TradeApplyCell)
                    cell.setChoise(type: false)
                    m_nSelTopPrice -= Int(m_TopListData[indexPath.row]["price"]!)!
                    let fm_sSub1 = "건 선택됨".localized(txt: "\(m_TopSelListData.count)");
                    let fm_sSub2 = "총 원".localized(txt: "\(String(m_nSelTopPrice).DecimalWon())");
                    uiTopInfoLabel.text = "\(fm_sSub1) | \(fm_sSub2)";
                    //uiTopInfoLabel.text = "\(m_TopSelListData.count)건 선택됨 | 총 \(String(m_nSelTopPrice).DecimalWon())원";
                    uiTopInfoLabel.TextPartColor(partstr: String(m_TopSelListData.count), Color: UIColor(rgb: 0x00BA87))
                }
            }
        }else if collectionView == uiMProducts {
            if let mypseq = m_BottomListData[indexPath.row]["my_product_seq"]{
                if !m_BottomSelListData.keys.contains(mypseq) {
                    m_BottomSelListData[mypseq] = m_BottomListData[indexPath.row]
                    let cell = (collectionView.cellForItem(at: indexPath) as! TradeApplyCell)
                    cell.setChoise(type: true)
                    m_nSelBottomPrice += Int(m_BottomListData[indexPath.row]["price"]!)!
                    let fm_sSub1 = "건 선택됨".localized(txt: "\(m_BottomSelListData.count)");
                    let fm_sSub2 = "총 원".localized(txt: "\(String(m_nSelBottomPrice).DecimalWon())");
                    uiBottomInfoLabel.text = "\(fm_sSub1) | \(fm_sSub2)";
                    
                    //uiBottomInfoLabel.text = "\(m_BottomSelListData.count)건 선택됨 | 총 \(String(m_nSelBottomPrice).DecimalWon())원";
                    uiBottomInfoLabel.TextPartColor(partstr: String(m_BottomSelListData.count), Color: UIColor(rgb: 0x00BA87))
                }else{
                    m_BottomSelListData.removeValue(forKey: mypseq)
                    let cell = (collectionView.cellForItem(at: indexPath) as! TradeApplyCell)
                    cell.setChoise(type: false)
                    m_nSelBottomPrice -= Int(m_BottomListData[indexPath.row]["price"]!)!
                    
                    let fm_sSub1 = "건 선택됨".localized(txt: "\(m_BottomSelListData.count)");
                    let fm_sSub2 = "총 원".localized(txt: "\(String(m_nSelBottomPrice).DecimalWon())");
                    uiBottomInfoLabel.text = "\(fm_sSub1) | \(fm_sSub2)";
                    //uiBottomInfoLabel.text = "\(m_BottomSelListData.count)건 선택됨 | 총 \(String(m_nSelBottomPrice).DecimalWon())원";
                    uiBottomInfoLabel.TextPartColor(partstr: String(m_BottomSelListData.count), Color: UIColor(rgb: 0x00BA87))
                }
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == uiYProducts {
            if (m_TopListData.count - 1) <= indexPath.row && m_nTopNextNum > 0 && !m_isTPagging{
                self.TopLoadItem();
            }
        }else if collectionView == uiMProducts {
            if (m_BottomListData.count - 1) <= indexPath.row && m_nBottomNextNum > 0 && !m_isBPagging{
                self.BottomLoadItem();
            }
        }
    }
    
}
extension TradeApply: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //let width = self.calculateWith()
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
