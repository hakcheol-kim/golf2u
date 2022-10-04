//
//  ProductInven.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/06.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON

class ProductInven: UIView {
    weak var m_tClickEvent: InventoryMainClickCellBtnDelegate? = nil;
    struct cellData {
        var m_isOpened = false;
        var m_HListData = [String:String]();
        var m_BListData = Array<[String:String]>();
    }
    private let SO = Single.getSO();
    private let JS = JsonC();
    
    private let xibName = "ProductInven"

    @IBOutlet weak var uiTopView: UIView!
    @IBOutlet weak var uiCntLabel: UILabel!
    @IBOutlet weak var uiTableView: UITableView!
    private var refreshControl = UIRefreshControl()//테이블 아래로 당겨서 리프레쉬 해주는거
    @IBOutlet weak var uiPdOpenListBtn: UIButton!
    @IBOutlet weak var uiSortBtn: UIButton!
    @IBOutlet weak var uiFilterBtn: UIButton!
    
    private var m_nPageNum = 0;
    private var m_nNextNum = 0;
    private var m_nDataCnt = 0;
    private var m_sUserSeq : String = "";
    private var m_sSortSeq : String = "2";
    private var m_isOpenAllList : Bool = false;
    private var m_nMarketOnly : Int = 0;
    private var m_nPrdDayOnly : Int = 0;
    private var m_nPrdDayLimitOnly : Int = 0;
    
    private var m_ListData = [cellData]();
    
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
        
        m_sUserSeq = SO.getUserInfoKey(key: "seq")
        
