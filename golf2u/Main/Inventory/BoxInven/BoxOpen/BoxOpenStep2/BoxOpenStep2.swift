//
//  BoxOpenStep2.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/06.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import EzPopup
import AppsFlyerLib


class BoxOpenStep2: VariousViewController {
    private var SO:Single = Single.getSO();
    private let JS = JsonC();
    
    @IBOutlet weak var uiTopView: UIView!
    @IBOutlet weak var uiInvenBtn: UIButton!
    @IBOutlet weak var uiBottomView: UIView!
    @IBOutlet weak var uiBgImg: UIImageView!
    @IBOutlet weak var uiCardBtn: UIButton!
    @IBOutlet weak var uiOneMoreBtn: UIButton!
    @IBOutlet weak var uiProductNameLbael: UILabel!
    @IBOutlet weak var uiMdView: UIView!
    @IBOutlet weak var uiMDConLabel: UILabel!
    @IBOutlet weak var uiCollectionView: UICollectionView!
    @IBOutlet weak var uiHelpLabel: UILabel!
    
    private let m_FlowLayout = UICollectionViewFlowLayout();
    private let m_CardLayout = CardsCollectionViewLayout();
    
    private var m_ListData = Array<[String:String]>();
    private var m_sBoxType = "1";
    private var estimateWidth = 160.0
    private var estimateHeght = 260.0
    private var cellMarginSize = 5.0
    private var m_isCardLayout = false;
    private var m_nRemainCnt = 0;
    private var m_sMaxGrade = "1";//나온 상품 중 가장 높은 등급(1:베이스,2:중박,3:프리미엄)
    private var m_sPointPE = "";//만료 환급 클로버
    private var m_sEAT = "";//보관 만료일 텍스트   ex)2021년 03월 14일 10시
    private var m_sEDD = "75";//보관기간 숫자 (기본 75)
    
    private var m_Step1Data = [String : String]();
    
