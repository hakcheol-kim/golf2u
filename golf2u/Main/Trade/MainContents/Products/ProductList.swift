//
//  ProductList.swift
//  golf2u
//
//  Created by 이원영 on 2020/10/15.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol ItemCellClickDelegate: class {
    func onItemClick(type : Int, Seq : String)
}

class ProductList: UIView {
    weak var ItemCellClick: ItemCellClickDelegate?
    private var SO:Single = Single.getSO();
    private let JS = JsonC();
    private let xibName = "ProductList"
    @IBOutlet weak var uiCollectionView: UICollectionView!
    private var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var uiSortBtn: UIButton!
    @IBOutlet weak var uiResetBtn: UIButton!
    @IBOutlet weak var uidataCntLabel: UILabel!
    
    private var m_ListData = Array<[String:String]>();
    private var SelProductCategory = Array<String>();
    private var m_nMinRange = 0
    private var m_nMaxRange = 8
    private var m_nPageNum = 0;
    private var m_nNextNum = 0;
    private var m_nDataCnt = 0;
    private var estimateWidth = 160.0
    private var cellMarginSize = 5.0
    private var m_sSortSeq : String = "0";
    private var m_sUserSeq : String = "";
    private var m_sKeyWord = "";
    
    private var m_isPagging = false;
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit(){
        let view = Bundle.main.loadNibNamed(xibName, owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        
        uiSortBtn.setTitle("최신순".localized, for: .normal)
        
        uiSortBtn.layer.cornerRadius = 5.0
        uiSortBtn.backgroundColor = .clear
        uiSortBtn.layer.borderWidth = 1
        uiSortBtn.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        m_sUserSeq = SO.getUserInfoKey(key: "seq")
        
        uiCollectionView.delegate = self;
        uiCollectionView.dataSource = self;
        let nib = UINib(nibName: "ProductListCell", bundle: nil)
        uiCollectionView.register(nib, forCellWithReuseIdentifier: "tradeproductlistcell")
        let flow = UICollectionViewFlowLayout()
        flow.sectionInset = UIEdgeInsets(top: 3, left: 13, bottom: 3, right:13)
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
    func ResetSearch(){
        if m_sKeyWord != "" || SelProductCategory.count > 0 || m_nMinRange != 0 || m_nMaxRange != 7{
            uiResetBtn.isHidden = false;
        }else{
            uiResetBtn.isHidden = true;
        }
    }
    @IBAction func onSearchResetBtn(_ sender: Any) {
        SO.TradePSearchReset();
        ItemCellClick?.onItemClick(type: 3, Seq: "")
    }
    @objc func refresh(){
        self.m_sKeyWord = SO.getTradePSearchKeyword()
        self.SelProductCategory = SO.getTradeSelPCategory();
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
        m_nMinRange = SO.getTradeSearchProductMin()
        m_nMaxRange = SO.getTradeSearchProductMax()
        m_sUserSeq = SO.getUserInfoKey(key: "seq")
        JS.TradeProductList(param: ["pagenum":"\(m_nPageNum)", "category_seqs":SelProductCategory, "order_type":m_sSortSeq, "account_seq":m_sUserSeq,"price_underbound":m_nMinRange,"price_upperbound":m_nMaxRange,"keyword":m_sKeyWord], callbackf: TradeProductListCallback)
    }
    func TradeProductListCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            //self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            if let val  = alldata["nextpage"].string{
                m_nNextNum = Int(val)!;
            }
            if let val = alldata["datacnt"].string{
                m_nDataCnt = Int(val)!;
                uidataCntLabel.text = "전체 건".localized(txt: "\(m_nDataCnt)");
                uidataCntLabel.TextPartColor(partstr: "\(m_nDataCnt)", Color: UIColor(rgb: 0x00BA87))
            }
            for (_, object) in alldata["data"] {
                var item = [String:String]()
                item["seq"] = object["seq"].stringValue;
                item["category_seq"] = object["category_seq"].stringValue;
                item["category_name"] = object["category_name"].stringValue;
                item["name"] = object["name"].stringValue;
                item["thumbnail"] = object["thumbnail"].stringValue;
                item["brand"] = object["brand"].stringValue;
                item["price"] = object["price"].stringValue;
                item["event_active"] = object["event_active"].stringValue;
                item["reg_count"] = object["reg_count"].stringValue;
                item["box_type"] = object["box_type"].stringValue;
                m_ListData.append(item)
            }
            ResetSearch();
        }
        self.uiCollectionView.reloadData()
        self.refreshControl.endRefreshing();
        m_isPagging = false
        LoadingHUD.hide()
    }
    @IBAction func onSortBtn(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: "정렬".localized, preferredStyle: .actionSheet)
        //옵션 초기화
        let alertacop1 = UIAlertAction(title: "최신순".localized, style: .default, handler: alertHandleOp1)
        let alertacop2 = UIAlertAction(title: "높은가격순".localized, style: .default, handler: alertHandleOp1)
        let alertacop3 = UIAlertAction(title: "낮은가격순".localized, style: .default, handler: alertHandleOp1)
        let cancelAction = UIAlertAction(title: "닫기".localized, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(alertacop1)
        optionMenu.addAction(alertacop2)
        optionMenu.addAction(alertacop3)
        optionMenu.addAction(cancelAction)
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        window?.rootViewController?.presentedViewController?.present(optionMenu, animated: true, completion: nil)
    }
    func alertHandleOp1(alertAction: UIAlertAction!) -> Void {
        if alertAction.title! == "최신순".localized {
            m_sSortSeq = "0";
        }else if alertAction.title! == "높은가격순".localized {
            m_sSortSeq = "1";
        }else if alertAction.title! == "낮은가격순".localized {
            m_sSortSeq = "2";
        }
        uiSortBtn.setTitle(alertAction.title!, for: .normal)
        refresh();
    }
    
}
extension ProductList:  UICollectionViewDelegate, UICollectionViewDataSource {
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tradeproductlistcell", for: indexPath) as! ProductListCell
        if m_ListData.count > indexPath.row{
            cell.setData(data: m_ListData[indexPath.row]);
        }else{
        }
        return cell;
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if m_ListData.count > indexPath.row{
            ItemCellClick?.onItemClick(type: 0, Seq: m_ListData[indexPath.row]["seq"]!)
        }
//        let Storyboard: UIStoryboard = UIStoryboard(name: "ProductMemberList", bundle: nil)
//        let viewController = Storyboard.instantiateViewController(withIdentifier: "productmemberlistidx") as! ProductMemberList
//        viewController.setPSeq(f_sPSeq: m_ListData[indexPath.row]["seq"]!);
//        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
//        window?.rootViewController?.navigationController?.pushViewController(viewController, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (m_ListData.count - 1) <= indexPath.row && m_nNextNum > 0 && !m_isPagging{
           self.LoadItem();
        }
    }
    
}
extension ProductList: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        return CGSize(width: width, height: width + 67)
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
