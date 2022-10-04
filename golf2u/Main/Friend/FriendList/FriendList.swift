//
//  FriendList.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/09.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwipeCellKit

class FriendList: UIView {
    weak var m_tClickEvent: ClickCellBtnDelegate? = nil;//FriendMain
    private let SO = Single.getSO();
    private let JS = JsonC();

    private let xibName = "FriendList"

    @IBOutlet weak var uiTopView: UIView!
    @IBOutlet weak var uiFriendCntLabel: UILabel!
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
        
        m_sUserSeq = SO.getUserInfoKey(key: "seq")
        
        self.uiTopView.layer.addBorder([.top, .bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
        uiCollectionView.delegate = self;
        uiCollectionView.dataSource = self;
        let nib = UINib(nibName: "FriendListCell", bundle: nil)
        uiCollectionView.register(nib, forCellWithReuseIdentifier: "FriendListCellidx")
        
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
        JS.FriendList(param: ["pagenum":m_nPageNum,"account_seq":m_sUserSeq], callbackf: FriendListCallback)
    }
    func FriendListCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            //self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            if let val = alldata["nextpage"].string{
                m_nNextNum = Int(val)!;
            }
            if let val = alldata["datacnt"].string{
                m_nDataCnt = Int(val)!;
                uiFriendCntLabel.text = "친구 명".localized(txt: "\(m_nDataCnt)");
                uiFriendCntLabel.TextPartColor(partstr: "\(m_nDataCnt)", Color: UIColor(rgb: 0x00BA87))
            }
            for (_, object) in alldata["data"] {
                var item = [String:String]()
                item["seq"] = object["seq"].stringValue;
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
    
    @IBAction func onMainListSearchBtn(_ sender: Any) {
        m_tClickEvent?.ClickEvent(viewtype: 1, type: 4, data: [:])
    }
    
    @IBAction func onBlackBtn(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: "블랙리스트".localized, preferredStyle: .actionSheet)
        //옵션 초기화
        let alertacop1 = UIAlertAction(title: "블랙리스트".localized, style: .default, handler: alertHandleOp1)
        let cancelAction = UIAlertAction(title: "취소".localized, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(alertacop1)
        optionMenu.addAction(cancelAction)
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        window?.rootViewController?.presentedViewController?.present(optionMenu, animated: true, completion: nil)
    }
    func alertHandleOp1(alertAction: UIAlertAction!) -> Void {
        m_tClickEvent?.ClickEvent(viewtype: 1, type: 6, data: [:])
    }
    @objc func onPCPhoto(tapGesture: UITapGestureRecognizer){
        let imgView = tapGesture.view as! UIImageView
        let fm_sUserImgUrl = "\(Single.DE_URLIMGSERVER)\(m_ListData[imgView.tag]["profile_image_url"] ?? "")"
        m_tClickEvent?.ClickEvent(viewtype: 1, type: 13, data: ["profile_image_url":fm_sUserImgUrl])
        
    }
}

extension FriendList:  UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         if SO.getUserInfoKey(key: Single.DE_USERVERIFIED) == "0" {
            ListViewHelper.FriendUVCollectionViewEmptyMessage(viewController: self, tableviewController: uiCollectionView)
            return 0
        }else if m_ListData.count > 0 {
            uiCollectionView.backgroundView = nil;
            return m_ListData.count;
        }else{
            ListViewHelper.CollectionViewEmptyMessage(message: "데이터가 없습니다.".localized, viewController: self, tableviewController: uiCollectionView)
            return 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FriendListCellidx", for: indexPath) as! FriendListCell
        if m_ListData.count > indexPath.row{
            cell.setData(data: m_ListData[indexPath.row], row: indexPath.row, viewtype: 1);
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
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (m_ListData.count - 1) <= indexPath.row && m_nNextNum > 0 && !m_isPagging{
           
           self.LoadItem();
        }
    }
}
extension FriendList: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        
        return CGSize(width: width, height: 60)
        
    }
    func calculateWith() -> CGFloat {
        let estimatedWidth = CGFloat(self.frame.size.width)
        let cellCount = floor(CGFloat(self.frame.size.width / estimatedWidth))
        
        let margin = CGFloat(cellMarginSize * 2)
        let width = (self.frame.size.width - CGFloat(cellMarginSize) * (cellCount - 1) - margin) / cellCount
        
        return width
    }
}

extension FriendList:  SwipeCollectionViewCellDelegate {

    
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "삭제".localized) { [self] action, indexPath in
            // handle action by updating model with deletion
//            self.JS.NewsRoomCommentDelete(param: ["seq":m_ListData[indexPath.row]["seq"]!], callbackf: NewsRoomCommentDeleteCallback)
            m_tClickEvent?.ClickEvent(viewtype : 1, type: 3, data: m_ListData[indexPath.row])
            action.fulfill(with: .delete)
            
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
