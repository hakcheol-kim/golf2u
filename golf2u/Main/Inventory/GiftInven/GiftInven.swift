//
//  GiftInven.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/06.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwipeCellKit

class GiftInven: UIView {
    private let SO = Single.getSO();
    private let JS = JsonC();
    weak var m_tClickEvent: InventoryMainClickCellBtnDelegate? = nil;

    private let xibName = "GiftInven"
    
    @IBOutlet weak var uiTopView: UIView!
    @IBOutlet weak var uiTabBtn1: UIButton!
    @IBOutlet weak var uiTabBtn2: UIButton!
    @IBOutlet weak var uiDataCnt: UILabel!
    @IBOutlet weak var uiSortBtn: UIButton!
    @IBOutlet weak var uiHelpLayout: UILabel!
    @IBOutlet weak var uiCodeBtn: UIButton!
    @IBOutlet weak var uiRecvBtn: UIButton!
    @IBOutlet weak var uiConllectionView: UICollectionView!
    private var refreshControl = UIRefreshControl()
    @IBOutlet weak var uiBottomView: UIView!
    
    private var m_ListData = Array<[String:String]>();
    
    private var m_nPageNum = 0;
    private var m_nNextNum = 0;
    private var m_nDataCnt = 0;
    private var estimateWidth = 160.0
    private var cellMarginSize = 0.0
    
    private var m_nTabIndex = 0;
    
    private var m_sUserSeq : String = "";
    private var m_sSortType = "0";
    
    private var m_nSelMode = 0;
    
    private var m_CVLayout = [NSLayoutConstraint]();
    private var m_BottomLayout = [NSLayoutConstraint]();
    
    private var m_SelListData: Dictionary<String, [String:String]> = Dictionary<String, [String:String]>()
    
    private var m_isAccBtn = false;
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
        
        uiTabBtn1.setTitle("받은 선물".localized, for: .normal)
        uiTabBtn2.setTitle("보낸 선물".localized, for: .normal)
        uiHelpLayout.text = "72시간 내에 상대방이 선물을 수령하지않을경우,\n선물을 보낸 회원에게 반송됩니다.".localized;
        uiCodeBtn.setTitle("선물코드 입력".localized, for: .normal)
        uiRecvBtn.setTitle("선물 수령".localized, for: .normal)
        
        m_sUserSeq = SO.getUserInfoKey(key: "seq")
        
        self.uiTopView.layer.addBorder([.top,.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
        uiTabBtn1.layer.cornerRadius = 8.0;
        uiTabBtn1.layer.borderWidth = 1.0
        uiTabBtn1.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        uiTabBtn2.layer.cornerRadius = 8.0;
        uiTabBtn2.layer.borderWidth = 1.0
        uiTabBtn2.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        uiSortBtn.layer.cornerRadius = 8.0;
        uiSortBtn.layer.borderWidth = 1.0
        uiSortBtn.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        uiDataCnt.TextPartColor(partstr: "0", Color: UIColor(rgb: 0x00BA87))
        uiHelpLayout.TextPartColor(partstr: "72시간 내".localized, Color: UIColor(rgb: 0x00BA87))
        
        uiConllectionView.delegate = self;
        uiConllectionView.dataSource = self;
        let nib = UINib(nibName: "GiftInvenCell", bundle: nil)
        uiConllectionView.register(nib, forCellWithReuseIdentifier: "GiftInvenCellidx")
        
        let flow = UICollectionViewFlowLayout()
        flow.sectionInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right:0)
        flow.scrollDirection = .vertical;
        flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
        
        uiConllectionView.collectionViewLayout = flow
        //리프레쉬
        if #available(iOS 10.0, *) {
          self.uiConllectionView.refreshControl = refreshControl
        } else {
          self.uiConllectionView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)//리프레시 이벤트
        //refreshControl.attributedTitle = NSAttributedString(string: "")
        
