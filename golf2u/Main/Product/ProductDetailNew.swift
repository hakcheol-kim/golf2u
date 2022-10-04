//
//  ProductDetailNew.swift
//  golf2u
//
//  Created by 이원영 on 2021/06/09.
//  Copyright © 2021 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON
import ImageSlideshow
import NBBottomSheet
import Toast_Swift

class ProductDetailNew: VariousViewController {
    public var LikeBtnHandler: (()->())?//클로저
    private var SO:Single = Single.getSO();
    private let JS = JsonC();
    
    private var m_arrPd = [String]();
    private var m_arrComment = Array<[String]>();
    private var m_sSeq = "";
    private var m_sMySeq = "";
    private var m_sUserSeq = "";
    
    private var m_ListData = Array<[String:String]>();
    
    private var m_nPageNum = 0;
    private var m_nNextNum = 0;
    private var m_nDataCnt = 0;
    
    @IBOutlet weak var productimagemainview: ImageSlideshow!
    @IBOutlet weak var uiCommnetTable: UITableView!
    @IBOutlet weak var uiHeaderView: UIView!
    private var cellDeleteIndexPath: IndexPath? = nil
    @IBOutlet weak var pdimage1: UIImageView!
    @IBOutlet weak var pdimage2: UIImageView!
    @IBOutlet weak var pdimage3: UIImageView!
    private var pdimages = [UIImageView]()
    private var m_BannerIS = [KingfisherSource]();
    
    private var m_nSlideBannerNum = 0;
    private var m_nImageCnt = 0;
    
    @IBOutlet weak var bannerpagerView: UIView!
    @IBOutlet weak var bannerpagerLabel: UILabel!
    
    private var BannerrefreshControl = UIRefreshControl()
    
    @IBOutlet weak var uiProductTitle: UILabel!
    @IBOutlet weak var uiPriceTitlelb: UILabel!
    @IBOutlet weak var uiGageTitlelb: UILabel!
    @IBOutlet weak var uiMdTitlelb: UILabel!
    @IBOutlet weak var uiPdCoTitlelb: UILabel!
    @IBOutlet weak var uiEventImg: UIImageView!
    @IBOutlet weak var uipriceLabel: UILabel!
    @IBOutlet weak var uiMdView: UIView!
    @IBOutlet weak var uiMdLabel: UILabel!
    
    @IBOutlet weak var uiGage1: UIImageView!
    @IBOutlet weak var uiGage2: UIImageView!
    @IBOutlet weak var uiGage3: UIImageView!
    @IBOutlet weak var uiGage4: UIImageView!
    @IBOutlet weak var uiGage5: UIImageView!
    @IBOutlet weak var uiGage6: UIImageView!
    @IBOutlet weak var uiGage7: UIImageView!
    @IBOutlet weak var uiGage8: UIImageView!
    @IBOutlet weak var uiGage9: UIImageView!
    @IBOutlet weak var uiGage10: UIImageView!
    @IBOutlet weak var uiGage11: UIImageView!
    @IBOutlet weak var uiGage12: UIImageView!
    @IBOutlet weak var uiGage13: UIImageView!
    @IBOutlet weak var uiGage14: UIImageView!
    @IBOutlet weak var uiGage15: UIImageView!
    @IBOutlet weak var uiGage16: UIImageView!
    @IBOutlet weak var uiGage17: UIImageView!
    @IBOutlet weak var uiGage18: UIImageView!
    @IBOutlet weak var uiGage19: UIImageView!
    @IBOutlet weak var uiGage20: UIImageView!
    private var uiGages = [UIImageView]()
    @IBOutlet weak var uiGagePoint: UIView!
    @IBOutlet weak var uiGageImgMainView: UIView!
    @IBOutlet weak var uiGageImgSubView: UIView!
    @IBOutlet weak var uiGageLabel: UILabel!
    @IBOutlet weak var uiIceProuctTxt: UILabel!
    
