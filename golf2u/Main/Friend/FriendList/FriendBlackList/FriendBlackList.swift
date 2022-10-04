//
//  FriendBlackList.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/10.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON
import EzPopup
import SwipeCellKit

class FriendBlackList: VariousViewController {
    weak var m_tClickEvent: ClickCellBtnDelegate? = nil;//FriendMain
    
    private var SO:Single = Single.getSO();
    private let JS = JsonC();

    @IBOutlet weak var uiTopView: UIView!
    @IBOutlet weak var uiCntLabel: UILabel!
    @IBOutlet weak var uiCollectionView: UICollectionView!
    private var refreshControl = UIRefreshControl()
    @IBOutlet weak var uiSearchBtn: UIButton!
    
    private var m_sUserSeq : String = "";
    private var m_nPageNum = 0;
    private var m_nNextNum = 0;
    private var m_nDataCnt = 0;
    private var estimateWidth = 160.0
    private var cellMarginSize = 0.0
    
    private var m_isPagging = false;
    
    private var m_ListData = Array<[String:String]>();
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "블랙리스트".localized)
        super.viewDidLoad()
        
        m_sUserSeq = super.getUserSeq()
        
        self.uiTopView.layer.addBorder([.top,.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        uiCntLabel.TextPartColor(partstr: "0", Color: UIColor(rgb: 0x00BA87))
        
        uiCollectionView.delegate = self;
        uiCollectionView.dataSource = self;
        let nib = UINib(nibName: "FriendListCell", bundle: nil)
        uiCollectionView.register(nib, forCellWithReuseIdentifier: "FriendListCellidx")
        
        let flow = UICollectionViewFlowLayout()
        flow.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right:5)
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
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 11.0, *) {
            if (UIDevice.current.hasNotch) {
                //아이폰x 부터 하단 safe 영역 버튼이 있으면 여기서 처리
                //let topPadding = self.view.safeAreaInsets.top
                //let leftPadding = self.view.safeAreaInsets.left
                //let rightPadding = self.view.safeAreaInsets.right
                let bottomPadding = self.view.safeAreaInsets.bottom;
                uiSearchBtn.frame = CGRect(x: 0, y: Int(uiSearchBtn.frame.minY), width: Int(uiSearchBtn.frame.size.width), height: Int(uiSearchBtn.frame.size.height + bottomPadding))
                uiSearchBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
            }

        }
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
        JS.BlackList(param: ["pagenum":m_nPageNum,"account_seq":m_sUserSeq], callbackf: FriendABlackSearchCallback)
    }
    func FriendABlackSearchCallback(alldata: JSON)->Void {
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
                item["account_seq"] = object["account_seq"].stringValue;
                item["name"] = object["name"].stringValue;
                item["profile_image_url"] = object["profile_image_url"].stringValue;
                item["is_new"] = object["is_new"].stringValue;
                item["created_at"] = object["created_at"].stringValue;
                m_ListData.append(item)
                
                
            }
        }
        self.uiCollectionView.reloadData()
        self.refreshControl.endRefreshing();
        m_isPagging = false
        LoadingHUD.hide()
    }
    
    @IBAction func onSearchBtn(_ sender: Any) {
        m_tClickEvent?.ClickEvent(viewtype : 1, type: 9, data: [:])
    }
    
    @objc func onPCPhoto(tapGesture: UITapGestureRecognizer){
        let imgView = tapGesture.view as! UIImageView
        let fm_sUserImgUrl = "\(Single.DE_URLIMGSERVER)\(m_ListData[imgView.tag]["profile_image_url"] ?? "")"
        m_tClickEvent?.ClickEvent(viewtype: 1, type: 13, data: ["profile_image_url":fm_sUserImgUrl])
        
    }
}
extension FriendBlackList:  UICollectionViewDelegate, UICollectionViewDataSource {
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FriendListCellidx", for: indexPath) as! FriendListCell
        if m_ListData.count > indexPath.row{
            cell.setData(data: m_ListData[indexPath.row], row: indexPath.row, viewtype: 3);
            cell.m_tClickEvent = m_tClickEvent;
            cell.delegate = self
            let tapGestureRecognizer1 = UITapGestureRecognizer(target:self, action: #selector(self.onPCPhoto(tapGesture:)))
            tapGestureRecognizer1.numberOfTapsRequired = 1
            cell.uiUserImg.isUserInteractionEnabled = true
            cell.uiUserImg.addGestureRecognizer(tapGestureRecognizer1)
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
extension FriendBlackList: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        
        return CGSize(width: width, height: 80)
        
    }
    func calculateWith() -> CGFloat {
        let estimatedWidth = CGFloat(self.view.frame.size.width)
        let cellCount = floor(CGFloat(self.view.frame.size.width / estimatedWidth))
        
        let margin = CGFloat(cellMarginSize * 2)
        let width = (self.view.frame.size.width - CGFloat(cellMarginSize) * (cellCount - 1) - margin) / cellCount
        
        return width
    }
}
extension FriendBlackList:  SwipeCollectionViewCellDelegate {

    
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "삭제".localized) { [self] action, indexPath in
            // handle action by updating model with deletion
//            self.JS.NewsRoomCommentDelete(param: ["seq":m_ListData[indexPath.row]["seq"]!], callbackf: NewsRoomCommentDeleteCallback)
            m_tClickEvent?.ClickEvent(viewtype : 1, type: 7, data:  m_ListData[indexPath.row])
            
        }

        // customize the action appearance
        //deleteAction.image = UIImage(named: "delete")
//        let m_US = m_ListData[indexPath.row]["account_seq"];
//        if m_US != m_sUserSeq{
//            return nil;
//        }
        
        return [deleteAction]
    }
}
