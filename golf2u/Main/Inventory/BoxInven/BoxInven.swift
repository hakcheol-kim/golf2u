//
//  BoxInven.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/04.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON
import EzPopup



class BoxInven: UIView {
    weak var m_tClickEvent: InventoryMainClickCellBtnDelegate? = nil;
    
    private var SO:Single = Single.getSO();
    private let JS = JsonC();
    
    private let xibName = "BoxInven"
    
    @IBOutlet weak var uiTopView: UIView!
    @IBOutlet weak var uiTableView: UITableView!
    private var refreshControl = UIRefreshControl()
    

    @IBOutlet weak var uiSortBtn: UIButton!
    @IBOutlet weak var uiDataCntLabel: UILabel!
    
    private var m_sUserSeq : String = "";
    
    private var m_nPageNum = 0;
    private var m_nNextNum = 0;
    private var m_nDataCnt = 0;
    private var m_sSortSeq : String = "0";
    
    private var m_ListData = Array<[String:String]>();
    
    private var m_isPagging = false;
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    func setSortBtnText(txt : String){
        uiSortBtn.setTitle(txt, for: .normal)
    }
    
    private func commonInit(){
        let view = Bundle.main.loadNibNamed(xibName, owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        
        self.uiTopView.layer.addBorder([.top,.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
        uiSortBtn.layer.cornerRadius = 5.0
        uiSortBtn.backgroundColor = .clear
        uiSortBtn.layer.borderWidth = 1
        uiSortBtn.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        m_sUserSeq = SO.getUserInfoKey(key: "seq")
        
        uiSortBtn.setTitle("전체박스".localized, for: .normal)
        
        self.uiTableView.tableFooterView = UIView(frame: .zero)
        self.uiTableView.dataSource = self
        self.uiTableView.delegate = self
        self.uiTableView.separatorStyle = .none//셀간 줄 없애기
        self.uiTableView.cellLayoutMarginsFollowReadableWidth = false
        self.uiTableView.separatorInset.left = 0
        //리프레쉬
        if #available(iOS 10.0, *) {
          self.uiTableView.refreshControl = refreshControl
        } else {
          self.uiTableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)//리프레시 이벤트
        //refreshControl.attributedTitle = NSAttributedString(string: "")
        
        let nibName = UINib(nibName: "BoxInvenCell", bundle: nil)
        self.uiTableView.register(nibName, forCellReuseIdentifier: "boxinvencell")
        
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
        m_sUserSeq = SO.getUserInfoKey(key: "seq")
        m_nPageNum += 1;
        JS.InventoryBoxList(param: ["pagenum":"\(m_nPageNum)","account_seq":m_sUserSeq, "select_type":m_sSortSeq], callbackf: InventoryBoxListCallback)
    }
    func InventoryBoxListCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            //self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            if let val  = alldata["nextpage"].string{
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
                item["account_seq"] = object["account_seq"].stringValue;
                item["type"] = object["type"].stringValue;
                item["qeue_revision"] = object["qeue_revision"].stringValue;
                item["purchase_seq"] = object["purchase_seq"].stringValue;
                item["price"] = object["price"].stringValue;
                item["point"] = object["point"].stringValue;
                item["coupon"] = object["coupon"].stringValue;
                item["is_present"] = object["is_present"].stringValue;
                item["created_at"] = object["created_at"].stringValue;
                item["state"] = object["state"].stringValue;
                item["paymented_at"] = object["paymented_at"].stringValue;
                item["cancel_remain_day"] = object["cancel_remain_day"].stringValue;
                item["box_explain"] = object["box_explain"].stringValue;
                item["payment_method"] = object["payment_method"].stringValue;
                m_ListData.append(item)
                
                
            }
        }
        self.uiTableView.reloadData()
        self.refreshControl.endRefreshing();
        m_isPagging = false
        LoadingHUD.hide()
    }
    
    @IBAction func onSortBtn(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: "정렬".localized, preferredStyle: .actionSheet)
        //옵션 초기화
        let alertacop1 = UIAlertAction(title: "전체박스".localized, style: .default, handler: alertHandleOp1)
        let alertacop2 = UIAlertAction(title: "랜덤박스".localized, style: .default, handler: alertHandleOp1)
        let alertacop3 = UIAlertAction(title: "이벤트박스".localized, style: .default, handler: alertHandleOp1)
        let alertacop4 = UIAlertAction(title: "선물받은박스".localized, style: .default, handler: alertHandleOp1)
        let cancelAction = UIAlertAction(title: "닫기".localized, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(alertacop1)
        optionMenu.addAction(alertacop2)
        optionMenu.addAction(alertacop3)
        optionMenu.addAction(alertacop4)
        optionMenu.addAction(cancelAction)
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        window?.rootViewController?.presentedViewController?.present(optionMenu, animated: true, completion: nil)
    }
    func alertHandleOp1(alertAction: UIAlertAction!) -> Void {
        if alertAction.title! == "전체박스".localized {
            m_sSortSeq = "0";
        }else if alertAction.title! == "랜덤박스".localized {
            m_sSortSeq = "1";
        }else if alertAction.title! == "이벤트박스".localized {
            m_sSortSeq = "2";
        }else if alertAction.title! == "선물받은박스".localized {
            m_sSortSeq = "3";
        }
        uiSortBtn.setTitle(alertAction.title!, for: .normal)
        refresh();
    }
    @objc func onProductListBtn(tapGesture: UITapGestureRecognizer){
        let View = tapGesture.view!
        if (View.tag >= 0  && m_ListData.count > View.tag) {
            let m_tWRP = BoxProductListPop.instantiate()
            guard let customAlertVC = m_tWRP else { return }
            m_tWRP?.setData(type: m_ListData[View.tag]["type"]!)
            m_tWRP?.ClickCellHandler = { (seq)-> Void in
                let Storyboard: UIStoryboard = UIStoryboard(name: "ProductDetail", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "productdetailide") as! ProductDetailNew
                viewController.InitSetting(seq: seq);
                
                if let parentVC = self.parentViewController {
                    parentVC.navigationController?.pushViewController(viewController, animated: true)
                }
            }
            let popupVC = PopupViewController(contentController: customAlertVC, popupWidth: (self.frame.width - 40), popupHeight: 520)
            popupVC.backgroundAlpha = 0.3
            popupVC.backgroundColor = .black
            popupVC.canTapOutsideToDismiss = true
            popupVC.cornerRadius = 10
            popupVC.shadowEnabled = false
            
            if let parentVC = self.parentViewController {
                parentVC.present(popupVC, animated: true, completion: nil)
            }
        }
    }
    @objc func onBoxOpenBtn(tapGesture: UITapGestureRecognizer){
        
        let View = tapGesture.view!
        if (View.tag >= 0 && m_ListData.count > View.tag) {
            let Storyboard: UIStoryboard = UIStoryboard(name: "BoxOpen", bundle: nil)
            let viewController = Storyboard.instantiateViewController(withIdentifier: "boxopenidx") as! BoxOpen
            viewController.setData(boxtype: m_ListData[View.tag]["type"]!, boxseq: m_ListData[View.tag]["seq"]!, data: m_ListData[View.tag])
            if let parentVC = self.parentViewController {
                //parentVC.navigationController?.pushViewController(viewController, animated: true)
                viewController.modalPresentationStyle = .fullScreen
                viewController.modalTransitionStyle = .crossDissolve
                parentVC.present(viewController, animated: true, completion: nil)

            }
        }
    }
    @objc func onBoxGiftBtn(tapGesture: UITapGestureRecognizer){
        let View = tapGesture.view!
        if (View.tag >= 0  && m_ListData.count > View.tag) {
//            let Storyboard: UIStoryboard = UIStoryboard(name: "FriendMain", bundle: nil)
//            let viewController = Storyboard.instantiateViewController(withIdentifier: "FriendMainidx") as! FriendMain
//            if let parentVC = self.parentViewController {
//                parentVC.navigationController?.pushViewController(viewController, animated: true)
//            }
            let Storyboard: UIStoryboard = UIStoryboard(name: "GiftCode", bundle: nil)
            let viewController = Storyboard.instantiateViewController(withIdentifier: "GiftCodeidx") as! GiftCode
            viewController.setData(type: Int(m_ListData[View.tag]["type"]!)!, data: m_ListData[View.tag])
            if let parentVC = self.parentViewController {
                parentVC.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    @objc func onBoxBuyBtn(tapGesture: UITapGestureRecognizer){
        let View = tapGesture.view as! UIButton
        if (View.tag >= 0  && m_ListData.count > View.tag) {
            if m_ListData[View.tag]["payment_method"]! == "4" {
                let m_tWRP = BoxBuyCancelPop.instantiate()
                guard let customAlertVC = m_tWRP else { return }
                m_tWRP?.setData(seq: m_ListData[View.tag]["seq"]!, data: m_ListData[View.tag])
                let popupVC = PopupViewController(contentController: customAlertVC, popupWidth: (self.frame.width - 40), popupHeight: 355)
                popupVC.backgroundAlpha = 0.3
                popupVC.backgroundColor = .black
                popupVC.canTapOutsideToDismiss = true
                popupVC.cornerRadius = 10
                popupVC.shadowEnabled = false
                
                if let parentVC = self.parentViewController {
                    parentVC.present(popupVC, animated: true, completion: nil)
                }
            }else{
                m_tClickEvent?.ClickEvent(viewtype : 1, type: 12, data: m_ListData[View.tag])
            }
        }
    }
}
extension BoxInven :  UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if m_ListData.count > 0 {
            uiTableView.backgroundView = nil;
            return m_ListData.count;
        } else {
            ListViewHelper.TableViewEmptyMessage(message: "데이터가 없습니다.".localized, viewController: self, tableviewController: uiTableView)
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "boxinvencell", for: indexPath) as! BoxInvenCell
        if m_ListData.count > indexPath.row{
            cell.setData(data: m_ListData[indexPath.row], row:indexPath.row)
            
            let tapGestureRecognizer1 = UITapGestureRecognizer(target:self, action: #selector(self.onProductListBtn(tapGesture:)))
            tapGestureRecognizer1.numberOfTapsRequired = 1
            cell.uiPdListBtnView.isUserInteractionEnabled = true
            cell.uiPdListBtnView.addGestureRecognizer(tapGestureRecognizer1)
            
            let tapGestureRecognizer2 = UITapGestureRecognizer(target:self, action: #selector(self.onBoxOpenBtn(tapGesture:)))
            tapGestureRecognizer2.numberOfTapsRequired = 1
            cell.uiBoxOpenBtnView.isUserInteractionEnabled = true
            cell.uiBoxOpenBtnView.addGestureRecognizer(tapGestureRecognizer2)
            
            let tapGestureRecognizer3 = UITapGestureRecognizer(target:self, action: #selector(self.onBoxGiftBtn(tapGesture:)))
            tapGestureRecognizer3.numberOfTapsRequired = 1
            cell.uiBoxGiftBtnView.isUserInteractionEnabled = true
            cell.uiBoxGiftBtnView.addGestureRecognizer(tapGestureRecognizer3)
            
            let tapGestureRecognizer4 = UITapGestureRecognizer(target:self, action: #selector(self.onBoxBuyBtn(tapGesture:)))
            tapGestureRecognizer4.numberOfTapsRequired = 1
            cell.uiPayCancelBtn.isUserInteractionEnabled = true
            cell.uiPayCancelBtn.addGestureRecognizer(tapGestureRecognizer4)
        }else{
        }
        
       
        return cell
        
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (m_ListData.count - 1) <= indexPath.row && m_nNextNum > 0 && !m_isPagging{
           self.LoadItem();
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130;
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //셀 선택시
        
    }

    
    
    
}