    @IBOutlet weak var uiDetailBtn: UIButton!
    @IBOutlet weak var uiFAQBtn: UIButton!
    @IBOutlet weak var uiCommBtn: UIButton!
    
    @IBOutlet weak var uiCommentCntLabel: UILabel!
    @IBOutlet weak var uiOrderbyBtn: UIButton!
    @IBOutlet weak var uiWriteBtn: UIButton!
    private var m_isWriteBtn : Bool = true;
    
    
    @IBOutlet weak var uiMarketBtn: UIButton!
    
    private var m_isMarket = false;
    
    private let m_isUserPZoom = ImageSlideshow()
    

    private var m_sOrder_by : String = "0";
    private var m_isPagging = false;
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "상품상세보기".localized)
        super.viewDidLoad()
        
        uiWriteBtn.isHidden = m_isWriteBtn
        
        uiProductTitle.text = "상품명".localized;
        uiPriceTitlelb.text = "정가".localized;
        uiGageTitlelb.text = "배송게이지".localized;
        uiMdTitlelb.text = "한마디".localized;
        uiPdCoTitlelb.text = "상품후기".localized;
        uiDetailBtn.setTitle("상세정보".localized, for: .normal)
        uiCommBtn.setTitle("법적고지".localized, for: .normal)
        
        uiOrderbyBtn.layer.cornerRadius = 5.0
        uiOrderbyBtn.backgroundColor = .clear
        uiOrderbyBtn.layer.borderWidth = 1
        uiOrderbyBtn.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        bannerpagerView.layer.cornerRadius = 10.0
        uiMdView.layer.cornerRadius = 8.0
        
        uiDetailBtn.layer.cornerRadius = 20.0;
        uiDetailBtn.layer.borderWidth = 1.0
        uiDetailBtn.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        uiFAQBtn.layer.cornerRadius = 20.0;
        uiFAQBtn.layer.borderWidth = 1.0
        uiFAQBtn.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        uiCommBtn.layer.cornerRadius = 20.0;
        uiCommBtn.layer.borderWidth = 1.0
        uiCommBtn.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        

