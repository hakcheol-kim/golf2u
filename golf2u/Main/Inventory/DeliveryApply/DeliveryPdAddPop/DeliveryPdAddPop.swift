//
//  DeliveryPdAddPop.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/16.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class DeliveryPdAddPop: VariousViewController {

    @IBOutlet weak var uiColoseBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiColoseBtn.layer.addBorder([.top,], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        uiColoseBtn.setTitle("닫기".localized, for: .normal)
    }
    static func instantiate() -> DeliveryPdAddPop? {
        return UIStoryboard(name: "DeliveryPdAddPop", bundle: nil).instantiateViewController(withIdentifier: "\(DeliveryPdAddPop.self)") as? DeliveryPdAddPop
    }

    @IBAction func onCloseBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