    private var m_tSharePopup : PopupViewController?

    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "박스 오픈".localized)
        super.viewDidLoad()
        
        
        
        self.uiInvenBtn.layer.addBorder([.left], color: UIColor.white, width: 1.0)
        
        uiOneMoreBtn.layer.cornerRadius = uiOneMoreBtn.bounds.height / 2;
        
        uiCollectionView.backgroundColor = UIColor.clear.withAlphaComponent(0);
        
        uiCollectionView.delegate = self;
        uiCollectionView.dataSource = self;
        let nib = UINib(nibName: "BoxOpenStep2Cell", bundle: nil)
        uiCollectionView?.register(nib, forCellWithReuseIdentifier: "boxopenstep2cellidx")
        
        
        m_FlowLayout.scrollDirection = .vertical;
        
        if m_sBoxType == "1" {
            uiBgImg.image = UIImage(named: "BoxOpenNew_random_bg2")
            uiTopView.backgroundColor = UIColor(rgb: 0x1e275b)
            view.backgroundColor = UIColor(rgb: 0x1e275b)
        }else{
            uiBgImg.image = UIImage(named: "BoxOpenNew_eventbox_bg2")
            uiTopView.backgroundColor = UIColor(rgb: 0x267b64)
            view.backgroundColor = UIColor(rgb: 0x267b64)
        }
        
        if m_ListData.count > 1 {
            uiBgImg.isHidden = false;
            uiCardBtn.isHidden = false;
            //uiProductNameLbael.isHidden = true;
            //uiMdView.isHidden = true;
            //uiMDConLabel.isHidden = true;
            
            uiCollectionView.collectionViewLayout = m_FlowLayout
            
        }else{
            uiBgImg.isHidden = false;
            //uiProductNameLbael.text = m_ListData[0]["name"]
            //uiMDConLabel.text = m_ListData[0]["md_comment"]
            
            uiCollectionView.collectionViewLayout = m_CardLayout
            
        }
        if m_sMaxGrade != "1" {
            super.AppReview()
        }
        if m_ListData.count > 1 {
            uiHelpLabel.text = "각 상품의 보관기간은 상품보관함에서 확인 가능합니다.\n보관기간이 만료된 상품은 클로버로 전환되며,\n보관기간이 만료되면 배송, 선물, 트레이드가 불가능합니다.".localized
        }else{
            let fm_sLine1 = "이 상품은 최대 일 보관 가능한 상품입니다.\n".localized(txt: "\(m_sEDD)");
            let fm_sLine2 = "기준으로".localized(txt: "\(m_sEAT)");
            let fm_sLine3 = "클로버로 전환되며,\n".localized(txt: "\(m_sPointPE.DecimalWon())");
            let fm_sLine4 = "보관기관 만료되면 배송, 선물, 트레이드가 불가능합니다.".localized;
            uiHelpLabel.text = "\(fm_sLine1)\(fm_sLine2)\(fm_sLine3)\(fm_sLine4)"
        }
        
        let params : [String: Any] = [
            "userseq":super.getUserSeq()
            ,"boxtype":m_sBoxType
            ,"boxInfos":m_ListData
            
        ];
        Analytics(eventname: "boxopen", params: params)
        
        for arrs in m_ListData {
            let paramsAF : [String: Any] = [
                AFEventParamContentType : m_sBoxType == "1" ? "random_box" : "event_box",
                AFEventParamQuantity : "1",
                "af_product_id" : arrs["product_seq"] ?? "",
                "af_product_category" : arrs["category_seq"] ?? ""
            ];
            AppsflyerLog(AFTitle: "af_box_open", params: paramsAF)
        }
        
    }
    @IBAction func onBackBtn(_ sender: Any) {
        SO.getInventoryMain()?.ViewRefrashEvent()
        dismiss(animated: true, completion: nil)
    }
    func getCellHeight() ->CGSize {
        //화면 높이 비율에 따른 셀 높이 공식
        //667 = 아이폰8 디스플레이 높이 기준(해상도 아님)
//        let height = (0.8 - CGFloat(10/100*(UIScreen.main.bounds.height - 667.0)/200))
//        return CGSize(width: CGFloat(OnecalculateWith()), height: (self.uiCollectionView.frame.size.height * height))
        return CGSize(width: OnecalculateWith(), height: OnecalculateWith() + 135)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if m_ListData.count > 1 {
            
        }else{
            m_CardLayout.itemSize = getCellHeight()
        }
        if #available(iOS 11.0, *) {
            if (UIDevice.current.hasNotch) {
                let bottomPadding = self.view.safeAreaInsets.bottom;
                uiBottomView.frame = CGRect(x: 0, y: Int(uiBottomView.frame.minY), width: Int(uiBottomView.frame.size.width), height: Int(uiBottomView.frame.size.height + bottomPadding))
                //uiBottomBtnView.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
            }
        }
    }
    func setDate(boxtype : String, data : Array<[String:String]>, subdata : [String:String], step1data : [String : String]){
        m_sBoxType = boxtype
        m_ListData = data
        m_Step1Data = step1data
        m_nRemainCnt = Int(subdata["remain_cnt"] ?? "0") ?? 0;
        m_sMaxGrade = subdata["max_grade"] ?? ""
        m_sPointPE = subdata["point_payback_expired"] ?? ""
        m_sEAT = subdata["expired_at_txt"] ?? ""
        m_sEDD = subdata["expire_due_date"] ?? "75"
    }
    @IBAction func onOneMoreBtn(_ sender: Any) {
        if m_nRemainCnt > 0 {
            //self.navigationController?.popViewController(animated: true);
            guard let pvc = self.presentingViewController else { return }
            self.dismiss(animated: false) { [self] in
                let Storyboard: UIStoryboard = UIStoryboard(name: "BoxOpen", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "boxopenidx") as! BoxOpen
                viewController.setData(boxtype: m_Step1Data["type"]!, boxseq: m_Step1Data["seq"]!, data: m_Step1Data)
                viewController.modalPresentationStyle = .fullScreen
                pvc.present(viewController, animated: true, completion: nil)
            }
        }else{
            //더이상 오픈할 박스가 없다면 박스 결제 페이지로
            MessagePop(title : "안내".localized, msg: "보유한 박스를 모두 소진하였습니다.\n박스구매를 하시겠습니까?".localized, lbtn: "취소".localized, rbtn: "구매".localized,succallbackf: {  ()-> Void in
                
                self.SO.getInventoryMain()?.ViewRefrashEvent()
                self.dismiss(animated: true, completion: nil)
                self.dismiss(animated: false) { [self] in
                    self.SO.getInventoryMain()?.BoxBuyView()
                }
                
            }, closecallbackf: { ()-> Void in
                self.SO.getInventoryMain()?.ViewRefrashEvent()
                self.dismiss(animated: true, completion: nil)
                self.dismiss(animated: true, completion: nil)
            })
            
            
        }
    }
    
    @IBAction func onSucBtn(_ sender: Any) {
        SO.getInventoryMain()?.ViewRefrashEvent()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onInventoryBtn(_ sender: Any) {
        SO.getInventoryMain()?.ViewRefrashEvent()
        self.dismiss(animated: false) { [self] in
            SO.getInventoryMain()?.goToProductInven()
        }
    }
    
    @IBAction func onCardBtn(_ sender: Any) {
        if !m_isCardLayout {
            m_isCardLayout = true;
            uiCardBtn.setImage(UIImage(named: "BoxOpenNew_view_box"), for: .normal)
            uiCollectionView.isPagingEnabled = true
            uiCollectionView.showsHorizontalScrollIndicator = false
            uiCollectionView.collectionViewLayout = m_CardLayout
            m_CardLayout.spacing = 20.0;
            m_CardLayout.maximumVisibleItems = 5
            m_CardLayout.itemSize = getCellHeight()
        }else {
            m_isCardLayout = false;
            uiCardBtn.setImage(UIImage(named: "BoxOpenNew_view_card"), for: .normal)
            uiCollectionView.isPagingEnabled = false
            uiCollectionView.showsHorizontalScrollIndicator = true
            uiCollectionView.collectionViewLayout = m_FlowLayout
        }
        
    }
    @objc func SharebuttonClicked(sender: UIButton) {
        let m_tWRP = ProductSharePop.instantiate()
        guard let customAlertVC = m_tWRP else { return }
        customAlertVC.setData(row: sender.tag)
        let popupVC = PopupViewController(contentController: customAlertVC, popupWidth: 272, popupHeight: 171)
        m_tSharePopup = popupVC
        popupVC.backgroundAlpha = 0.3
        popupVC.backgroundColor = .black
        popupVC.canTapOutsideToDismiss = true
        popupVC.cornerRadius = 10
        popupVC.shadowEnabled = false
        
        self.present(popupVC, animated: true, completion: nil)
        
        customAlertVC.uiKakao.addTarget(self, action:#selector(onKakaoShare(sender:)), for: UIControl.Event.touchUpInside)
        customAlertVC.uiFacebook.addTarget(self, action:#selector(onFaceShare(sender:)), for: UIControl.Event.touchUpInside)

    }
    @objc func onKakaoShare(sender: UIButton) {
        m_tSharePopup?.dismiss(animated: true, completion: nil)
        
        KakaoShare(title: "\(m_ListData[sender.tag]["name"] ?? "")", contents: "나 이거 5천원에뽑았다!?\\n너도 행운을 확인해봐!", imgurl: "\(Single.DE_URLIMGSERVER)\(m_ListData[sender.tag]["thumbnail"] ?? "")")
    }
    @objc func onFaceShare(sender: UIButton) {
        m_tSharePopup?.dismiss(animated: true, completion: nil)
        do {
            let url = URL(string: "\(Single.DE_URLIMGSERVER)\(self.m_ListData[sender.tag]["thumbnail"] ?? "")")
            let data = try Data(contentsOf: url!)
            super.FaceBookShare(img: UIImage(data: data)!, link: "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/product/info/\(self.m_ListData[sender.tag]["product_seq"] ?? "")/1");// /1 = ios 페북 공유 상세페이지에 앱으로가는 버튼 이나온다
            //super.FaceBookShare(img: UIImage(data: data)!, link: "\(Single.DE_WEBAPIPROTOCOL)://random2u.com");
        }catch{
            print(error)
        }
        
    }
}
extension BoxOpenStep2:  UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return m_ListData.count;
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "boxopenstep2cellidx", for: indexPath) as! BoxOpenStep2Cell
        if m_ListData.count > indexPath.row{
            cell.setData(data: m_ListData[indexPath.row], row:indexPath.row);
            cell.uiShareBtn.addTarget(self, action:#selector(SharebuttonClicked(sender:)), for: UIControl.Event.touchUpInside)
        }else{
        }
        return cell;
    }
    
    
}
extension BoxOpenStep2: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = CGFloat(0);
        if m_ListData.count > 1 {
            width = self.calculateWith()
        }else{
            width = self.OnecalculateWith()
        }
        //let heigh = CGFloat(estimateHeght);
        return CGSize(width: width, height: width + 135)
    }
    
    func calculateWith() -> CGFloat {
        let estimatedWidth = CGFloat(estimateWidth)
        let cellCount = floor(CGFloat(self.uiCollectionView.frame.size.width / estimatedWidth))
        
        let margin = CGFloat(cellMarginSize * 2)
        let width = (self.uiCollectionView.frame.size.width - CGFloat(cellMarginSize) * (cellCount - 1) - margin) / cellCount
        
        return width
    }
    func OnecalculateWith() -> CGFloat {
        
        let width = (self.uiCollectionView.frame.size.width) / 2 + 20
        
        return width
    }
}
extension BoxOpenStep2:  BoxBuyClickCellBtnDelegate{
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
