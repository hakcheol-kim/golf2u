//
//  DeliveryPdAdd.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/16.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import EzPopup
import SwiftyJSON

class DeliveryPdAdd: VariousViewController {
    weak var m_tClickEvent: DeliveryApplyClickCellBtnDelegate? = nil;
    
    private let SO = Single.getSO();
    private let JS = JsonC();
    
    private let DE_MAXGAGE = 20;
    
    @IBOutlet weak var uiTopHelplb: UILabel!
    @IBOutlet weak var uiDeliGagelb: UILabel!
    
    @IBOutlet weak var uiHelpView: UIView!
    @IBOutlet weak var uiHelpBtn: UIButton!
    @IBOutlet weak var uiCollectionView: UICollectionView!
    private var refreshControl = UIRefreshControl()
    @IBOutlet weak var uiSelOkBtn: UIButton!
    
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
    @IBOutlet weak var uiBottomView: UIView!
    @IBOutlet weak var uiGagePoint: UIView!
    @IBOutlet weak var uiGageImgMainView: UIView!
    @IBOutlet weak var uiGageImgSubView: UIView!
    @IBOutlet weak var uiGageLabel: UILabel!
    
    private var m_SelListData: Dictionary<String, [String:String]> = Dictionary<String, [String:String]>()
    private var m_ListData = Array<[String:String]>();
    private var m_nPageNum = 0;
    private var m_nNextNum = 0;
    private var m_nDataCnt = 0;
    private var estimateWidth = 160.0
    private var cellMarginSize = 0.0
    
    private var m_SelData = Array<[String : String]>();
    private var m_SelSeqData = [String]()
    private var m_sOriMyPdSeq = "";
    
    private var m_nNowGage = 0;
    
