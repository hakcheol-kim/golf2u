//
//  TextPopup.swift
//  golf2u
//
//  Created by 이원영 on 2020/09/19.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class FiltterPopup: VariousViewController {
    private let SO = Single.getSO();
    
    public var SaveHandler: (()->())?
    
    @IBOutlet weak var uiTopTabView: ReportCustomSegmentedControl!{
        didSet{
            uiTopTabView.setButtonTitles(buttonTitles: ["랜덤박스".localized,"이벤트박스".localized])
            uiTopTabView.selectorViewColor = UIColor(rgb: 0x00BA87)
            uiTopTabView.selectorTextColor = UIColor(rgb: 0x00BA87)
            uiTopTabView.textColor = .black
            uiTopTabView.backgroundColor = .white
        }
    }
    private var m_nSelMenu = 0;
    private var CheckBtns: Dictionary<String, FiltterPopupCell> = Dictionary<String, FiltterPopupCell>()
    
    private var ProductCategory = Array<[String]>();
    private var m_SelProductCategory = Array<String>();
    
    @IBOutlet weak var categoryCollection: UICollectionView!
    @IBOutlet weak var selView: UIView!
    @IBOutlet weak var selLabel: UILabel!
    @IBOutlet weak var uiCloseBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    
    private var estimateWidth : CGFloat = 125
    private var cellMarginSize : CGFloat = 5
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiTopTabView.delegate = self;
        
        uiCloseBtn.setTitle("닫기".localized, for: .normal)
        saveBtn.setTitle("확인".localized, for: .normal)
        
        self.ProductCategory = SO.getProductCategory();
        ProductCategory = [[String]](ProductCategory.sorted{ Int($0[0])! < Int($1[0])! })
        self.m_SelProductCategory = SO.getSelPCategory();
        self.selLabel.text = "개 선택됨".localized(txt: "\(self.m_SelProductCategory.count)");
        
        selView.layer.cornerRadius = 10.0
        selView.layer.borderWidth = 1.0
        selView.layer.borderColor = UIColor(rgb: 0x00BA87).cgColor
        //saveBtn.layer.cornerRadius = 24.0
        
        Init();
    }
    func Init(){
        categoryCollection.delegate = self;
        categoryCollection.dataSource = self;
        let nib = UINib(nibName: "FiltterPopupCell", bundle: nil)
        categoryCollection?.register(nib, forCellWithReuseIdentifier: "filtterpopcell")
        
        let flow = UICollectionViewFlowLayout()
        flow.sectionInset = UIEdgeInsets(top: 5, left: 13, bottom: 5, right:13)
        flow.scrollDirection = .vertical;
        //flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        //flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
        categoryCollection.collectionViewLayout = flow
        
        
    }
    static func instantiate() -> FiltterPopup? {
        return UIStoryboard(name: "FiltterPopup", bundle: nil).instantiateViewController(withIdentifier: "\(FiltterPopup.self)") as? FiltterPopup
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
            //탭 인덱스가 화면 로딩후 바로 안떠서 0.3초 정도 딜레이 주고 바꿈
            self.uiTopTabView.setIndex(index: SO.getSelPCategoryTab())
            m_nSelMenu = SO.getSelPCategoryTab()
        }
    }
    @IBAction func onCloseBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func onResetBtn(_ sender: Any) {
        onTab()
    }
    @IBAction func onSaveBtn(_ sender: Any) {
        SO.setSelPCategory(data: m_SelProductCategory);
        SO.setSelPCategoryTab(tab: m_nSelMenu)
        SaveHandler?();
        dismiss(animated: true, completion: nil)
    }
    
    func onTab(){
        for (_, value) in CheckBtns{
            value.resetCheck(isA: false)
        }
        m_SelProductCategory.removeAll();
        self.selLabel.text = "개 선택됨".localized(txt: "\(self.m_SelProductCategory.count)");
    }

}
extension FiltterPopup : ReportCustomSegmentedControlDelegate{
    func changeToIndex(index: Int) {
        if m_nSelMenu == index{
            return;
        }
        m_nSelMenu = index;
        onTab()
    }
}
extension FiltterPopup:  UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ProductCategory.count;
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filtterpopcell", for: indexPath) as! FiltterPopupCell
        if ProductCategory.count > indexPath.row{
            
            //let firstKey = Array(ProductCategory.keys)[indexPath.row]
            //let title = ProductCategory[firstKey];
            let item = ProductCategory[indexPath.row]
            let indexOfA = m_SelProductCategory.firstIndex(of: item[0])
            var isCheck = false;
            if indexOfA != nil {
                isCheck = true;
            }
            cell.setCTitle(key: item[0], title: item[1],isCheck: isCheck)
            cell.checkHandler = { (Key:String, Check:Bool)-> Void in
                //print("\(Key) \(Check)");
                if Check {
                    self.m_SelProductCategory.append(Key)
                }else{
                    if let index = self.m_SelProductCategory.firstIndex(of: Key){
                        self.m_SelProductCategory.remove(at: index)
                    }
                }
                self.selLabel.text = "개 선택됨".localized(txt: "\(self.m_SelProductCategory.count)");
            }
            if !CheckBtns.keys.contains(item[0]) {
                CheckBtns[item[0]] = cell;
            }
        }else{
        }
        return cell;
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
}
extension FiltterPopup: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        return CGSize(width: width, height: 47)
    }
    
    func calculateWith() -> CGFloat {
//        let estimatedWidth = CGFloat(estimateWidth)
//        let cellCount = floor(CGFloat(self.categoryCollection.frame.size.width / estimatedWidth))
//
//        let margin = CGFloat(cellMarginSize * 2)
//        let width = (self.categoryCollection.frame.size.width - CGFloat(cellMarginSize) * (cellCount - 1) - margin) / cellCount
//
//        return width
        return (self.categoryCollection.frame.size.width / 2 - 18)
    }
}
