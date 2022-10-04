//
//  Customer.swift
//  golf2u
//
//  Created by 이원영 on 2020/12/03.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class Customer: VariousViewController {
    private let SO = Single.getSO();
    private let JS = JsonC();

    @IBOutlet weak var uiFaqBtn: UIButton!
    @IBOutlet weak var uiNoticeBtn: UIButton!
    @IBOutlet weak var uiEventBtn: UIButton!
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "고객센터".localized)
        super.viewDidLoad()
        
        uiFaqBtn.setTitle("FAQ 및 1:1 문의".localized, for: .normal)
        uiNoticeBtn.setTitle("공지사항".localized, for: .normal)
        uiEventBtn.setTitle("이벤트".localized, for: .normal)
        
        self.uiFaqBtn.layer.addBorder([.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        self.uiNoticeBtn.layer.addBorder([.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        self.uiEventBtn.layer.addBorder([.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)

    }
    
    @IBAction func onFaqBtn(_ sender: Any) {
        let Storyboard: UIStoryboard = UIStoryboard(name: "FaqInfo", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "FaqInfoidx") as! FaqInfo
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    @IBAction func onNoticeBtn(_ sender: Any) {
        let Storyboard: UIStoryboard = UIStoryboard(name: "NoticeInfo", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "NoticeInfoidx") as! NoticeInfo
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    @IBAction func onEventBtn(_ sender: Any) {
        let Storyboard: UIStoryboard = UIStoryboard(name: "EventInfo", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "EventInfoidx") as! EventInfo
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}
