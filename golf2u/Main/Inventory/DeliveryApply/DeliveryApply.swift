//
//  DeliveryApply.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/12.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import EzPopup
import SwiftyJSON

protocol DeliveryApplyClickCellBtnDelegate: class {
    func ClickEvent(celltype :Int, type:Int, data : [String:String])
    func ClickEvent(celltype :Int, type:Int, data : Array<[String:String]>)
}

class DeliveryApply: VariousViewController {
    weak var m_tClickEvent: InventoryMainClickCellBtnDelegate? = nil;
    
    struct cellData {
        var m_nCellType = 1;
        var m_Data = [String:String]();
    }
    
    private let SO = Single.getSO();
    private let JS = JsonC();
    
    private let DE_PROCELLTYPE = 1;
    private let DE_BODYCELLTYPE = 2;

    @IBOutlet weak var uiCollectionView: UICollectionView!
    @IBOutlet weak var uiDeliveryBtn: UIButton!
    
    private var estimateWidth = 160.0
    private var cellMarginSize = 0.0
    
    private var m_sUserSeq : String = "";
    
    private var m_ListData = [cellData]();
    
    private var m_sMaxDeliveryPrice = "0";
    private var m_sMaxGage = "0";
    private var m_DeliveryBodyCell : DeliveryBodyCell?
    
