//
//  DeliveryManage.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/16.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON
import EzPopup
import SwipeCellKit

class DeliveryManage: VariousViewController {
    weak var m_tClickEvent: DeliveryApplyClickCellBtnDelegate? = nil;
    
    private let SO = Single.getSO();
    private let JS = JsonC();
    
    @IBOutlet weak var uiTopView: UIView!
    @IBOutlet weak var uiDataCnt: UILabel!
    @IBOutlet weak var uiCollectionView: UICollectionView!
    private var refreshControl = UIRefreshControl()
    @IBOutlet weak var uiDeliAddBtn: UIButton!
    
    private var m_ListData = Array<[String:String]>();
    private var m_nPageNum = 0;
    private var m_nNextNum = 0;
    private var m_nDataCnt = 0;
    private var estimateWidth = 160.0
    private var cellMarginSize = 0.0
    
    private var m_nViewType = 0;//0:설정에서온곳, 1:인벤토리 배송신청에서 온곳
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "배송지 관리".localized)
        super.viewDidLoad()
        
        uiDeliAddBtn.setTitle("배송지 추가".localized, for: .normal)
        
        uiTopView.layer.addBorder([.top,.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
        uiCollectionView.delegate = self;
        uiCollectionView.dataSource = self;
        let nib = UINib(nibName: "DeliveryManageCell", bundle: nil)
        uiCollectionView.register(nib, forCellWithReuseIdentifier: "DeliveryManageCellidx")
        
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
    func setViewType(ViewType : Int){
        m_nViewType = ViewType
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
        m_nPageNum += 1;
        JS.getAllUserAddress(param: ["pagenum":m_nPageNum,"account_seq":super.getUserSeq()], callbackf: getAllUserAddressCallback)
    }
    func getAllUserAddressCallback(alldata: JSON)->Void {
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
                item["is_default"] = object["is_default"].stringValue;
                item["is_last"] = object["is_last"].stringValue;
                item["title"] = object["title"].stringValue;
                item["name"] = object["name"].stringValue;
                item["zipcode"] = object["zipcode"].stringValue;
                item["address1"] = object["address1"].stringValue;
                item["address2"] = object["address2"].stringValue;
                item["phone_number"] = object["phone_number"].stringValue;
                item["military_address"] = object["military_address"].stringValue;
                item["has_additional_cost"] = object["has_additional_cost"].stringValue
                item["price"] = object["price"].stringValue
                m_ListData.append(item)
            }
            uiDataCnt.text = "전체 건".localized(txt: "\(m_ListData.count)");
            uiDataCnt.TextPartColor(partstr: "\(m_ListData.count)", Color: UIColor(rgb: 0x00BA87))
        }
        self.uiCollectionView.reloadData()
        self.refreshControl.endRefreshing();
        LoadingHUD.hide()
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
                uiDeliAddBtn.frame = CGRect(x: 0, y: Int(uiDeliAddBtn.frame.minY), width: Int(uiDeliAddBtn.frame.size.width), height: Int(uiDeliAddBtn.frame.size.height + bottomPadding))
                uiDeliAddBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
            }

        }
    }
    @IBAction func onDeliAddBtn(_ sender: Any) {
        AddModifyBtn(viewtype: 0, data: [:])
    }
}
extension DeliveryManage:  UICollectionViewDelegate, UICollectionViewDataSource {
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DeliveryManageCellidx", for: indexPath) as! DeliveryManageCell
        if m_ListData.count > indexPath.row{
            cell.setData(data: m_ListData[indexPath.row], row : indexPath.row);
            cell.setVisibleSelBtn(type: (m_nViewType == 0 ? true : false))
            cell.ClickEvenHandler = { (type : Int, data : [String : String])-> Void in
                if type == 1 {
                    //삭제
                    self.DeliDel(data: data);
                }else if type == 2 {
                    //수정
                    self.AddModifyBtn(viewtype: 1, data: data)
                }else if type == 3 {
                    //선택
                    self.addrSel(data: data);
                }
            }
            cell.delegate = self
        }else{
        }
        return cell;
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //if (m_ListData.count - 1) == indexPath.row && m_nNextNum > 0 {
        //   self.LoadItem();
        //}
    }
    func addrSel(data : [String : String]){
        m_tClickEvent?.ClickEvent(celltype : 1, type: 5, data: data)
        self.navigationController?.popViewController(animated: true);
    }
    func DeliDel(data : [String : String]){
        if data["is_default"] == "0" {
            MessagePop(title : "배송지 삭제".localized, msg: "선택하신 배송지를 삭제 하시겠습니까?".localized, lbtn: "취소".localized, rbtn: "확인".localized,succallbackf: { ()-> Void in
                LoadingHUD.show()
                self.JS.deleteUserAddress(param: ["address_seq":data["seq"] ?? "","account_seq":super.getUserSeq()], callbackf:  self.deleteUserAddressCallback)
            }, closecallbackf: { ()-> Void in
            })
        }else{
            self.MessagePop(msg: "기본 배송지는 삭제할 수 없습니다.".localized, btntype : 2)
        }
        
    }
    func deleteUserAddressCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            self.refresh();
        }
        LoadingHUD.hide()
    }
    func AddModifyBtn(viewtype : Int, data : [String : String]){
        let Storyboard: UIStoryboard = UIStoryboard(name: "DeliveryManageAddModi", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "DeliveryManageAddModiidx") as! DeliveryManageAddModi
        viewController.setViewType(viewtype: viewtype, data: data)
        viewController.m_tClickEvent = m_tClickEvent;
        viewController.InsertModifyHandler = { ()-> Void in
            self.refresh();
        }
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}
extension DeliveryManage: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        return CGSize(width: width, height: 130)
    }
    
    func calculateWith() -> CGFloat {
        let estimatedWidth = CGFloat(self.view.frame.size.width)
        let cellCount = floor(CGFloat(self.view.frame.size.width / estimatedWidth))
        
        let margin = CGFloat(cellMarginSize * 2)
        let width = (self.view.frame.size.width - CGFloat(cellMarginSize) * (cellCount - 1) - margin) / cellCount
        
        return width
    }
}
extension DeliveryManage:  SwipeCollectionViewCellDelegate {

    
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "삭제".localized) { [self] action, indexPath in
            self.DeliDel(data:  m_ListData[indexPath.row]);
            action.fulfill(with: .delete)
            
        }
        
        return [deleteAction]
    }
}
