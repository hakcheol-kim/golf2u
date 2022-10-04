//
//  ProductFilterPop.swift
//  golf2u
//
//  Created by 이원영 on 2021/06/21.
//  Copyright © 2021 이원영. All rights reserved.
//

import UIKit

class ProductFilterPop: UIViewController {
    private let SO = Single.getSO();
    
    public var SaveHandler: (()->())?

    @IBOutlet weak var selView: UIView!
    @IBOutlet weak var selLabel: UILabel!
    @IBOutlet weak var uiCloseBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    
    @IBOutlet weak var chec1kbtn: CircleCheckBoxBtn!
    @IBOutlet weak var chec2kbtn: CircleCheckBoxBtn!
    @IBOutlet weak var chec3kbtn: CircleCheckBoxBtn!
    
    private var m_SelProductCategory = Array<String>();
    
    static func instantiate() -> ProductFilterPop? {
        return UIStoryboard(name: "ProductFilterPop", bundle: nil).instantiateViewController(withIdentifier: "\(ProductFilterPop.self)") as? ProductFilterPop
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiCloseBtn.setTitle("닫기".localized, for: .normal)
        saveBtn.setTitle("확인".localized, for: .normal)
        
        self.m_SelProductCategory = SO.getSelInvenPCategory();
        if m_SelProductCategory.firstIndex(of: "1") != nil {
            chec1kbtn.buttonStateModify(isA:true)
        }
        if m_SelProductCategory.firstIndex(of: "2") != nil {
            chec2kbtn.buttonStateModify(isA:true)
        }
        if m_SelProductCategory.firstIndex(of: "3") != nil {
            chec3kbtn.buttonStateModify(isA:true)
        }
        
        self.selLabel.text = "개 선택됨".localized(txt: "\(m_SelProductCategory.count)");
        
        selView.layer.cornerRadius = 10.0
        selView.layer.borderWidth = 1.0
        selView.layer.borderColor = UIColor(rgb: 0x00BA87).cgColor

    }
    @IBAction func onCloseBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func onResetBtn(_ sender: Any) {
        chec1kbtn.buttonStateModify(isA:false)
        chec2kbtn.buttonStateModify(isA:false)
        chec3kbtn.buttonStateModify(isA:false)
        m_SelProductCategory.removeAll()
        self.selLabel.text = "개 선택됨".localized(txt: "0");
    }
    @IBAction func onSaveBtn(_ sender: Any) {
        SO.setSelInvenPCategory(data: m_SelProductCategory)
        SaveHandler?();
        dismiss(animated: true, completion: nil)
    }
    @IBAction func onCheck1Btn(_ sender: Any) {
        let fm_sKey = "1"
        let indexOfA = m_SelProductCategory.firstIndex(of: fm_sKey)
        var isCheck = false;
        if indexOfA != nil {
            isCheck = true;
        }
        if !isCheck {
            self.m_SelProductCategory.append(fm_sKey)
        }else{
            if let index = self.m_SelProductCategory.firstIndex(of: fm_sKey){
                self.m_SelProductCategory.remove(at: index)
            }
        }
        self.selLabel.text = "개 선택됨".localized(txt: "\(self.m_SelProductCategory.count)");
    }
    @IBAction func onCheck2Btn(_ sender: Any) {
        let fm_sKey = "2"
        let indexOfA = m_SelProductCategory.firstIndex(of: fm_sKey)
        var isCheck = false;
        if indexOfA != nil {
            isCheck = true;
        }
        if !isCheck {
            self.m_SelProductCategory.append(fm_sKey)
        }else{
            if let index = self.m_SelProductCategory.firstIndex(of: fm_sKey){
                self.m_SelProductCategory.remove(at: index)
            }
        }
        self.selLabel.text = "개 선택됨".localized(txt: "\(self.m_SelProductCategory.count)");
    }
    @IBAction func onCheck3Btn(_ sender: Any) {
        let fm_sKey = "3"
        let indexOfA = m_SelProductCategory.firstIndex(of: fm_sKey)
        var isCheck = false;
        if indexOfA != nil {
            isCheck = true;
        }
        if !isCheck {
            self.m_SelProductCategory.append(fm_sKey)
        }else{
            if let index = self.m_SelProductCategory.firstIndex(of: fm_sKey){
                self.m_SelProductCategory.remove(at: index)
            }
        }
        self.selLabel.text = "개 선택됨".localized(txt: "\(self.m_SelProductCategory.count)");
    }


}
