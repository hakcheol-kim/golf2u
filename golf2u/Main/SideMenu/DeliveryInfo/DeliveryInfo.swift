//
//  DeliveryInfo.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/24.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON
import EzPopup
import AppsFlyerLib

protocol DeliveryInfoDelegate: class {
    func ClickEvent(type:Int, data : [String:String])
}
class DeliveryInfo: VariousViewController {
    private let SO = Single.getSO();
    private let JS = JsonC();
    
    @IBOutlet weak var uiSearchInput: UITextField!
    @IBOutlet weak var uiSearchBtn: UIImageView!
    
    @IBOutlet weak var uiCntView: UIView!
    @IBOutlet weak var uiCntLabel: UILabel!
    
    @IBOutlet weak var uiCollectionView: UICollectionView!
    private var refreshControl = UIRefreshControl()
    
    private var m_ListData = Array<[String:String]>();
    
    private var m_nPageNum = 0;
    private var m_nNextNum = 0;
    private var m_nDataCnt = 0;
    private var estimateWidth = 160.0
    private var cellMarginSize = 0.0
    
    private var m_sUserSeq : String = "";
    private var m_sKeyWord : String = "";
    
    private var m_DeliPayCancel : [String : String]?
    
    private var m_isPagging = false;
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "배송 조회".localized)
        super.viewDidLoad()
        
        uiSearchInput.placeholder = "배송 신청 상품을 검색하세요.".localized
        
        m_sUserSeq = super.getUserSeq()
        
        self.uiCntView.layer.addBorder([.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
        uiCollectionView.delegate = self;
        uiCollectionView.dataSource = self;
        let nib = UINib(nibName: "DeliveryInfoCell", bundle: nil)
        uiCollectionView.register(nib, forCellWithReuseIdentifier: "DeliveryInfoCellidx")
        
        let flow = UICollectionViewFlowLayout()
        flow.sectionInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right:0)
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
        
        
        self.uiSearchInput.returnKeyType = .done;
        self.uiSearchInput.delegate = self;
        
        LoadItem();

    }
    @objc func refresh(){
        m_nPageNum = 0;
        m_nNextNum = 0;
        m_nDataCnt = 0;
        m_ListData.removeAll();
        LoadItem();
    }
    func LoadItem(){
        m_isPagging = true;
        m_nPageNum += 1;
        LoadingHUD.show()
        JS.getAllUserOrder(param: ["pagenum":m_nPageNum,"account_seq":m_sUserSeq,"keyword":m_sKeyWord], callbackf: getAllUserOrderCallback)
    }
    func getAllUserOrderCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            if let val = alldata["nextpage"].string{
                m_nNextNum = Int(val)!;
            }
            if let val = alldata["datacnt"].string{
                m_nDataCnt = Int(val)!;
                uiCntLabel.text = "전체 건".localized(txt: "\(m_nDataCnt)");
                uiCntLabel.TextPartColor(partstr: "\(m_nDataCnt)", Color: UIColor(rgb: 0x00BA87))
            }
            for (_, object) in alldata["data"] {
                var item = [String:String]()
                item["seq"] = object["seq"].stringValue;
                item["created_at_dt"] = object["created_at_dt"].stringValue;
                item["state"] = object["state"].stringValue;
                item["name"] = object["name"].stringValue;
                item["thumbnail"] = object["thumbnail"].stringValue;
                item["price"] = object["price"].stringValue;
                item["prd_cnt"] = object["prd_cnt"].stringValue;
                item["pay_txt"] = object["pay_txt"].stringValue;
                item["method_txt"] = object["method_txt"].stringValue;
                item["payment_method"] = object["payment_method"].stringValue;
                item["product_seq"] = object["product_seq"].stringValue;
                item["my_product_seq"] = object["my_product_seq"].stringValue;
                
                m_ListData.append(item)
                
                
            }
        }
        self.uiCollectionView.reloadData()
        self.refreshControl.endRefreshing();
        m_isPagging = false
        LoadingHUD.hide()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    @IBAction func onSearchBtn(_ sender: Any) {
        SearchF()
    }
    func SearchF(){
        let searchkey = uiSearchInput.text!
        if searchkey == "" {
            //return;
        }
        m_sKeyWord = searchkey
        refresh()
    }
}
extension DeliveryInfo:  UICollectionViewDelegate, UICollectionViewDataSource {
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DeliveryInfoCellidx", for: indexPath) as! DeliveryInfoCell
        if m_ListData.count > indexPath.row{
            cell.setData(data: m_ListData[indexPath.row], row: indexPath.row);
            cell.m_tClickEvent = self;
        }else{
        }
        return cell;
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.view.endEditing(true)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (m_ListData.count - 1) <= indexPath.row && m_nNextNum > 0 && !m_isPagging{
           
           self.LoadItem();
        }
    }
}
extension DeliveryInfo: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        
        return CGSize(width: width, height: 140)
        
    }
    func calculateWith() -> CGFloat {
        let estimatedWidth = CGFloat(self.view.frame.size.width)
        let cellCount = floor(CGFloat(self.view.frame.size.width / estimatedWidth))
        
        let margin = CGFloat(cellMarginSize * 2)
        let width = (self.view.frame.size.width - CGFloat(cellMarginSize) * (cellCount - 1) - margin) / cellCount
        
        return width
    }
}
extension DeliveryInfo: DeliveryInfoDelegate {
    func ClickEvent(type:Int, data : [String:String]){
        if type == 1 {
            //배송취소
            if data["payment_method"] == "4" {
                let m_tWRP = DeliveryCancelPop.instantiate()
                guard let customAlertVC = m_tWRP else { return }
                m_tWRP?.setData(seq: data["seq"]!, data: data, tDI: self)
                let popupVC = PopupViewController(contentController: customAlertVC, popupWidth: (self.view.frame.width - 40), popupHeight: 355)
                popupVC.backgroundAlpha = 0.3
                popupVC.backgroundColor = .black
                popupVC.canTapOutsideToDismiss = true
                popupVC.cornerRadius = 10
                popupVC.shadowEnabled = false
                self.present(popupVC, animated: true, completion: nil)
            }else{
                MessagePop(title : "취소 안내".localized, msg: "선택하신 상품의 배송을 취소\n하시겠습니까?".localized, lbtn: "취소".localized, rbtn: "확인".localized,succallbackf: { ()-> Void in
                    self.m_DeliPayCancel = data
                    LoadingHUD.show()
                    self.JS.cancelOrder(param: ["account_seq":self.m_sUserSeq,"order_seq":data["seq"] ?? ""], callbackf: self.cancelOrderCallback)
                }, closecallbackf: { ()-> Void in
                    
                })
            }
        }else if type == 2 {
            //후기입력
            if data["prd_cnt"] == "1" {
//                let Storyboard: UIStoryboard = UIStoryboard(name: "ProductCommentDetail", bundle: nil)
//                let viewController = Storyboard.instantiateViewController(withIdentifier: "productcommentdetailidx") as! ProductCommentDetail
//                viewController.setInitData(seq: data["product_seq"] ?? "", myseq: data["my_product_seq"] ?? "")
//                viewController.setWriteBtn(isv: false)
//                viewController.modalPresentationStyle = .fullScreen
//                self.navigationController?.pushViewController(viewController, animated: true)
                
                let Storyboard: UIStoryboard = UIStoryboard(name: "ProductDetail", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "productdetailide") as! ProductDetailNew
                viewController.InitSetting(seq: data["product_seq"] ?? "", myseq: data["my_product_seq"] ?? "")
                viewController.setWriteBtn(isv: false)
                viewController.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(viewController, animated: true)
            }else{
                let Storyboard: UIStoryboard = UIStoryboard(name: "DeliveryInfoDtail", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "DeliveryInfoDtailidx") as! DeliveryInfoDtail
                viewController.modalPresentationStyle = .fullScreen
                viewController.setData(DeliSeq: data["seq"] ?? "")
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }else if type == 3 {
            //상세정보
            let m_tWRP = DeliveryInfoPop.instantiate()
            guard let customAlertVC = m_tWRP else { return; }
            customAlertVC.setData(DeliSeq: data["seq"] ?? "")
            let popupVC = PopupViewController(contentController: customAlertVC, popupWidth: (self.view.frame.width + Single.DE_TEXTPOPSIZEW), popupHeight: 496)
            popupVC.backgroundAlpha = 0.3
            popupVC.backgroundColor = .black
            popupVC.canTapOutsideToDismiss = true
            popupVC.cornerRadius = 10
            popupVC.shadowEnabled = false
            present(popupVC, animated: true, completion: nil)
        }
    }
    func cancelOrderCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            MessagePop(msg: alldata["errormessage"].stringValue, btntype : 2)
        }else{
            //self.view.makeToast("결제가 취소되었습니다. (환불완료까지 최대 5 영업일이 소요됩니다.)")
            MessagePop(msg: "결제가 취소되었습니다. (환불완료까지 최대 5 영업일이 소요됩니다.)".localized, btntype: 2)
            if let data = m_DeliPayCancel {
                let params : [String: Any] = [
                    "userseq":super.getUserSeq()
                    ,"payInfos":data
                    
                ];
                Analytics(eventname: "deliverycancel", params: params)
                
                let paramsAF : [String: Any] = [
                    AFEventParamReceiptId : data["seq"] ?? "",
                    "af_product_id" : alldata["data"]["product_seqs"],
                    "af_product_category" : alldata["data"]["category_seqs"],
                    "af_product_quantity" : alldata["data"]["product_cnt"],
                    "af_delivery_fee" : alldata["data"]["canceled_price"]
                ];
                AppsflyerLog(AFTitle: "af_delivery_cancel", params: paramsAF)
            }
            refresh()
        }
        LoadingHUD.hide()
    }
}
extension DeliveryInfo : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        SearchF()
        return false
    }
}