//        productimagemainview.layer.cornerRadius = 8.0;
//        productimagemainview.layer.borderWidth = 1.0
//        productimagemainview.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        pdimage1.isUserInteractionEnabled = true
        pdimage2.isUserInteractionEnabled = true
        pdimage3.isUserInteractionEnabled = true
        let subimgevntg1 = UITapGestureRecognizer(target: self, action: #selector(ProductDetail.didSubBannerTap(tapGesture:)))
        let subimgevntg2 = UITapGestureRecognizer(target: self, action: #selector(ProductDetail.didSubBannerTap(tapGesture:)))
        let subimgevntg3 = UITapGestureRecognizer(target: self, action: #selector(ProductDetail.didSubBannerTap(tapGesture:)))
        pdimage1.addGestureRecognizer(subimgevntg1)
        pdimage2.addGestureRecognizer(subimgevntg2)
        pdimage3.addGestureRecognizer(subimgevntg3)
        pdimages.append(pdimage1)
        pdimages.append(pdimage2)
        pdimages.append(pdimage3)
        
        SubImageUISetting();
        
        //PDScrollBiew.alwaysBounceVertical = true
        //PDScrollBiew.bounces  = true
        BannerrefreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
          self.uiCommnetTable.refreshControl = BannerrefreshControl
        } else {
          self.uiCommnetTable.addSubview(BannerrefreshControl)
        }
        
        uiGages.append(uiGage1)
        uiGages.append(uiGage2)
        uiGages.append(uiGage3)
        uiGages.append(uiGage4)
        uiGages.append(uiGage5)
        uiGages.append(uiGage6)
        uiGages.append(uiGage7)
        uiGages.append(uiGage8)
        uiGages.append(uiGage9)
        uiGages.append(uiGage10)
        uiGages.append(uiGage11)
        uiGages.append(uiGage12)
        uiGages.append(uiGage13)
        uiGages.append(uiGage14)
        uiGages.append(uiGage15)
        uiGages.append(uiGage16)
        uiGages.append(uiGage17)
        uiGages.append(uiGage18)
        uiGages.append(uiGage19)
        uiGages.append(uiGage20)
        
        //table setting
        
        //스토리보드에 헤더뷰를 만들었는데 여기서 다시하면
        //보이지 않는다 스토리보드에서 넣던지 아니면
        //아래처럼 넣기위해선 다른 뷰스토리보드를 만들어 nib 연결
        //방식으로 해야 나온다
        //uiHeaderView.frame.size.height = 1000
        //self.uiCommnetTable.tableHeaderView = uiHeaderView
        
//        let footerView = UIView()
//        footerView.backgroundColor = .systemBlue
//        footerView.frame.size.height = 0
//        self.uiCommnetTable.tableFooterView = footerView
        
       
        
        
        self.uiCommnetTable.dataSource = self
        self.uiCommnetTable.delegate = self
        self.uiCommnetTable.separatorStyle = .none//셀간 줄 없애기
        self.uiCommnetTable.cellLayoutMarginsFollowReadableWidth = false
        self.uiCommnetTable.separatorInset.left = 0
        //self.uiCommnetTable.rowHeight = UITableView.automaticDimension;
        //self.uiCommnetTable.estimatedRowHeight = 123;


        //테이블뷰 리프레쉬
        if #available(iOS 10.0, *) {
          self.uiCommnetTable.refreshControl = BannerrefreshControl
        } else {
          self.uiCommnetTable.addSubview(BannerrefreshControl)
        }
        BannerrefreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)//리프레시 이벤트
        //refreshControl.attributedTitle = NSAttributedString(string: "H2Care")
        
        let nibName = UINib(nibName: "ProductCommnetDetailCell", bundle: nil)
        self.uiCommnetTable.register(nibName, forCellReuseIdentifier: "productcommnetdetailcellidx")
        
        LoadProductDetail();
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if pdimage1.frame.width != 110 {
            //서브 이미지가 아이폰8 기준 넓이 110 인대 만약 110 이 아닌경우 해당 해상도에 넓이에 맞게 높이도 설정해준다
            pdimage1.translatesAutoresizingMaskIntoConstraints =  true;
            pdimage2.translatesAutoresizingMaskIntoConstraints =  true;
            pdimage3.translatesAutoresizingMaskIntoConstraints =  true;
            pdimage1.frame = CGRect(x: pdimage1.frame.minX, y: pdimage1.frame.minY, width: pdimage1.frame.width, height: pdimage1.frame.width)
            pdimage2.frame = CGRect(x: pdimage2.frame.minX, y: pdimage2.frame.minY, width: pdimage2.frame.width, height: pdimage2.frame.width)
            pdimage3.frame = CGRect(x: pdimage3.frame.minX, y: pdimage3.frame.minY, width: pdimage3.frame.width, height: pdimage3.frame.width)
        }
        
        //uiHeaderView.frame = CGRect(x: 0, y: 0, width:100, height: uiHeaderView.frame.height)