    private var m_sOriMyPdSeq = "";
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "배송 신청".localized)
        super.viewDidLoad()
        
        uiDeliveryBtn.setTitle("배송 신청".localized, for: .normal)
        
        m_sUserSeq = super.getUserSeq()
        
        self.uiCollectionView.layer.addBorder([.top], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
        uiCollectionView.delegate = self;
        uiCollectionView.dataSource = self;
        
        let nib1 = UINib(nibName: "ProductCell", bundle: nil)
        uiCollectionView.register(nib1, forCellWithReuseIdentifier: "ProductCellidx")
        
        let nib2 = UINib(nibName: "DeliveryBodyCell", bundle: nil)
        uiCollectionView.register(nib2, forCellWithReuseIdentifier: "DeliveryBodyCellidx")
        
        let flow = UICollectionViewFlowLayout()
        flow.sectionInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right:0)
        flow.scrollDirection = .vertical;
        flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
        
        uiCollectionView.collectionViewLayout = flow
        
        
        
    }
    func getMaxDeliveryPrice() -> Int{
        var fm_nDeliveryPrice = 0;
        var fm_nMaxGage = 0;
        for (_, val) in m_ListData.enumerated() {
            if val.m_nCellType == DE_PROCELLTYPE {
                if fm_nDeliveryPrice < Int(val.m_Data["delivery_price"] ?? "0") ?? 0 {
                    fm_nDeliveryPrice = Int(val.m_Data["delivery_price"] ?? "0") ?? 0 ;
                }
                fm_nMaxGage += Int(val.m_Data["delivery_gauge"] ?? "0") ?? 0;
            }
        }
        m_sMaxGage = String(fm_nMaxGage)
        return fm_nDeliveryPrice;
    }
    func addCell(CellType : Int, data : [String : String]){
        if CellType == DE_PROCELLTYPE {
            var fm_nIdx = 0;
            for (i, val) in m_ListData.enumerated() {
                if val.m_nCellType == DE_BODYCELLTYPE {
                    fm_nIdx = i
                    break;
                }
            }
            m_ListData.insert(cellData(m_nCellType: CellType, m_Data: data), at: fm_nIdx)
        }else{
            m_ListData.append(cellData(m_nCellType: CellType, m_Data: data))
        }
        m_sMaxDeliveryPrice = String(getMaxDeliveryPrice());
        //최고 금액을 가져온뒤
        m_DeliveryBodyCell?.setMaxDeliveryPrice(price: m_sMaxDeliveryPrice, gage: m_sMaxGage)
        //도서산간 지역일경우 배송비 프리미엄 붙이기
        //m_DeliveryBodyCell?.setHas_additional_cost();
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
                uiDeliveryBtn.frame = CGRect(x: 0, y: Int(uiDeliveryBtn.frame.minY), width: Int(uiDeliveryBtn.frame.size.width), height: Int(uiDeliveryBtn.frame.size.height + bottomPadding))
                uiDeliveryBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
            }

        }
    }
    
    func setData(data : [String : String]){
        m_sOriMyPdSeq = data["my_product_seq"] ?? "";
        addCell(CellType: DE_PROCELLTYPE, data: data)
        addCell(CellType: DE_BODYCELLTYPE, data: data)
    }

    @IBAction func onDeliveryBtn(_ sender: Any) {
        let fm_nPay = m_DeliveryBodyCell?.getLastPayment();
        if let fm_nPayO = fm_nPay {
            let fm_nPaymentMd = (m_DeliveryBodyCell?.getPayType() ?? 0)
            if fm_nPaymentMd == 3 && SO.getUserInfoKey(key: Single.DE_USERVERIFIED) == "0"{
                MessagePop(title : "본인인증".localized, msg: "본인인증 하시겠습니까?".localized, ostuch:false, lbtn: "취소".localized, rbtn: "본인인증".localized,succallbackf: { ()-> Void in
                    //self.navigationController?.popViewController(animated: true);
                    let Storyboard: UIStoryboard = UIStoryboard(name: "UserVerification", bundle: nil)
                    let viewController = Storyboard.instantiateViewController(withIdentifier: "UserVerificationidx") as! UserVerification
                    viewController.setData(data: ["os_type":Single.DE_PLATFORMIDX, "account_seq":super.getUserSeq()])
                    self.navigationController?.pushViewController(viewController, animated: true)
                }, closecallbackf: { ()-> Void in
                    //self.navigationController?.popViewController(animated: true);
                })
            }else if fm_nPayO < 0 {
                MessagePop(msg: "배송비 보다 많은 쿠폰 또는 클로버를 사용할수없습니다.".localized, btntype : 2)
            }else{
                let fm_sDeliveryMSG = self.m_DeliveryBodyCell?.getDeliMsg() ?? ""
                if !fm_sDeliveryMSG.hasCharactersNew() {
                    MessagePop(msg: "배송메시지에 특수문자를 입력하실 수 없습니다.".localized, btntype : 2)
                    return;
                }
                
                var fm_arrPdSeqs = [String]()
                for (_, val) in m_ListData.enumerated() {
                    if val.m_nCellType == DE_PROCELLTYPE {
                        fm_arrPdSeqs.append(val.m_Data["my_product_seq"]!)
                    }
                }
                
                let Storyboard: UIStoryboard = UIStoryboard(name: "DeliveryApplyWeb", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "DeliveryApplyWebidx") as! DeliveryApplyWeb
                var data = [String : Any]()
                data["account_seq"] = m_sUserSeq
                data["delivery_price"] = String(fm_nPayO)
                //data["delivery_price_origin"] = m_sMaxDeliveryPrice
                data["delivery_price_origin"] = m_DeliveryBodyCell?.getOriginLastPayMoney();
                data["address_seq"] = m_DeliveryBodyCell?.getAddrSeq() ?? ""
                data["my_product_seqs"] = fm_arrPdSeqs
                data["point"] = "\(m_DeliveryBodyCell?.getUsePoint() ?? 0)"
                data["payment_method"] = "\(fm_nPaymentMd + 1)"
                data["comment"] = m_DeliveryBodyCell?.getDeliMsg() ?? ""
                data["coupon"] = "\(m_DeliveryBodyCell?.getUseCupon() ?? 0)"
                data["account_coupon_seq"] = m_DeliveryBodyCell?.getUseCuponSeq() ?? ""
                viewController.setData(data: data)
                viewController.modalPresentationStyle = .fullScreen
                viewController.m_tClickEvent = m_tClickEvent
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
}
extension DeliveryApply:  UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return m_ListData.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if m_ListData[indexPath.row].m_nCellType == DE_PROCELLTYPE {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCellidx", for: indexPath) as! ProductCell
            cell.m_tClickEvent = self
            cell.setData(data: m_ListData[indexPath.row].m_Data, row: indexPath.row)
            if m_ListData[indexPath.row].m_Data["my_product_seq"] == m_sOriMyPdSeq {
                cell.setHiddenDelBtn(type: true)
            }else{
                cell.setHiddenDelBtn(type: false)
            }
            return cell;
        }else if m_ListData[indexPath.row].m_nCellType == DE_BODYCELLTYPE {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DeliveryBodyCellidx", for: indexPath) as! DeliveryBodyCell
            cell.m_tClickEvent = self
            cell.setData(data: m_ListData[indexPath.row].m_Data, row: indexPath.row)
            cell.setMaxDeliveryPrice(price: m_sMaxDeliveryPrice, gage: m_sMaxGage)
            m_DeliveryBodyCell = cell;
            return cell;
        }
        return collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCellidx", for: indexPath) as! ProductCell;
    }
    
}
extension DeliveryApply: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        var fm_nHeight : CGFloat = 100;
        if m_ListData[indexPath.row].m_nCellType == DE_PROCELLTYPE {
            fm_nHeight = 100;
        }else if m_ListData[indexPath.row].m_nCellType == DE_BODYCELLTYPE {
            fm_nHeight = 1150
        }
        return CGSize(width: width, height: fm_nHeight)
        
    }
    func calculateWith() -> CGFloat {
        let estimatedWidth = CGFloat(self.view.frame.size.width)
        let cellCount = floor(CGFloat(self.view.frame.size.width / estimatedWidth))
        
        let margin = CGFloat(cellMarginSize * 2)
        let width = (self.view.frame.size.width - CGFloat(cellMarginSize) * (cellCount - 1) - margin) / cellCount
        
        return width
    }
}

