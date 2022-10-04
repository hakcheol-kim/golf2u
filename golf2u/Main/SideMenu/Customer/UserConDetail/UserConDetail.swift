//
//  UserConDetail.swift
//  golf2u
//
//  Created by 이원영 on 2020/12/03.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON
import EzPopup
import ImageSlideshow

class UserConDetail: VariousViewController {
    private let SO = Single.getSO();
    private let JS = JsonC();
    
    @IBOutlet weak var uiTopView: UIView!
    @IBOutlet weak var uiTitle: UILabel!
    @IBOutlet weak var uiDate: UILabel!
    @IBOutlet weak var uiDelBtn: UIButton!
    @IBOutlet weak var uiMyCon: UITextView!
    @IBOutlet weak var uiImg1: UIImageView!
    @IBOutlet weak var uiImg2: UIImageView!
    @IBOutlet weak var uiImg3: UIImageView!
    @IBOutlet weak var uiImg4: UIImageView!
    @IBOutlet weak var uiImg5: UIImageView!
    private var uiImageFiles = [UIImageView]();
    
    @IBOutlet weak var uiAdminView: UIView!
    @IBOutlet weak var uiArrowImg: UIImageView!
    @IBOutlet weak var uiAdminCon: UITextView!
    
    private var m_Data = [String: String]();
    private var m_DataImgUrl = [String]();
    
