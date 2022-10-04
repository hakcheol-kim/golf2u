//
//  NoticeInfo.swift
//  golf2u
//
//  Created by 이원영 on 2020/12/03.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON
import EzPopup

class NoticeInfo: VariousViewController {
    private let SO = Single.getSO();
    private let JS = JsonC();
    
    @IBOutlet weak var uiSearchInput: UITextField!
    @IBOutlet weak var uiSearchBtn: UIImageView!
    
    @IBOutlet weak var uiCntView: UIView!
    @IBOutlet weak var uiCntLabel: UILabel!
    
    @IBOutlet weak var uiCollectionView: UICollectionView!
    private var refreshControl = UIRefreshControl()
    
    private var m_ListData = Array<[String:String]>();
    
    private var m_nPageNum = 0;
    private var m_nNextNum = 0;
    private var m_nDataCnt = 0;
    private var estimateWidth = 160.0
    private var cellMarginSize = 0.0
    
    private var m_sUserSeq : String = "";
    private var m_sKeyWord : String = "";
    
    private var m_isPagging = false;

    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "공지사항".localized)
        super.viewDidLoad()
        
        uiSearchInput.placeholder = "제목 또는 내용을 검색하세요.".localized
        
        m_sUserSeq = super.getUserSeq()
        
        self.uiCntView.layer.addBorder([.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
        uiCollectionView.delegate = self;
        uiCollectionView.dataSource = self;
        let nib = UINib(nibName: "NoticeInfoCell", bundle: nil)
        uiCollectionView.register(nib, forCellWithReuseIdentifier: "NoticeInfoCellidx")
        
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
        
        
        self.uiSearchInput.returnKeyType = .done;
        self.uiSearchInput.delegate = self;
        
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
        JS.getAllNotice(param: ["pagenum":m_nPageNum,"keyword":m_sKeyWord], callbackf: getAllNoticeCallback)
    }
    func getAllNoticeCallback(alldata: JSON)->Void {
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
                item["created_at"] = object["created_at"].stringValue;
                item["title"] = object["title"].stringValue;
                
                m_ListData.append(item)
                
                
            }
        }
        self.uiCollectionView.reloadData()
        self.refreshControl.endRefreshing();
        m_isPagging = false
        LoadingHUD.hide()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    @IBAction func onSearchBtn(_ sender: Any) {
        SearchF()
    }
    func SearchF(){
        let searchkey = uiSearchInput.text!
        if searchkey == "" {
            //return;
        }else if searchkey.count <= 1 {
            MessagePop(msg: "검색어는 2자 이상 입력해주세요.".localized, btntype : 2)
            return;
        }
        m_sKeyWord = searchkey
        refresh()
    }


}
extension NoticeInfo:  UICollectionViewDelegate, UICollectionViewDataSource {
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoticeInfoCellidx", for: indexPath) as! NoticeInfoCell
        if m_ListData.count > indexPath.row{
            cell.setData(data: m_ListData[indexPath.row], row: indexPath.row);
        }else{
        }
        return cell;
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.view.endEditing(true)
        let Storyboard: UIStoryboard = UIStoryboard(name: "NoticeInfoDetail", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "NoticeInfoDetailidx") as! NoticeInfoDetail
        viewController.setData(data: m_ListData[indexPath.row]["seq"] ?? "")
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (m_ListData.count - 1) <= indexPath.row && m_nNextNum > 0  && !m_isPagging{
           
           self.LoadItem();
        }
    }
}
extension NoticeInfo: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        
        return CGSize(width: width, height: 56)
        
    }
    func calculateWith() -> CGFloat {
        let estimatedWidth = CGFloat(self.view.frame.size.width)
        let cellCount = floor(CGFloat(self.view.frame.size.width / estimatedWidth))
        
        let margin = CGFloat(cellMarginSize * 2)
        let width = (self.view.frame.size.width - CGFloat(cellMarginSize) * (cellCount - 1) - margin) / cellCount
        
        return width
    }
}
extension NoticeInfo : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        SearchF()
        return false
    }
}
