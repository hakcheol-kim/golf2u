//
//  ProductDetail.swift
//  golf2u
//
//  Created by 이원영 on 2020/10/08.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON
import ImageSlideshow

class ProductDetail: VariousViewController {
    public var LikeBtnHandler: (()->())?//클로저
    private var SO:Single = Single.getSO();
    private let JS = JsonC();
    
    private var m_arrPd = [String]();
    private var m_arrComment = Array<[String]>();
    private var m_sSeq = "";
    private var m_sMySeq = "";
    private var m_sUserSeq = "";
    
    @IBOutlet weak var productimagemainview: ImageSlideshow!
    @IBOutlet weak var PDScrollBiew: UIScrollView!
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
    
    @IBOutlet weak var uiDetailBtn: UIButton!
    @IBOutlet weak var uiFAQBtn: UIButton!
    @IBOutlet weak var uiCommBtn: UIButton!
    @IBOutlet weak var uiMoreBtn: UIButton!
    
    @IBOutlet weak var uiComtCollection: UICollectionView!
    private var cellMarginSize = 5.0
    
    @IBOutlet weak var uiMarketBtn: UIButton!
    
    private var m_isMarket = false;
    
    private let m_isUserPZoom = ImageSlideshow()
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "상품상세보기".localized)
        super.viewDidLoad()
        
        uiProductTitle.text = "상품명".localized;
        uiPriceTitlelb.text = "정가".localized;
        uiGageTitlelb.text = "배송게이지".localized;
        uiMdTitlelb.text = "한마디".localized;
        uiPdCoTitlelb.text = "상품후기".localized;
        uiMoreBtn.setTitle("더보기".localized, for: .normal)
        uiDetailBtn.setTitle("상세정보".localized, for: .normal)
        uiCommBtn.setTitle("법적고지".localized, for: .normal)
        
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
        

        productimagemainview.layer.cornerRadius = 8.0;
        productimagemainview.layer.borderWidth = 1.0
        productimagemainview.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
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
          self.PDScrollBiew.refreshControl = BannerrefreshControl
        } else {
          self.PDScrollBiew.addSubview(BannerrefreshControl)
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
        
        uiComtCollection.delegate = self;
        uiComtCollection.dataSource = self;
        let nib = UINib(nibName: "ProductCommentCell", bundle: nil)
        uiComtCollection?.register(nib, forCellWithReuseIdentifier: "productcommentcellidx")
        
        let flow = UICollectionViewFlowLayout()
        flow.sectionInset = UIEdgeInsets(top: 3, left: 5, bottom: 3, right:5)
        flow.scrollDirection = .horizontal;
        flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
        //flow.sectionHeadersPinToVisibleBounds = true;//헤더 고정
        uiComtCollection.collectionViewLayout = flow
        
        LoadProductDetail();
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
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
    func InitSetting(seq : String, myseq : String = ""){
        self.m_sSeq = seq;
        self.m_sMySeq = myseq
    }
    func refresh(){
        LoadProductDetail();
    }
    func LoadProductDetail(){
        m_sUserSeq = getUserSeq();
        LoadingHUD.show()
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
            self.uiComtCollection.reloadData()
        }
        BannerrefreshControl.endRefreshing();
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
                    uiGagePoint.frame = CGRect(x: pointX, y: uiGageImgMainView.frame.minY-12, width: 50, height:50)
                }
            }
        }
    
        
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
    @IBAction func onCommentMoreBtn(_ sender: Any) {
        let Storyboard: UIStoryboard = UIStoryboard(name: "ProductCommentDetail", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "productcommentdetailidx") as! ProductCommentDetail
        viewController.setInitData(seq: m_sSeq, myseq: m_sMySeq)
        viewController.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func onPCPhoto(tapGesture: UITapGestureRecognizer){
        let imgView = tapGesture.view as! UIImageView
        if (imgView.tag >= 0) //Give your image View tag
        {
            m_isUserPZoom.removeFromSuperview()
            self.view.addSubview(m_isUserPZoom)
            var m_tPicArr = [KingfisherSource]();
            var tumpimgcnt = 0;
            for i in 6...7{
                if m_arrComment[imgView.tag][i] == "" {
                    continue;
                }
                tumpimgcnt += 1;
                let fm_sUrlS = "\(Single.DE_URLIMGSERVER)\(m_arrComment[imgView.tag][i])";
                if let URLString = KingfisherSource(urlString: fm_sUrlS){
                    m_tPicArr.append(URLString)
                }
            }
            if tumpimgcnt <= 0 {
                return;
            }
            m_isUserPZoom.setImageInputs(m_tPicArr)
            let fullScreenController = m_isUserPZoom.presentFullScreenController(from: self)
            fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .medium, color: nil)
        }
        else{

        }
    }
    @objc func onProPhoto(tapGesture: UITapGestureRecognizer){
        let imgView = tapGesture.view as! UIImageView
        let fm_sUserImgUrl = "\(Single.DE_URLIMGSERVER)\(m_arrComment[imgView.tag][1] ?? "")"
        super.ProfileImagePlus(UserImgUrl: fm_sUserImgUrl)
        
    }
}
extension ProductDetail: ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        m_nSlideBannerNum = page;
        SubImageUISetting()
    }
}
extension ProductDetail:  UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if m_arrComment.count > 0 {
            uiComtCollection.backgroundView = nil;
            return m_arrComment.count;
        } else {
            ListViewHelper.PdCommentUVCollectionViewEmptyMessage(viewController: self, tableviewController: uiComtCollection)
            return 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productcommentcellidx", for: indexPath) as! ProductCommentCell
        if m_arrComment.count > indexPath.row{
            cell.setData(data: m_arrComment[indexPath.row], row: indexPath.row);
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
        return cell;
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        /*if (m_ListData.count - 1) <= indexPath.row && m_nNextNum > 0 {
           
           self.LoadItem();
        }*/
    }
    
}
extension ProductDetail: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        return CGSize(width: width, height: 125)
    }
    
    func calculateWith() -> CGFloat {
        
        return 250.0
    }
}
