//
//  CuponInfo.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/25.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON
import EzPopup

protocol CuponInfoDelegate: class {
    func ClickEvent(type:Int, data : [String:String])
}

class CuponInfo: VariousViewController {
    private let SO = Single.getSO();
    private let JS = JsonC();
    
    @IBOutlet weak var uiTopTabView: ReportCustomSegmentedControl!{
        didSet{
            uiTopTabView.setButtonTitles(buttonTitles: ["획득가능쿠폰".localized,"쿠폰보관함".localized])
            uiTopTabView.selectorViewColor = UIColor(rgb: 0x00BA87)
            uiTopTabView.selectorTextColor = UIColor(rgb: 0x00BA87)
            uiTopTabView.textColor = .black
            uiTopTabView.backgroundColor = .white
        }
    }
    
    private var m_nSelMenu = 0;
    @IBOutlet weak var uiTopView: UIView!
    @IBOutlet weak var uiCntLabel: UILabel!
    @IBOutlet weak var uiCollectionView: UICollectionView!
    private var refreshControl = UIRefreshControl()
    @IBOutlet weak var uiHelplb: UILabel!
    @IBOutlet weak var uiAccBtn: UIButton!
    
    private var m_nPageNum = 0;
    private var m_nNextNum = 0;
    private var m_nDataCnt = 0;
    private var estimateWidth = 160.0
    private var cellMarginSize = 0.0
    
    private var m_ListData = Array<[String:String]>();
    private var m_CViewLayout = [NSLayoutConstraint]();
    
    private var m_sUserSeq : String = "";
    
    private var m_isPagging = false;
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "쿠폰함".localized)
        super.viewDidLoad()
        
        uiHelplb.text = "유효기간 경과 후 자동 소멸".localized
        uiAccBtn.setTitle("지류쿠폰 등록하기".localized, for: .normal)
        
        uiTopTabView.delegate = self;
        
        m_sUserSeq = super.getUserSeq()
        
        uiAccBtn.layer.cornerRadius = uiAccBtn.bounds.height/2;
        
        self.uiTopView.layer.addBorder([.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
        uiCollectionView.delegate = self;
        uiCollectionView.dataSource = self;
        let nib = UINib(nibName: "CuponInfoCell", bundle: nil)
        uiCollectionView.register(nib, forCellWithReuseIdentifier: "CuponInfoCellidx")
        
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
        
        
        setContentsView();
        
        LoadItem();
        
    }
    func setContentsView(){
        if m_CViewLayout.count > 0 {
            //기존에 적용되어있던 레이아웃이 있으면 삭제
            NSLayoutConstraint.deactivate(m_CViewLayout)
        }
        uiCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let leadingCons = uiCollectionView.topAnchor.constraint(equalTo: uiTopView.bottomAnchor,constant: 10)
        let trailingCons = uiCollectionView.leftAnchor.constraint(equalTo:self.view.leftAnchor,constant: 0)
        let topCons = uiCollectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0)
        var bottomCons : NSLayoutConstraint?
        if m_nSelMenu == 0 {
            bottomCons = uiCollectionView.bottomAnchor.constraint(equalTo: self.uiAccBtn.topAnchor, constant: -10)
        }else{
            bottomCons = uiCollectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        }
        m_CViewLayout = [leadingCons, trailingCons, topCons, bottomCons!]
        //새로운 레이아웃 적용
        NSLayoutConstraint.activate(m_CViewLayout)
    }
    @objc func refresh(){
        m_nPageNum = 0;
        m_nNextNum = 0;
        m_nDataCnt = 0;
        m_ListData.removeAll();
        LoadItem();
    }
    func LoadItem(){
        m_isPagging = true;
        m_nPageNum += 1;
        LoadingHUD.show()
        JS.getAllRecvableCoupon(param: ["pagenum":m_nPageNum,"account_seq":m_sUserSeq,"type":String(m_nSelMenu)], callbackf: getAllRecvableCouponCallback)
    }
    func getAllRecvableCouponCallback(alldata: JSON)->Void {
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
                item["description"] = object["description"].stringValue;
                item["type"] = object["type"].stringValue;
                item["usage_start_date"] = object["usage_start_date"].stringValue;
                item["usage_end_date"] = object["usage_end_date"].stringValue;
                item["d_day"] = object["d_day"].stringValue;
                item["limit_start_date"] = object["limit_start_date"].stringValue;
                item["discount_price"] = object["discount_price"].stringValue;
                item["need_verified"] = object["need_verified"].stringValue;
                item["downloaded"] = object["downloaded"].stringValue;
                item["account_coupon_seq"] = object["account_coupon_seq"].stringValue;
                item["discount_price"] = object["discount_price"].stringValue;
                m_ListData.append(item)
            }
        }
        self.uiCollectionView.reloadData()
        self.refreshControl.endRefreshing();
        m_isPagging = false
        LoadingHUD.hide()
    }
    
    @IBAction func onAccBtn(_ sender: Any) {
        let Storyboard: UIStoryboard = UIStoryboard(name: "CuponInfoPaper", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "CuponInfoPaperidx") as! CuponInfoPaper
        viewController.m_tClickEvent = self;
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    

}
extension CuponInfo:  UICollectionViewDelegate, UICollectionViewDataSource {
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CuponInfoCellidx", for: indexPath) as! CuponInfoCell
        if m_ListData.count > indexPath.row{
            cell.setData(data: m_ListData[indexPath.row], row: indexPath.row, viewtype : m_nSelMenu);
            cell.m_tClickEvent = self;
        }else{
        }
        return cell;
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (m_ListData.count - 1) <= indexPath.row && m_nNextNum > 0 && !m_isPagging{
           
           self.LoadItem();
        }
    }
}
extension CuponInfo: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        
        return CGSize(width: width, height: 160)
        
    }
    func calculateWith() -> CGFloat {
        let estimatedWidth = CGFloat(self.view.frame.size.width)
        let cellCount = floor(CGFloat(self.view.frame.size.width / estimatedWidth))
        
        let margin = CGFloat(cellMarginSize * 2)
        let width = (self.view.frame.size.width - CGFloat(cellMarginSize) * (cellCount - 1) - margin) / cellCount
        
        return width
    }
}

