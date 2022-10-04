//
//  DefProfilePop.swift
//  golf2u
//
//  Created by 이원영 on 2020/12/08.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class DefProfilePop: VariousViewController {
    private let SO = Single.getSO();
    
    public var SaveHandler: ((Int, UIImage)->())?
    
    private var estimateWidth = 150.0
    private var cellMarginSize = 5.0

    @IBOutlet weak var uiTitlelb: UILabel!
    @IBOutlet weak var uiCollectionView: UICollectionView!
    @IBOutlet weak var uiAccBtn: UIButton!
    private let m_ArrData = [UIImage(named: "profile_01")!, UIImage(named: "profile_02")!, UIImage(named: "profile_03")!, UIImage(named: "profile_04")!]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiTitlelb.text = "기본이미지 선택".localized;
        uiAccBtn.setTitle("닫기".localized, for: .normal)

        uiCollectionView.delegate = self;
        uiCollectionView.dataSource = self;
        let flow = UICollectionViewFlowLayout()
        flow.sectionInset = UIEdgeInsets(top: 3, left: 13, bottom: 3, right:13)
        flow.scrollDirection = .vertical;
        flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
        //flow.sectionHeadersPinToVisibleBounds = true;//헤더 고정
        uiCollectionView.collectionViewLayout = flow
        let nib = UINib(nibName: "DefProfilePopCell", bundle: nil)
        uiCollectionView?.register(nib, forCellWithReuseIdentifier: "DefProfilePopCellidx")
        
        self.uiAccBtn.layer.addBorder([.top], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
    }
    static func instantiate() -> DefProfilePop? {
        return UIStoryboard(name: "DefProfilePop", bundle: nil).instantiateViewController(withIdentifier: "\(DefProfilePop.self)") as? DefProfilePop
    }

    @IBAction func onAccBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
extension DefProfilePop:  UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return m_ArrData.count;
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DefProfilePopCellidx", for: indexPath) as! DefProfilePopCell
        cell.setImage(url: m_ArrData[indexPath.row])
        return cell;
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        SaveHandler?(indexPath.row, m_ArrData[indexPath.row])
        dismiss(animated: true, completion: nil)
    }
    
}
extension DefProfilePop: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        return CGSize(width: width, height: width)
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