        setTab(index: 0)
        setContentsView();
        LoadItem()
    }
    
    func setTab(index : Int){
        if m_nTabIndex == index{
            return;
        }
        m_nTabIndex = index;
        uiTabBtn1.setTitleColor(UIColor(rgb: 0x333333), for: .normal)
        uiTabBtn1.backgroundColor = UIColor(rgb: 0xf8f8f8)
        uiTabBtn2.setTitleColor(UIColor(rgb: 0x333333), for: .normal)
        uiTabBtn2.backgroundColor = UIColor(rgb: 0xf8f8f8)
        if m_nTabIndex == 0 {
            uiTabBtn1.setTitleColor(UIColor.white, for: .normal)
            uiTabBtn1.backgroundColor = UIColor(rgb: 0x00BA87)
        }else if m_nTabIndex == 1{
            uiTabBtn2.setTitleColor(UIColor.white, for: .normal)
            uiTabBtn2.backgroundColor = UIColor(rgb: 0x00BA87)
        }
        setContentsView();
        m_sSortType = "0";
        uiSortBtn.setTitle("전체".localized, for: .normal)
        refresh();
    }
    @IBAction func onTab1(_ sender: Any) {
        setTab(index: 0)
    }
    @IBAction func onTab2(_ sender: Any) {
        setTab(index: 1)
    }
    @IBAction func onCodeACanBtn(_ sender: Any) {
        if m_nSelMode == 0 {
            m_tClickEvent?.ClickEvent(viewtype : 1, type: 7, data: [:])
        }else if m_nSelMode == 1 {
            m_nSelMode = 0
            uiCodeBtn.setTitle("선물코드 입력".localized, for: .normal)
            uiRecvBtn.setTitle("선물 수령".localized, for: .normal)
            m_SelListData.removeAll();
            self.uiConllectionView.reloadData()
        }
    }
    @IBAction func onSelARecvBtn(_ sender: Any) {
        if m_nSelMode == 0 {
            m_nSelMode = 1
            uiCodeBtn.setTitle("취소".localized, for: .normal)
            uiRecvBtn.setTitle("보관함으로 이동".localized, for: .normal)
            self.uiConllectionView.reloadData()
        }else if m_nSelMode == 1 {
            if m_SelListData.count > 0 {
                if m_isAccBtn {
                    return;
                }
                m_isAccBtn = true;
                let Keys = Array(m_SelListData.keys)
                m_tClickEvent?.ClickEvent(viewtype : 1, type: 6, data: Keys)
            }else{
                
            }
        }
    }
    func GiftRecvFinish(){
        m_isAccBtn = false;
    }
    @IBAction func onSortBtn(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: "정렬".localized, preferredStyle: .actionSheet)
        //옵션 초기화
        let alertacop1 = UIAlertAction(title: "전체".localized, style: .default, handler: alertHandleOp1)
        let alertacop2 = UIAlertAction(title: "미수령".localized, style: .default, handler: alertHandleOp1)
        let alertacop3 = UIAlertAction(title: "수령".localized, style: .default, handler: alertHandleOp1)
        let alertacop4 = UIAlertAction(title: "반송".localized, style: .default, handler: alertHandleOp1)
        let alertacop5 = UIAlertAction(title: "코드발행".localized, style: .default, handler: alertHandleOp1)
        let cancelAction = UIAlertAction(title: "닫기".localized, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(alertacop1)
        optionMenu.addAction(alertacop2)
        optionMenu.addAction(alertacop3)
        optionMenu.addAction(alertacop4)
        if m_nTabIndex == 1 {
            optionMenu.addAction(alertacop5)
        }
        optionMenu.addAction(cancelAction)
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        window?.rootViewController?.presentedViewController?.present(optionMenu, animated: true, completion: nil)
    }
    
    func alertHandleOp1(alertAction: UIAlertAction!) -> Void {
        if alertAction.title! == "전체".localized {
            m_sSortType = "0";
        }else if alertAction.title! == "미수령".localized {
            m_sSortType = "1";
        }else if alertAction.title! == "수령".localized {
            m_sSortType = "2";
        }else if alertAction.title! == "반송".localized {
            m_sSortType = "3";
        }else if alertAction.title! == "코드발행".localized {
            m_sSortType = "4";
        }
        uiSortBtn.setTitle(alertAction.title!, for: .normal)
        refresh();
    }
    func setContentsView(){
        if m_BottomLayout.count > 0 {
            //기존에 적용되어있던 레이아웃이 있으면 삭제
            NSLayoutConstraint.deactivate(m_BottomLayout)
        }
        if m_CVLayout.count > 0 {
            //기존에 적용되어있던 레이아웃이 있으면 삭제
            NSLayoutConstraint.deactivate(m_CVLayout)
        }
        uiHelpLayout.translatesAutoresizingMaskIntoConstraints = false
        uiConllectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let leadingCons = uiConllectionView.topAnchor.constraint(equalTo: uiTopView.bottomAnchor,constant: 2)
        let trailingCons = uiConllectionView.leftAnchor.constraint(equalTo:self.leftAnchor,constant: 0)
        let topCons = uiConllectionView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0)
        
        //let bthelpleadingCons = uiConllectionView.topAnchor.constraint(equalTo: uiTopView.bottomAnchor,constant: 2)
        let bthelptrailingCons = uiHelpLayout.leftAnchor.constraint(equalTo:self.leftAnchor,constant: 0)
        let bthelptopCons = uiHelpLayout.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0)
        
        var bottomCons : NSLayoutConstraint?
        var bthelpbottomCons : NSLayoutConstraint?
        
        uiHelpLayout.heightAnchor.constraint(equalToConstant:40).isActive = true;
        if m_nTabIndex == 0 {
            uiBottomView.isHidden = false;
            bthelpbottomCons = uiConllectionView.bottomAnchor.constraint(equalTo: uiBottomView.topAnchor, constant: -40)
            bottomCons = uiConllectionView.bottomAnchor.constraint(equalTo: uiHelpLayout.topAnchor, constant: 0)
            uiHelpLayout.text = "72시간 내에 상대방이선물을수령하지않을경우,\n선물을 보낸 회원에게 반송됩니다.".localized
        }else{
            uiBottomView.isHidden = true;
            bthelpbottomCons = uiConllectionView.bottomAnchor.constraint(equalTo: uiBottomView.topAnchor, constant: 10)
            bottomCons = uiConllectionView.bottomAnchor.constraint(equalTo: uiHelpLayout.topAnchor, constant: 0)
            uiHelpLayout.text = "72시간 내에 상대방이선물을수령하지않을경우,\n선물이 반송되어 보관함으로 돌아옵니다.".localized
            
        }
        m_BottomLayout = [bthelptrailingCons, bthelptopCons, bthelpbottomCons!]
        m_CVLayout = [leadingCons, trailingCons, topCons, bottomCons!]
        //새로운 레이아웃 적용
        
        NSLayoutConstraint.activate(m_CVLayout)
        NSLayoutConstraint.activate(m_BottomLayout)
        
        uiHelpLayout.TextPartColor(partstr: "72시간 내".localized, Color: UIColor(rgb: 0x00BA87))
        
        
