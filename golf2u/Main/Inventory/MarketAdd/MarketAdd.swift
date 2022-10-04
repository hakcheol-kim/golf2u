//
//  MarketAdd.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/11.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import EzPopup
import SwiftyJSON

class MarketAdd: VariousViewController {
    weak var m_tClickEvent: InventoryMainClickCellBtnDelegate? = nil;
    private let SO = Single.getSO();
    private let JS = JsonC();

    @IBOutlet weak var uiTopView: UIView!
    @IBOutlet weak var uiProImg: UIImageView!
    @IBOutlet weak var uiProName: UILabel!
    @IBOutlet weak var uiPrice: UILabel!
    @IBOutlet weak var uiTitle: UILabel!
    @IBOutlet weak var uiTextView: UITextView!{
        didSet {
            uiTextView?.addDoneToolbar(onDone: (target: self, action: #selector(doneButtonTappedForMyNumericTextField)))
        }
    }
    @IBOutlet weak var uiAccBtn: UIButton!
    
    private var m_sData = [String : String]()
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "마켓 등록".localized)
        super.viewDidLoad()
        
        uiTitle.text = "메시지 등록(선택)".localized;
        uiAccBtn.setTitle("등록하기".localized, for: .normal)
        
        uiProImg.layer.cornerRadius = 8.0;
        uiProImg.layer.borderWidth = 1.0
        uiProImg.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        uiTextView.layer.cornerRadius = 8.0;
        uiTextView.layer.borderWidth = 1.0
        uiTextView.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiTextView.delegate = self;
        uiTextView.text = "트레이드 마켓에 상품 등록 시 필요한 내용을 입력하세요.(100자 이내)".localized;
        uiTextView.textColor = UIColor.lightGray
        
        uiTopView.layer.addBorder([.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
        uiTitle.TextPartColor(partstr: "(선택)".localized, Color: UIColor(rgb: 0x00BA87))
        
        uiProImg.image = nil
        if let imgurl = m_sData["thumbnail"]{
            uiProImg.setImage(with: "\(Single.DE_URLIMGSERVER)\(imgurl)")
        }
        uiProName.text = m_sData["name"];
        uiPrice.text = "정가 | 원".localized(txt: "\(m_sData["price"]!.DecimalWon())");

    }
    @objc func doneButtonTappedForMyNumericTextField() {
        self.view.endEditing(true)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 11.0, *) {
            if (UIDevice.current.hasNotch) {
                //아이폰x 부터 하단 safe 영역 버튼이 있으면 여기서 처리
                //let topPadding = self.view.safeAreaInsets.top
                //let leftPadding = self.view.safeAreaInsets.left
                //let rightPadding = self.view.safeAreaInsets.right
                let bottomPadding = self.view.safeAreaInsets.bottom;
                uiAccBtn.frame = CGRect(x: 0, y: Int(uiAccBtn.frame.minY), width: Int(uiAccBtn.frame.size.width), height: Int(uiAccBtn.frame.size.height + bottomPadding))
                uiAccBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
            }

        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func setData(data : [String : String]){
        m_sData = data
    }

    @IBAction func onAccBtn(_ sender: Any) {
        MessagePop(title : "마켓 등록".localized, msg: "해당 상품을 마켓에 등록하시겠습니까?".localized, lbtn: "취소".localized, rbtn: "등록".localized,succallbackf: { ()-> Void in
            self.MarketAddS();
        }, closecallbackf: { ()-> Void in
            
        })
        
    }
    func MarketAddS(){
//        if let marketaddtime = UserDefaults.standard.value(forKey: Single.DE_MARKETLIMITMINKEY)
//        {
//            let now = Date()
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//            dateFormatter.timeZone = NSTimeZone(name: "KST") as TimeZone?
//            let date:Date = dateFormatter.date(from: (marketaddtime as! String))!
//            let calcday = now.timeIntervalSince(date)
//            if Int(calcday / 60) >= Single.DE_MARKETADDLIMITEDMIN{
//                
//            }else{
//                dismiss(animated: true, completion: nil)
//                MessagePop(msg: "마켓 등록 취소 후, 5분이 지나야 재등록할 수 있습니다.".localized, btntype : 2)
//                return;
//            }
//        }
        
        var Cont = uiTextView.text!;
        if uiTextView.textColor == UIColor.lightGray {
            Cont = ""
        }
        Cont = Cont.replacingOccurrences(of: "\n", with: "")
        
        m_tClickEvent?.ClickEvent(viewtype : 1, type: 9, data: [m_sData["my_product_seq"]!, Cont])
        let fm_Contrllers = self.navigationController?.viewControllers
        if let val = fm_Contrllers{
            for VC in val{
                if VC is InventoryMain {
                    self.navigationController?.popToViewController(VC, animated: true)
                    break;
                }
                
            }
        }
    }
    
    
}
extension MarketAdd : UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "트레이드 마켓에 상품 등록 시 필요한 내용을 입력하세요.(100자 이내)".localized
            textView.textColor = UIColor.lightGray
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let str = textView.text else {return true}
        let newLength = str.count + text.count - range.length;
        return newLength <= 100
    }
    
}
