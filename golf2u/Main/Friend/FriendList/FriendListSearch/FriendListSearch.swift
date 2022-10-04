//
//  FriendListSearch.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/09.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON
import EzPopup
import SwipeCellKit

class FriendListSearch: VariousViewController {
    weak var m_tClickEvent: ClickCellBtnDelegate? = nil;//FriendMain
    private var SO:Single = Single.getSO();
    private let JS = JsonC();
    
    @IBOutlet weak var uiSearchText: UITextField!
    @IBOutlet weak var uiCntView: UIView!
    @IBOutlet weak var uiCntLabel: UILabel!
    @IBOutlet weak var uiCollectionView: UICollectionView!
    private var refreshControl = UIRefreshControl()
    private var m_ListData = Array<[String:String]>();
    
    private var m_sUserSeq : String = "";
    private var m_nPageNum = 0;
    private var m_nNextNum = 0;
    private var m_nDataCnt = 0;
    private var estimateWidth = 160.0
    private var cellMarginSize = 0.0
    
    private var m_nType = 1;//0:블랙검색, 1:친구검색
    
    private var m_sSearchTxt = "";
    
    private var m_isPagging = false;
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "회원 검색".localized)
        super.viewDidLoad()
        
        uiSearchText.placeholder = "검색할 회원의 닉네임이나 이메일을 입력하세요.".localized
        
        m_sUserSeq = super.getUserSeq()
        
        self.uiCntView.layer.addBorder([.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        uiCntLabel.TextPartColor(partstr: "0", Color: UIColor(rgb: 0x00BA87))
        
        self.uiSearchText.returnKeyType = .done;
        self.uiSearchText.delegate = self;
        
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

    }
    func setTypeList(type : Int){
        m_nType = type;
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
        LoadingHUD.show()
        m_nPageNum += 1;
        JS.FriendABlackSearch(param: ["pagenum":m_nPageNum,"account_seq":m_sUserSeq,"keyword":m_sSearchTxt, "type":"\(m_nType)"], callbackf: FriendABlackSearchCallback)
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
                uiCntLabel.text = "명 검색됨".localized(txt: "\(m_nDataCnt)");
                uiCntLabel.TextPartColor(partstr: "\(m_nDataCnt)", Color: UIColor(rgb: 0x00BA87))
            }else{
                
            }
            for (_, object) in alldata["data"] {
                var item = [String:String]()
                item["seq"] = object["seq"].stringValue;
                item["account_seq"] = object["account_seq"].stringValue;
                item["name"] = object["name"].stringValue;
                item["profile_image_url"] = object["profile_image_url"].stringValue;
                item["is_new"] = object["is_new"].stringValue;
                item["created_at"] = object["created_at"].stringValue;
                item["is_related"] = object["is_related"].stringValue;
                m_ListData.append(item)
                
                
            }
        }
        self.uiCollectionView.reloadData()
        self.refreshControl.endRefreshing();
        LoadingHUD.hide()
        m_isPagging = false
    }
    
    @IBAction func onSearchBtn(_ sender: Any) {
        SearchStart()
    }
    func SearchStart(){
        m_sSearchTxt = uiSearchText.text!
        if m_sSearchTxt == "" {
            uiCntLabel.text = "명 검색됨".localized(txt: "0");
            uiCntLabel.TextPartColor(partstr: "0", Color: UIColor(rgb: 0x00BA87))
            MessagePop(msg: "검색어를 입력해주세요.".localized, btntype : 2)
        }
        refresh();
    }
    @objc func onPCPhoto(tapGesture: UITapGestureRecognizer){
        let imgView = tapGesture.view as! UIImageView
        let fm_sUserImgUrl = "\(Single.DE_URLIMGSERVER)\(m_ListData[imgView.tag]["profile_image_url"] ?? "")"
        m_tClickEvent?.ClickEvent(viewtype: 1, type: 13, data: ["profile_image_url":fm_sUserImgUrl])
        
    }
}
extension FriendListSearch : UITextFieldDelegate{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        SearchStart();
        self.view.endEditing(true)
        return false
    }
}
extension FriendListSearch:  UICollectionViewDelegate, UICollectionViewDataSource {
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
            cell.setData(data: m_ListData[indexPath.row], row: indexPath.row, viewtype: (m_nType == 0 ? 4 : 2));
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
extension FriendListSearch: UICollectionViewDelegateFlowLayout {
    
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
extension FriendListSearch:  SwipeCollectionViewCellDelegate {

    
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "삭제".localized) { [self] action, indexPath in
            // handle action by updating model with deletion
//            self.JS.NewsRoomCommentDelete(param: ["seq":m_ListData[indexPath.row]["seq"]!], callbackf: NewsRoomCommentDeleteCallback)
            if m_nType == 1 {
                m_tClickEvent?.ClickEvent(viewtype : 1, type: 3, data: m_ListData[indexPath.row])
            action.fulfill(with: .delete)
            }else{
                m_tClickEvent?.ClickEvent(viewtype : 1, type: 7, data:  m_ListData[indexPath.row])
            }
            
        }

        // customize the action appearance
        //deleteAction.image = UIImage(named: "delete")
//        let m_US = m_ListData[indexPath.row]["account_seq"];
        if m_nType != 1 || m_ListData[indexPath.row]["is_related"] != "1"{
            return nil;
        }
        
        return [deleteAction]
    }
}
