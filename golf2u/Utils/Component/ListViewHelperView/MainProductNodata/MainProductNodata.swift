//
//  MainProductNodata.swift
//  golf2u
//
//  Created by 이원영 on 2021/02/08.
//  Copyright © 2021 이원영. All rights reserved.
//

import UIKit

class MainProductNodata: UIView {

    private let xibName = "MainProductNodata"
    
    @IBOutlet weak var uiHelpLb: UILabel!
    
    
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
        uiHelpLb.text = "등록된 상품후기가 없습니다.".localized
        
        
    }
    

}