//        uiHelpLayout.heightConstraint?.constant = 40;
//        self.layoutIfNeeded()
//        if let parentVC = self.parentViewController {
//            parentVC.view.layoutIfNeeded()
//        }
        
    }
    
    @objc func refresh(){
        m_nPageNum = 0;
        m_nNextNum = 0;
        m_nDataCnt = 0;
        m_ListData.removeAll();
        m_SelListData.removeAll();
        m_nSelMode = 0
        uiCodeBtn.setTitle("선물코드 입력".localized, for: .normal)
        uiRecvBtn.setTitle("선물 수령".localized, for: .normal)
        LoadItem();
    }
    func LoadItem(){
        LoadingHUD.show()
        m_isPagging = true;
        m_sUserSeq = SO.getUserInfoKey(key: "seq")
        m_nPageNum += 1;
        if m_nTabIndex == 0 {
            JS.getAllRecvGift(param: ["pagenum":m_nPageNum,"account_seq":m_sUserSeq, "select_type":m_sSortType], callbackf: getAllGiftCallback)
        }else if m_nTabIndex == 1 {
            JS.getAllSendGift(param: ["pagenum":m_nPageNum,"account_seq":m_sUserSeq,"select_type":m_sSortType], callbackf: getAllGiftCallback)
        }else{
        }
    }
    func getAllGiftCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            //self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            if let val = alldata["nextpage"].string{
                m_nNextNum = Int(val)!;
            }
            if let val = alldata["datacnt"].string{
                m_nDataCnt = Int(val)!;
                uiDataCnt.text = "전체 건".localized(txt: "\(m_nDataCnt)");
                uiDataCnt.TextPartColor(partstr: "\(m_nDataCnt)", Color: UIColor(rgb: 0x00BA87))
            }
            for (_, object) in alldata["data"] {
                var item = [String:String]()
                item["gift_seq"] = object["gift_seq"].stringValue;
                item["name"] = object["name"].stringValue;
                item["profile_image_url"] = object["profile_image_url"].stringValue;
                item["created_at_dt"] = object["created_at_dt"].stringValue;
                item["gift_name"] = object["gift_name"].stringValue;
                item["recv_state"] = object["recv_state"].stringValue;
                item["product_seq"] = object["product_seq"].stringValue;
                item["thumbnail"] = object["thumbnail"].stringValue;
                item["type"] = object["type"].stringValue;
                item["box_type"] = object["box_type"].stringValue;
                item["random_box_seq"] = object["random_box_seq"].stringValue;
                item["code"] = object["code"].stringValue;
                item["box_explain"] = object["box_explain"].stringValue;
                item["my_product_seq"] = object["my_product_seq"].stringValue;
                item["product_name"] = object["product_name"].stringValue;
                item["expired_at"] = object["expired_at"].stringValue;
                item["expired_at_dt"] = object["expired_at_dt"].stringValue;
                item["created_at"] = object["created_at"].stringValue;
                item["remain_date"] = object["remain_date"].stringValue;
                item["price"] = object["price"].stringValue;
                item["paymented_at"] = object["paymented_at"].stringValue;
                item["gift_expired_at_dt"] = object["gift_expired_at_dt"].stringValue;
                
                m_ListData.append(item)
                
                
            }
        }
        self.uiConllectionView.reloadData()
        self.refreshControl.endRefreshing();
        m_isPagging = false
        LoadingHUD.hide()
    }
    @objc func onCellPrdClick(tapGesture: UITapGestureRecognizer){
        if m_nSelMode == 1 {
            return;
        }
        let imgView = tapGesture.view as! UIImageView
        m_tClickEvent?.ClickEvent(viewtype : 1, type: 11, data: ["seq":m_ListData[imgView.tag]["product_seq"] ?? "0", "tabindex":"\(m_nTabIndex)"])
    }
}
extension GiftInven:  UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if m_ListData.count > 0 {
            uiConllectionView.backgroundView = nil;
            return m_ListData.count;
        } else {
            ListViewHelper.CollectionViewEmptyMessage(message: "데이터가 없습니다.".localized, viewController: self, tableviewController: uiConllectionView)
            return 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GiftInvenCellidx", for: indexPath) as! GiftInvenCell
        if m_ListData.count > indexPath.row{
            cell.setData(data: m_ListData[indexPath.row], row: indexPath.row, viewtype: m_nTabIndex, selmode : m_nSelMode);
            cell.delegate = self
            if let mypseq = m_ListData[indexPath.row]["gift_seq"]{
                if !m_SelListData.keys.contains(mypseq) {
                    cell.setChoise(type: false)
                }else{
                    cell.setChoise(type: true)
                }
            }
            let tapGestureRecognizer1 = UITapGestureRecognizer(target:self, action: #selector(self.onCellPrdClick(tapGesture:)))
            tapGestureRecognizer1.numberOfTapsRequired = 1
            cell.uiProImg.isUserInteractionEnabled = true
            cell.uiProImg.addGestureRecognizer(tapGestureRecognizer1)
            
        }else{
        }
        return cell;
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if m_nSelMode != 1 {
            var dataarr = [String:String]();
            dataarr["profile_image_url"] = m_ListData[indexPath.row]["profile_image_url"];
            dataarr["created_at_dt"] = m_ListData[indexPath.row]["created_at_dt"];
            dataarr["gift_name"] = m_ListData[indexPath.row]["gift_name"];
            dataarr["recv_state"] = m_ListData[indexPath.row]["recv_state"];
            dataarr["product_seq"] = m_ListData[indexPath.row]["product_seq"];
            dataarr["thumbnail"] = m_ListData[indexPath.row]["thumbnail"];
            dataarr["type"] = m_ListData[indexPath.row]["box_type"];
            dataarr["random_box_seq"] = m_ListData[indexPath.row]["random_box_seq"];
            dataarr["seq"] = m_ListData[indexPath.row]["random_box_seq"];
            dataarr["code"] = m_ListData[indexPath.row]["code"];
            dataarr["box_explain"] = m_ListData[indexPath.row]["box_explain"];
            dataarr["my_product_seq"] = m_ListData[indexPath.row]["my_product_seq"];
            dataarr["name"] = m_ListData[indexPath.row]["product_name"];
            dataarr["expired_at"] = m_ListData[indexPath.row]["expired_at"];
            dataarr["expired_at_dt"] = m_ListData[indexPath.row]["expired_at_dt"];
            dataarr["created_at"] = m_ListData[indexPath.row]["created_at"];
            dataarr["remain_date"] = m_ListData[indexPath.row]["remain_date"];
            dataarr["price"] = m_ListData[indexPath.row]["price"];
            dataarr["paymented_at"] = m_ListData[indexPath.row]["paymented_at"];
            dataarr["gift_expired_at_dt"] = m_ListData[indexPath.row]["gift_expired_at_dt"];
            dataarr["TabIndex"] = "\(m_nTabIndex)"
            m_tClickEvent?.ClickEvent(viewtype : 1, type: 13, data: dataarr)
        }else{
            if let mypseq = m_ListData[indexPath.row]["gift_seq"] {
                if !m_SelListData.keys.contains(mypseq) {
                    if m_ListData[indexPath.row]["recv_state"] == "1" {
                        m_SelListData[mypseq] = m_ListData[indexPath.row]
                        let cell = (collectionView.cellForItem(at: indexPath) as! GiftInvenCell)
                        cell.setChoise(type: true)
                    }else if m_ListData[indexPath.row]["recv_state"] == "2" {
                        self.makeToast("이미 수령하신 선물입니다.".localized)
                    }else if m_ListData[indexPath.row]["recv_state"] == "3" {
                        self.makeToast("반송 하신 선물입니다.".localized)
                    }else{
                        self.makeToast("잘못된 상품입니다.".localized)
                    }
                }else{
                    m_SelListData.removeValue(forKey: mypseq)
                    let cell = (collectionView.cellForItem(at: indexPath) as! GiftInvenCell)
                    cell.setChoise(type: false)
                }
                
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (m_ListData.count - 1) <= indexPath.row && m_nNextNum > 0 && !m_isPagging{
           
           self.LoadItem();
        }
    }
}
extension GiftInven: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        
        return CGSize(width: width, height: 100)
        
    }
    func calculateWith() -> CGFloat {
        let estimatedWidth = CGFloat(self.frame.size.width)
        let cellCount = floor(CGFloat(self.frame.size.width / estimatedWidth))
        
        let margin = CGFloat(cellMarginSize * 2)
        let width = (self.frame.size.width - CGFloat(cellMarginSize) * (cellCount - 1) - margin) / cellCount
        
        return width
    }
}
extension GiftInven:  SwipeCollectionViewCellDelegate {
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
            self.JS.deleteGift(param: ["account_seq":m_sUserSeq, "gift_seq":m_ListData[indexPath.row]["gift_seq"] ?? ""], callbackf: deleteGiftDeleteCallback)
            //self.m_ListData.remove(at: indexPath.row)
            //self.uiCollectionView.deleteItems(at: [indexPath])
            action.fulfill(with: .delete)
            
        }

        // customize the action appearance
        //deleteAction.image = UIImage(named: "delete")
//        let m_US = m_ListData[indexPath.row]["account_seq"];
        
        //미수령상품 이외 삭제되게
        if m_ListData[indexPath.row]["recv_state"] == "1"{
            return nil;
        }
        
        return [deleteAction]
    }
    
    func deleteGiftDeleteCallback(alldata: JSON)->Void {
        
        if alldata["errorcode"] != "0"{
        }else{
            self.refresh();
        }
        LoadingHUD.hide()
    }
}
