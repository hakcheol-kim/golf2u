//
//  ProductMemberList.swift
//  golf2u
//
//  Created by 이원영 on 2020/10/19.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON

class ProductMemberList: VariousViewController {
    private var SO:Single = Single.getSO();
    private let JS = JsonC();
    
    @IBOutlet weak var uiProductTopView: UIView!
    @IBOutlet weak var uiProductImg: UIImageView!
    @IBOutlet weak var uiProductName: UILabel!
    @IBOutlet weak var uiProductPrice: UILabel!
    @IBOutlet weak var uiDataCntLabel: UILabel!
    
    @IBOutlet weak var uiCollectionView: UICollectionView!
    private var refreshControl = UIRefreshControl()
    
    private var m_sPSeq : String = "";
    
    private var m_ListData = Array<[String:String]>();
    
    private var m_nPageNum = 0;
    private var m_nNextNum = 0;
    private var m_nDataCnt = 0;
    private var estimateWidth = 160.0
    private var cellMarginSize = 5.0
    
    private var m_isPSet : Bool = false;
    private var m_isPagging = false;
    private var m_nType : Int = 0;// 1:상품상세에서 왔지만 다시 상세페이지로 갈경우 그냥 뒤로 보내면됨
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "상품등록고객")
        super.viewDidLoad()
        
        self.uiProductTopView.layer.addBorder([.top,.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)

        uiCollectionView.delegate = self;
        uiCollectionView.dataSource = self;
        let nib = UINib(nibName: "ProductMemberListCell", bundle: nil)
        uiCollectionView.register(nib, forCellWithReuseIdentifier: "productmemberlistidx")
        let flow = UICollectionViewFlowLayout()
        flow.sectionInset = UIEdgeInsets(top: 3, left: 12, bottom: 3, right:12)
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
        
        let tapGestureRecognizer1 = UITapGestureRecognizer(target:self, action: #selector(self.onGotoProductDetail(tapGesture:)))
        tapGestureRecognizer1.numberOfTapsRequired = 1
        uiProductTopView.isUserInteractionEnabled = true
        uiProductTopView.addGestureRecognizer(tapGestureRecognizer1)
        
        uiProductImg.layer.cornerRadius = 8.0;
        
        LoadItem()
    }
    @objc func onGotoProductDetail(tapGesture: UITapGestureRecognizer){
        if m_nType == 0 {
            let Storyboard: UIStoryboard = UIStoryboard(name: "ProductDetail", bundle: nil)
            let viewController = Storyboard.instantiateViewController(withIdentifier: "productdetailide") as! ProductDetailNew
            viewController.InitSetting(seq: m_sPSeq);
            self.navigationController?.pushViewController(viewController, animated: true)
        }else {
            self.navigationController?.popViewController(animated: true);
        }
    }
    func setPSeq(f_sPSeq : String, f_nType : Int = 0){
        self.m_sPSeq = f_sPSeq;
        self.m_nType = f_nType
    }
    
    @objc func refresh(){
        m_isPSet = false;
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
        JS.TradeProductMemberList(param: ["pagenum":"\(m_nPageNum)", "account_seq":getUserSeq(), "product_seq":m_sPSeq], callbackf: TradeProductMemberListCallback)
    }
    func TradeProductMemberListCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            if let val = alldata["nextpage"].string{
                m_nNextNum = Int(val)!;
            }
            if let val = alldata["datacnt"].string{
                m_nDataCnt = Int(val)!;
                uiDataCntLabel.text = "전체 \(m_nDataCnt)건"
                uiDataCntLabel.TextPartColor(partstr: String(m_nDataCnt), Color: UIColor(rgb: 0x00BA87))
            }
            for (_, object) in alldata["data"]["data_arr"] {
                var item = [String:String]()
                item["seq"] = object["seq"].stringValue;
                item["name"] = object["name"].stringValue;
                item["email"] = object["email"].stringValue;
                item["last_reged_at"] = object["last_reged_at"].stringValue;
                item["profile_image_url"] = object["profile_image_url"].stringValue;
                item["comment"] = object["comment"].stringValue;
                item["opposite_blacklisted"] = object["opposite_blacklisted"].stringValue;//해당 회원이 자신을 블랙했는지 여부(0:안함, 그 외:블랙함)
                m_ListData.append(item)
            }
            if !m_isPSet {
                m_isPSet = true;
                uiProductImg.setImage(with: "\(Single.DE_URLIMGSERVER)\(alldata["data"]["thumbnail"])")
                uiProductName.text = alldata["data"]["name"].stringValue
                uiProductPrice.text = (alldata["data"]["price"].stringValue).DecimalWon()
            }
        }
        self.uiCollectionView.reloadData()
        self.refreshControl.endRefreshing();
        m_isPagging = false
        LoadingHUD.hide()
    }


}
extension ProductMemberList:  UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if m_ListData.count > 0 {
            uiCollectionView.backgroundView = nil;
            return m_ListData.count;
        } else {
            ListViewHelper.CollectionViewEmptyMessage(message: "데이터가 없습니다.", viewController: self, tableviewController: uiCollectionView)
            return 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productmemberlistidx", for: indexPath) as! ProductMemberListCell
        if m_ListData.count > indexPath.row{
            cell.setData(data: m_ListData[indexPath.row]);
        }else{
        }
        return cell;
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if super.getUserSeq() == "" {
            //self.view.makeToast("로그인 후 이용해주세요.", duration: 1.0, position: .bottom)
            super.LoginMove()
            return;
        }
        if let opposite_blacklisted = m_ListData[indexPath.row]["opposite_blacklisted"]{
            if opposite_blacklisted != "0"{
                MessagePop(msg: "트레이드가 불가능한 회원입니다".localized, btntype : 2);
                return;
            }
        }
        let Storyboard: UIStoryboard = UIStoryboard(name: "TradeApply", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "tradeapplyidx") as! TradeApply
        viewController.setData(selUSeq: m_ListData[indexPath.row]["seq"]!, selPSeq: m_sPSeq);
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (m_ListData.count - 1) <= indexPath.row && m_nNextNum > 0 && !m_isPagging{
           
           self.LoadItem();
        }
    }
    
}
extension ProductMemberList: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
//        return CGSize(width: width, height: width + 63)
        return CGSize(width: width, height: 90)
    }
    
    func calculateWith() -> CGFloat {
        //        let estimatedWidth = CGFloat(estimateWidth)
        //        let cellCount = floor(CGFloat(self.productCollectionView.frame.size.width / estimatedWidth))
        //
        //        let margin = CGFloat(cellMarginSize * 2)
        //        let width = (self.productCollectionView.frame.size.width - CGFloat(cellMarginSize) * (cellCount - 1) - margin) / cellCount
                
        return (self.uiCollectionView.frame.size.width / 2 - 18)
    }
}
