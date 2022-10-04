//
//  PushLIst.swift
//  golf2u
//
//  Created by 이원영 on 2020/12/07.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON

/*
 private var m_isPagging = false;
 
 m_isPagging = true;
 
 m_isPagging = false
 
 && !m_isPagging
 */

class PushLIst: VariousViewController {
    private let SO = Single.getSO();
    private let JS = JsonC();
    private let JS1 = JsonC();
    
    @IBOutlet weak var uiTopTabView: ReportCustomSegmentedControl!{
        didSet{
            uiTopTabView.setButtonTitles(buttonTitles: ["랜덤투유 알림".localized,"트레이드 알림".localized])
            uiTopTabView.selectorViewColor = UIColor(rgb: 0x00BA87)
            uiTopTabView.selectorTextColor = UIColor(rgb: 0x00BA87)
            uiTopTabView.textColor = .black
            uiTopTabView.backgroundColor = .white
        }
    }
    
    @IBOutlet weak var uiTabelView: UITableView!
    private var refreshControl = UIRefreshControl()
    @IBOutlet weak var uiBottomView: UIView!
    
    private var m_ListData = Array<[String:String]>();
    
    private var m_nPageNum = 0;
    private var m_nNextNum = 0;
    private var m_nDataCnt = 0;
    
    private var m_nSelMenu = 0;
    private var cellDeleteIndexPath: IndexPath? = nil
    
    private var m_nMaxSeq = 0;
    
    private var m_saPushSeqs = [String]()
    