extension CuponInfo : ReportCustomSegmentedControlDelegate{
    func changeToIndex(index: Int) {
        if m_nSelMenu == index{
            return;
        }
        m_nSelMenu = index;
        if m_nSelMenu == 1 {
            uiAccBtn.isHidden = true;
        }else{
            uiAccBtn.isHidden = false;
        }
        setContentsView();
        refresh();
    }
    
}
extension CuponInfo: CuponInfoDelegate {
    func ClickEvent(type:Int, data : [String:String]){
        if type == 1 {
            //쿠폰 다운로드
            if data["need_verified"] == "1" {
                if SO.getUserInfoKey(key: Single.DE_USERVERIFIED) == "0" {
                    MessagePop(title : "본인인증".localized, msg: "본 쿠폰을 획득하기 위해서는\n본인인증이 필요합니다.".localized, ostuch:false, lbtn: "취소".localized, rbtn: "인증하기".localized,succallbackf: { ()-> Void in
                        
                        let Storyboard: UIStoryboard = UIStoryboard(name: "UserVerification", bundle: nil)
                        let viewController = Storyboard.instantiateViewController(withIdentifier: "UserVerificationidx") as! UserVerification
                        viewController.setData(data: ["os_type":Single.DE_PLATFORMIDX, "account_seq":super.getUserSeq()])
                        self.navigationController?.pushViewController(viewController, animated: true)
                    }, closecallbackf: { ()-> Void in
                        
                    })
                    
                }else{
                    JS.takeCoupon(param: ["coupon_seq":data["seq"] ?? "","account_seq":m_sUserSeq], callbackf: takeCouponCallback)
                }
            }else{
                JS.takeCoupon(param: ["coupon_seq":data["seq"] ?? "","account_seq":m_sUserSeq], callbackf: takeCouponCallback)
            }
        }else if type == 2 {
            //획득 완료
        }else if type == 3 {
            //쿠폰사용
            if data["type"] == "0" {
                //박스
                let Storyboard: UIStoryboard = UIStoryboard(name: "BoxBuy", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "BoxBuyidx") as! BoxBuy
                self.navigationController?.pushViewController(viewController, animated: true)
            }else if data["type"] == "1" {
                //배송쿠폰은 상품보관함으로(인벤토리)
                SO.setInventoryTabIdx(TabbarIndex: 1)
                self.tabBarController?.selectedIndex = 3;
                self.navigationController?.popViewController(animated: true);
            }
        }else if type == 4 {
            //쿠폰 획득 완료
        }
    }
    func takeCouponCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            MessagePop(msg: alldata["errormessage"].stringValue, btntype : 2)
        }else{
            refresh()
            MessagePop(msg: "쿠폰을 획득했습니다.\n쿠폰 보관함을 확인하세요.".localized, btntype : 2)
        }
    }
}