    private var m_isPagging = false;
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "배송상품 추가".localized)
        super.viewDidLoad()
        
        uiTopHelplb.text = "함께 배송 받으실 상품을 선택하세요.".localized
        uiDeliGagelb.text = "배송게이지".localized
        uiHelpBtn.setTitle("묶음배송?".localized, for: .normal)
        uiSelOkBtn.setTitle("선택완료".localized, for: .normal)
        
        uiHelpBtn.layer.cornerRadius = 8.0;
        uiHelpBtn.layer.borderWidth = 1.0
        uiHelpBtn.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        uiHelpView.layer.addBorder([.top,.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        uiBottomView.layer.addBorder([.top], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
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
        
        uiCollectionView.delegate = self;
        uiCollectionView.dataSource = self;
        let nib = UINib(nibName: "DeliveryPdAddCell", bundle: nil)
        uiCollectionView.register(nib, forCellWithReuseIdentifier: "DeliveryPdAddCellidx")
        
        let flow = UICollectionViewFlowLayout()
        flow.sectionInset = UIEdgeInsets(top: 3, left: 0, bottom: 3, right:0)
        flow.scrollDirection = .vertical;
        flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
        uiCollectionView.collectionViewLayout = flow
        
        //리프레쉬
        if #available(iOS 10.0, *) {
          self.uiCollectionView.refreshControl = refreshControl
        } else {
          self.uiCollectionView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)//리프레시 이벤트
        //refreshControl.attributedTitle = NSAttributedString(string: "")
        
        for (_, val) in m_SelData.enumerated() {
            if let dataseq = val["my_product_seq"]{
                m_SelListData[dataseq] = val;
            }
        }
        m_SelSeqData = Array(m_SelListData.keys)
        
        
        
        LoadItem();
    }
    func setData(orimypdseq : String, data : Array<[String:String]>){
        m_sOriMyPdSeq = orimypdseq
        m_SelData = data
    }
    @objc func refresh(){
        m_nPageNum = 0;
        m_nNextNum = 0;
        m_nDataCnt = 0;
        m_ListData.removeAll();
        LoadItem();
    }
    func LoadItem(){
        LoadingHUD.show()
        m_isPagging = true;
        m_nPageNum += 1;
        JS.getAllMyProductsCanOrder(param: ["pagenum":m_nPageNum,"account_seq":super.getUserSeq(),"my_product_seqs":m_SelSeqData], callbackf: getAllMyProductsCanOrderCallback)
    }
    func getAllMyProductsCanOrderCallback(alldata: JSON)->Void {
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
                item["my_product_seq"] = object["my_product_seq"].stringValue;
                item["product_seq"] = object["product_seq"].stringValue;
                item["name"] = object["name"].stringValue;
                item["thumbnail"] = object["thumbnail"].stringValue;
                item["brand"] = object["brand"].stringValue;
                item["expired_at"] = object["expired_at"].stringValue;
                item["delivery_gauge"] = object["delivery_gauge"].stringValue;
                item["price"] = object["price"].stringValue;
                item["point_payback"] = object["point_payback"].stringValue;
                item["point_payback_expired"] = object["point_payback_expired"].stringValue;
                item["point_payback_current"] = object["point_payback_current"].stringValue;
                item["is_expired"] = object["is_expired"].stringValue;
                item["is_market_reged"] = object["is_market_reged"].stringValue;
                item["delivery_price"] = object["delivery_price"].stringValue;
                item["is_digital_item"] = object["is_digital_item"].stringValue;
                item["is_selected"] = object["is_selected"].stringValue;
                item["remain_date"] = object["remain_date"].stringValue;
                item["box_type"] = object["box_type"].stringValue;
                
                m_ListData.append(item)
                
                
            }
        }
        self.uiCollectionView.reloadData()
        self.refreshControl.endRefreshing();
        m_isPagging = false
        LoadingHUD.hide()
        GageSetting()
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
                uiSelOkBtn.frame = CGRect(x: 0, y: Int(uiSelOkBtn.frame.minY), width: Int(uiSelOkBtn.frame.size.width), height: Int(uiSelOkBtn.frame.size.height + bottomPadding))
                uiSelOkBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
            }

        }
    }
    
    func GageSetting(){
        var fm_nNowGage = 0;
        for (_, val) in m_SelListData {
            fm_nNowGage += Int(val["delivery_gauge"] ?? "0") ?? 0
        }
        m_nNowGage = fm_nNowGage
        uiGageLabel.text = String(fm_nNowGage)
        for (i, val) in uiGages.enumerated(){
            if i < fm_nNowGage {
                val.image = UIImage(named:"Gauge_\((i + 1))")
            }else{
                val.image = UIImage(named:"Gauge_non")
            }
            if i == (fm_nNowGage - 1) {
                let pointX = uiGageImgMainView.frame.origin.x + uiGageImgSubView.frame.origin.x + val.frame.origin.x
                uiGagePoint.frame = CGRect(x: pointX, y: 0, width: 50, height:50)
            }
        }
    }
    
    @IBAction func onHelpBtn(_ sender: Any) {
        let m_tWRP = DeliveryPdAddPop.instantiate()
        guard let customAlertVC = m_tWRP else { return }
        let popupVC = PopupViewController(contentController: customAlertVC, popupWidth: (self.view.frame.width - 40), popupHeight: 550)
        popupVC.backgroundAlpha = 0.3
        popupVC.backgroundColor = .black
        popupVC.canTapOutsideToDismiss = true
        popupVC.cornerRadius = 10
        popupVC.shadowEnabled = false
        
        self.present(popupVC, animated: true, completion: nil)
    }
    @IBAction func onSelAcBtn(_ sender: Any) {
        m_tClickEvent?.ClickEvent(celltype : 1, type: 3, data: Array(m_SelListData.values))
        self.navigationController?.popViewController(animated: true);
    }
    
}
extension DeliveryPdAdd:  UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if m_ListData.count > 0 {
            uiCollectionView.backgroundView = nil;
            return m_ListData.count;
        } else {
            ListViewHelper.CollectionViewEmptyMessage(message: "데이터가 없습니다.".localized, viewController: self, tableviewController: uiCollectionView)
            return 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DeliveryPdAddCellidx", for: indexPath) as! DeliveryPdAddCell
        if m_ListData.count > indexPath.row{
            cell.setData(data: m_ListData[indexPath.row], row : indexPath.row);
            if let mypseq = m_ListData[indexPath.row]["my_product_seq"]{
                if !m_SelListData.keys.contains(mypseq) {
                    cell.setChoise(type: false)
                }else{
                    cell.setChoise(type: true)
                }
            }
        }else{
        }
        return cell;
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let mypseq = m_ListData[indexPath.row]["my_product_seq"]{
            if !m_SelListData.keys.contains(mypseq) {
                let fm_nProGage = Int(m_ListData[indexPath.row]["delivery_gauge"] ?? "0") ?? 0
                if (m_nNowGage + fm_nProGage) <= DE_MAXGAGE{
                    m_SelListData[mypseq] = m_ListData[indexPath.row]
                    let cell = (collectionView.cellForItem(at: indexPath) as! DeliveryPdAddCell)
                    cell.setChoise(type: true)
                }else{
                    MessagePop(msg: "선택하신 상품의 배송게이지가 초과되었습니다.".localized,btntype : 2)
                }
            }else{
                m_SelListData.removeValue(forKey: mypseq)
                let cell = (collectionView.cellForItem(at: indexPath) as! DeliveryPdAddCell)
                cell.setChoise(type: false)
            }
            GageSetting()
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (m_ListData.count - 1) == indexPath.row && m_nNextNum > 0 && !m_isPagging{
           self.LoadItem();
        }
    }
    
    
    
}
extension DeliveryPdAdd: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        return CGSize(width: width, height: 105)
    }
    
    func calculateWith() -> CGFloat {
        let estimatedWidth = CGFloat(self.view.frame.size.width)
        let cellCount = floor(CGFloat(self.view.frame.size.width / estimatedWidth))
        
        let margin = CGFloat(cellMarginSize * 2)
        let width = (self.view.frame.size.width - CGFloat(cellMarginSize) * (cellCount - 1) - margin) / cellCount
        
        return width
    }
}