        self.uiTopView.layer.addBorder([.top, .bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
        uiPdOpenListBtn.setTitle("상품 펼치기".localized, for: .normal)
        uiSortBtn.setTitle("최신순".localized, for: .normal)
        
        //table setting
        self.uiTableView.tableFooterView = UIView(frame: .zero)
        self.uiTableView.dataSource = self
        self.uiTableView.delegate = self
        self.uiTableView.separatorStyle = .none//셀간 줄 없애기
        self.uiTableView.cellLayoutMarginsFollowReadableWidth = false
        self.uiTableView.separatorInset.left = 0
        self.uiTableView.rowHeight = UITableView.automaticDimension;
        self.uiTableView.estimatedRowHeight = 123;
        
        uiPdOpenListBtn.layer.cornerRadius = 5.0
        uiPdOpenListBtn.backgroundColor = .clear
        uiPdOpenListBtn.layer.borderWidth = 1
        uiPdOpenListBtn.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiSortBtn.layer.cornerRadius = 5.0
        uiSortBtn.backgroundColor = .clear
        uiSortBtn.layer.borderWidth = 1
        uiSortBtn.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor


        //테이블뷰 리프레쉬
        if #available(iOS 10.0, *) {
          self.uiTableView.refreshControl = refreshControl
        } else {
          self.uiTableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)//리프레시 이벤트
        //refreshControl.attributedTitle = NSAttributedString(string: "H2Care")
        
        let nibName = UINib(nibName: "ProductInvenHCell", bundle: nil)
        self.uiTableView.register(nibName, forCellReuseIdentifier: "ProductInvenHCellidx")
        let SubnibName = UINib(nibName: "ProductInvenBCell", bundle: nil)
        self.uiTableView.register(SubnibName, forCellReuseIdentifier: "ProductInvenBCellidx")
        
        LoadItem();
    }
    @objc func refresh(){
        m_nPageNum = 0;
        m_ListData.removeAll();
        LoadItem();
    }
    func LoadItem(){
        LoadingHUD.show()
        let fm_SelProductCategory = SO.getSelInvenPCategory();
        if fm_SelProductCategory.firstIndex(of: "1") != nil {
            m_nMarketOnly = 1
        }else{
            m_nMarketOnly = 0
        }
        if fm_SelProductCategory.firstIndex(of: "2") != nil {
            m_nPrdDayOnly = 1
        }else{
            m_nPrdDayOnly = 0
        }
        if fm_SelProductCategory.firstIndex(of: "3") != nil {
            m_nPrdDayLimitOnly = 1
        }else{
            m_nPrdDayLimitOnly = 0
        }
        m_isPagging = true;
        m_sUserSeq = SO.getUserInfoKey(key: "seq")
        m_nPageNum += 1;
        JS.InvenProductList(param: ["pagenum":"\(m_nPageNum)", "account_seq" : m_sUserSeq, "market_reged_only" : m_nMarketOnly, "imminent_only" : m_nPrdDayOnly, "not_refresh_on_trade_only" : m_nPrdDayLimitOnly, "order_type" : m_sSortSeq], callbackf: InvenProductListCallback)
    }
    func InvenProductListCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            //self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            if let val = alldata["nextpage"].string{
                m_nNextNum = Int(val)!;
            }
            if let val = alldata["datacnt"].string{
                m_nDataCnt = Int(val)!;
                
            }else{
                m_nDataCnt = 0;
            }
            uiCntLabel.text = "전체 건".localized(txt: "\(m_nDataCnt)");
            uiCntLabel.TextPartColor(partstr: "\(m_nDataCnt)", Color: UIColor(rgb: 0x00BA87))
            
            for (_, object) in alldata["data"] {
                var fm_tData = cellData();
                var item = [String:String]()
                item["my_product_seq"] = object["my_product_seq"].stringValue;
                item["product_seq"] = object["product_seq"].stringValue;
                item["name"] = object["name"].stringValue;
                item["thumbnail"] = object["thumbnail"].stringValue;
                item["brand"] = object["brand"].stringValue;
                item["expired_at"] = object["expired_at"].stringValue;
                item["delivery_gauge"] = object["delivery_gauge"].stringValue;
                item["price"] = object["price"].stringValue;
                item["product_cnt"] = object["product_cnt"].stringValue;
                item["is_refresh_on_trade"] = object["is_refresh_on_trade"].stringValue;
                fm_tData.m_HListData = item
                for subd in object["product_arr"].arrayValue {
                    var subitem = [String:String]()
                    subitem["my_product_seq"] = subd["my_product_seq"].stringValue;
                    subitem["product_seq"] = subd["product_seq"].stringValue;
                    subitem["name"] = subd["name"].stringValue;
                    subitem["thumbnail"] = subd["thumbnail"].stringValue;
                    subitem["brand"] = subd["brand"].stringValue;
                    subitem["expired_at"] = subd["expired_at"].stringValue;
                    subitem["delivery_gauge"] = subd["delivery_gauge"].stringValue;
                    subitem["price"] = subd["price"].stringValue;
                    subitem["point_payback"] = object["point_payback"].stringValue;
                    subitem["point_payback_expired"] = subd["point_payback_expired"].stringValue;
                    subitem["point_payback_current"] = subd["point_payback_current"].stringValue;
                    subitem["is_expired"] = subd["is_expired"].stringValue;
                    subitem["is_market_reged"] = subd["is_market_reged"].stringValue;
                    subitem["delivery_price"] = subd["delivery_price"].stringValue;
                    subitem["is_digital_item"] = subd["is_digital_item"].stringValue;
                    subitem["created_at"] = subd["created_at"].stringValue;
                    subitem["remain_date"] = subd["remain_date"].stringValue;
                    subitem["expired_at_dt"] = subd["expired_at_dt"].stringValue;
                    subitem["delivery_possible"] = subd["delivery_possible"].stringValue;
                    subitem["is_forever"] = subd["is_forever"].stringValue;
                    subitem["box_type"] = subd["box_type"].stringValue;
                    subitem["shipping_location"] = subd["shipping_location"].stringValue;
                    fm_tData.m_BListData.append(subitem)
                    
                }
                if m_isOpenAllList{
                    fm_tData.m_isOpened = true;//초기 설정 리스트 전체 펼치기 기본
                }else{
                    fm_tData.m_isOpened = false;//리스크 전체 접기
                }
                m_ListData.append(fm_tData)
                
            }
        }
        self.uiTableView.reloadData()
        self.refreshControl.endRefreshing();
        m_isPagging = false
        LoadingHUD.hide()
    }
    func MarketDel(indexpath : IndexPath){
        m_ListData[indexpath.section].m_BListData[indexpath.row - 1]["is_market_reged"] = "0";
        self.uiTableView.reloadData()
    }
    func MarketAdd(indexpath : IndexPath){
        m_ListData[indexpath.section].m_BListData[indexpath.row - 1]["is_market_reged"] = "1";
        self.uiTableView.reloadData()
    }
    func CloverReturn(indexpath : IndexPath){
        if (m_ListData[indexpath.section].m_BListData.count - 1) <= 0 {
            m_ListData.remove(at: indexpath.section)
        }else{
            let fm_nHCnt =  Int(m_ListData[indexpath.section].m_HListData["product_cnt"] ?? "0") ?? 0
            m_ListData[indexpath.section].m_HListData["product_cnt"] = "\(fm_nHCnt - 1)";
            m_ListData[indexpath.section].m_BListData.remove(at: indexpath.row - 1)
        }
        m_nDataCnt -= 1;
        uiCntLabel.text = "전체 건".localized(txt: "\(m_nDataCnt)");
        uiCntLabel.TextPartColor(partstr: "\(m_nDataCnt)", Color: UIColor(rgb: 0x00BA87))
        self.uiTableView.reloadData()
    }
    func GiftReturn(indexpath : IndexPath){
        if (m_ListData[indexpath.section].m_BListData.count - 1) <= 0 {
            m_ListData.remove(at: indexpath.section)
            m_nDataCnt -= 1;
            uiCntLabel.text = "전체 건".localized(txt: "\(m_nDataCnt)");
            uiCntLabel.TextPartColor(partstr: "\(m_nDataCnt)", Color: UIColor(rgb: 0x00BA87))
        }else{
            let fm_nHCnt =  Int(m_ListData[indexpath.section].m_HListData["product_cnt"] ?? "0") ?? 0
            m_ListData[indexpath.section].m_HListData["product_cnt"] = "\(fm_nHCnt - 1)";
            m_ListData[indexpath.section].m_BListData.remove(at: indexpath.row - 1)
        }
        self.uiTableView.reloadData()
    }
    func DeliveryReturn(indexpath : IndexPath){
        if (m_ListData[indexpath.section].m_BListData.count - 1) <= 0 {
            m_ListData.remove(at: indexpath.section)
            m_nDataCnt -= 1;
            uiCntLabel.text = "전체 건".localized(txt: "\(m_nDataCnt)");
            uiCntLabel.TextPartColor(partstr: "\(m_nDataCnt)", Color: UIColor(rgb: 0x00BA87))
        }else{
            let fm_nHCnt =  Int(m_ListData[indexpath.section].m_HListData["product_cnt"] ?? "0") ?? 0
            m_ListData[indexpath.section].m_HListData["product_cnt"] = "\(fm_nHCnt - 1)";
            m_ListData[indexpath.section].m_BListData.remove(at: indexpath.row - 1)
        }
        self.uiTableView.reloadData()
    }
    func DigiterDelivery(indexpath : IndexPath){
        if (m_ListData[indexpath.section].m_BListData.count - 1) <= 0 {
            m_ListData.remove(at: indexpath.section)
        }else{
            let fm_nHCnt =  Int(m_ListData[indexpath.section].m_HListData["product_cnt"] ?? "0") ?? 0
            m_ListData[indexpath.section].m_HListData["product_cnt"] = "\(fm_nHCnt - 1)";
            m_ListData[indexpath.section].m_BListData.remove(at: indexpath.row - 1)
        }
        self.uiTableView.reloadData()
    }
    func DeliveryPayAcc(indexpath : IndexPath){
        if (m_ListData[indexpath.section].m_BListData.count - 1) <= 0 {
            m_ListData.remove(at: indexpath.section)
            m_nDataCnt -= 1;
            uiCntLabel.text = "전체 건".localized(txt: "\(m_nDataCnt)");
            uiCntLabel.TextPartColor(partstr: "\(m_nDataCnt)", Color: UIColor(rgb: 0x00BA87))
        }else{
            let fm_nHCnt =  Int(m_ListData[indexpath.section].m_HListData["product_cnt"] ?? "0") ?? 0
            m_ListData[indexpath.section].m_HListData["product_cnt"] = "\(fm_nHCnt - 1)";
            m_ListData[indexpath.section].m_BListData.remove(at: indexpath.row - 1)
        }
        self.uiTableView.reloadData()
    }
    @IBAction func onPdOpenListBtn(_ sender: Any) {
        if !m_isOpenAllList{
            m_isOpenAllList = true;
            uiPdOpenListBtn.setTitle("상품 접기".localized, for: .normal)
        }else{
            m_isOpenAllList = false
            uiPdOpenListBtn.setTitle("상품 펼치기".localized, for: .normal)
        }
        refresh();
    }
    @IBAction func onSortBtn(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: "정렬".localized, preferredStyle: .actionSheet)
        //옵션 초기화
        let alertacop1 = UIAlertAction(title: "이름순".localized, style: .default, handler: alertHandleOp1)
        let alertacop2 = UIAlertAction(title: "가격순".localized, style: .default, handler: alertHandleOp1)
        let alertacop3 = UIAlertAction(title: "최신순".localized, style: .default, handler: alertHandleOp1)
        let alertacop4 = UIAlertAction(title: "보관일순".localized, style: .default, handler: alertHandleOp1)
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
        if alertAction.title! == "이름순".localized {
            m_sSortSeq = "0";
        }else if alertAction.title! == "가격순".localized {
            m_sSortSeq = "1";
        }else if alertAction.title! == "최신순".localized {
            m_sSortSeq = "2";
        }else if alertAction.title! == "보관일순".localized {
            m_sSortSeq = "3";
        }
        uiSortBtn.setTitle(alertAction.title!, for: .normal)
        refresh();
    }
    @IBAction func onFilterBtn(_ sender: Any) {
        m_tClickEvent?.ClickEvent(viewtype : 1, type: 14, data: [:])
    }
    
}
extension ProductInven :  UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        if m_ListData.count <= 0 {
            ListViewHelper.TableViewEmptyMessage(message: "데이터가 없습니다.".localized, viewController: self, tableviewController: uiTableView)
        }else{
            uiTableView.backgroundView = nil;
        }
        return m_ListData.count;
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if m_ListData[section].m_isOpened == true {
            return m_ListData[section].m_BListData.count + 1;
        }else{
            return 1;
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dtaIndex = indexPath.row - 1;
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductInvenHCellidx", for: indexPath) as! ProductInvenHCell
            if m_ListData.count > indexPath.section{
                cell.setData(data: m_ListData[indexPath.section].m_HListData, row: indexPath.section, opened: m_ListData[indexPath.section].m_isOpened)
                cell.m_tClickEvent = m_tClickEvent;
            }
            return cell;
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductInvenBCellidx", for: indexPath) as! ProductInvenBCell
            if m_ListData.count > indexPath.section{
                cell.setData(data: m_ListData[indexPath.section].m_BListData[dtaIndex], row: dtaIndex, indexpath: indexPath)
                cell.m_tClickEvent = m_tClickEvent;
                
            }
            return cell;
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //셀 선택시
        if indexPath.row == 0  && m_ListData.count > indexPath.section{
            //let cell = (tableView.cellForRow(at: indexPath) as! ProductInvenHCell)
            if m_ListData[indexPath.section].m_isOpened == true {
                m_ListData[indexPath.section].m_isOpened = false
            }else{
                m_ListData[indexPath.section].m_isOpened = true
            }
            let section = IndexSet.init(integer: indexPath.section)
            tableView.reloadSections(section, with: .none)
        }
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (m_ListData.count - 1) == indexPath.section && m_nNextNum > 0  && !m_isPagging{
            self.LoadItem();
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 80;
        }else{
            var fm_nBH = 85.0
            if indexPath.row != 1 {
                fm_nBH = 62.0
            }
            return CGFloat(fm_nBH);
        }
    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension;
//    }
    
}