//        if let headerView = uiCommnetTable.tableHeaderView {
//
//            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
//            var headerFrame = headerView.frame
//
//            //Comparison necessary to avoid infinite loop
//            if height != headerFrame.size.height {
//                headerFrame.size.height = height
//                headerView.frame = headerFrame
//                uiCommnetTable.tableHeaderView = headerView
//            }
//        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //refresh()
    }
    func SubImageUISetting(){
        for i in 0 ..< pdimages.count {
            pdimages[i].tag = (i + 1);
            pdimages[i].layer.cornerRadius = 8.0;
            pdimages[i].layer.borderWidth = 1.0
            if m_nSlideBannerNum == i{
                pdimages[i].layer.borderColor = UIColor(rgb: 0x00BA87).cgColor
            }else {
                pdimages[i].layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
            }
        }
        bannerpagerLabel.text = "\((m_nSlideBannerNum + 1)) | \(m_nImageCnt)";
    }
    @objc func didPullToRefresh() {
        refresh()
     }
    func setWriteBtn(isv : Bool){
        m_isWriteBtn = isv
    }
    func InitSetting(seq : String, myseq : String = ""){
        self.m_sSeq = seq;
        self.m_sMySeq = myseq
    }
    @objc func refresh(){
        LoadProductDetail();
    }
    func LoadProductDetail(){
        m_sUserSeq = getUserSeq();
        //LoadingHUD.show()
        m_nImageCnt = 0;
        m_arrPd.removeAll();
        m_BannerIS.removeAll();
        m_arrComment.removeAll();
        
        JS.getProductDetail(param: ["seq":"\(m_sSeq)", "account_seq":"\(m_sUserSeq)"], callbackf: ProductDetailCallback)
    }
    func ProductDetailCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            m_arrPd.append(alldata["data"]["name"].stringValue)
            m_arrPd.append(alldata["data"]["brand"].stringValue)
            m_arrPd.append(alldata["data"]["price"].stringValue)
            m_arrPd.append(alldata["data"]["event_active"].stringValue)
            m_arrPd.append(alldata["data"]["file1"].stringValue)
            m_arrPd.append(alldata["data"]["file2"].stringValue)
            m_arrPd.append(alldata["data"]["file3"].stringValue)
            m_arrPd.append(alldata["data"]["md_comment"].stringValue)
            m_arrPd.append(alldata["data"]["delivery_gauge"].stringValue)//8
            m_arrPd.append(alldata["data"]["is_market_reged"].stringValue)
            m_arrPd.append(alldata["data"]["shipping_location"].stringValue)
