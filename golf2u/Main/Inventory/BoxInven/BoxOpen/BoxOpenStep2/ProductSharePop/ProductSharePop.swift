//
//  ProductSharePop.swift
//  golf2u
//
//  Created by 이원영 on 2020/12/18.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class ProductSharePop: VariousViewController {

    @IBOutlet weak var uiTitlelb: UILabel!
    @IBOutlet weak var uiKakao: UIButton!
    @IBOutlet weak var uiFacebook: UIButton!
    @IBOutlet weak var uiClose: UIButton!
    
    private var m_nRow : Int = 0;
    
    static func instantiate() -> ProductSharePop? {
        return UIStoryboard(name: "ProductSharePop", bundle: nil).instantiateViewController(withIdentifier: "\(ProductSharePop.self)") as? ProductSharePop
    }
    func setData(row : Int) {
        m_nRow = row
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiTitlelb.text = "공유하기".localized;
        uiKakao.setTitle("카카오톡".localized, for: .normal)
        uiFacebook.setTitle("페이스북".localized, for: .normal)
        uiClose.setTitle("닫기".localized, for: .normal)
        
        uiClose.layer.addBorder([.top], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
        uiKakao.tag = m_nRow
        uiFacebook.tag = m_nRow

    }
    @IBAction func onClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    


}
