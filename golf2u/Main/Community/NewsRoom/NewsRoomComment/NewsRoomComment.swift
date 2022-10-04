//
//  NewsRoomComment.swift
//  golf2u
//
//  Created by 이원영 on 2020/10/22.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON
import NBBottomSheet
import Toast_Swift
import ImageSlideshow
import SwipeCellKit

class NewsRoomComment: VariousViewController {
    private let SO = Single.getSO();
    private let JS = JsonC();
    
    private var m_ListData = Array<[String:String]>();

    @IBOutlet weak var uiInfoView: UIView!
    @IBOutlet weak var uiDataCntLabel: UILabel!
    @IBOutlet weak var uiSortBtn: UIButton!
    @IBOutlet weak var uiCollectionView: UICollectionView!
    private var refreshControl = UIRefreshControl()
    
    private var m_sSortSeq : String = "0";
    
    private var m_nPageNum = 0;
    private var m_nNextNum = 0;
    private var m_nDataCnt = 0;
    private var estimateWidth = 160.0
    private var cellMarginSize = 5.0
    
    private var m_sMPSeq : String = "";
    private var m_sUserSeq : String = "";
    private var m_sPrentSeq : String = "";
    
    private var cellDeleteIndexPath: IndexPath? = nil
    
    private var m_isPagging = false;
    
