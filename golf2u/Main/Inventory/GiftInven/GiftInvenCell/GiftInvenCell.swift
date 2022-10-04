//
//  GiftInvenCell.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/18.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwipeCellKit
class GiftInvenCell: SwipeCollectionViewCell {

    @IBOutlet weak var uiCheck: UIImageView!
    @IBOutlet weak var uiProImg: UIImageView!
    @IBOutlet weak var uiUserImg: UIImageView!
    @IBOutlet weak var uiTitle: UILabel!
    @IBOutlet weak var uiProName: UILabel!
    @IBOutlet weak var uiDate: UILabel!
    @IBOutlet weak var uiProImgVIew: UIView!
    @IBOutlet weak var uiProImgLabel: UILabel!
    private var m_nSelMode = 0;
    private var m_Data = [String : String]();
    @IBOutlet weak var uiEventImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        uiUserImg.layer.cornerRadius = uiUserImg.frame.height/2
        
        uiProImgVIew.layer.roundCorners(corners: [.bottomLeft, .bottomRight
        ], radius: 8.0)
        
        uiProImg.layer.cornerRadius = 8.0;
        uiProImg.layer.borderWidth = 1.0
        uiProImg.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        self.contentView.layer.addBorder([.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
    }
    func setChoise(type : Bool){
        if type {
            uiCheck.image = UIImage(named: "check_circle")
        }else{
            uiCheck.image = UIImage(named: "check_circle_blank")
        }
    }
    func setData(data : [String : String], row : Int, viewtype : Int, selmode : Int){
        m_Data = data;
        m_nSelMode = selmode
        if m_nSelMode == 0 {
            uiCheck.isHidden = true;
        }else{
            if data["recv_state"] == "1"{
                uiCheck.isHidden = false;
            }
        }
        uiProImg.tag = row
        uiUserImg.image = nil;
        if let imgurl = data["profile_image_url"]{
            if imgurl != ""{
                uiUserImg.setImage(with: "\(Single.DE_URLIMGSERVER)\(imgurl)")
            }
        }
        if viewtype == 0 {//받은 선물함
//            uiDate.text = "받은날짜 ".localized(txt: "\(data["created_at_dt"] ?? "")");
//            uiTitle.text = " 님이 보낸 선물".localized(txt: "\(data["name"] ?? "")");
//            uiTitle.TextPartColor(partstr: "\(data["name"] ?? "")", Color: UIColor(rgb: 0x00BA87))
//            uiTitle.frame = CGRect(x: uiUserImg.frame.maxX + 8, y: uiTitle.frame.minY, width: uiTitle.frame.width, height: uiTitle.frame.height)
//            uiUserImg.isHidden = false;
            uiDate.text = "받은날짜 ".localized(txt: "\(data["created_at_dt"] ?? "")");
            if data["type"] == "1" {
                uiTitle.text = "\(data["name"] ?? "")";
                //uiTitle.TextPartColor(partstr: "코드 발행", Color: UIColor(rgb: 0x00BA87))
                uiUserImg.isHidden = true;
                uiTitle.frame = CGRect(x: uiUserImg.frame.minX, y: uiTitle.frame.minY, width: uiTitle.frame.width, height: uiTitle.frame.height)
            }else if data["type"] == "0"{
                uiTitle.text = " 님이 보낸 선물".localized(txt: "\(data["name"] ?? "")");
                //uiDate.text = "보낸날짜 ".localized(txt: "\(data["created_at_dt"] ?? "")");
                uiTitle.TextPartColor(partstr: "\(data["name"] ?? "")", Color: UIColor(rgb: 0x00BA87))
                uiUserImg.isHidden = false;
                uiTitle.frame = CGRect(x: uiUserImg.frame.maxX + 8, y: uiTitle.frame.minY, width: uiTitle.frame.width, height: uiTitle.frame.height)
            }
            
            if data["recv_state"] == "1" {
                uiProImgLabel.text = "미수령".localized;
                uiProImgVIew.isHidden = true;
            }else if data["recv_state"] == "2" {
                uiProImgLabel.text = "수령".localized;
                uiProImgVIew.isHidden = false;
            }else if data["recv_state"] == "3" {
                uiProImgLabel.text = "반송".localized;
                uiProImgVIew.isHidden = false;
            }
        }else if viewtype == 1 {//보낸 선물함
            uiProImgVIew.isHidden = false;
            uiDate.text = "보낸날짜 ".localized(txt: "\(data["created_at_dt"] ?? "")");
            if data["type"] == "1" {
                uiTitle.text = "\(data["name"] ?? "")";
                //uiTitle.TextPartColor(partstr: "코드 발행", Color: UIColor(rgb: 0x00BA87))
                uiUserImg.isHidden = true;
                uiTitle.frame = CGRect(x: uiUserImg.frame.minX, y: uiTitle.frame.minY, width: uiTitle.frame.width, height: uiTitle.frame.height)
            }else if data["type"] == "0"{
                uiTitle.text = " 님에게 보낸 선물".localized(txt: "\(data["name"] ?? "")");
                //uiDate.text = "보낸날짜 ".localized(txt: "\(data["created_at_dt"] ?? "")");
                uiTitle.TextPartColor(partstr: "\(data["name"] ?? "")", Color: UIColor(rgb: 0x00BA87))
                uiUserImg.isHidden = false;
                uiTitle.frame = CGRect(x: uiUserImg.frame.maxX + 8, y: uiTitle.frame.minY, width: uiTitle.frame.width, height: uiTitle.frame.height)
            }
            if data["recv_state"] == "1" {
                uiProImgLabel.text = "미수령".localized;
                uiProImgVIew.isHidden = true;
            }else if data["recv_state"] == "2" {
                uiProImgLabel.text = "수령".localized;
                uiProImgVIew.isHidden = false;
            }else if data["recv_state"] == "3" {
                uiProImgLabel.text = "반송".localized;
                uiProImgVIew.isHidden = false;
            }
        }
        
        uiProName.text = data["gift_name"];
        
        if data["random_box_seq"] == "0" {
            uiProImg.image = nil;
            if let imgurl = data["thumbnail"]{
                if imgurl != ""{
                    uiProImg.setImage(with: "\(Single.DE_URLIMGSERVER)\(imgurl)")
                }
            }
        }else{
            uiProImg.image = nil;
            if data["box_type"] == "2" {
                uiEventImg.isHidden = false;
                uiProImg.image = UIImage(named: "inven_gifteventbox")
            }else{
                uiEventImg.isHidden = true;
                uiProImg.image = UIImage(named: "inven_giftrandombox")
            }
        }
    }
}
