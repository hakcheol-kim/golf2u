//
//  TradeStatusList.swift
//  golf2u
//
//  Created by 이원영 on 2020/10/20.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON

class TradeStatusList: VariousViewController {
    
    private let SO = Single.getSO();
    private let JS = JsonC();

    @IBOutlet weak var uiTopTabView: ReportCustomSegmentedControl!{
        didSet{
            uiTopTabView.setButtonTitles(buttonTitles: ["진행중".localized,"완료".localized])
            uiTopTabView.selectorViewColor = UIColor(rgb: 0x00BA87)
            uiTopTabView.selectorTextColor = UIColor(rgb: 0x00BA87)
            uiTopTabView.textColor = .black
            uiTopTabView.backgroundColor = .white
        }
    }
    
    @IBOutlet weak var uiInfoView: UIView!
    @IBOutlet weak var uiCntLabel: UILabel!
    @IBOutlet weak var uiSortBtn: UIButton!
    @IBOutlet weak var uiTabelView: UITableView!
    private var refreshControl = UIRefreshControl()
    
    private var m_ListData = Array<[String:String]>();
    
    private var m_nPageNum = 0;
    private var m_nNextNum = 0;
    private var m_nDataCnt = 0;
    
    private var m_nSelMenu = 0;
    private var m_nSubType = 0;
    private var cellDeleteIndexPath: IndexPath? = nil
    