    @IBOutlet var uiNOtConView: UIView!
    @IBOutlet weak var uiTitlelb1: UILabel!
    @IBOutlet weak var uiTitlelb2: UILabel!
    private let m_isUserPZoom = ImageSlideshow()
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "문의 내역 상세보기".localized)
        super.viewDidLoad()
        
        uiTitlelb1.text = "답변 준비중입니다.".localized
        uiTitlelb2.text = "(우선 접수된 문의부터 순차적으로 답변 중입니다.)".localized
        uiDelBtn.setTitle("삭제".localized, for: .normal)
        
        uiTopView.layer.addBorder([.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
        uiDelBtn.layer.cornerRadius = 8.0;
        uiDelBtn.layer.borderWidth = 1.0
        uiDelBtn.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        uiAdminView.layer.cornerRadius = 8.0;
        uiAdminView.layer.borderWidth = 1.0
        uiAdminView.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        uiImg1.layer.cornerRadius = 8.0;
        uiImg1.layer.borderWidth = 1.0
        uiImg1.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiImg2.layer.cornerRadius = 8.0;
        uiImg2.layer.borderWidth = 1.0
        uiImg2.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiImg3.layer.cornerRadius = 8.0;
        uiImg3.layer.borderWidth = 1.0
        uiImg3.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiImg4.layer.cornerRadius = 8.0;
        uiImg4.layer.borderWidth = 1.0
        uiImg4.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiImg5.layer.cornerRadius = 8.0;
        uiImg5.layer.borderWidth = 1.0
        uiImg5.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        uiImg1.isUserInteractionEnabled = true
        let subimgevntg1 = UITapGestureRecognizer(target: self, action: #selector(self.onFileTab(tapGesture:)))
        uiImg1.addGestureRecognizer(subimgevntg1)
        
        uiImg2.isUserInteractionEnabled = true
        let subimgevntg2 = UITapGestureRecognizer(target: self, action: #selector(self.onFileTab(tapGesture:)))
        uiImg2.addGestureRecognizer(subimgevntg2)
        
        uiImg3.isUserInteractionEnabled = true
        let subimgevntg3 = UITapGestureRecognizer(target: self, action: #selector(self.onFileTab(tapGesture:)))
        uiImg3.addGestureRecognizer(subimgevntg3)
        
        uiImg4.isUserInteractionEnabled = true
        let subimgevntg4 = UITapGestureRecognizer(target: self, action: #selector(self.onFileTab(tapGesture:)))
        uiImg4.addGestureRecognizer(subimgevntg4)
        
        uiImg5.isUserInteractionEnabled = true
        let subimgevntg5 = UITapGestureRecognizer(target: self, action: #selector(self.onFileTab(tapGesture:)))
        uiImg5.addGestureRecognizer(subimgevntg5)
        
        uiImageFiles.append(uiImg1)
        uiImageFiles.append(uiImg2)
        uiImageFiles.append(uiImg3)
        uiImageFiles.append(uiImg4)
        uiImageFiles.append(uiImg5)
        
        
        LoadDetail();
        

    }
    @objc func onFileTab(tapGesture: UITapGestureRecognizer) {
        let imgView = tapGesture.view as! UIImageView
        m_isUserPZoom.removeFromSuperview()
        self.view.addSubview(m_isUserPZoom)
        var m_tPicArr = [KingfisherSource]();
        if imgView == uiImg1 {
            if let URLString = KingfisherSource(urlString: m_DataImgUrl[0]){
                m_tPicArr.append(URLString)
            }
        }else if imgView == uiImg2 {
            if let URLString = KingfisherSource(urlString: m_DataImgUrl[1]){
                m_tPicArr.append(URLString)
            }
        }else if imgView == uiImg3 {
            if let URLString = KingfisherSource(urlString: m_DataImgUrl[2]){
                m_tPicArr.append(URLString)
            }
        }else if imgView == uiImg4 {
            if let URLString = KingfisherSource(urlString: m_DataImgUrl[3]){
                m_tPicArr.append(URLString)
            }
        }else if imgView == uiImg5 {
            if let URLString = KingfisherSource(urlString: m_DataImgUrl[4]){
                m_tPicArr.append(URLString)
            }
        }
        m_isUserPZoom.setImageInputs(m_tPicArr)
        let fullScreenController = m_isUserPZoom.presentFullScreenController(from: self)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .medium, color: nil)
    }
    func setData(data : [String : String]){
        self.m_Data = data;
    }

    @IBAction func onDelBtn(_ sender: Any) {
        MessagePop(title : "문의 삭제".localized, msg: "삭제 시 해당 문의는 더 이상 확인이\n불가합니다. 삭제하시겠습니까?".localized, lbtn: "취소".localized, rbtn: "확인".localized,succallbackf: { ()-> Void in
            LoadingHUD.show()
            self.JS.delQna(param: ["seq":self.m_Data["seq"] ?? "","account_seq":super.getUserSeq()], callbackf: self.delQnaDelCallback)
        }, closecallbackf: { ()-> Void in
            
        })
    }
    func delQnaDelCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            MessagePop(msg: alldata["errormessage"].stringValue, btntype : 2)
        }else{
            let fm_Contrllers = self.navigationController?.viewControllers
            if let val = fm_Contrllers{
                for VC in val{
                    if VC is UserCon {
                        let VCC = VC as! UserCon
                        VCC.refresh()
                        self.navigationController?.popToViewController(VC, animated: true)
                        break;
                    }
                    
                }
            }
        }
        LoadingHUD.hide()
    }
    func LoadDetail(){
        LoadingHUD.show()
        JS.getUserQna(param: ["account_seq":super.getUserSeq(), "seq":m_Data["seq"] ?? ""], callbackf: getUserQnaCallback)
    }
    func getUserQnaCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            MessagePop(msg: alldata["errormessage"].stringValue, btntype : 2)
        }else{
            uiTitle.text = "[\(alldata["data"]["qna_category_title"])]\(alldata["data"]["title"])";
            uiDate.text = alldata["data"]["created_at"].stringValue;
            uiMyCon.text = alldata["data"]["contents"].stringValue;
            for i in 0 ... 4 {
                if alldata["data"]["file\(i+1)"] != "" {
                    let fm_RUrl = "\(Single.DE_URLIMGSERVER)\(alldata["data"]["file\(i+1)"])";
                    m_DataImgUrl.append(fm_RUrl)
                    uiImageFiles[i].setImage(with: fm_RUrl)
                    uiImageFiles[i].isHidden = false;
                }else{
                    uiImageFiles[i].image = nil;
                    uiImageFiles[i].isHidden = true;
                }
            }
            if alldata["data"]["answer_state"] == "1"{
                uiArrowImg.isHidden = false;
                uiAdminCon.isHidden = false;
                uiAdminCon.text = alldata["data"]["answer"].stringValue;
            }else{
                uiArrowImg.isHidden = true;
                uiAdminCon.isHidden = true;
                
                self.uiAdminView.addSubview(uiNOtConView)
                uiNOtConView.translatesAutoresizingMaskIntoConstraints = false
                uiNOtConView.topAnchor.constraint(equalTo: uiAdminView.topAnchor,constant: 0).isActive = true
                uiNOtConView.leftAnchor.constraint(equalTo:uiAdminView.leftAnchor,constant: 0).isActive = true
                uiNOtConView.rightAnchor.constraint(equalTo: uiAdminView.rightAnchor, constant: 0).isActive = true
                uiNOtConView.bottomAnchor.constraint(equalTo: uiAdminView.bottomAnchor, constant: 0).isActive = true
            }
        }
        LoadingHUD.hide()
        
    }
}
