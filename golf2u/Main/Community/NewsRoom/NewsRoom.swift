//
//  NewsRoom.swift
//  golf2u
//
//  Created by 이원영 on 2020/10/22.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON

class NewsRoom: UIView {
    public var CellClickHandler: ((Int, String)->())?
    private var SO:Single = Single.getSO();
    private let JS = JsonC();
    private let xibName = "NewsRoom"
    
    @IBOutlet weak var uiCollectionVIew: UICollectionView!
    private var refreshControl = UIRefreshControl()
    
    private var m_ListData = Array<[String:String]>();
    private var m_nPageNum = 0;
    private var m_nNextNum = 0;
    private var m_nDataCnt = 0;
    private var estimateWidth = 160.0
    private var cellMarginSize = 0.0
    
    private var m_sTopBannerUrl = "";
    private var m_sStrSlider = "";
    private var m_sTopProductUrl = "";
    private var m_sTopProfileUrl = "";
    
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
        
        
        uiCollectionVIew.delegate = self;
        uiCollectionVIew.dataSource = self;
        let nib = UINib(nibName: "NewsRoomCell", bundle: nil)
        uiCollectionVIew.register(nib, forCellWithReuseIdentifier: "newsroomcellidx")
        
        let headernib = UINib(nibName: "NewsRoomHeader", bundle: nil)
        uiCollectionVIew.register(headernib,
                                       forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier:"newsroomheaderidx")
        
        let flow = UICollectionViewFlowLayout()
        flow.sectionInset = UIEdgeInsets(top: 3, left: 0, bottom: 3, right:0)
        flow.scrollDirection = .vertical;
        flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
        uiCollectionVIew.collectionViewLayout = flow
        
