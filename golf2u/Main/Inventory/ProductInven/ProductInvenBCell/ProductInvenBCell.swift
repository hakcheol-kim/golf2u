//
//  ProductInvenBCell.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/10.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class ProductInvenBCell: UITableViewCell {
    weak var m_tClickEvent: InventoryMainClickCellBtnDelegate? = nil;
    
    @IBOutlet weak var uiHeadTitlelb: UILabel!
    @IBOutlet weak var uiHead1lb: UILabel!
    @IBOutlet weak var uiHead2lb: UILabel!
    @IBOutlet weak var uiHead3lb: UILabel!
    @IBOutlet weak var uiHead4lb: UILabel!
    
    @IBOutlet weak var uiDay: UILabel!
    @IBOutlet weak var uiDate: UILabel!
    @IBOutlet weak var uiMarketBtn: UIButton!
    @IBOutlet weak var uiGiftBtn: UIButton!
    @IBOutlet weak var uiSendBtn: UIButton!
    @IBOutlet weak var uiCloverBtn: UIButton!
    @IBOutlet weak var uiTitleView: UIView!
    @IBOutlet weak var uiBodyView: UIView!
    @IBOutlet weak var uiBtnView: UIView!
    private var m_IndexPath : IndexPath?
    
    private var m_data = [String:String]();
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.uiTitleView.layer.addBorder([.top,.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        //self.layer.addBorder([.top,.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
        uiHeadTitlelb.text = "보관기간".localized
        uiHead1lb.text = "마켓등록marketadd".localized
        uiHead2lb.text = "선물하기".localized
        uiHead3lb.text = "배송신청".localized
        uiHead4lb.text = "클로버환급".localized
        
    }
    
    func setData(data : [String : String], row : Int, indexpath : IndexPath){
        m_data = data;
        m_IndexPath = indexpath;
        uiBodyView.translatesAutoresizingMaskIntoConstraints =  true;
        if row == 0 {
            uiTitleView.isHidden = false;
            uiBodyView.frame = CGRect(x: uiBodyView.frame.minX, y: 29, width: self.frame.width - 13, height: uiBodyView.frame.height)
        }
        else{
            uiTitleView.isHidden = true;
            uiBodyView.frame = CGRect(x: uiBodyView.frame.minX, y: 7, width: self.frame.width - 13, height: uiBodyView.frame.height)
        }
        //uiBtnView.frame = CGRect(x: (uiBodyView.frame.width - uiBtnView.frame.width - 13), y: uiBtnView.frame.minY, width: uiBtnView.frame.width, height: uiBtnView.frame.height)
        if let daynum = data["remain_date"] {
            var nDayNum = 0
            if daynum != "" {
                nDayNum = Int(daynum)!
            }
            if nDayNum > 5 {
                //uiDay.text = "일 남음".localized(txt: "\(nDayNum)");
                uiMarketBtn.isHidden = false;
                uiGiftBtn.isHidden = false;
                uiSendBtn.isHidden = false;
            }else if nDayNum <= 5 && nDayNum > 0{
                //uiDay.text = "일 남음".localized(txt: "\(nDayNum)");
                uiMarketBtn.isHidden = false;
                uiSendBtn.isHidden = false;
                uiGiftBtn.isHidden = true;
            }else{
                //uiDay.text = "일 남음(만료)".localized(txt: "\(nDayNum)");
                uiMarketBtn.isHidden = true;
                uiGiftBtn.isHidden = true;
                uiSendBtn.isHidden = true;
            }
            if data["box_type"] == "2" {
                uiDay.text = "D-\(nDayNum) (EVENT)"
            }else{
                uiDay.text = "D-\(nDayNum)"
            }
            
        }
        if data["is_market_reged"] == "1" {
            uiMarketBtn.setImage(UIImage(named: "inven_01_on.png"), for: .normal)
        }else{
            uiMarketBtn.setImage(UIImage(named: "inven_01_off.png"), for: .normal)
        }
        uiDate.text = "\(data["created_at"]!)~\(data["expired_at"]!)";
        
        if data["is_forever"] == "1" {
            //문화 상품권일경우 날자와 일자를 없앤다
            uiDay.isHidden = true;
            uiDate.isHidden = true;
        }else{
            uiDay.isHidden = false;
            uiDate.isHidden = false;
        }
    }
    
    @IBAction func onMarketBtn(_ sender: Any) {
        m_tClickEvent?.ClickEvent(viewtype : 1, type: 3, data: m_data, indexpath : m_IndexPath!)
    }
    @IBAction func onGiftBtn(_ sender: Any) {
        m_tClickEvent?.ClickEvent(viewtype : 1, type: 2, data: m_data, indexpath : m_IndexPath!)
    }
    @IBAction func onSendBtn(_ sender: Any) {
        m_tClickEvent?.ClickEvent(viewtype : 1, type: 5, data: m_data, indexpath : m_IndexPath!)
    }
    @IBAction func onClover(_ sender: Any) {
        m_tClickEvent?.ClickEvent(viewtype : 1, type: 4, data: m_data, indexpath : m_IndexPath!)
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //contentView.layer.addBorder([.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        if selected {
            contentView.backgroundColor = UIColor.white
            
        } else {
            contentView.backgroundColor = UIColor.white
        }
    }
    
}
