//
//  MainPopupNoticeItem.swift
//  golf2u
//
//  Created by 이원영 on 2020/12/08.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class MainPopupNoticeItem: UIView {

    private let xibName = "MainPopupNoticeItem"
    
    private var m_nRow = 0;
    
    @IBOutlet weak var uiImg: UIImageView!
    private var m_ArrData = [String : String]()
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
    }
    func setData(data : [String : String], row : Int){
        m_nRow = row;
        m_ArrData = data;
        uiImg.setImage(with: "\(Single.DE_URLIMGSERVER)\(data["file1"] ?? "")")
    }

}