        //리프레쉬
        if #available(iOS 10.0, *) {
          self.uiCollectionVIew.refreshControl = refreshControl
        } else {
          self.uiCollectionVIew.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)//리프레시 이벤트
        //refreshControl.attributedTitle = NSAttributedString(string: "")
        
        LoadBanner();
    }
    @objc func refresh(){
        m_nPageNum = 0;
        m_nNextNum = 0;
        m_nDataCnt = 0;
        m_ListData.removeAll();
        LoadBanner();
    }
    func LoadBanner(){
        JS.CommunityBannerNewsRoom(param: [:], callbackf: CommunityBannerNewsRoomCallback)
    }
    func CommunityBannerNewsRoomCallback(alldata: JSON)->Void{
        if alldata["errorcode"] != "0"{
            //self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            m_sTopBannerUrl = alldata["data"]["top_bg"].stringValue;
            m_sStrSlider = alldata["data"]["top_txt"].stringValue;
            m_sTopProductUrl = alldata["data"]["top_product_img"].stringValue;
            m_sTopProfileUrl = alldata["data"]["top_profile_image_url"].stringValue;
            LoadItem();
        }
    }
    func LoadItem(){
        LoadingHUD.show()
        m_isPagging = true;
        m_nPageNum += 1;
        JS.CommunityListNewsRoom(param: ["pagenum":m_nPageNum], callbackf: CommunityListNewsRoomCallback)
    }
    func CommunityListNewsRoomCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
        }else{
            if let val = alldata["nextpage"].string{
                m_nNextNum = Int(val)!;
            }
            if let val = alldata["datacnt"].string{
                m_nDataCnt = Int(val)!;
            }
            for (_, object) in alldata["data"] {
                var item = [String:String]()
                item["my_product_seq"] = object["my_product_seq"].stringValue;
                item["account_seq"] = object["account_seq"].stringValue;
                item["product_seq"] = object["product_seq"].stringValue;
                item["name"] = object["name"].stringValue;
                item["profile_image_url"] = object["profile_image_url"].stringValue;
                item["created_at"] = object["created_at"].stringValue;
                item["thumbnail"] = object["thumbnail"].stringValue;
                item["price"] = object["price"].stringValue;
                item["product_name"] = object["product_name"].stringValue;
                item["comment_cnt"] = object["comment_cnt"].stringValue;
                m_ListData.append(item)
                
                
            }
        }
        self.uiCollectionVIew.reloadData()
        self.refreshControl.endRefreshing();
        m_isPagging = false
        LoadingHUD.hide()
    }
    @objc func onCellPrdClick(tapGesture: UITapGestureRecognizer){
        let imgView = tapGesture.view as! UIImageView
        CellClickHandler?(0, m_ListData[imgView.tag]["product_seq"]!);
    }
    @objc func onCellCommentClick(tapGesture: UITapGestureRecognizer){
        let label = tapGesture.view as! UILabel
        CellClickHandler?(1, m_ListData[label.tag]["my_product_seq"]!);
    }
    @objc func onPCPhoto(tapGesture: UITapGestureRecognizer){
        let imgView = tapGesture.view as! UIImageView
        let fm_sUserImgUrl = "\(Single.DE_URLIMGSERVER)\(m_ListData[imgView.tag]["profile_image_url"] ?? "")"
        CellClickHandler?(2, fm_sUserImgUrl);
        
    }
}
extension NewsRoom:  UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if m_ListData.count > 0 {
            uiCollectionVIew.backgroundView = nil;
            return m_ListData.count;
        } else {
            ListViewHelper.CollectionViewEmptyMessage(message: "데이터가 없습니다.".localized, viewController: self, tableviewController: uiCollectionVIew)
            return 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newsroomcellidx", for: indexPath) as! NewsRoomCell
        if m_ListData.count > indexPath.row{
            cell.setData(data: m_ListData[indexPath.row], row : indexPath.row);
            let tapGestureRecognizer1 = UITapGestureRecognizer(target:self, action: #selector(self.onCellPrdClick(tapGesture:)))
            tapGestureRecognizer1.numberOfTapsRequired = 1
            cell.uiProIMg.isUserInteractionEnabled = true
            cell.uiProIMg.addGestureRecognizer(tapGestureRecognizer1)
            
            let tapGestureRecognizer2 = UITapGestureRecognizer(target:self, action: #selector(self.onCellCommentClick(tapGesture:)))
            tapGestureRecognizer2.numberOfTapsRequired = 1
            cell.uiCommCnt.isUserInteractionEnabled = true
            cell.uiCommCnt.addGestureRecognizer(tapGestureRecognizer2)
            
            let tapGestureRecognizer3 = UITapGestureRecognizer(target:self, action: #selector(self.onPCPhoto(tapGesture:)))
            tapGestureRecognizer3.numberOfTapsRequired = 1
            cell.uiUserImg.isUserInteractionEnabled = true
            cell.uiUserImg.addGestureRecognizer(tapGestureRecognizer3)
        }else{
        }
        return cell;
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //CellClickHandler?(m_ListData[indexPath.row]["my_product_seq"]!);
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (m_ListData.count - 1) <= indexPath.row && m_nNextNum > 0 && !m_isPagging{
           
           self.LoadItem();
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "newsroomheaderidx", for: indexPath) as! NewsRoomHeader;
        header.setBanner(topurl: m_sTopBannerUrl, slidertxt: m_sStrSlider, producturl: m_sTopProductUrl, profileurl: m_sTopProfileUrl)
        //header.m_tClickEvent = self;
        //self.m_tHeaderMCH = header;
        return header;
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let bounds = UIScreen.main.bounds
        let profilewidth = bounds.size.width
        let fm_nHeBanner = (profilewidth * (360/720)) + 40;
        return CGSize(width: self.frame.size.width, height: fm_nHeBanner)
    }
    
}
extension NewsRoom: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        return CGSize(width: width, height: 105)
    }
    
    func calculateWith() -> CGFloat {
        let estimatedWidth = CGFloat(self.frame.size.width)
        let cellCount = floor(CGFloat(self.frame.size.width / estimatedWidth))
        
        let margin = CGFloat(cellMarginSize * 2)
        let width = (self.frame.size.width - CGFloat(cellMarginSize) * (cellCount - 1) - margin) / cellCount
        
        return width
    }
}
