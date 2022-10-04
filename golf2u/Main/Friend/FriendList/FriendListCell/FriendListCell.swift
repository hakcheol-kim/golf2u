//
//  FriendListCell.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/09.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwipeCellKit


class FriendListCell: SwipeCollectionViewCell {
    weak var m_tClickEvent: ClickCellBtnDelegate? = nil;
    @IBOutlet weak var uiUserImg: UIImageView!
    @IBOutlet weak var uiNewImg: UIImageView!
    @IBOutlet weak var uiName: UILabel!
    @IBOutlet weak var uiDate: UILabel!
    
    @IBOutlet weak var uiTradeBtn: UIButton!
    @IBOutlet weak var uiGiftBtn: UIButton!
    @IBOutlet weak var uiDelBtn: UIButton!
    
    @IBOutlet weak var uiAddFriendBtn: UIButton!
    
    @IBOutlet weak var uiBlackAddBtn: UIButton!
    @IBOutlet weak var uiBlackDelBtn: UIButton!
    
    @IBOutlet weak var uiCancelBtn: UIButton!
    
    @IBOutlet weak var uiFAccepBtn: UIButton!
    @IBOutlet weak var uiFRejecBtn: UIButton!
    
    private var m_Data = [String:String]();
    
    private var m_nViewType = 0;
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.addBorder([.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        uiUserImg.layer.cornerRadius = uiUserImg.frame.height/2

    }
    
    func setData(data : [String:String], row:Int, viewtype:Int){
        m_Data = data;
        m_nViewType = viewtype
        
        uiUserImg.tag = row
        uiUserImg.image = nil;
        if let imgurl = data["profile_image_url"]{
            if imgurl != ""{
                uiUserImg.setImage(with: "\(Single.DE_URLIMGSERVER)\(imgurl)")
            }
        }
        if data["is_new"] == "1" {
            uiNewImg.isHidden = false;
        }else{
            uiNewImg.isHidden = true;
        }
        uiName.text = data["name"]
        uiDate.text = data["created_at"]
        
        //우선 버튼들 히든처리 후 밑에서 타입에맞는 버튼만 히든취소
        uiTradeBtn.isHidden = true;
        uiGiftBtn.isHidden = true;
        uiDelBtn.isHidden = true;
        uiAddFriendBtn.isHidden = true;
        uiBlackAddBtn.isHidden = true;
        uiBlackDelBtn.isHidden = true;
        uiCancelBtn.isHidden = true;
        uiFAccepBtn.isHidden = true;
        uiFRejecBtn.isHidden = true;
        
        if viewtype == 1{
            //친구 관리 목록
            uiTradeBtn.isHidden = false;
            uiGiftBtn.isHidden = false;
            //uiDelBtn.isHidden = false;
        }else if viewtype == 2{
            //친구검색
            if data["is_related"] == "1" {
                uiTradeBtn.isHidden = false;
                uiGiftBtn.isHidden = false;
                //uiDelBtn.isHidden = false;
                uiDate.isHidden = false;
            }else{
                uiAddFriendBtn.isHidden = false;
                uiDate.isHidden = true;
            }
        }else if viewtype == 3{
            //블랙리스트
            //uiDelBtn.isHidden = false;
        }else if viewtype == 4{
            //블랙리스트 검색
            if data["is_related"] == "1" {
                uiBlackAddBtn.isHidden = true;
                uiBlackDelBtn.isHidden = false;
            }else{
                uiBlackAddBtn.isHidden = false;
                uiBlackDelBtn.isHidden = true;
            }
        }else if viewtype == 5{
            //친구 신청 목록
            if data["direction"] == "0" {
                uiCancelBtn.isHidden = false;
                uiFAccepBtn.isHidden = true;
                uiFRejecBtn.isHidden = true;
            }else{uiCancelBtn.isHidden = true;
                uiFAccepBtn.isHidden = false;
                uiFRejecBtn.isHidden = false;
                
            }
        }
    }
    @IBAction func onTradeBtn(_ sender: Any) {
        m_tClickEvent?.ClickEvent(viewtype : 1, type: 1, data: m_Data)
    }
    @IBAction func onGiftBtn(_ sender: Any) {
        m_tClickEvent?.ClickEvent(viewtype : 1, type: 2, data: m_Data)
    }
    @IBAction func onDelBtn(_ sender: Any) {
        if m_nViewType == 1 || m_nViewType == 2{
            m_tClickEvent?.ClickEvent(viewtype : 1, type: 3, data: m_Data)
        }else if m_nViewType == 3 {
            m_tClickEvent?.ClickEvent(viewtype : 1, type: 7, data: m_Data)
        }
    }
    @IBAction func onFAddBtn(_ sender: Any) {
        m_tClickEvent?.ClickEvent(viewtype : 1, type: 5, data: m_Data)
    }
    @IBAction func onBlackAddBtn(_ sender: Any) {
        m_tClickEvent?.ClickEvent(viewtype : 1, type: 8, data: m_Data)
    }
    @IBAction func onBlackDellBtn(_ sender: Any) {
        m_tClickEvent?.ClickEvent(viewtype : 1, type: 7, data: m_Data)
    }
    @IBAction func onCancelBtn(_ sender: Any) {
        m_tClickEvent?.ClickEvent(viewtype : 1, type: 10, data: m_Data)
    }
    @IBAction func onRejecBtn(_ sender: Any) {
        m_tClickEvent?.ClickEvent(viewtype : 1, type: 12, data: m_Data)
    }
    @IBAction func onAccepBtn(_ sender: Any) {
        m_tClickEvent?.ClickEvent(viewtype : 1, type: 11, data: m_Data)
    }
    
}