    private var m_isPagging = false;

    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "알림".localized)
        super.viewDidLoad()
        
        uiTopTabView.delegate = self;
        
        self.uiTabelView.layer.addBorder([.top], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        self.uiBottomView.layer.addBorder([.top], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
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
        
        let nibName = UINib(nibName: "PushLIstCell", bundle: nil)
        self.uiTabelView.register(nibName, forCellReuseIdentifier: "PushLIstCellidx")
        
        m_saPushSeqs = UserDefaults.standard.array(forKey: Single.DE_PUSHLOCALSAVESEQ) as? [String] ?? [String]()
        
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
                uiBottomView.frame = CGRect(x: 0, y: Int(uiBottomView.frame.minY), width: Int(uiBottomView.frame.size.width), height: Int(uiBottomView.frame.size.height + bottomPadding))
                
            }

        }
    }
    @objc func refresh(){
        m_nPageNum = 0;
        m_ListData.removeAll();
        LoadItem();
    }
    func LoadItem(){
        m_isPagging = true;
        m_nPageNum += 1;
        LoadingHUD.show();
        JS.getAllUserNotification(param: ["pagenum":"\(m_nPageNum)","type":m_nSelMenu, "account_seq" : getUserSeq()], callbackf: getAllUserNotificationCallback)
    }
    func getAllUserNotificationCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            if let val = alldata["nextpage"].string{
                m_nNextNum = Int(val)!;
            }
            if let val = alldata["datacnt"].string{
                m_nDataCnt = Int(val)!;
            }
            for (_, object) in alldata["data"] {
                var item = [String:String]()
                item["noti_seq"] = object["noti_seq"].stringValue;
                item["title"] = object["title"].stringValue;
                item["content"] = object["content"].stringValue;
                item["account_seq"] = object["account_seq"].stringValue;
                item["type"] = object["type"].stringValue;
                item["subtype"] = object["subtype"].stringValue;
                item["target_seq"] = object["target_seq"].stringValue;
                item["created_at"] = object["created_at"].stringValue;
                m_ListData.append(item)
                
                let fm_nMaxSeq = Int(item["noti_seq"] ?? "0") ?? 0
                if fm_nMaxSeq > m_nMaxSeq {
                    m_nMaxSeq = fm_nMaxSeq;
                    JS1.updateLast(param: ["noti_seq":"\(m_nMaxSeq)", "account_seq" : getUserSeq()], callbackf: updateLastCallback)
                }
            }
            
        }
        self.uiTabelView.reloadData()
        self.refreshControl.endRefreshing();
        m_isPagging = false
        LoadingHUD.hide();
    }
    func updateLastCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
        }
    }
    func MoveDetailView(type : String, subtype : String, seq : String){
        if type == "0" {
            if subtype == "0" {
                //트레이드 신청 받은거
                let Storyboard: UIStoryboard = UIStoryboard(name: "TradeApplyTry", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "tradeapplytryidx") as! TradeApplyTry
                viewController.setData(viewType: 4, TradeSeq: seq);
                self.navigationController?.pushViewController(viewController, animated: true)
            }else if subtype == "1" {
                let Storyboard: UIStoryboard = UIStoryboard(name: "TradeApplyTry", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "tradeapplytryidx") as! TradeApplyTry
                viewController.setData(viewType: 3, TradeSeq: seq);
                self.navigationController?.pushViewController(viewController, animated: true)
            }else if subtype == "2" {
                let fm_Contrllers = self.navigationController?.viewControllers
                if let val = fm_Contrllers{
                    for VC in val{
                        if VC is StartMain {
                            SO.setInventoryTabIdx(TabbarIndex: 1)
                            self.tabBarController?.selectedIndex = 3;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }else if VC is TradeMain {
                            SO.setInventoryTabIdx(TabbarIndex: 1)
                            self.tabBarController?.selectedIndex = 3;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }else if VC is CommunityMain {
                            SO.setInventoryTabIdx(TabbarIndex: 1)
                            self.tabBarController?.selectedIndex = 3;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }else if VC is InventoryMain {
                            SO.setInventoryTabIdx(TabbarIndex: 1)
                            self.tabBarController?.selectedIndex = 3;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }
                        
                    }
                }
            }else if subtype == "3" {
                let Storyboard: UIStoryboard = UIStoryboard(name: "TradeApplyTry", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "tradeapplytryidx") as! TradeApplyTry
                viewController.setData(viewType: 3, TradeSeq: seq);
                self.navigationController?.pushViewController(viewController, animated: true)
            }else if subtype == "5" {
                let Storyboard: UIStoryboard = UIStoryboard(name: "TradeApplyTry", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "tradeapplytryidx") as! TradeApplyTry
                viewController.setData(viewType: 2, TradeSeq: seq);
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }else if type == "1" {
            if subtype == "0" || subtype == "1" {
                let fm_Contrllers = self.navigationController?.viewControllers
                if let val = fm_Contrllers{
                    for VC in val{
                        if VC is StartMain {
                            self.tabBarController?.selectedIndex = 3;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }else if VC is TradeMain {
                            self.tabBarController?.selectedIndex = 3;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }else if VC is CommunityMain {
                            self.tabBarController?.selectedIndex = 3;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }else if VC is InventoryMain {
                            self.tabBarController?.selectedIndex = 3;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }
                        
                    }
                }
            }
        }else if type == "2" {
            if subtype == "0" {
                let fm_Contrllers = self.navigationController?.viewControllers
                if let val = fm_Contrllers{
                    for VC in val{
                        if VC is StartMain {
                            SO.setInventoryTabIdx(TabbarIndex: 1)
                            self.tabBarController?.selectedIndex = 3;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }else if VC is TradeMain {
                            SO.setInventoryTabIdx(TabbarIndex: 1)
                            self.tabBarController?.selectedIndex = 3;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }else if VC is CommunityMain {
                            SO.setInventoryTabIdx(TabbarIndex: 1)
                            self.tabBarController?.selectedIndex = 3;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }else if VC is InventoryMain {
                            SO.setInventoryTabIdx(TabbarIndex: 1)
                            self.tabBarController?.selectedIndex = 3;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }
                        
                    }
                }
            }
        }else if type == "3" {
            if subtype == "0" || subtype == "1" || subtype == "2" {
                let Storyboard: UIStoryboard = UIStoryboard(name: "DeliveryInfo", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "DeliveryInfoidx") as! DeliveryInfo
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }else if type == "4" {
            if subtype == "0" {
                let Storyboard: UIStoryboard = UIStoryboard(name: "FriendMain", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "FriendMainidx") as! FriendMain
                viewController.setMenu(selmenu: 0)
                self.navigationController?.pushViewController(viewController, animated: true)
            }else if subtype == "1" {
                let Storyboard: UIStoryboard = UIStoryboard(name: "FriendMain", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "FriendMainidx") as! FriendMain
                viewController.setMenu(selmenu: 1)
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }else if type == "5" {
            if subtype == "0" {
                let Storyboard: UIStoryboard = UIStoryboard(name: "CloverInfo", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "CloverInfoidx") as! CloverInfo
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }else if type == "6" {
            if subtype == "0" {
                let fm_Contrllers = self.navigationController?.viewControllers
                if let val = fm_Contrllers{
                    for VC in val{
                        if VC is StartMain {
                            SO.setInventoryTabIdx(TabbarIndex: 2)
                            self.tabBarController?.selectedIndex = 3;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }else if VC is TradeMain {
                            SO.setInventoryTabIdx(TabbarIndex: 2)
                            self.tabBarController?.selectedIndex = 3;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }else if VC is CommunityMain {
                            SO.setInventoryTabIdx(TabbarIndex: 2)
                            self.tabBarController?.selectedIndex = 3;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }else if VC is InventoryMain {
                            SO.setInventoryTabIdx(TabbarIndex: 2)
                            self.tabBarController?.selectedIndex = 3;
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }
                        
                    }
                }
            }
        }else if type == "7" {
            if subtype == "0" {
                let Storyboard: UIStoryboard = UIStoryboard(name: "UserConDetail", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "UserConDetailidx") as! UserConDetail
                viewController.setData(data: ["seq" : seq])
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }else if type == "8" {
            if subtype == "0" {
                let fm_Contrllers = self.navigationController?.viewControllers
                if let val = fm_Contrllers{
                    for VC in val{
                        if VC is StartMain {
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }else if VC is TradeMain {
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }else if VC is CommunityMain {
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }else if VC is InventoryMain {
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }
                        
                    }
                }
            }
        }else if type == "9" {
            if subtype == "0" {
                let fm_Contrllers = self.navigationController?.viewControllers
                if let val = fm_Contrllers{
                    for VC in val{
                        if VC is StartMain {
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }else if VC is TradeMain {
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }else if VC is CommunityMain {
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }else if VC is InventoryMain {
                            self.navigationController?.popToViewController(VC, animated: true)
                            break;
                        }
                        
                    }
                }
            }else if subtype == "1" {
                let Storyboard: UIStoryboard = UIStoryboard(name: "CuponInfo", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "CuponInfoidx") as! CuponInfo
                self.navigationController?.pushViewController(viewController, animated: true)
            }else if subtype == "2" {
                let Storyboard: UIStoryboard = UIStoryboard(name: "CloverInfo", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "CloverInfoidx") as! CloverInfo
                self.navigationController?.pushViewController(viewController, animated: true)
            }else if subtype == "3" {
                let Storyboard: UIStoryboard = UIStoryboard(name: "EventInfoDetail", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "EventInfoDetailidx") as! EventInfoDetail
                viewController.setData(seq: seq)
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }

}
extension PushLIst : ReportCustomSegmentedControlDelegate{
    func changeToIndex(index: Int) {
        if m_nSelMenu == index{
            return;
        }
        m_nSelMenu = index;
        refresh();
    }
}
extension PushLIst :  UITableViewDelegate, UITableViewDataSource{
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "PushLIstCellidx", for: indexPath) as! PushLIstCell
        if m_ListData.count > indexPath.row{
            cell.setData(data: m_ListData[indexPath.row], row:indexPath.row, viewtype: m_nSelMenu)
            if m_saPushSeqs.contains(m_ListData[indexPath.row]["noti_seq"] ?? "") {
                cell.setSaveColor(color: UIColor.white)
            }else{
                cell.setSaveColor(color: UIColor(rgb: 0xfffafa))
            }
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
        return 85;
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //셀 선택시
        if let seq = m_ListData[indexPath.row]["noti_seq"] {
            if !m_saPushSeqs.contains(seq) {
                m_saPushSeqs.append(seq)
                UserDefaults.standard.set(m_saPushSeqs, forKey: Single.DE_PUSHLOCALSAVESEQ)
                let cell = (uiTabelView.cellForRow(at: indexPath) as! PushLIstCell)
                cell.setSaveColor(color: UIColor.white)
            }
        }
        
        MoveDetailView(type: m_ListData[indexPath.row]["type"] ?? "", subtype: m_ListData[indexPath.row]["subtype"] ?? "", seq: m_ListData[indexPath.row]["target_seq"] ?? "");
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
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
            JS.invisibleNotification(param: ["noti_seq":m_ListData[indexPath.row]["noti_seq"]!, "account_seq":getUserSeq()], callbackf: invisibleNotificationCallback)
            uiTabelView.beginUpdates()
            m_ListData.remove(at: indexPath.row)
            uiTabelView.deleteRows(at: [indexPath], with: .automatic)
            cellDeleteIndexPath = nil
            uiTabelView.endUpdates()
        }
    }
    func invisibleNotificationCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
        }
    }
    
    
}
