//
//  NewsRoomCommentCell.swift
//  golf2u
//
//  Created by 이원영 on 2020/10/22.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toast_Swift
import SwipeCellKit

class NewsRoomCommentCell: SwipeCollectionViewCell {
    public var LikeBtnHandler: (()->())?//클로저
    public var CoCoHandler: ((String)->())?//클로저
    private let SO = Single.getSO()
    private let JS = JsonC();
    
    @IBOutlet weak var uiUserImg: UIImageView!
    @IBOutlet weak var uiProImg: UIImageView!
    @IBOutlet weak var uiUserName: UILabel!
    @IBOutlet weak var uiContents: UILabel!
    @IBOutlet weak var uiInfo: UILabel!
    @IBOutlet weak var uiLikeBtn: UIButton!
    @IBOutlet weak var uiLikeCnt: UILabel!
    @IBOutlet weak var uiPMoreImg: UIView!
    @IBOutlet weak var uiCoComentImg: UIImageView!
    @IBOutlet weak var uiContentsView: UIView!
    @IBOutlet weak var uiCoCoBtn: UIButton!
    @IBOutlet weak var uiSirenBTN: UIButton!
    @IBOutlet weak var uiLikeView: UIView!
    
    private var m_data = [String:String]();
    
    private var m_sUserSeq : String = "";
    private var m_isAccBtn = false;
    
    override func awakeFromNib() {
        super.awakeFromNib()
        uiUserImg.layer.cornerRadius = uiUserImg.frame.height/2
        
        uiProImg.layer.cornerRadius = 8.0
        uiPMoreImg.layer.cornerRadius = 8.0
        
        //uiContentsView.layer.cornerRadius = 8.0
        self.layer.cornerRadius = 10.0
    }
    
    func setData(data : [String:String], row:Int){
        m_data = data;
        m_sUserSeq = SO.getUserInfoKey(key: "seq");
        
        
        uiUserImg.tag = row
        uiUserImg.image = nil;
        if let imgurl = data["profile_image_url"]{
            if imgurl != ""{
                uiUserImg.setImage(with: "\(Single.DE_URLIMGSERVER)\(imgurl)")
            }
        }
        uiProImg.image = nil;
        if let imgurl = data["file1"]{
            if imgurl != ""{
                uiProImg.setImage(with: "\(Single.DE_URLIMGSERVER)\(imgurl)")
            }
        }
        uiProImg.tag = row;
        if data["file1"] != "" && data["file2"] != ""{
            uiPMoreImg.isHidden = false;
        }else{
            uiPMoreImg.isHidden = true;
        }
        
        uiUserName.text = data["name"];
        uiContents.text = data["contents"];
        
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "KST") as TimeZone?
        let date:Date = dateFormatter.date(from: data["created_at"]!)!
        let calcday = date.offset(from: date, now: now)
        
        
        
        uiLikeCnt.text = data["like_cnt"];
        