    private var m_isPagging = false;
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "트레이드현황".localized)
        super.viewDidLoad()
        
        uiSortBtn.layer.cornerRadius = 5.0
        uiSortBtn.backgroundColor = .clear
        uiSortBtn.layer.borderWidth = 1
        uiSortBtn.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        uiTopTabView.delegate = self;
        
        self.uiInfoView.layer.addBorder([.top,.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
        uiCntLabel.TextPartColor(partstr: "0", Color: UIColor(rgb: 0x00BA87))
        
        //table setting
        self.uiTabelView.tableFooterView = UIView(frame: .zero)
        self.uiTabelView.dataSource = self
        self.uiTabelView.delegate = self
        self.uiTabelView.separatorStyle = .none//셀간 줄 없애기
        self.uiTabelView.separatorColor = .white
        self.uiTabelView.layoutMargins = .zero
        self.uiTabelView.cellLayoutMarginsFollowReadableWidth = false
        self.uiTabelView.separatorInset.left = 0
        //테이블뷰 리프레쉬
        if #available(iOS 10.0, *) {
          self.uiTabelView.refreshControl = refreshControl
        } else {
          self.uiTabelView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)//리프레시 이벤트
        //refreshControl.attributedTitle = NSAttributedString(string: "H2Care")
        
        let nibName = UINib(nibName: "TradeStatusListCell", bundle: nil)
        self.uiTabelView.register(nibName, forCellReuseIdentifier: "tradestatuslistcellidx")
        
        LoadItem();

    }
    @objc func refresh(){
        m_nPageNum = 0;
        m_ListData.removeAll();
        LoadItem();
    }
    func LoadItem(){
        LoadingHUD.show()
        m_isPagging = true;
        m_nPageNum += 1;
        JS.TradeStatusList(param: ["pagenum":"\(m_nPageNum)","type":m_nSelMenu, "account_seq" : getUserSeq(), "sub_type" : m_nSubType], callbackf: ProductCommentDetailCallback)
    }
    func ProductCommentDetailCallback(alldata: JSON)->Void {
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
                item["direction"] = object["direction"].stringValue;
                item["name"] = object["name"].stringValue;
                item["profile_image_url"] = object["profile_image_url"].stringValue;
                item["is_retry"] = object["is_retry"].stringValue;
                item["state"] = object["state"].stringValue;
                item["icon_state"] = object["icon_state"].stringValue;
                m_ListData.append(item)
            }
        }
        self.uiTabelView.reloadData()
        self.refreshControl.endRefreshing();
        m_isPagging = false
        LoadingHUD.hide()
    }
    @IBAction func onSortBtn(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: "정렬".localized, preferredStyle: .actionSheet)
        if m_nSelMenu == 0 {
            let alertacop1 = UIAlertAction(title: "거래전체".localized, style: .default, handler: alertHandleOp1)
            let alertacop2 = UIAlertAction(title: "보낸신청".localized, style: .default, handler: alertHandleOp1)
            let alertacop3 = UIAlertAction(title: "받은신청".localized, style: .default, handler: alertHandleOp1)
            let alertacop4 = UIAlertAction(title: "보낸흥정".localized, style: .default, handler: alertHandleOp1)
            let alertacop5 = UIAlertAction(title: "받은흥정".localized, style: .default, handler: alertHandleOp1)
            let cancelAction = UIAlertAction(title: "닫기".localized, style: .cancel, handler: {
                (alert: UIAlertAction!) -> Void in
            })
            optionMenu.addAction(alertacop1)
            optionMenu.addAction(alertacop2)
            optionMenu.addAction(alertacop3)
            optionMenu.addAction(alertacop4)
            optionMenu.addAction(alertacop5)
            optionMenu.addAction(cancelAction)
        }else if m_nSelMenu == 1{
            let alertacop1 = UIAlertAction(title: "거래전체".localized, style: .default, handler: alertHandleOp1)
            let alertacop2 = UIAlertAction(title: "수락".localized, style: .default, handler: alertHandleOp1)
            let alertacop3 = UIAlertAction(title: "거절".localized, style: .default, handler: alertHandleOp1)
            let alertacop4 = UIAlertAction(title: "취소".localized, style: .default, handler: alertHandleOp1)
            let cancelAction = UIAlertAction(title: "닫기".localized, style: .cancel, handler: {
                (alert: UIAlertAction!) -> Void in
            })
            optionMenu.addAction(alertacop1)
            optionMenu.addAction(alertacop2)
            optionMenu.addAction(alertacop3)
            optionMenu.addAction(alertacop4)
            optionMenu.addAction(cancelAction)
        }
        self.present(optionMenu, animated: true, completion: nil)
    }
    func alertHandleOp1(alertAction: UIAlertAction!) -> Void {
        if m_nSelMenu == 0 {
            if alertAction.title! == "거래전체".localized {
                m_nSubType = 0;
            }else if alertAction.title! == "보낸신청".localized {
                m_nSubType = 1;
            }else if alertAction.title! == "받은신청".localized {
                m_nSubType = 2;
            }else if alertAction.title! == "보낸흥정".localized {
                m_nSubType = 3;
            }else if alertAction.title! == "받은흥정".localized {
                m_nSubType = 4;
            }
        }else if m_nSelMenu == 1 {
            if alertAction.title! == "거래전체".localized {
                m_nSubType = 0;
            }else if alertAction.title! == "수락".localized {
                m_nSubType = 1;
            }else if alertAction.title! == "거절".localized {
                m_nSubType = 2;
            }else if alertAction.title! == "취소".localized {
                m_nSubType = 3;
            }
        }
        uiSortBtn.setTitle(alertAction.title!, for: .normal)
        refresh();
    }
}
extension TradeStatusList : ReportCustomSegmentedControlDelegate{
    func changeToIndex(index: Int) {
        if m_nSelMenu == index{
            return;
        }
        m_nSelMenu = index;
        m_nSubType = 0;
        uiSortBtn.setTitle("거래전체".localized, for: .normal)
        refresh();
    }
}
extension TradeStatusList :  UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if m_ListData.count > 0 {
            uiTabelView.backgroundView = nil;
            return m_ListData.count;
        } else {
            ListViewHelper.TableViewEmptyMessage(message: "데이터가 없습니다.".localized, viewController: self, tableviewController: uiTabelView)
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tradestatuslistcellidx", for: indexPath) as! TradeStatusListCell
        if m_ListData.count > indexPath.row{
            cell.setData(data: m_ListData[indexPath.row], row:indexPath.row, viewtype: m_nSelMenu)
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
        return 80;
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //셀 선택시
        var fm_nViewType = 1;
        if m_nSelMenu == 0 {//진행중
            let fm_sIconState = m_ListData[indexPath.row]["icon_state"];
            if fm_sIconState == "0" {//보낸신청
                fm_nViewType = 1;
            }else if fm_sIconState == "1" {//받은신청
                fm_nViewType = 4;
            }else if fm_sIconState == "2" {//보낸흥정
                fm_nViewType = 1;
            }else if fm_sIconState == "3" {//받은흥정
                fm_nViewType = 4;
            }
        }else if m_nSelMenu == 1 {//완료
            let fm_sState = m_ListData[indexPath.row]["state"];
            let fm_sDirection = m_ListData[indexPath.row]["direction"];
            if fm_sState == "2" {//거절
                if fm_sDirection == "0"{//보낸것
                    fm_nViewType = 3;
                }else if fm_sDirection == "1"{//받은것
                    fm_nViewType = 2;
                }
            }else if fm_sState == "3" {//취소
                fm_nViewType = 2;
            }else if fm_sState == "5" {//수락
                fm_nViewType = 2;
            }else if fm_sState == "6" {//흥정
                fm_nViewType = 2;
            }
        }
        let Storyboard: UIStoryboard = UIStoryboard(name: "TradeApplyTry", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "tradeapplytryidx") as! TradeApplyTry
        viewController.setData(viewType: fm_nViewType, TradeSeq: m_ListData[indexPath.row]["seq"]!);
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        var fm_isEdit = false;
        if m_nSelMenu == 1 {
            fm_isEdit = true;
        }
        return fm_isEdit
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "삭제".localized;
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        cellDeleteIndexPath = indexPath
        //let planetToDelete = m_ListData[indexPath.row]
        confirmDelete()
    }

    
    func confirmDelete() {
        if let indexPath = cellDeleteIndexPath {
            LoadingHUD.show()
            JS.TradeStatusListDelete(param: ["trade_seq":m_ListData[indexPath.row]["seq"]!, "account_seq":getUserSeq()], callbackf: TradeStatusListDeleteCallback)
            uiTabelView.beginUpdates()
            m_ListData.remove(at: indexPath.row)
            uiTabelView.deleteRows(at: [indexPath], with: .automatic)
            cellDeleteIndexPath = nil
            uiTabelView.endUpdates()
            uiCntLabel.text = "전체 건".localized(txt: "\(m_ListData.count)");
            uiCntLabel.TextPartColor(partstr: "\(m_ListData.count)", Color: UIColor(rgb: 0x00BA87))
        }
    }
    func TradeStatusListDeleteCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
        }
        LoadingHUD.hide()
    }
    
    
}
