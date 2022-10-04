//
//  CheckBoxBtn.swift
//  golf2u
//
//  Created by 이원영 on 2020/09/18.
//  Copyright © 2020 이원영. All rights reserved.
//

import Foundation
import UIKit

protocol ClickCircleEventDelegate: class {
    func ClickEvent(isChecked: Bool, compo : CircleCheckBoxBtn)
}

class CircleCheckBoxBtn: UIButton {
    weak var m_tClickEvent: ClickCircleEventDelegate? = nil;
    // Images
    let checkedImage = UIImage(named: "check_circle")! as UIImage
    let uncheckedImage = UIImage(named: "check_circle_blank")! as UIImage
    
    // Bool property
    var isChecked: Bool = false {
        didSet {
            if isChecked == true {
                self.setImage(checkedImage, for: UIControl.State.normal)
                //self.tintColor  = UIColor(rgb: 0x00BA87)
            } else {
                self.setImage(uncheckedImage, for: UIControl.State.normal)
            }
        }
    }
        
    override func awakeFromNib() {
        self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)
        self.isChecked = false
        //self.setImage(uncheckedImage, for: UIControl.State.normal)
    }
    func buttonStateModify(isA : Bool){
        isChecked = isA
    }
    func buttonStateModify(){
        isChecked = !isChecked
    }
    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            buttonStateModify()
        }
        if let event = m_tClickEvent{
            event.ClickEvent(isChecked: isChecked, compo: self);
        }
    }
}