        if data["liked"] == "1" {
            uiLikeBtn.setImage(UIImage(named:"like"), for: .normal)
        }else{
            uiLikeBtn.setImage(UIImage(named:"unlike"), for: .normal)
        }
        if data["level"] == "0"{
            if row != 0 {
                self.layer.addBorder([.top], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
            }
            uiCoCoBtn.isHidden = false;
            uiCoComentImg.isHidden = true;
            uiInfo.text = "\(calcday) | 답글(\(data["comments_cnt"]!))";
            uiInfo.sizeToFit()
            //uiContentsView.layer.addBorder([.bottom], color: UIColor(rgb: 0xffffff), width: 0)
            uiContentsView.layer.backgroundColor = UIColor(rgb: 0xffffff).cgColor
            if data["comments_cnt"] == "0" {
                //uiContentsView.layer.addBorder([.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
            }
            uiLikeView.translatesAutoresizingMaskIntoConstraints =  true;
            uiLikeView.frame = CGRect(x: uiInfo.frame.maxX + 5, y: self.frame.height - 35, width: uiLikeView.frame.width, height: uiLikeView.frame.height)
            //uiCoCoBtn.frame = CGRect(x: uiLikeView.frame.maxX + 5, y: uiCoCoBtn.frame.minY, width: uiCoCoBtn.frame.width, height: uiCoCoBtn.frame.height)
        }else if data["level"] == "1"{
            uiCoCoBtn.isHidden = true;
            uiCoComentImg.isHidden = false;
            uiInfo.text = "\(calcday)";
            uiInfo.sizeToFit()
            //uiContentsView.layer.addBorder([.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
            uiContentsView.layer.backgroundColor = UIColor(rgb: 0xf8f8f8).cgColor
            uiLikeView.translatesAutoresizingMaskIntoConstraints =  true;
            uiLikeView.frame = CGRect(x: uiInfo.frame.maxX + 5, y: self.frame.height - 35, width: uiLikeView.frame.width, height: uiLikeView.frame.height)
            //uiCoCoBtn.frame = CGRect(x: uiLikeView.frame.maxX + 5, y: uiCoCoBtn.frame.minY, width: uiCoCoBtn.frame.width, height: uiCoCoBtn.frame.height)
        }
        
        if data["account_seq"] != m_sUserSeq {
            uiSirenBTN.isHidden = false;
        }else{
            uiSirenBTN.isHidden = true;
        }
        
        self.sizeToFit()
    }
    func getViewHeight()->Int{
        return Int(self.frame.height);
    }
    @IBAction func onLikeBtn(_ sender: Any) {
        if m_isAccBtn {
            return;
        }
        if m_sUserSeq == ""{
            //self.makeToast("로그인 후 이용해주세요.", duration: 1.0, position: .bottom)
            LikeBtnHandler?()
            return;
        }
        LoadingHUD.show()
        m_isAccBtn = true
        JS.CommunityCommentLikeToggleNewsRoom(param: ["account_seq" : m_sUserSeq, "comment_seq" : m_data["seq"]!], callbackf: CommunityCommentLikeToggleNewsRoomCallback)
    }
    func CommunityCommentLikeToggleNewsRoomCallback(alldata: JSON)->Void {
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
        m_isAccBtn = false;
        LoadingHUD.hide()
    }
    @IBAction func onSirenBtn(_ sender: Any) {
        if m_sUserSeq == ""{
            //self.makeToast("로그인 후 이용해주세요.", duration: 1.0, position: .bottom)
            LikeBtnHandler?()
            return;
        }
        let optionMenu = UIAlertController(title: nil, message: "신고하기".localized, preferredStyle: .actionSheet)
        //옵션 초기화
        let alertacop1 = UIAlertAction(title: "도배성 댓글".localized, style: .default, handler: alertHandleOp1)
        let alertacop2 = UIAlertAction(title: "광고/음란성 댓글".localized, style: .default, handler: alertHandleOp1)
        let alertacop3 = UIAlertAction(title: "욕설/인신공격".localized, style: .default, handler: alertHandleOp1)
        let alertacop4 = UIAlertAction(title: "개인정보노출".localized, style: .default, handler: alertHandleOp1)
        let alertacop5 = UIAlertAction(title: "기타".localized, style: .default, handler: alertHandleOp1)
        let cancelAction = UIAlertAction(title: "취소".localized, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(alertacop1)
        optionMenu.addAction(alertacop2)
        optionMenu.addAction(alertacop3)
        optionMenu.addAction(alertacop4)
        optionMenu.addAction(alertacop5)
        optionMenu.addAction(cancelAction)
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        window?.rootViewController?.presentedViewController?.present(optionMenu, animated: true, completion: nil)
    }
    func alertHandleOp1(alertAction: UIAlertAction!) -> Void {
        var fm_sSirenType = "";
        if alertAction.title! == "도배성 댓글".localized {
            fm_sSirenType = "0"
        }else if alertAction.title! == "광고/음란성 댓글".localized {
            fm_sSirenType = "1"
        }else if alertAction.title! == "욕설/인신공격".localized {
            fm_sSirenType = "2"
        }else if alertAction.title! == "개인정보노출".localized {
            fm_sSirenType = "3"
        }else if alertAction.title! == "기타".localized {
            fm_sSirenType = "4"
        }
        LoadingHUD.show()
        JS.ComunityCommentSiren(param: ["account_seq" : m_sUserSeq, "comment_seq" : m_data["seq"]!, "type":fm_sSirenType], callbackf: ComunityCommentSirenCallback)
    }
    func ComunityCommentSirenCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
        }else{
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            window?.makeToast("신고가 완료되었습니다.".localized)
        }
        LoadingHUD.hide()
    }
    
    @IBAction func onCoCoBtn(_ sender: Any) {
        CoCoHandler?(m_data["seq"]!);
    }
}
