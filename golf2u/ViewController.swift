//
//  ViewController.swift
//  golf2u
//
//  Created by 이원영 on 2020/09/16.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import EzPopup
import SwiftyJSON


class ViewController: VariousViewController {
    
    
    
    private var SO:Single = Single.getSO();
    private let JS = JsonC();
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad();
        // Do any additional setup after loading the view.
        Init();
        
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    func Init(){
        if let userseq = UserDefaults.standard.value(forKey: Single.DE_AUTOLOGIN){
            //자동로그인 사용자
            JS.AutoLogin(param: ["seq":userseq], callbackf: AutoLoginCallback)
        }else{
            StartMain()
        }
    }
    func AutoLoginCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            UserDefaults.standard.removeObject(forKey: Single.DE_AUTOLOGIN)//재재 회원이면 자동로그인 풀어야됨
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            for (k, v) in alldata["data"]{
                if let dat = v.string{
                    SO.setUserInfoKey(key: k, value: dat)
                }
            }
        }
        StartMain();
    }
    func CategoryCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            /*var post = Array<[String:String]>()

            for (_, object) in alldata["data"] {
                var posta = [String:String]()
                posta["seq"] = object["seq"].stringValue;
                posta["title"] = object["title"].stringValue;
                post.append(posta)
            }
            print(post[0]["title"]!);*/
            for (_, obj) in alldata["data"]{
                var item = [String]()
                item.append(obj["seq"].stringValue);
                item.append(obj["title"].stringValue);
                SO.setProductCategory(fProductCategory: item)
            }
            
            self.JS.BankList(param: [:], callbackf: BankListCallback)
        }
    }
    func BankListCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            
            for (_, obj) in alldata["data"]{
                var item = [String]()
                item.append(obj["code"].stringValue);
                item.append(obj["name"].stringValue);
                SO.setBankList(fProductCategory: item)
            }
            MainConMove();
        }
    }
    func StartMain(){
        if UserDefaults.standard.value(forKey: "authpopup") != nil {
            //권한 요청 팝업이 최초 뜬적이 있다면 안띄움
            NextMain();
        }else{
            //권한 요청 팝업을 본적이 없는 사람은 팝업띄우고
            //팝업에서 확인 콜백 받으면 다음 화면 으로
            DispatchQueue.main.async {
                let m_tWRP = StartAuthority.instantiate()
                guard let customAlertVC = m_tWRP else { return }
                customAlertVC.m_tfinishStartAuthority = self;
                
                let popupVC = PopupViewController(contentController: customAlertVC, popupWidth: (self.view.frame.width - 100), popupHeight: 340)
                popupVC.backgroundAlpha = 0.3
                popupVC.backgroundColor = .black
                popupVC.canTapOutsideToDismiss = true
                popupVC.cornerRadius = 10
                popupVC.shadowEnabled = false
                self.present(popupVC, animated: true, completion: nil)
            }
        }
    }
    func AuthPopupOKBtn(){
        UserDefaults.standard.set("1", forKey: "authpopup")
        StartMain()
    }
    func NextMain(){
        self.JS.getAppInfo(param: [:], callbackf: getAppInfoCallback)
        
        
    }
    func getAppInfoCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            for (k, v) in alldata["data"]{
                if let dat = v.string{
                    SO.setSystemInfoKey(key: k, value: dat)
                }
            }
            self.JS.getAllPopup(param: [:], callbackf: getAllPopupCallback)
        }
    }
    func getAllPopupCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            for (_, object) in alldata["data"] {
                var item = [String:String]()
                item["seq"] = object["seq"].stringValue;
                item["title"] = object["title"].stringValue;
                item["description"] = object["description"].stringValue;
                item["file1"] = object["file1"].stringValue;
                item["out_link"] = object["out_link"].stringValue;
                item["in_link_type"] = object["in_link_type"].stringValue;
                item["in_link_seq"] = object["in_link_seq"].stringValue;
                SO.setMainPopKey(value: item)
                
                
            }
            self.JS.CategoryListGet(param: [:], callbackf: CategoryCallback)
        }
    }
}
extension ViewController: StartAuthorityPopDelegate {
    func finishStartAuthority(){
        self.AuthPopupOKBtn();
    }
}
