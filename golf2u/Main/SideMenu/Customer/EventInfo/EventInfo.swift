//
//  EventInfo.swift
//  golf2u
//
//  Created by 이원영 on 2020/12/03.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON
import EzPopup

class EventInfo: VariousViewController {
    private let SO = Single.getSO();
    private let JS = JsonC();

    @IBOutlet weak var uiTopView: UIView!
    @IBOutlet weak var uiCntLabel: UILabel!
    @IBOutlet weak var uiSortBtn: UIButton!
    
    @IBOutlet weak var uiCollectionView: UICollectionView!
    private var refreshControl = UIRefreshControl()
    
    private var m_ListData = Array<[String:String]>();
    
    private var m_nPageNum = 0;
    private var m_nNextNum = 0;
    private var m_nDataCnt = 0;
    private var estimateWidth = 160.0
    private var cellMarginSize = 13.0
    
    private var m_sUserSeq : String = "";
    private var m_sSortType = "0";
    
    private var m_isPagging = false;
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "이벤트".localized)
        super.viewDidLoad()

        m_sUserSeq = super.getUserSeq()
        
        uiSortBtn.layer.cornerRadius = 5.0
        uiSortBtn.backgroundColor = .clear
        uiSortBtn.layer.borderWidth = 1
        uiSortBtn.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        self.uiTopView.layer.addBorder([.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
        uiCollectionView.delegate = self;
        uiCollectionView.dataSource = self;
        let nib = UINib(nibName: "EventInfoCell", bundle: nil)
        uiCollectionView.register(nib, forCellWithReuseIdentifier: "EventInfoCellidx")
        
        let flow = UICollectionViewFlowLayout()
        flow.sectionInset = UIEdgeInsets(top: 5, left: 13, bottom: 5, right:13)
        flow.scrollDirection = .vertical;
        //flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        //flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
        
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
    
    @IBAction func onSortBtn(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: "정렬".localized, preferredStyle: .actionSheet)
        //옵션 초기화
        let alertacop1 = UIAlertAction(title: "전체".localized, style: .default, handler: alertHandleOp1)
        let alertacop2 = UIAlertAction(title: "진행중".localized, style: .default, handler: alertHandleOp1)
        let alertacop3 = UIAlertAction(title: "마감".localized, style: .default, handler: alertHandleOp1)
        let cancelAction = UIAlertAction(title: "닫기".localized, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(alertacop1)
        optionMenu.addAction(alertacop2)
        optionMenu.addAction(alertacop3)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    func alertHandleOp1(alertAction: UIAlertAction!) -> Void {
        if alertAction.title! == "전체".localized {
            m_sSortType = "0";
        }else if alertAction.title! == "진행중".localized {
            m_sSortType = "1";
        }else if alertAction.title! == "마감".localized {
            m_sSortType = "2";
        }
        uiSortBtn.setTitle(alertAction.title!, for: .normal)
        refresh();
    }
    
    @objc func refresh(){
        m_nPageNum = 0;
        m_nNextNum = 0;
        m_nDataCnt = 0;
        m_ListData.removeAll();
        LoadItem();
    }
    func LoadItem(){
        LoadingHUD.show();
        m_isPagging = true;
        m_nPageNum += 1;
        JS.getAllEvent(param: ["pagenum":m_nPageNum,"select_type":m_sSortType], callbackf: getAllEventCallback)
    }
    func getAllEventCallback(alldata: JSON)->Void {
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
                item["title"] = object["title"].stringValue;
                item["type"] = object["type"].stringValue;
                item["image_url"] = object["image_url"].stringValue;
                item["out_link"] = object["out_link"].stringValue;
                item["begin_at"] = object["begin_at"].stringValue;
                item["end_at"] = object["end_at"].stringValue;
                item["period_txt"] = object["period_txt"].stringValue;
                item["available"] = object["available"].stringValue;
                item["event_randing_type"] = object["event_randing_type"].stringValue;
                item["event_btn_type"] = object["event_btn_type"].stringValue;
                item["created_at"] = object["created_at"].stringValue;
                
                m_ListData.append(item)
                
                
            }
        }
        self.uiCollectionView.reloadData()
        self.refreshControl.endRefreshing();
        m_isPagging = false;
        LoadingHUD.hide();
    }
}
extension EventInfo:  UICollectionViewDelegate, UICollectionViewDataSource {
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventInfoCellidx", for: indexPath) as! EventInfoCell
        if m_ListData.count > indexPath.row{
            cell.setData(data: m_ListData[indexPath.row], row: indexPath.row);
        }else{
        }
        return cell;
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.view.endEditing(true)
        let Storyboard: UIStoryboard = UIStoryboard(name: "EventInfoDetail", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "EventInfoDetailidx") as! EventInfoDetail
        viewController.setData(seq: m_ListData[indexPath.row]["seq"] ?? "")
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (m_ListData.count - 1) <= indexPath.row && m_nNextNum > 0 && !m_isPagging{
           
           self.LoadItem();
        }
    }
}
extension EventInfo: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        
        let fm_nHeaderH = (width * (660/1320));
        
        return CGSize(width: width, height: fm_nHeaderH)
        
    }
    func calculateWith() -> CGFloat {
        let estimatedWidth = CGFloat(self.view.frame.size.width)
        let cellCount = floor(CGFloat(self.view.frame.size.width / estimatedWidth))
        
        let margin = CGFloat(cellMarginSize * 2)
        let width = (self.view.frame.size.width - CGFloat(cellMarginSize) * (cellCount - 1) - margin) / cellCount
        
        return width
    }
}
