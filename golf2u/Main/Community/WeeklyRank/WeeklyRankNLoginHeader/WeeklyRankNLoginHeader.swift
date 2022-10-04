//
//  WeeklyRankNLoginHeader.swift
//  golf2u
//
//  Created by 이원영 on 2020/12/17.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class WeeklyRankNLoginHeader: UICollectionReusableView {
    private let SO = Single.getSO();
    @IBOutlet weak var uiTitle: UILabel!
    @IBOutlet weak var uiLoginBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        uiTitle.text = "랭킹전에참가하여\n다양한 보상을 받아보세요!".localized;
        uiTitle.TextPartBold(partstr: "다양한 보상".localized, fontSize: 18)
        uiLoginBtn.layer.cornerRadius = uiLoginBtn.bounds.height/2;
        uiLoginBtn.setTitle("로그인하여 자동 참가", for: .normal)
    }
    func setData(){
        
    }
}