//            for (_, object) in alldata["data"]["comments"] {
//                var item = [String]()
//                item.append(object["seq"].stringValue);
//                item.append(object["profile_image_url"].stringValue);
//                item.append(object["name"].stringValue);
//                item.append(object["contents"].stringValue);
//                item.append(object["like_cnt"].stringValue);
//                item.append(object["liked"].stringValue);
//                item.append(object["file1"].stringValue);//6
//                item.append(object["file2"].stringValue);
//                m_arrComment.append(item)
//            }
            DetailSetting()
            Commentrefresh()
            //self.uiCommnetTable.reloadData()
        }
        //BannerrefreshControl.endRefreshing();
        //LoadingHUD.hide()
    }
    @objc func Commentrefresh(){
        m_nPageNum = 0;
        m_ListData.removeAll();
        CommentLoadItem();
    }
    func CommentLoadItem(){
        LoadingHUD.show()
        m_isPagging = true;
        m_sUserSeq = getUserSeq();
        m_nPageNum += 1;
        JS.ProductCommentDetail(param: ["pagenum":"\(m_nPageNum)","product_seq":m_sSeq, "account_seq" : m_sUserSeq, "order_type" : m_sOrder_by, "include_2nd" : "1"], callbackf: ProductCommentDetailCallback)
    }
    func ProductCommentDetailCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            if let val = alldata["nextpage"].string{
                m_nNextNum = Int(val)!;
            }
            if let val = alldata["datacnt"].string{
                m_nDataCnt = Int(val)!;
                uiCommentCntLabel.text = "건".localized(txt: "\(String(m_nDataCnt).DecimalWon())");
                uiCommentCntLabel.TextPartColor(partstr: "\(m_nDataCnt)", Color: UIColor(rgb: 0x00BA87))
            }
            for (_, object) in alldata["data"] {
                var item = [String:String]()
                item["seq"] = object["seq"].stringValue;
                item["title"] = object["title"].stringValue;
                item["contents"] = object["contents"].stringValue;
                item["file1"] = object["file1"].stringValue;
                item["file2"] = object["file2"].stringValue;
                item["created_at"] = object["created_at"].stringValue;
                item["name"] = object["name"].stringValue;
                item["profile_image_url"] = object["profile_image_url"].stringValue;
                item["like_cnt"] = object["like_cnt"].stringValue;
                item["liked"] = object["liked"].stringValue;
                item["comments_cnt"] = object["comments_cnt"].stringValue;
                item["account_seq"] = object["account_seq"].stringValue;
                item["comments_cnt"] = object["comments_cnt"].stringValue;
                item["level"] = object["level"].stringValue;
                m_ListData.append(item)
            }
        }
        DispatchQueue.main.async {
            self.uiCommnetTable.reloadData()
            self.BannerrefreshControl.endRefreshing();
        }
        m_isPagging = false
        LoadingHUD.hide()
    }
    
    func DetailSetting(){
        if(m_arrPd[9] == "1"){
            m_isMarket = true;
            uiMarketBtn.isHidden = false;
        }
        for i in 4 ..< 7 {
            if m_arrPd[i] == "" {
                pdimages[i - 4].image = nil;
                continue;
            }
            let fm_sUrlS = "\(Single.DE_URLIMGSERVER)\(m_arrPd[i])";
           
            guard let URLString = KingfisherSource(urlString: fm_sUrlS) else { continue; }
            m_BannerIS.append(URLString)
            let subimage = "\(Single.DE_URLIMGSERVER)\(m_arrPd[i])";
            pdimages[i - 4].setImage(with: subimage)
            m_nImageCnt += 1;
        }
        
        productimagemainview.contentScaleMode = UIViewContentMode.scaleAspectFit
        productimagemainview.slideshowInterval = 3.0
        productimagemainview.pageIndicatorPosition = PageIndicatorPosition(horizontal: .center, vertical: .bottom)
        productimagemainview.pageIndicator = nil

        productimagemainview.activityIndicator = DefaultActivityIndicator()
        productimagemainview.delegate = self
        productimagemainview.setImageInputs(m_BannerIS)
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(ProductDetail.didBannerTap))
        productimagemainview.addGestureRecognizer(recognizer)
        
        bannerpagerLabel.text = "1 | \(m_nImageCnt)";
        
        uiProductTitle.text = m_arrPd[0];
        
        /*
         uiProductTitle.sizeToFit()
         uiEventImg.frame = CGRect(x: uiProductTitle.intrinsicContentSize.width, y: uiProductTitle.frame.minY, width: 51, height:30)
         */
        
        if m_arrPd[3] == "1" {
            uiEventImg.isHidden = false;
        }
        uipriceLabel.text = "원".localized(txt: "\(m_arrPd[2].DecimalWon())")
        uiMdLabel.text = m_arrPd[7];
        
        if m_arrPd[8].isNumber{
            uiGageLabel.text = m_arrPd[8]
            let fm_nGageNum = Int(m_arrPd[8])!
            for (i, val) in uiGages.enumerated(){
                if i < fm_nGageNum {
                    val.image = UIImage(named:"Gauge_\((i + 1))")
                }else{
                    val.image = UIImage(named:"Gauge_non")
                }
                if i == (fm_nGageNum - 1) {
                    let pointX = uiGageImgMainView.frame.origin.x + uiGageImgSubView.frame.origin.x + val.frame.origin.x - 9
                    uiGagePoint.frame = CGRect(x: pointX, y: uiGageImgMainView.frame.minY - 12, width: 50, height:50)
                }
            }
            uiGagePoint.isHidden = false;
        }
        
        
        if(m_arrPd[10] == "400"){
            uiIceProuctTxt.isHidden = false;//냉장 냉동 식품일 경우
            uiIceProuctTxt.text = "신선식품은 신선식품간의 묶음배송만 가능합니다.".localized;
        }else if(m_arrPd[10] == "300"){
            uiIceProuctTxt.isHidden = false;//냉장 냉동 식품일 경우
            uiIceProuctTxt.text = "냉동식품은 냉동식품간의 묶음배송만 가능합니다.".localized;
        }else{
            uiIceProuctTxt.isHidden = true;//냉장 냉동 식품일 경우
        }
    
        
    }
    @IBAction func onWriteBtn(_ sender: Any) {
        if m_sUserSeq == ""{
            //self.view.makeToast("로그인 후 이용해주세요.", duration: 1.0, position: .bottom)
            super.LoginMove()
            return;
        }
        let configuration = NBBottomSheetConfiguration(animationDuration: 0.4, sheetSize: .fixed(143))
        let bottomSheetController = NBBottomSheetController(configuration:configuration)
        let viewController = ProductCommnetPop(pseq: m_sSeq, myseq: m_sMySeq)
        viewController.closeHandler = { (pointtype : String, point : String)-> Void in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.EndComment(pointtype : pointtype, point : point )
            }
        }
        bottomSheetController.present(viewController, on: self)
    }
    func EndComment(pointtype : String, point : String){
        self.Commentrefresh();
        //print(pointtype, point);
        if pointtype == "2" {
            //첫후기
            MessagePop(title : "첫 후기 등록 완료".localized, msg: "첫 후기를 등록해주셔서 감사합니다. 클로버를 드립니다.".localized(txt: "\(point.DecimalWon())"), lbtn: "클로버내역".localized, rbtn: "확인".localized,succallbackf: {  ()-> Void in
                super.AppReview()
            }, closecallbackf: {  ()-> Void in
                let Storyboard: UIStoryboard = UIStoryboard(name: "CloverInfo", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "CloverInfoidx") as! CloverInfo
                self.navigationController?.pushViewController(viewController, animated: true)
                
            })
        }else if pointtype == "1" {
            //후기
            MessagePop(title : "후기 등록 완료".localized, msg: "후기를 등록해주셔서 감사합니다. 클로버를 드립니다.".localized(txt: "\(point.DecimalWon())"), lbtn: "클로버내역".localized, rbtn: "확인".localized,succallbackf: {  ()-> Void in
                super.AppReview()
            }, closecallbackf: {  ()-> Void in
                
                let Storyboard: UIStoryboard = UIStoryboard(name: "CloverInfo", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "CloverInfoidx") as! CloverInfo
                self.navigationController?.pushViewController(viewController, animated: true)
            })
        }else{
            //super.AppReview()
        }
        
    }
    @IBAction func onOderByBtn(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: "정렬".localized, preferredStyle: .actionSheet)
        //옵션 초기화
        let alertacop1 = UIAlertAction(title: "최신순".localized, style: .default, handler: alertHandleOp1)
        let alertacop2 = UIAlertAction(title: "도움순".localized, style: .default, handler: alertHandleOp1)
        let cancelAction = UIAlertAction(title: "닫기".localized, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(alertacop1)
        optionMenu.addAction(alertacop2)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    func alertHandleOp1(alertAction: UIAlertAction!) -> Void {
        if alertAction.title! == "최신순".localized {
            uiOrderbyBtn.setTitle("최신순".localized, for: .normal);
            m_sOrder_by = "0";
        }else if alertAction.title! == "도움순".localized {
            uiOrderbyBtn.setTitle("도움순".localized, for: .normal);
            m_sOrder_by = "1";
        }
        Commentrefresh();
    }
    @IBAction func onMarketBtn(_ sender: Any) {
        let Storyboard: UIStoryboard = UIStoryboard(name: "ProductMemberList", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "productmemberlistidx") as! ProductMemberList
        viewController.setPSeq(f_sPSeq: m_sSeq, f_nType: 1)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    @objc func didBannerTap() {
        let fullScreenController = productimagemainview.presentFullScreenController(from: self)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .large, color: nil)
    }
    @objc func didSubBannerTap(tapGesture: UITapGestureRecognizer) {
        let imgView = tapGesture.view as! UIImageView
        if imgView.image == nil{
            return;
        }
        if (imgView.tag - 1) == m_nSlideBannerNum{
            return;
        }
        productimagemainview.setCurrentPage((imgView.tag - 1), animated: true)
    }
    @IBAction func onDetailBtn(_ sender: Any) {
        let Storyboard: UIStoryboard = UIStoryboard(name: "ProductWebView", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "productwebviewidx") as! ProductWebView
        viewController.setUrl(url: "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/product/info/\(m_sSeq)", f_sTitle: "상세정보".localized)
        viewController.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    @IBAction func onFAQBtn(_ sender: Any) {
        let Storyboard: UIStoryboard = UIStoryboard(name: "ProductWebView", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "productwebviewidx") as! ProductWebView
        viewController.setUrl(url: "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/product/faq/\(m_sSeq)", f_sTitle: "FAQ")
        viewController.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    @IBAction func onCommBtn(_ sender: Any) {
        let Storyboard: UIStoryboard = UIStoryboard(name: "ProductWebView", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "productwebviewidx") as! ProductWebView
        viewController.setUrl(url: "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/product/legal_notice/\(m_sSeq)", f_sTitle: "법적고지".localized)
        viewController.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    @objc func onProPhoto(tapGesture: UITapGestureRecognizer){
        let imgView = tapGesture.view as! UIImageView
        let fm_sUserImgUrl = "\(Single.DE_URLIMGSERVER)\(m_ListData[imgView.tag]["profile_image_url"] ?? "")"
        super.ProfileImagePlus(UserImgUrl: fm_sUserImgUrl)
        
    }
}
extension ProductDetailNew: ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        m_nSlideBannerNum = page;
        SubImageUISetting()
    }
}
extension ProductDetailNew :  UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return uiHeaderView;
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 768;
        //pdimage1 서브 이미지 첫번째가 해상도 넓이에 맞게 늘어난것을 기본 높이를 빼서 그만큼 헤더를 늘려놓는다
        return 788 + pdimage1.frame.width - pdimage1.frame.height;
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if m_ListData.count > 0 {
//            uiCommnetTable.backgroundView = nil;
//            return m_ListData.count;
//        } else {
//            ListViewHelper.TableViewEmptyMessage(message: "데이터가 없습니다.".localized, viewController: self, tableviewController: uiCommnetTable)
//            return 0
//        }
        return m_ListData.count;
        //return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productcommnetdetailcellidx", for: indexPath) as! ProductCommnetDetailCell
        if m_ListData.count > indexPath.row{
            cell.setData(data: m_ListData[indexPath.row], row:indexPath.row)
            let tapGestureRecognizer1 = UITapGestureRecognizer(target:self, action: #selector(self.onPCPhoto(tapGesture:)))
            tapGestureRecognizer1.numberOfTapsRequired = 1
            cell.uiProductImg.isUserInteractionEnabled = true
            cell.uiProductImg.addGestureRecognizer(tapGestureRecognizer1)
            cell.LikeBtnHandler = { ()-> Void in
                super.LoginMove()
            }
            let tapGestureRecognizer2 = UITapGestureRecognizer(target:self, action: #selector(self.onProPhoto(tapGesture:)))
            tapGestureRecognizer2.numberOfTapsRequired = 1
            cell.uiProfileImg.isUserInteractionEnabled = true
            cell.uiProfileImg.addGestureRecognizer(tapGestureRecognizer2)
        }else{
        }
        
       
        return cell
        
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (m_ListData.count - 1) == indexPath.row && m_nNextNum > 0 && !m_isPagging{

           self.CommentLoadItem();
        }
    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return 123;
    //    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //return UITableView.automaticDimension;
        if m_ListData.count > indexPath.row{
            if m_ListData[indexPath.row]["file1"] != "" || m_ListData[indexPath.row]["file2"] != ""{
                var heightT : CGFloat = 103;
                
                let bounds = UIScreen.main.bounds
                let width = bounds.size.width //화면 너비
                //let height = bounds.size.height //화면 높이
                
                //74 를 뺀이유는 스토리보드 컨텐츠 레이블 에서 양쪽 여백 을 더한 숫자다 화면 크기 를 구한다면 양쪽 여백을빼면 실제 콘텐츠 넓이가 나온다
                heightT += m_ListData[indexPath.row]["contents"]!.heightT(withConstrainedWidth: (width - 74), font: UIFont.systemFont(ofSize: CGFloat(12)))
                return heightT
            }else{
                var heightT : CGFloat = 61;
                
                let bounds = UIScreen.main.bounds
                let width = bounds.size.width //화면 너비
                //let height = bounds.size.height //화면 높이
                //74 를 뺀이유는 스토리보드 컨텐츠 레이블 에서 양쪽 여백 을 더한 숫자다 화면 크기 를 구한다면 양쪽 여백을빼면 실제 콘텐츠 넓이가 나온다
                heightT += m_ListData[indexPath.row]["contents"]!.heightT(withConstrainedWidth: (width - 74), font: UIFont.systemFont(ofSize: CGFloat(12)))
                return heightT
            }
        }
        return 132
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //셀 선택시
        
        self.view.endEditing(true)
//        let Storyboard: UIStoryboard = UIStoryboard(name: "StationDetail", bundle: nil)
//        let viewController = Storyboard.instantiateViewController(withIdentifier: "station_detail") as! StationDetail
//        viewController.modalPresentationStyle = .fullScreen
//        viewController.InitSetting(stuid: m_ListData[indexPath.row][2]);
//        self.navigationController?.pushViewController(viewController, animated: true)
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        var isEditCell : Bool = false;
        if m_ListData.count <= indexPath.row{
            return isEditCell
        }
        
        let m_US = m_ListData[indexPath.row]["account_seq"];
        if m_US == m_sUserSeq{
            isEditCell = true;
        }
        return isEditCell
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "삭제";
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        cellDeleteIndexPath = indexPath
        //let planetToDelete = m_ListData[indexPath.row]
        confirmDelete()
    }
    
    
    func confirmDelete() {
        if let indexPath = cellDeleteIndexPath {
            LoadingHUD.show()
            JS.ProductCommentDelete(param: ["seq":m_ListData[indexPath.row]["seq"]!], callbackf: ProductCommentDeleteCallback)
            uiCommnetTable.beginUpdates()
            m_ListData.remove(at: indexPath.row)
            uiCommnetTable.deleteRows(at: [indexPath], with: .automatic)
            cellDeleteIndexPath = nil
            uiCommnetTable.endUpdates()
            self.m_nDataCnt -= 1;
            uiCommentCntLabel.text = String(m_nDataCnt).DecimalWon();
        }
    }
    func ProductCommentDeleteCallback(alldata: JSON)->Void {
        
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
        }
        LoadingHUD.hide()
    }
    @objc func onPCPhoto(tapGesture: UITapGestureRecognizer){
        let imgView = tapGesture.view as! UIImageView
        if (imgView.tag >= 0) //Give your image View tag
        {
            m_isUserPZoom.removeFromSuperview()
            self.view.addSubview(m_isUserPZoom)
            var m_tPicArr = [KingfisherSource]();
            var tumpimgcnt = 0;
            for i in 1...2{
                if let imgurl = m_ListData[imgView.tag]["file\(i)"] {
                    if imgurl == "" {
                        continue;
                    }
                    tumpimgcnt += 1;
                    let fm_sUrlS = "\(Single.DE_URLIMGSERVER)\(imgurl)";
                    if let URLString = KingfisherSource(urlString: fm_sUrlS){
                        m_tPicArr.append(URLString)
                    }
                }
            }
            if tumpimgcnt <= 0{
                return;
            }
            m_isUserPZoom.setImageInputs(m_tPicArr)
            let fullScreenController = m_isUserPZoom.presentFullScreenController(from: self)
            fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .medium, color: nil)
        }
        else{

        }
    }
    
}
