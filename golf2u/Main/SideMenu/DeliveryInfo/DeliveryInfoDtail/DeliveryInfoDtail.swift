//
//  DeliveryInfoDtail.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/24.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON

class DeliveryInfoDtail: VariousViewController {
    private let SO = Single.getSO();
    private let JS = JsonC();
    
    @IBOutlet weak var uiTopView: UIView!
    @IBOutlet weak var uiLeftLAbel: UILabel!
    @IBOutlet weak var uiDateLabel: UILabel!
    
    @IBOutlet weak var uiCollectionView: UICollectionView!
    private var refreshControl = UIRefreshControl()
    
    private var m_ListData = Array<[String:String]>();
    
    private var estimateWidth = 160.0
    private var cellMarginSize = 0.0
    
    private var m_sUserSeq : String = "";
    private var m_sDeliSeq : String = ""
    
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "작성 가능한 구매후기".localized)
        super.viewDidLoad()
        
        m_sUserSeq = super.getUserSeq()
        
        uiLeftLAbel.text = "후기를 남길 상품을 선택해주세요.".localized
        uiLeftLAbel.TextPartColor(partstr: "후기".localized, Color: UIColor(rgb: 0x00BA87))
        
        uiTopView.layer.cornerRadius = 8.0
        self.uiCollectionView.layer.addBorder([.top], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
        uiCollectionView.delegate = self;
        uiCollectionView.dataSource = self;
        let nib = UINib(nibName: "DeliveryInfoDtailCell", bundle: nil)
        uiCollectionView.register(nib, forCellWithReuseIdentifier: "DeliveryInfoDtailCellidx")
        
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
        
        
        LoadItem();
    }
    func setData(DeliSeq : String){
        m_sDeliSeq = DeliSeq;
    }
    @objc func refresh(){
        m_ListData.removeAll();
        LoadItem();
    }
    func LoadItem(){
        LoadingHUD.show()
        JS.getOrderComplete(param: ["order_seq":m_sDeliSeq,"account_seq":m_sUserSeq], callbackf: getOrderCompleteCallback)
    }
    func getOrderCompleteCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            
            for (_, object) in alldata["data"]["product_arr"] {
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
            uiDateLabel.text = "배송완료일 | ".localized(txt: "\(alldata["data"]["completed_at_dt"])");
        }
        self.uiCollectionView.reloadData()
        self.refreshControl.endRefreshing();
        LoadingHUD.hide()
    }


}
extension DeliveryInfoDtail:  UICollectionViewDelegate, UICollectionViewDataSource {
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DeliveryInfoDtailCellidx", for: indexPath) as! DeliveryInfoDtailCell
        if m_ListData.count > indexPath.row{
            cell.setData(data: m_ListData[indexPath.row], row: indexPath.row);
        }else{
        }
        return cell;
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let Storyboard: UIStoryboard = UIStoryboard(name: "ProductDetail", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "productdetailide") as! ProductDetailNew
        viewController.InitSetting(seq: m_ListData[indexPath.row]["product_seq"] ?? "0", myseq: m_ListData[indexPath.row]["my_product_seq"] ?? "")
        viewController.setWriteBtn(isv: false)
        viewController.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
}
extension DeliveryInfoDtail: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        
        return CGSize(width: width, height: 120)
        
    }
    func calculateWith() -> CGFloat {
        let estimatedWidth = CGFloat(self.view.frame.size.width)
        let cellCount = floor(CGFloat(self.view.frame.size.width / estimatedWidth))
        
        let margin = CGFloat(cellMarginSize * 2)
        let width = (self.view.frame.size.width - CGFloat(cellMarginSize) * (cellCount - 1) - margin) / cellCount
        
        return width
    }
}
