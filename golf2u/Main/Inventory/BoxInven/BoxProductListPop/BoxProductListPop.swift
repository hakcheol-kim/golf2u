//
//  BoxProductListPop.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/05.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON

class BoxProductListPop: VariousViewController {
    public var ClickCellHandler: ((String)->())?
    
    private var SO:Single = Single.getSO();
    private let JS = JsonC();

    @IBOutlet weak var uiBoxTypeLabel: UILabel!
    @IBOutlet weak var uiDataCntLabel: UILabel!
    @IBOutlet weak var uiCollectionView: UICollectionView!
    @IBOutlet weak var uiPrivateLabel: UILabel!
    @IBOutlet weak var uiCloseBtn: UIButton!
    
    private var m_ListData = Array<[String:String]>();
    
    private var m_nPageNum = 0;
    private var m_nNextNum = 0;
    private var m_nDataCnt = 0;
    
    private var estimateWidth = 95.0
    private var cellMarginSize = 0.0
    
    private var m_sBoxType = "1";
    
    private var m_isPagging = false;
    
    func setData(type : String){
        m_sBoxType = type;
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        uiCollectionView.delegate = self;
        uiCollectionView.dataSource = self;
        let nib = UINib(nibName: "BoxProductListPopCell", bundle: nil)
        uiCollectionView?.register(nib, forCellWithReuseIdentifier: "BoxProductListPopCellidx")
        
        let flow = UICollectionViewFlowLayout()
        flow.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right:0)
        flow.scrollDirection = .vertical;
        flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
        //flow.sectionHeadersPinToVisibleBounds = true;//헤더 고정
        
        //flow.minimumInteritemSpacing = 20//양쪽 마진
        flow.minimumLineSpacing = 10//아래위 마진
        
        uiCollectionView.collectionViewLayout = flow
        uiCloseBtn.setTitle("닫기".localized, for: .normal)
        uiPrivateLabel.text = "박스 오픈 시점에 '상품리스트'에 노출된 상품 중 한 상품이 획득됩니다.".localized;
        uiPrivateLabel.TextPartColor(partstr: "'상품리스트'".localized, Color: UIColor(rgb: 0x00BA87))
        
        if m_sBoxType == "1" {
            uiBoxTypeLabel.text = "랜덤박스 상품리스트".localized;
            uiBoxTypeLabel.TextPartColor(partstr: "랜덤박스".localized, Color: UIColor(rgb: 0x00BA87))
        }else{
            uiBoxTypeLabel.text = "이벤트박스 상품리스트".localized;
            uiBoxTypeLabel.TextPartColor(partstr: "이벤트박스".localized, Color: UIColor(rgb: 0x00BA87))
        }
        
        LoadItem();
        
    }
    
    static func instantiate() -> BoxProductListPop? {
        return UIStoryboard(name: "BoxProductListPop", bundle: nil).instantiateViewController(withIdentifier: "\(BoxProductListPop.self)") as? BoxProductListPop
    }
    
    @IBAction func onCloseBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func LoadItem(){
        LoadingHUD.show()
        m_isPagging = true;
        m_nPageNum += 1;
        JS.InventoryBoxRandomList(param: ["pagenum":"\(m_nPageNum)", "box_type":m_sBoxType], callbackf: InventoryBoxRandomListCallback)
    }
    func InventoryBoxRandomListCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            if let val = alldata["nextpage"].string{
                m_nNextNum = Int(val)!;
            }
            if let val = alldata["datacnt"].string{
                m_nDataCnt = Int(val)!;
                uiDataCntLabel.text = "총 개 상품".localized(txt: "\(m_nDataCnt)");
                uiDataCntLabel.TextPartColor(partstr: "\(m_nDataCnt)", Color: UIColor(rgb: 0x00BA87))
            }
            for (_, object) in alldata["data"] {
                var item = [String:String]()
                item["seq"] = object["seq"].stringValue;
                item["name"] = object["name"].stringValue;
                item["thumbnail"] = object["thumbnail"].stringValue;
                item["brand"] = object["brand"].stringValue;
                item["price"] = object["price"].stringValue;
                m_ListData.append(item)
            }
        }
        self.uiCollectionView.reloadData()
        m_isPagging = false
        LoadingHUD.hide()
    }

}
extension BoxProductListPop:  UICollectionViewDelegate, UICollectionViewDataSource {
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BoxProductListPopCellidx", for: indexPath) as! BoxProductListPopCell
        if m_ListData.count > indexPath.row{
            cell.setData(data: m_ListData[indexPath.row]);
        }else{
        }
        return cell;
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (m_ListData.count - 1) <= indexPath.row && m_nNextNum > 0 && !m_isPagging{
           
           self.LoadItem();
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ClickCellHandler?(m_ListData[indexPath.row]["seq"]!)
        dismiss(animated: true, completion: nil)
    }
    
    
}
extension BoxProductListPop: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        return CGSize(width: width, height: width)
    }
    
    func calculateWith() -> CGFloat {
        let estimatedWidth = CGFloat(estimateWidth)
        let cellCount = floor(CGFloat(uiCollectionView.frame.size.width / estimatedWidth))
        
        let width = (self.view.frame.size.width) / cellCount - 15
        
        return width
    }
}
