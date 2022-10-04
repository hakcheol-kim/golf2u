//
//  TradeSearchProduct.swift
//  golf2u
//
//  Created by 이원영 on 2020/10/16.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import RangeSeekSlider

class TradeSearchProduct: UIView {
    private var SO:Single = Single.getSO();
    private let JS = JsonC();
    private let xibName = "TradeSearchProduct"
    
    private var m_sUserSeq : String = "";
    
    @IBOutlet weak var uiCollectionView: UICollectionView!
    @IBOutlet weak var uiTitlelb: UILabel!
    @IBOutlet weak var uiSubTktlelb: UILabel!
    
    private var estimateWidth = 160.0
    private var cellMarginSize = 5.0
    
    private var CheckBtns: Dictionary<String, TradeSearchProductCell> = Dictionary<String, TradeSearchProductCell>()
    private var ProductCategory = Array<[String]>();
    private var m_SelProductCategory = Array<String>();
    
    @IBOutlet weak var uiSlider: RangeSeekSlider!
    
    private var m_srRangeValue = ["10,000","30,000","50,000 ","100,000","200,000" ,"300,000","500,000","1,000,000+"];
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing(true)
    }
    private func commonInit(){
        let view = Bundle.main.loadNibNamed(xibName, owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        
        uiTitlelb.text = "카테고리 필터 설정";
        uiSubTktlelb.text = "가격대(정가) 필터 설정";
        
        m_sUserSeq = SO.getUserInfoKey(key: "seq")
        
        self.ProductCategory = SO.getProductCategory();
        ProductCategory = [[String]](ProductCategory.sorted{ Int($0[0])! < Int($1[0])! })
        self.m_SelProductCategory = SO.getTradeSelPCategory();
        
        uiCollectionView.delegate = self;
        uiCollectionView.dataSource = self;
        let nib = UINib(nibName: "TradeSearchProductCell", bundle: nil)
        uiCollectionView?.register(nib, forCellWithReuseIdentifier: "tradesearchproductcellidx")
        
        let flow = UICollectionViewFlowLayout()
        //flow.sectionInset = UIEdgeInsets(top: 5, left: 1, bottom: 1, right:1)
        flow.scrollDirection = .vertical;
        //flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        //flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
        uiCollectionView.collectionViewLayout = flow
        
        // custom number formatter range slider
        
        uiSlider.minValue = 0.0
        uiSlider.maxValue = 7.0
        uiSlider.selectedMinValue = CGFloat(SO.getTradeSearchProductMin())
        uiSlider.selectedMaxValue = CGFloat(SO.getTradeSearchProductMax())
        uiSlider.handleImage = UIImage(named: "trade_Gauge")?.resizeImage(targetSize: CGSize(width: 40, height: 40))
        uiSlider.selectedHandleDiameterMultiplier = 1.0
        uiSlider.colorBetweenHandles = UIColor(rgb: 0x00BA87)
        uiSlider.tintColor = UIColor(rgb: 0x999999)
        uiSlider.lineHeight = 8.0
        uiSlider.numberFormatter.positivePrefix = ""
        uiSlider.numberFormatter.positiveSuffix = ""
        
        uiSlider.delegate = self
        
//        uiSliderView.setValueChangedCallback { (minValue, maxValue) in
//                    //print("rangeSlider1 min value:\(minValue)")
//                    //print("rangeSlider1 max value:\(maxValue)")
//                }
//        uiSliderView.setMinValueDisplayTextGetter { (minValue) -> String? in
//                    return "\(minValue)"
//                }
//        uiSliderView.setMaxValueDisplayTextGetter { (maxValue) -> String? in
//                    return "\(maxValue)"
//                }
//        uiSliderView.setMinAndMaxRange(0, maxRange: 9)
//        uiSliderView.setMinAndMaxValue(0, maxValue: 9)
//        //uiSliderView.tintColor = UIColor.red;
//        uiSliderView.trackHighlightTintColor = UIColor(rgb: 0x00BA87)
//        uiSliderView.minValueThumbTintColor = UIColor(rgb: 0x00BA87)
//        uiSliderView.maxValueThumbTintColor = UIColor(rgb: 0x00BA87)
        
        
    }
}
extension TradeSearchProduct:  UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ProductCategory.count;
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tradesearchproductcellidx", for: indexPath) as! TradeSearchProductCell
        if ProductCategory.count > indexPath.row{
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
                self.SO.setTradeSelPCategory(data: self.m_SelProductCategory);
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
extension TradeSearchProduct: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        return CGSize(width: width, height: 45)
    }
    
    func calculateWith() -> CGFloat {
        let estimatedWidth = CGFloat(estimateWidth)
        let cellCount = floor(CGFloat(self.uiCollectionView.frame.size.width / estimatedWidth))
        
        let margin = CGFloat(cellMarginSize * 2)
        let width = (self.uiCollectionView.frame.size.width - CGFloat(cellMarginSize) * (cellCount - 1) - margin) / cellCount
        
        return width
    }
}
extension TradeSearchProduct: RangeSeekSliderDelegate {

    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        if slider === uiSlider {
            self.SO.setTradeSearchProductMinAndMax(f_nTradeSearchMemberMin: Int(minValue), f_nTradeSearchMemberMax: Int(maxValue))
        }
    }
    
    func didStartTouches(in slider: RangeSeekSlider) {
        //print("did start touches")
    }

    func didEndTouches(in slider: RangeSeekSlider) {
        //print("did end touches")
    }
    func rangeSeekSlider(_ slider: RangeSeekSlider, stringForMinValue minValue: CGFloat) -> String? {
        let intt = Int(minValue)
        return m_srRangeValue[intt]
        
    }
    func rangeSeekSlider(_ slider: RangeSeekSlider, stringForMaxValue maxValue: CGFloat) -> String? {
        let intt = Int(maxValue)
        return m_srRangeValue[intt]
    }
}
 
