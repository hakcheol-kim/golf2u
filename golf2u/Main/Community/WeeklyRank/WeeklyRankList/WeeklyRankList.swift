//
//  WeeklyRankList.swift
//  golf2u
//
//  Created by 이원영 on 2020/10/23.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON

class WeeklyRankList: VariousViewController {
    private var SO:Single = Single.getSO();
    private let JS = JsonC();
    
    @IBOutlet weak var uiTopView: UIView!
    @IBOutlet weak var uiBottomView: UIView!
    @IBOutlet weak var uiYearWeekLabel: UILabel!
    @IBOutlet weak var uiDateLabel: UILabel!
    @IBOutlet weak var uiCollectionView: UICollectionView!
    private var refreshControl = UIRefreshControl()
    @IBOutlet weak var uiPreBtn: UIButton!
    @IBOutlet weak var uiNextBtn: UIButton!
    
    private var m_ListData = Array<[String:String]>();
    private var estimateWidth = 160.0
    private var cellMarginSize = 0.0
    
    private var m_sTitleMain = "";
    private var m_sTitleSub = "";
    private var m_isNext = "";
    private var m_isPre = "";
    private var m_nWeekNum = 0;
    
    @IBOutlet weak var uiNextBorderBtn: UIButton!
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "지난 랭킹전 결과".localized)
        super.viewDidLoad()
        
        uiPreBtn.setTitle("이전".localized, for: .normal)
        uiNextBtn.setTitle("다음".localized, for: .normal)
        
        //uiNextBorderBtn.layer.addSperater([.left], color: UIColor.white, width: 1.0, heipl: -4.0)
        self.uiNextBorderBtn.layer.addBorder([.left], color: UIColor.white, width: 1.0)
        self.uiTopView.layer.addBorder([.top,.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
        uiCollectionView.delegate = self;
        uiCollectionView.dataSource = self;
        let nib = UINib(nibName: "WeeklyRankListCell", bundle: nil)
        uiCollectionView.register(nib, forCellWithReuseIdentifier: "weeklyranklistcellidx")
        
        let flow = UICollectionViewFlowLayout()
        flow.sectionInset = UIEdgeInsets(top: 3, left: 0, bottom: 3, right:0)
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
                
                let bottomPadding = self.view.safeAreaInsets.bottom;
                uiBottomView.frame = CGRect(x: 0, y: Int(uiBottomView.frame.minY), width: Int(uiBottomView.frame.size.width), height: Int(uiBottomView.frame.size.height + bottomPadding))
                //uiBottomBtnView.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
            }

        }
    }
    @objc func refresh(){
        m_ListData.removeAll();
        LoadItem();
    }
    func LoadItem(){
        LoadingHUD.show()
        JS.WeeklySubList(param: ["week_num":m_nWeekNum], callbackf: WeeklySubListCallback)
    }
    func WeeklySubListCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            if let val = alldata["data"]["date_txt"].string{
                m_sTitleMain = val;
                uiYearWeekLabel.text = m_sTitleMain
            }
            if let val = alldata["data"]["date_txt_sub"].string{
                m_sTitleSub = val;
                uiDateLabel.text = m_sTitleSub
            }
            if let val = alldata["data"]["nextpage"].string{
                m_isNext = val;
            }
            if let val = alldata["data"]["prevpage"].string{
                m_isPre = val;
            }
            if let val = alldata["data"]["week_num"].string{
                m_nWeekNum = Int(val)!
            }
            for (_, object) in alldata["data"]["date_arr"] {
                var item = [String:String]()
                item["profile_image_url"] = object["profile_image_url"].stringValue;
                item["name"] = object["name"].stringValue;
                item["score"] = object["score"].stringValue;
                m_ListData.append(item)
            }
        }
        self.uiCollectionView.reloadData()
        self.refreshControl.endRefreshing();
        LoadingHUD.hide()
    }

    @IBAction func onPreBtn(_ sender: Any) {
        if m_isPre != "1"{
            return;
        }
        m_nWeekNum -= 1;
        refresh();
    }
    @IBAction func onNextBtn(_ sender: Any) {
        if m_isNext != "1"{
            return;
        }
        m_nWeekNum += 1;
        refresh();
    }
    @objc func onProPhoto(tapGesture: UITapGestureRecognizer){
        let imgView = tapGesture.view as! UIImageView
        let fm_sUserImgUrl = "\(Single.DE_URLIMGSERVER)\(m_ListData[imgView.tag]["profile_image_url"] ?? "")"
        super.ProfileImagePlus(UserImgUrl: fm_sUserImgUrl)
        
    }

}
extension WeeklyRankList:  UICollectionViewDelegate, UICollectionViewDataSource {
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "weeklyranklistcellidx", for: indexPath) as! WeeklyRankListCell
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
    
}
extension WeeklyRankList: UICollectionViewDelegateFlowLayout {
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
