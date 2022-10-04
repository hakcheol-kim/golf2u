//
//  UserCon.swift
//  golf2u
//
//  Created by 이원영 on 2020/12/03.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON
import EzPopup

class UserCon: VariousViewController {
    private let SO = Single.getSO();
    private let JS = JsonC();
    
    
    @IBOutlet weak var uiCntView: UIView!
    @IBOutlet weak var uiCntLabel: UILabel!
    @IBOutlet weak var uiSortBtn: UIButton!
    
    @IBOutlet weak var uiCollectionView: UICollectionView!
    private var refreshControl = UIRefreshControl()
    
    private var m_ListData = Array<[String:String]>();
    @IBOutlet weak var uiUserBtn: UIButton!
    
    private var m_nPageNum = 0;
    private var m_nNextNum = 0;
    private var m_nDataCnt = 0;
    private var estimateWidth = 60.0
    private var cellMarginSize = 0.0
    
    private var m_sUserSeq : String = "";
    private var m_sSortSeq : String = "0";
    
    private var m_isPagging = false;

    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "1:1 문의".localized)
        super.viewDidLoad()
        
        uiUserBtn.setTitle("문의 작성".localized, for: .normal)
        
        self.uiCntView.layer.addBorder([.top,.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
        uiSortBtn.layer.cornerRadius = 5.0
        uiSortBtn.backgroundColor = .clear
        uiSortBtn.layer.borderWidth = 1
        uiSortBtn.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        m_sUserSeq = SO.getUserInfoKey(key: "seq")
        
        uiCollectionView.delegate = self;
        uiCollectionView.dataSource = self;
        let nib = UINib(nibName: "UserConCell", bundle: nil)
        uiCollectionView.register(nib, forCellWithReuseIdentifier: "UserConCellidx")
        
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
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if #available(iOS 11.0, *) {
            if (UIDevice.current.hasNotch) {
                //아이폰x 부터 하단 safe 영역 버튼이 있으면 여기서 처리
                //let topPadding = self.view.safeAreaInsets.top
                //let leftPadding = self.view.safeAreaInsets.left
                //let rightPadding = self.view.safeAreaInsets.right
                let bottomPadding = self.view.safeAreaInsets.bottom;
                uiUserBtn.frame = CGRect(x: 0, y: Int(uiUserBtn.frame.minY), width: Int(uiUserBtn.frame.size.width), height: Int(uiUserBtn.frame.size.height + bottomPadding))
                uiUserBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
            }

        }
        
    }
    @IBAction func onUserBtn(_ sender: Any) {
        let Storyboard: UIStoryboard = UIStoryboard(name: "UserConAdd", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "UserConAddidx") as! UserConAdd
        self.navigationController?.pushViewController(viewController, animated: true)
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
        JS.getAllUserQna(param: ["pagenum":m_nPageNum,"account_seq":m_sUserSeq,"select_type":m_sSortSeq], callbackf: getAllUserQnaCallback)
    }
    func getAllUserQnaCallback(alldata: JSON)->Void {
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
                item["contents"] = object["contents"].stringValue;
                item["answer"] = object["answer"].stringValue;
                item["state"] = object["state"].stringValue;
                item["answer_state"] = object["answer_state"].stringValue;
                item["qna_category_seq"] = object["qna_category_seq"].stringValue;
                item["qna_category_title"] = object["qna_category_title"].stringValue;
                item["file1"] = object["file1"].stringValue;
                item["file2"] = object["file2"].stringValue;
                item["file3"] = object["file3"].stringValue;
                item["file4"] = object["file4"].stringValue;
                item["file5"] = object["file5"].stringValue;
                item["created_at"] = object["created_at"].stringValue;
                
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
        let alertacop1 = UIAlertAction(title: "전체".localized, style: .default, handler: alertHandleOp1)
        let alertacop2 = UIAlertAction(title: "답변완료".localized, style: .default, handler: alertHandleOp1)
        let alertacop3 = UIAlertAction(title: "미답변".localized, style: .default, handler: alertHandleOp1)
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
            m_sSortSeq = "0";
        }else if alertAction.title! == "답변완료".localized {
            m_sSortSeq = "1";
        }else if alertAction.title! == "미답변".localized {
            m_sSortSeq = "2";
        }
        uiSortBtn.setTitle(alertAction.title!, for: .normal)
        refresh();
    }

}
extension UserCon:  UICollectionViewDelegate, UICollectionViewDataSource {
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserConCellidx", for: indexPath) as! UserConCell
        if m_ListData.count > indexPath.row{
            cell.setData(data: m_ListData[indexPath.row], row: indexPath.row);
            
        }else{
        }
        return cell;
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.view.endEditing(true)
        let Storyboard: UIStoryboard = UIStoryboard(name: "UserConDetail", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "UserConDetailidx") as! UserConDetail
        viewController.setData(data: m_ListData[indexPath.row])
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (m_ListData.count - 1) <= indexPath.row && m_nNextNum > 0  && !m_isPagging{
           
           self.LoadItem();
        }
    }
}
extension UserCon: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        
        return CGSize(width: width, height: 60)
        
    }
    func calculateWith() -> CGFloat {
        let estimatedWidth = CGFloat(self.view.frame.size.width)
        let cellCount = floor(CGFloat(self.view.frame.size.width / estimatedWidth))
        
        let margin = CGFloat(cellMarginSize * 2)
        let width = (self.view.frame.size.width - CGFloat(cellMarginSize) * (cellCount - 1) - margin) / cellCount
        
        return width
    }
}
