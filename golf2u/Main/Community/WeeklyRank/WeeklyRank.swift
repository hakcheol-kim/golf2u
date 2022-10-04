//
//  WeeklyRank.swift
//  golf2u
//
//  Created by 이원영 on 2020/10/22.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON

class WeeklyRank: UIView {
    public var WeeklyHeaderBtnClickHandler: ((Int , String)->())?
    private var SO:Single = Single.getSO();
    private let JS = JsonC();
    private let xibName = "WeeklyRank"
    
    @IBOutlet weak var uiCollectionVIew: UICollectionView!
    @IBOutlet weak var uiPreBtn: UIButton!
    @IBOutlet weak var uiRuleBtn: UIButton!
    
    private var refreshControl = UIRefreshControl()
    
    private var m_ListData = Array<[String:String]>();
    private var m_nPageNum = 0;
    private var m_nNextNum = 0;
    private var m_nDataCnt = 0;
    private var estimateWidth = 160.0
    private var cellMarginSize = 0.0
    
    private var m_sRanking = "";
    private var m_sScore = "";
    private var m_sUserSeq = "";
    private var m_nHeaderH : CGFloat = 211;
    
    private var m_tHeaher : WeeklyRankHeader?;
    
    private var m_isModifyRank = false
    
    private var m_isPagging = false;
    
    @IBOutlet weak var uiPreBorderBtn: UIButton!
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
        
        //uiPreBorderBtn.layer.addSperater([.right], color: UIColor.white, width: 1.0, heipl: 0)
        
        uiPreBtn.setTitle("이전 랭킹전 보기".localized, for: .normal)
        uiRuleBtn.setTitle("랭킹전 규칙".localized, for: .normal)
        
        uiCollectionVIew.delegate = self;
        uiCollectionVIew.dataSource = self;
        let nib = UINib(nibName: "WeeklyRankCell", bundle: nil)
        uiCollectionVIew.register(nib, forCellWithReuseIdentifier: "weeklyrankcellidx")
        
        let headernib = UINib(nibName: "WeeklyRankHeader", bundle: nil)
        uiCollectionVIew.register(headernib,
                                       forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier:"weeklyrankheaderidx")
        let headernibnotlogin = UINib(nibName: "WeeklyRankNLoginHeader", bundle: nil)
        uiCollectionVIew.register(headernibnotlogin,
                                       forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier:"WeeklyRankNLoginHeaderidx")
        
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
        m_isModifyRank = false;
        m_nPageNum = 0;
        m_nNextNum = 0;
        m_nDataCnt = 0;
        m_ListData.removeAll();
        LoadBanner();
    }
    func LoadBanner(){
        LoadingHUD.show()
        m_sUserSeq = SO.getUserInfoKey(key: "seq")
        if m_sUserSeq == "" {
            let bounds = UIScreen.main.bounds
            let profilewidth = bounds.size.width
            m_nHeaderH = (profilewidth * (720/1440));
        }else{
            let bounds = UIScreen.main.bounds
            let profilewidth = bounds.size.width
            m_nHeaderH = (profilewidth * (720/1440)) + 51;
        }
        JS.WeeklyBanner(param: ["account_seq":m_sUserSeq], callbackf: WeeklyBannerCallback)
    }
    func WeeklyBannerCallback(alldata: JSON)->Void{
        LoadingHUD.hide()
        if alldata["errorcode"] != "0"{
            //self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            m_sRanking = alldata["data"]["ranking"].stringValue;
            //m_sStrSlider = alldata["data"]["box"].stringValue;
            //m_sStrSlider = alldata["data"]["trade"].stringValue;
            m_sScore = alldata["data"]["score"].stringValue;
            LoadItem();
        }
    }
    func LoadItem(){
        LoadingHUD.show()
        m_isPagging = true;
        m_nPageNum += 1;
        JS.WeeklyMainList(param: [:], callbackf: WeeklyMainListCallback)
    }
    func WeeklyMainListCallback(alldata: JSON)->Void {
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
                item["profile_image_url"] = object["profile_image_url"].stringValue;
                item["name"] = object["name"].stringValue;
                item["score"] = object["score"].stringValue;
                m_ListData.append(item)
                
                
            }
        }
        
        self.uiCollectionVIew.reloadData()
        self.refreshControl.endRefreshing();
        m_isPagging = false
        LoadingHUD.hide()
    }
    @IBAction func onWeekRankBtn(_ sender: Any) {
        WeeklyHeaderBtnClickHandler?(0, "")
    }
    @IBAction func onNoticeBtn(_ sender: Any) {
        WeeklyHeaderBtnClickHandler?(1, "")
    }
    @objc func didTapLoginBtn() {
        WeeklyHeaderBtnClickHandler?(2, "")
    }
    @objc func onProPhoto(tapGesture: UITapGestureRecognizer){
        let imgView = tapGesture.view as! UIImageView
        let fm_sUserImgUrl = "\(Single.DE_URLIMGSERVER)\(m_ListData[imgView.tag]["profile_image_url"] ?? "")"
        WeeklyHeaderBtnClickHandler?(3, fm_sUserImgUrl)
        
    }
}
extension WeeklyRank:  UICollectionViewDelegate, UICollectionViewDataSource {
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "weeklyrankcellidx", for: indexPath) as! WeeklyRankCell
        if m_ListData.count > indexPath.row{
            cell.setData(data: m_ListData[indexPath.row], row : indexPath.row);
            let tapGestureRecognizer1 = UITapGestureRecognizer(target:self, action: #selector(self.onProPhoto(tapGesture:)))
            tapGestureRecognizer1.numberOfTapsRequired = 1
            cell.uiUProfileImg.isUserInteractionEnabled = true
            cell.uiUProfileImg.addGestureRecognizer(tapGestureRecognizer1)
        }else{
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (m_ListData.count - 1) <= indexPath.row && m_nNextNum > 0 && !m_isPagging{
           self.LoadItem();
        }
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if m_sUserSeq != "" {
            let nologinheader = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "weeklyrankheaderidx", for: indexPath) as! WeeklyRankHeader;
            if !m_isModifyRank {
            nologinheader.setBanner(rank: m_sRanking, clover: m_sScore)
                m_isModifyRank = true;
            }
            m_tHeaher = nologinheader
            return nologinheader;
        }else{
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "WeeklyRankNLoginHeaderidx", for: indexPath) as! WeeklyRankNLoginHeader;
            header.uiLoginBtn.addTarget(self, action: #selector(didTapLoginBtn), for: .touchUpInside)
            return header;
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
       
        return CGSize(width: self.frame.size.width, height: m_nHeaderH)
    }
    
    
}
extension WeeklyRank: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        return CGSize(width: width, height: 80)
    }
    
    func calculateWith() -> CGFloat {
        let estimatedWidth = CGFloat(self.frame.size.width)
        let cellCount = floor(CGFloat(self.frame.size.width / estimatedWidth))
        
        let margin = CGFloat(cellMarginSize * 2)
        let width = (self.frame.size.width - CGFloat(cellMarginSize) * (cellCount - 1) - margin) / cellCount
        
        return width
    }
}
