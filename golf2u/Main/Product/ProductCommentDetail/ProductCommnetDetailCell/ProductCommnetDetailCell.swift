//
//  ProductCommnetDetailCell.swift
//  golf2u
//
//  Created by 이원영 on 2020/10/12.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toast_Swift

class ProductCommnetDetailCell: UITableViewCell {
    public var LikeBtnHandler: (()->())?//클로저
    private let SO = Single.getSO()
    private let JS = JsonC();
    
    @IBOutlet weak var uiProfileImg: UIImageView!
    @IBOutlet weak var uiUserNameLabel: UILabel!
    @IBOutlet weak var uiProductImg: UIImageView!
    @IBOutlet weak var uiPMoreImg: UIView!
    @IBOutlet weak var uiTimeLabel: UILabel!
    @IBOutlet weak var uiLikeBtn: UIButton!
    @IBOutlet weak var uiLikeCntLabel: UILabel!
    @IBOutlet weak var uiContextLebel: UILabel!
    @IBOutlet weak var uiBottomView: UIView!
    
    private var m_data = [String:String]();
    private var m_sUserSeq : String = "";
    
    private var m_isAccBtn = false;
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //self.layer.addBorder([.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
        uiProfileImg.layer.cornerRadius = uiProfileImg.frame.height/2
        
        uiProductImg.layer.cornerRadius = 8.0
        
        uiPMoreImg.layer.cornerRadius = 8.0
        
        
    }
    func setData(data : [String : String], row : Int){
        m_data = data;
        uiProfileImg.tag = row
        m_sUserSeq = SO.getUserInfoKey(key: "seq");
        if row != 0 {
            self.layer.addBorder([.top], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        }
        uiProfileImg.image = nil;
        if let imgurl = data["profile_image_url"]{
            if imgurl != ""{
                uiProfileImg.setImage(with: "\(Single.DE_URLIMGSERVER)\(imgurl)")
            }
        }
        if let nameu = data["name"]{
            uiUserNameLabel.text = nameu;
//            if data["level"] == "1" {
//                uiUserNameLabel.text = "|_ \(nameu)";
//            }
        }
        
        uiLikeCntLabel.text = data["like_cnt"];
        uiProductImg.tag = row
        uiProductImg.image = nil;
        if let imgurl = data["file1"]{
            if imgurl != ""{
                uiProductImg.setImage(with: "\(Single.DE_URLIMGSERVER)\(imgurl)")
            }
        }
       
        uiContextLebel.text = data["contents"];
        
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "KST") as TimeZone?
        let date:Date = dateFormatter.date(from: data["created_at"]!)!
        let calcday = date.offset(from: date, now: now)
        self.uiTimeLabel.text = calcday;
        
        if data["liked"] == "1" {
            uiLikeBtn.setImage(UIImage(named:"like"), for: .normal)
        }else{
            uiLikeBtn.setImage(UIImage(named:"unlike"), for: .normal)
        }
        
        if data["file1"] != "" && data["file2"] != ""{
            uiPMoreImg.isHidden = false;
//            var heightT : CGFloat = 29.0;
//            let width = uiContextLebel.frame.width //화면 너비
//            heightT += data["contents"]!.heightT(withConstrainedWidth: (width), font: UIFont.systemFont(ofSize: CGFloat(12)))
//            uiBottomView.frame = CGRect(x: uiBottomView.frame.minX, y: uiPMoreImg.frame.maxY + heightT, width: uiBottomView.frame.width, height: uiBottomView.frame.height)
        }else{
            uiPMoreImg.isHidden = true;
//            var heightT : CGFloat = 29.0;
//            let width = uiContextLebel.frame.width //화면 너비
//            heightT += data["contents"]!.heightT(withConstrainedWidth: (width), font: UIFont.systemFont(ofSize: CGFloat(12)))
//            uiBottomView.frame = CGRect(x: uiBottomView.frame.minX, y: heightT + 10, width: uiBottomView.frame.width, height: uiBottomView.frame.height)
        }
        var heightT : CGFloat = 0;
        let bounds = UIScreen.main.bounds
        let width = bounds.size.width //화면 너비
        //let height = bounds.size.height //화면 높이
        //74 를 뺀이유는 스토리보드 컨텐츠 레이블 에서 양쪽 여백 을 더한 숫자다 화면 크기 를 구한다면 양쪽 여백을빼면 실제 콘텐츠 넓이가 나온다
        heightT += data["contents"]!.heightT(withConstrainedWidth: (width - 74), font: UIFont.systemFont(ofSize: CGFloat(12)))
        uiContextLebel.frame = CGRect(x: uiContextLebel.frame.minX, y: uiContextLebel.frame.minY, width: (width - 94), height: heightT)
        
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
        JS.ProductCommentLikeToggle(param: ["account_seq" : m_sUserSeq, "comment_seq" : m_data["seq"]!], callbackf: CommentLikeToggleCallback)
    }
    func CommentLikeToggleCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            //self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            if alldata["data"] == "0" {
                uiLikeCntLabel.text = "\((Int(uiLikeCntLabel.text!)! - 1))"
                uiLikeBtn.setImage(UIImage(named:"unlike"), for: .normal)
            }else if alldata["data"] == "1" {
                uiLikeCntLabel.text = "\((Int(uiLikeCntLabel.text!)! + 1))"
                uiLikeBtn.setImage(UIImage(named:"like"), for: .normal)
            }
        }
        m_isAccBtn = false;
        LoadingHUD.hide()
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
