//
//  ProductCommentCell.swift
//  golf2u
//
//  Created by 이원영 on 2020/10/09.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toast_Swift

class ProductCommentCell: UICollectionViewCell {
    
    public var LikeBtnHandler: (()->())?//클로저
    private let SO = Single.getSO()
    private let JS = JsonC();

    @IBOutlet weak var uiProfileImg: UIImageView!
    @IBOutlet weak var uiUserNAme: UILabel!
    @IBOutlet weak var uiLikeBtn: UIButton!
    @IBOutlet weak var uiLikeCnt: UILabel!
    @IBOutlet weak var uiProductImg: UIImageView!
    @IBOutlet weak var uiContentsLabel: UILabel!
    @IBOutlet weak var uiImageCntView: UIView!
    
    
    private var m_data = [String]();
    private var m_sUserSeq : String = "";
    private var m_isLike : Bool = false;
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        uiImageCntView.layer.cornerRadius = 9.0
        
        self.layer.cornerRadius = 8.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        self.layer.masksToBounds = true
        
        uiProfileImg.layer.cornerRadius = uiProfileImg.frame.height/2
        
        uiProductImg.layer.cornerRadius = 8.0
        uiProductImg.layer.masksToBounds = true
        
    }
    func setData(data : [String], row : Int){
        m_sUserSeq = SO.getUserInfoKey(key: "seq");
        
        self.m_data = data;
        uiProfileImg.tag = row
        uiProfileImg.setImage(with: "\(Single.DE_URLIMGSERVER)\(data[1])")
        uiUserNAme.text = data[2];
        uiLikeCnt.text = data[4];
        uiProductImg.setImage(with: "\(Single.DE_URLIMGSERVER)\(data[6])")
        uiProductImg.tag = row
        uiContentsLabel.text = data[3];
        if data[6] != "" && data[7] != ""{
            uiImageCntView.isHidden = false;
        }else{
            uiImageCntView.isHidden = true;
        }
        if data[5] == "1" {
            uiLikeBtn.setImage(UIImage(named:"like"), for: .normal)
        }else{
            uiLikeBtn.setImage(UIImage(named:"unlike"), for: .normal)
        }
    }
    @IBAction func onLikeBtn(_ sender: Any) {
        if m_sUserSeq == ""{
            //self.makeToast("로그인 후 이용해주세요.", duration: 1.0, position: .bottom)
            LikeBtnHandler?()
            return;
        }
        LoadingHUD.show()
        JS.ProductCommentLikeToggle(param: ["account_seq" : m_sUserSeq, "comment_seq" : m_data[0]], callbackf: CommentLikeToggleCallback)
    }
    func CommentLikeToggleCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            //self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            if alldata["data"] == "0" {
                uiLikeCnt.text = "\((Int(uiLikeCnt.text!)! - 1))"
                uiLikeBtn.setImage(UIImage(named:"unlike"), for: .normal)
            }else if alldata["data"] == "1" {
                uiLikeCnt.text = "\((Int(uiLikeCnt.text!)! + 1))"
                uiLikeBtn.setImage(UIImage(named:"like"), for: .normal)
            }
        }
        LoadingHUD.hide()
    }
}
