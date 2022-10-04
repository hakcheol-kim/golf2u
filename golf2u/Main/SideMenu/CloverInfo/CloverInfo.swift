//
//  CloverInfo.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/24.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON
import EzPopup



class CloverInfo: VariousViewController {
    private let SO = Single.getSO();
    private let JS = JsonC();
    
    @IBOutlet weak var uiTopVIew: UIView!
    @IBOutlet weak var uiCloverLabel: UILabel!
    @IBOutlet weak var uiCollectionView: UICollectionView!
    private var refreshControl = UIRefreshControl()
    
    private var m_ListData = Array<[String:String]>();
    
    private var m_nPageNum = 0;
    private var m_nNextNum = 0;
    private var m_nDataCnt = 0;
    private var estimateWidth = 160.0
    private var cellMarginSize = 0.0
    
    private var m_sUserSeq : String = "";
    
    private var m_isPagging = false;
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "클로버 내역".localized)
        super.viewDidLoad()

        m_sUserSeq = super.getUserSeq()
        
        self.uiTopVIew.layer.addBorder([.top, .bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
        uiCollectionView.delegate = self;
        uiCollectionView.dataSource = self;
        let nib = UINib(nibName: "CloverInfoCell", bundle: nil)
        uiCollectionView.register(nib, forCellWithReuseIdentifier: "CloverInfoCellidx")
        
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
        
        
//        uiCloverLabel.text = SO.getUserInfoKey(key: "point_total").DecimalWon();
        
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
        LoadingHUD.show()
        m_isPagging = true;
        m_nPageNum += 1;
        JS.getAllUserPointHistory(param: ["pagenum":m_nPageNum,"account_seq":m_sUserSeq], callbackf: getAllUserPointHistoryCallback)
    }
    func getAllUserPointHistoryCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            if let val = alldata["nextpage"].string{
                m_nNextNum = Int(val)!;
            }
            if let val = alldata["datacnt"].string{
                m_nDataCnt = Int(val)!;
            }
            if let val = alldata["total_point"].string{
                SO.setUserInfoKey(key: Single.DE_USERCLOVER, value: val )
                uiCloverLabel.text = val.DecimalWon();
            }
            for (_, object) in alldata["data"] {
                var item = [String:String]()
                item["seq"] = object["seq"].stringValue;
                item["amount"] = object["amount"].stringValue;
                item["type"] = object["type"].stringValue;
                item["comment"] = object["comment"].stringValue;
                item["prev_point"] = object["prev_point"].stringValue;
                item["created_at"] = object["created_at"].stringValue;
                m_ListData.append(item)
                
                
            }
        }
        self.uiCollectionView.reloadData()
        self.refreshControl.endRefreshing();
        m_isPagging = false
        LoadingHUD.hide()
    }
    
    @IBAction func onCloverInfoBtn(_ sender: Any) {
        MessagePop(title : "클로버 사용".localized, msg: "클로버는 1개당 1원 가치의 랜덤투유 포인트입니다.\n랜덤박스 및 배송비 결제 시 사용가능합니다.".localized, btntype: 2)
    }
    
}
extension CloverInfo:  UICollectionViewDelegate, UICollectionViewDataSource {
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CloverInfoCellidx", for: indexPath) as! CloverInfoCell
        if m_ListData.count > indexPath.row{
            cell.setData(data: m_ListData[indexPath.row], row: indexPath.row);
        }else{
        }
        return cell;
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (m_ListData.count - 1) <= indexPath.row && m_nNextNum > 0 && !m_isPagging{
           
           self.LoadItem();
        }
    }
}
extension CloverInfo: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        
        return CGSize(width: width, height: 70)
        
    }
    func calculateWith() -> CGFloat {
        let estimatedWidth = CGFloat(self.view.frame.size.width)
        let cellCount = floor(CGFloat(self.view.frame.size.width / estimatedWidth))
        
        let margin = CGFloat(cellMarginSize * 2)
        let width = (self.view.frame.size.width - CGFloat(cellMarginSize) * (cellCount - 1) - margin) / cellCount
        
        return width
    }
}