extension DeliveryApply: DeliveryApplyClickCellBtnDelegate {
    func ClickEvent(celltype :Int, type:Int, data : [String:String]){
        if celltype == 1{
            if type == 1{
                //바디, 배송상품 추가
                var fm_Data = Array<[String:String]>();
                for (_, val) in m_ListData.enumerated() {
                    if val.m_nCellType == DE_PROCELLTYPE {
                        fm_Data.append(val.m_Data)
                    }
                }
                let Storyboard: UIStoryboard = UIStoryboard(name: "DeliveryPdAdd", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "DeliveryPdAddidx") as! DeliveryPdAdd
                viewController.setData(orimypdseq : m_sOriMyPdSeq, data: fm_Data)
                viewController.m_tClickEvent = self;
                self.navigationController?.pushViewController(viewController, animated: true)
            }else if type == 2{
                //바디, 배송지 관리
                let Storyboard: UIStoryboard = UIStoryboard(name: "DeliveryManage", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "DeliveryManageidx") as! DeliveryManage
                viewController.setViewType(ViewType: 1)
                viewController.m_tClickEvent = self;
                self.navigationController?.pushViewController(viewController, animated: true)
            }else if type == 4{
                //헤더 상품 삭제
                if let sdelrow = data["cellrow"] {
                    if let delrow = Int(sdelrow) {
                        self.m_ListData.remove(at: delrow)
                        uiCollectionView.reloadData()
                    }
                }
            }else if type == 5{
                //인벤토리 배송지관리 배송지 선택시
                self.m_DeliveryBodyCell?.setAddress(data: data)
            }else if type == 6{
                //헬프 팝업
                MessagePop(title : "클로버 사용".localized, msg: "클로버는 1개당 1원 가치의 랜덤투유 포인트입니다.\n랜덤박스 및 배송비 결제 시 사용가능합니다.".localized, btntype: 2)
            }
        }
    }
    func ClickEvent(celltype :Int, type:Int, data : Array<[String:String]>){
        if type == 3{
            //배송 상품 추가
            for (_, fmval) in data.enumerated() {
                var fm_isDis = false;
                for (_, val) in m_ListData.enumerated() {
                    if val.m_nCellType == DE_PROCELLTYPE &&
                        (fmval["my_product_seq"] == m_sOriMyPdSeq ||
                        fmval["my_product_seq"] == val.m_Data["my_product_seq"]) {
                        fm_isDis = true;
                    }
                }
                if !fm_isDis {
                    addCell(CellType: DE_PROCELLTYPE, data: fmval)
                }
                
            }
            uiCollectionView.reloadData()
        }
    }
    
}
