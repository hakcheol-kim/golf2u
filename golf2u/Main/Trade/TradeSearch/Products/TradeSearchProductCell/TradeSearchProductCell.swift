//
//  TradeSearchProductCell.swift
//  golf2u
//
//  Created by 이원영 on 2020/10/16.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class TradeSearchProductCell: UICollectionViewCell {
    public var checkHandler: ((String, Bool)->())?
    private var m_sKey : String = "";
    private var m_isCheck : Bool = false;
    @IBOutlet weak var checkbtn: CircleCheckBoxBtn!
    @IBOutlet weak var ctitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setCTitle(key : String, title : String, isCheck : Bool){
        m_sKey = key;
        ctitle.text = title;
        m_isCheck = isCheck;
        resetCheck(isA: m_isCheck);
    }

    @IBAction func onCheckBtn(_ sender: Any) {
        checkHandler?(m_sKey, (!checkbtn.isChecked))
    }
    
    func resetCheck(isA : Bool){
        checkbtn.buttonStateModify(isA:isA)
    }
}
