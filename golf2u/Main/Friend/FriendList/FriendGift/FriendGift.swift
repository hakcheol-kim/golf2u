//
//  FriendGift.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/10.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON
import EzPopup

class FriendGift: VariousViewController {
    weak var m_tClickEvent: ClickCellBtnDelegate? = nil;//FriendMain
    
    private var SO:Single = Single.getSO();
    private let JS = JsonC();
    
    @IBOutlet weak var uiTopTabView: ReportCustomSegmentedControl!{
        didSet{
            uiTopTabView.setButtonTitles(buttonTitles: ["랜덤박스".localized,"상품".localized])
            uiTopTabView.selectorViewColor = UIColor(rgb: 0x00BA87)
            uiTopTabView.selectorTextColor = UIColor(rgb: 0x00BA87)
            uiTopTabView.textColor = .black
            uiTopTabView.backgroundColor = .white
        }
    }
    @IBOutlet weak var uiUserInfoView: UIView!
    @IBOutlet weak var uiUserImg: UIImageView!
    @IBOutlet weak var uiUserName: UILabel!
    @IBOutlet weak var uiUserDate: UILabel!
    
    @IBOutlet weak var uiGiftBtn: UIButton!
    @IBOutlet weak var uiCollectionView: UICollectionView!
    private var refreshControl = UIRefreshControl()
    
    
    private var m_sUserSeq : String = "";
    private var m_nPageNum = 0;
    private var m_nNextNum = 0;
    private var m_nDataCnt = 0;
    private var estimateWidth = 160.0
    private var estimateHeight = 263.0
    private var cellMarginSize = 5.0
    private var m_nSelMenu = 0;
    private var m_sWhere = "0";
    private var m_isAccBtn = false;
    
    private var m_ListData = Array<[String:String]>();
    private var m_UserDate =  [String:String]();
    
    private var m_SelListData = [String]()
    