    private let m_isUserPZoom = ImageSlideshow()
    
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "축하 댓글".localized)
        super.viewDidLoad()
        
        uiSortBtn.layer.cornerRadius = 8.0;
        uiSortBtn.layer.borderWidth = 1.0
        uiSortBtn.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        self.uiInfoView.layer.addBorder([.top,.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
        uiCollectionView.delegate = self;
        uiCollectionView.dataSource = self;
        let nib = UINib(nibName: "NewsRoomCommentCell", bundle: nil)
        uiCollectionView.register(nib, forCellWithReuseIdentifier: "newsroomcommentcellidx")
        
        let flow = UICollectionViewFlowLayout()
        flow.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right:0)
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
    func setData(my_product_seq : String){
        m_sMPSeq = my_product_seq;
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
        m_sUserSeq = getUserSeq();
        m_nPageNum += 1;
        JS.CommunityCommentListNewsRoom(param: ["pagenum":m_nPageNum,"my_product_seq":m_sMPSeq,"include_2nd":"1","account_seq":super.getUserSeq(),"order_type":m_sSortSeq], callbackf: CommunityCommentListNewsRoomCallback)
    }
    func CommunityCommentListNewsRoomCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            if let val = alldata["nextpage"].string{
                m_nNextNum = Int(val)!;
            }
            if let val = alldata["datacnt"].string{
                m_nDataCnt = Int(val)!;
                uiDataCntLabel.text = "전체 건".localized(txt: "\(m_nDataCnt)");
                uiDataCntLabel.TextPartColor(partstr: "\(m_nDataCnt)", Color: UIColor(rgb: 0x00BA87))
            }
            for (_, object) in alldata["data"] {
                var item = [String:String]()
                item["seq"] = object["seq"].stringValue;
                item["contents"] = object["contents"].stringValue;
                item["file1"] = object["file1"].stringValue;
                item["file2"] = object["file2"].stringValue;
                item["created_at"] = object["created_at"].stringValue;
                item["account_seq"] = object["account_seq"].stringValue;
                item["name"] = object["name"].stringValue;
                item["profile_image_url"] = object["profile_image_url"].stringValue;
                item["email"] = object["email"].stringValue;
                item["level"] = object["level"].stringValue;
                item["comments_cnt"] = object["comments_cnt"].stringValue;
                item["like_cnt"] = object["like_cnt"].stringValue;
                item["liked"] = object["liked"].stringValue;
                m_ListData.append(item)
                
                
            }
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
        let alertacop2 = UIAlertAction(title: "좋아요순".localized, style: .default, handler: alertHandleOp1)
        let cancelAction = UIAlertAction(title: "닫기".localized, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(alertacop1)
        optionMenu.addAction(alertacop2)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    func alertHandleOp1(alertAction: UIAlertAction!) -> Void {
        if alertAction.title! == "최신순".localized {
            m_sSortSeq = "0";
        }else if alertAction.title! == "좋아요순".localized {
            m_sSortSeq = "1";
        }
        uiSortBtn.setTitle(alertAction.title!, for: .normal)
        refresh();
    }
    @IBAction func onWriteBtn(_ sender: Any) {
        m_sPrentSeq = "";
        WirteComment();
    }
    func WirteComment(){
        if m_sUserSeq == ""{
            //self.view.makeToast("로그인 후 이용해주세요.", duration: 1.0, position: .bottom)
            super.LoginMove()
            return;
        }
        let configuration = NBBottomSheetConfiguration(animationDuration: 0.4, sheetSize: .fixed(143))
        let bottomSheetController = NBBottomSheetController(configuration:configuration)
        let viewController = NewsRoomCommentPop(f_sMPSeq: m_sMPSeq, f_sPrentSeq: m_sPrentSeq)
        viewController.closeHandler = { ()-> Void in
            self.refresh();
        }
        bottomSheetController.present(viewController, on: self)
    }
    @objc func onPCPhoto(tapGesture: UITapGestureRecognizer){
        let imgView = tapGesture.view as! UIImageView
        if (imgView.tag >= 0) //Give your image View tag
        {
            m_isUserPZoom.removeFromSuperview()
            self.view.addSubview(m_isUserPZoom)
            var m_tPicArr = [KingfisherSource]();
            var tumpimgcnt = 0;
            for i in 1...2{
                if let imgurl = m_ListData[imgView.tag]["file\(i)"] {
                    if imgurl == "" {
                        continue;
                    }
                    tumpimgcnt += 1;
                    let fm_sUrlS = "\(Single.DE_URLIMGSERVER)\(imgurl)";
                    if let URLString = KingfisherSource(urlString: fm_sUrlS){
                        m_tPicArr.append(URLString)
                    }
                }
            }
            if tumpimgcnt <= 0{
                return;
            }
            m_isUserPZoom.setImageInputs(m_tPicArr)
            let fullScreenController = m_isUserPZoom.presentFullScreenController(from: self)
            fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .medium, color: nil)
        }
        else{

        }
    }
    @objc func onProPhoto(tapGesture: UITapGestureRecognizer){
        let imgView = tapGesture.view as! UIImageView
        let fm_sUserImgUrl = "\(Single.DE_URLIMGSERVER)\(m_ListData[imgView.tag]["profile_image_url"] ?? "")"
        super.ProfileImagePlus(UserImgUrl: fm_sUserImgUrl)
        
    }
}
extension NewsRoomComment:  UICollectionViewDelegate, UICollectionViewDataSource {
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newsroomcommentcellidx", for: indexPath) as! NewsRoomCommentCell
        if m_ListData.count > indexPath.row{
            cell.setData(data: m_ListData[indexPath.row], row: indexPath.row);
            cell.CoCoHandler = { (seq : String)-> Void in
                self.m_sPrentSeq = seq;
                self.WirteComment();
            }
            let tapGestureRecognizer1 = UITapGestureRecognizer(target:self, action: #selector(self.onPCPhoto(tapGesture:)))
            tapGestureRecognizer1.numberOfTapsRequired = 1
            cell.uiProImg.isUserInteractionEnabled = true
            cell.uiProImg.addGestureRecognizer(tapGestureRecognizer1)
            cell.delegate = self
            cell.LikeBtnHandler = { ()-> Void in
                super.LoginMove()
            }
            let tapGestureRecognizer2 = UITapGestureRecognizer(target:self, action: #selector(self.onProPhoto(tapGesture:)))
            tapGestureRecognizer2.numberOfTapsRequired = 1
            cell.uiUserImg.isUserInteractionEnabled = true
            cell.uiUserImg.addGestureRecognizer(tapGestureRecognizer2)
            
            
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
extension NewsRoomComment:  SwipeCollectionViewCellDelegate {
//    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
//        var options = SwipeOptions()
//
//        options.expansionStyle = .destructive
//        options.transitionStyle = .border
//        return options
//    }
    
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "삭제".localized) { [self] action, indexPath in
            // handle action by updating model with deletion
            LoadingHUD.show()
            self.JS.NewsRoomCommentDelete(param: ["seq":m_ListData[indexPath.row]["seq"]!], callbackf: NewsRoomCommentDeleteCallback)
            //self.m_ListData.remove(at: indexPath.row)
            //self.uiCollectionView.deleteItems(at: [indexPath])
            action.fulfill(with: .delete)
            
        }

        // customize the action appearance
        //deleteAction.image = UIImage(named: "delete")
        let m_US = m_ListData[indexPath.row]["account_seq"];
        if m_US != m_sUserSeq{
            return nil;
        }
        
        return [deleteAction]
    }
    
    func NewsRoomCommentDeleteCallback(alldata: JSON)->Void {
        
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            self.refresh();
        }
        LoadingHUD.hide()
    }
}

extension NewsRoomComment: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = self.calculateWith()
        if m_ListData[indexPath.row]["level"] == "1" {
            width -= 26
        }
        var heightT : CGFloat = 110.0;
        
        if let heightlabel = m_ListData[indexPath.row]["contents"] {
            heightT += heightlabel.heightT(withConstrainedWidth: width - 115, font: UIFont.systemFont(ofSize: CGFloat(12)))
        }
        
        return CGSize(width: width, height: heightT)
        
        //return CGSize(width: width, height: 126)
    }
    func calculateWith() -> CGFloat {
        let estimatedWidth = CGFloat(self.view.frame.size.width)
        let cellCount = floor(CGFloat(self.view.frame.size.width / estimatedWidth))
        
        let margin = CGFloat(cellMarginSize * 2)
        let width = (self.view.frame.size.width - CGFloat(cellMarginSize) * (cellCount - 1) - margin) / cellCount
        
        return width
    }
}