    private var m_isPagging = false;
    
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "선물하기".localized)
        super.viewDidLoad()
        
        uiGiftBtn.setTitle("선물하기".localized, for: .normal)
        m_sUserSeq = super.getUserSeq()
        
        uiUserImg.layer.cornerRadius = uiUserImg.frame.height/2
        
        self.uiUserInfoView.layer.addBorder([.top,.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        self.uiTopTabView.layer.addBorder([.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
        uiTopTabView.delegate = self

        uiCollectionView.delegate = self;
        uiCollectionView.dataSource = self;
        let nibBox = UINib(nibName: "FriendGiftBoxCell", bundle: nil)
        uiCollectionView.register(nibBox, forCellWithReuseIdentifier: "FriendGiftBoxCellidx")
        let nibPro = UINib(nibName: "FriendGiftProCell", bundle: nil)
        uiCollectionView.register(nibPro, forCellWithReuseIdentifier: "FriendGiftProCellidx")
        
        let flow = UICollectionViewFlowLayout()
        flow.sectionInset = UIEdgeInsets(top: 5, left: 13, bottom: 5, right:13)
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
        
        uiUserImg.image = nil;
        if let imgurl = m_UserDate["profile_image_url"]{
            if imgurl != ""{
                uiUserImg.setImage(with: "\(Single.DE_URLIMGSERVER)\(imgurl)")
            }
        }
        uiUserName.text = m_UserDate["name"]
        uiUserDate.text = m_UserDate["created_at"]
        
        if SO.m_sProductGiftSeq != "" {
            self.m_nSelMenu = 1;
            m_SelListData.append(SO.m_sProductGiftSeq)
        }
        LoadItem();
    }
    func setUserDate(data : [String:String]){
        m_UserDate = data
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if SO.m_sProductGiftSeq != "" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                //탭 인덱스가 화면 로딩후 바로 안떠서 0.3초 정도 딜레이 주고 바꿈
                //앱 첫시작하고 인벤토리를 한번도 안누르면 탭 객체가 없기때문에 인벤토리 이동후
                //해당 생명주기 함수에서 0.3초 정도있다가 싱글톤에 값을 보고 탭을 바꿔줌
                self.uiTopTabView.setIndex(index: self.m_nSelMenu)
                
            }
        }
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
                uiGiftBtn.frame = CGRect(x: 0, y: Int(uiGiftBtn.frame.minY), width: Int(uiGiftBtn.frame.size.width), height: Int(uiGiftBtn.frame.size.height + bottomPadding))
                uiGiftBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
            }

        }
    }
    @objc func refresh(){
        m_nPageNum = 0;
        m_nNextNum = 0;
        m_nDataCnt = 0;
        m_ListData.removeAll();
        m_SelListData.removeAll();
        LoadItem();
    }
    func LoadItem(){
        m_isPagging = true;
        m_nPageNum += 1;
        LoadingHUD.show()
        if m_nSelMenu == 0 {
            estimateHeight = 263
            JS.MyBoxList(param: ["pagenum":m_nPageNum,"account_seq":m_sUserSeq, "select_type":m_sWhere], callbackf: MyBoxListCallback)
        }else{
            estimateHeight = 280;
            JS.MyProductList(param: ["pagenum":m_nPageNum,"account_seq":m_sUserSeq, "giveable_only":m_sWhere, "my_product_seq" : SO.m_sProductGiftSeq], callbackf: MyProductListCallback)
        }
    }
    func MyBoxListCallback(alldata: JSON)->Void {
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
                item["seq"] = object["seq"].stringValue;
                item["type"] = object["type"].stringValue;
                item["box_explain"] = object["box_explain"].stringValue;
                item["paymented_at"] = object["paymented_at"].stringValue;
                item["price"] = object["price"].stringValue;
                m_ListData.append(item)
                
                
            }
        }
        self.uiCollectionView.reloadData()
        self.refreshControl.endRefreshing();
        m_isPagging = false
        LoadingHUD.hide()
    }
    func MyProductListCallback(alldata: JSON)->Void {
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
                item["my_product_seq"] = object["my_product_seq"].stringValue;
                item["product_seq"] = object["product_seq"].stringValue;
                item["name"] = object["name"].stringValue;
                item["thumbnail"] = object["thumbnail"].stringValue;
                item["price"] = object["price"].stringValue;
                item["delivery_gauge"] = object["delivery_gauge"].stringValue;
                item["expired_at"] = object["expired_at"].stringValue;
                item["box_type"] = object["box_type"].stringValue;
                m_ListData.append(item)
                
                
            }
        }
        self.uiCollectionView.reloadData()
        self.refreshControl.endRefreshing();
        m_isPagging = false
        LoadingHUD.hide()
    }
    func SendGift(){
        LoadingHUD.show()
        if m_nSelMenu == 0 {
            JS.MyBoxProGift(param: ["target_account_seq":m_UserDate["account_seq"]!,"account_seq":m_sUserSeq,"random_box_seqs":m_SelListData], callbackf: MyBoxProGiftCallback)
        }else if m_nSelMenu == 1 {
            JS.MyBoxProGift(param: ["target_account_seq":m_UserDate["account_seq"]!,"account_seq":m_sUserSeq,"my_product_seqs":m_SelListData], callbackf: MyBoxProGiftCallback)
        }
    }
    func MyBoxProGiftCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            let fm_sLine1 = "님께 총 ".localized(txt: "\(m_UserDate["name"]!)");
            let fm_sLine2 = "개의 상품을 선물하였습니다.".localized(txt: "\(m_SelListData.count)");
            
            MessagePop(title : "선물하기".localized, msg: "\(fm_sLine1)\(fm_sLine2)", lbtn: "취소".localized, rbtn: "선물함가기".localized,succallbackf: { ()-> Void in
                self.goToInven();
            }, closecallbackf: { ()-> Void in
                self.refresh()
            })
        }
        m_isAccBtn = false
        LoadingHUD.hide()
    }
    func goToInven(){
        let fm_Contrllers = self.navigationController?.viewControllers
        if let val = fm_Contrllers{
            for VC in val{
                //if VC is InventoryMain {
                    //let VCC = VC as! InventoryMain
                    //VCC.goToProductInven()
                    //self.navigationController?.popToViewController(VC, animated: true)
//                    if m_nSelMenu == 0 {
//                        SO.setInventoryTabIdx(TabbarIndex: 2)
//                    }else if m_nSelMenu == 1 {
//                        SO.setInventoryTabIdx(TabbarIndex: 2)
//                    }
//
//                    self.tabBarController?.selectedIndex = 3;
//                    self.navigationController?.popToViewController(VC, animated: true)
                //}
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
    @IBAction func onGiftBtn(_ sender: Any) {
        if m_isAccBtn {
            return;
        }
        if m_SelListData.count <= 0 {
            MessagePop(msg: "선택후 선물하기 해주세요.".localized, btntype : 2)
            return;
        }
        m_isAccBtn = true;
        let fm_sLine1 = "님에게 총 ".localized(txt: "\(m_UserDate["name"]!)");
        let fm_sLine2 = "개의 상품을 선물합니다.\n(선물한 상품은 회수가 불가능합니다.)".localized(txt: "\(m_SelListData.count)");
        
        MessagePop(title : "선물하기".localized, msg: "\(fm_sLine1)\(fm_sLine2)", lbtn: "취소".localized, rbtn: "확인".localized,succallbackf: { ()-> Void in
            self.SendGift();
        }, closecallbackf: {  ()-> Void in
            self.m_isAccBtn = false
            
        })
    }
    
}
extension FriendGift:  UICollectionViewDelegate, UICollectionViewDataSource {
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
        
        if m_ListData.count > indexPath.row{
            if m_nSelMenu == 0 {
               let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FriendGiftBoxCellidx", for: indexPath) as! FriendGiftBoxCell
                cell.setData(data: m_ListData[indexPath.row], row: indexPath.row);
                if let fm_sSeq = m_ListData[indexPath.row]["seq"] {
                    if !m_SelListData.contains(fm_sSeq) {
                        cell.setChoise(type: false)
                    }else{
                        cell.setChoise(type: true)
                    }
                }
                return cell;
            }else if m_nSelMenu == 1 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FriendGiftProCellidx", for: indexPath) as! FriendGiftProCell
                 cell.setData(data: m_ListData[indexPath.row], row: indexPath.row);
                if let fm_sSeq = m_ListData[indexPath.row]["my_product_seq"] {
                    if !m_SelListData.contains(fm_sSeq) {
                        cell.setChoise(type: false)
                    }else{
                        cell.setChoise(type: true)
                    }
                }
                 return cell;
             }
        }else{
        }
        return collectionView.dequeueReusableCell(withReuseIdentifier: "FriendGiftBoxCellidx", for: indexPath) as! FriendGiftBoxCell;
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if m_nSelMenu == 0 {
            let fm_sSeq = m_ListData[indexPath.row]["seq"]!
            if !m_SelListData.contains(fm_sSeq) {
                m_SelListData.append(fm_sSeq)
                let cell = (collectionView.cellForItem(at: indexPath) as! FriendGiftBoxCell)
                cell.setChoise(type: true)
            }else{
                let indexOfA = m_SelListData.firstIndex(of: fm_sSeq)
                m_SelListData.remove(at: indexOfA!)
                let cell = (collectionView.cellForItem(at: indexPath) as! FriendGiftBoxCell)
                cell.setChoise(type: false)
            }
        }else if m_nSelMenu == 1 {
            let fm_sSeq = m_ListData[indexPath.row]["my_product_seq"]!
            if !m_SelListData.contains(fm_sSeq) {
                m_SelListData.append(fm_sSeq)
                let cell = (collectionView.cellForItem(at: indexPath) as! FriendGiftProCell)
                cell.setChoise(type: true)
            }else{
                let indexOfA = m_SelListData.firstIndex(of: fm_sSeq)
                m_SelListData.remove(at: indexOfA!)
                let cell = (collectionView.cellForItem(at: indexPath) as! FriendGiftProCell)
                cell.setChoise(type: false)
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (m_ListData.count - 1) <= indexPath.row && m_nNextNum > 0 && !m_isPagging{
           
           self.LoadItem();
        }
    }
}
extension FriendGift: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        return CGSize(width: width, height: CGFloat(estimateHeight))
    }
    
    func calculateWith() -> CGFloat {
        //        let estimatedWidth = CGFloat(estimateWidth)
        //        let cellCount = floor(CGFloat(self.productCollectionView.frame.size.width / estimatedWidth))
        //
        //        let margin = CGFloat(cellMarginSize * 2)
        //        let width = (self.productCollectionView.frame.size.width - CGFloat(cellMarginSize) * (cellCount - 1) - margin) / cellCount
                
                return (self.uiCollectionView.frame.size.width / 2 - 18)
    }
}
extension FriendGift : ReportCustomSegmentedControlDelegate{
    func changeToIndex(index: Int) {
        if m_nSelMenu == index{
            return;
        }
        m_nSelMenu = index;
        refresh();
    }
    
}
