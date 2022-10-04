//
//  PassFind.swift
//  golf2u
//
//  Created by 이원영 on 2020/09/19.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import EzPopup
import SwiftyJSON
import Toast_Swift

class PassFind: VariousViewController, UITextFieldDelegate{
    
    private var SO : Single = Single.getSO();
    private let JS = JsonC();

    @IBOutlet weak var uiTitle: UILabel!
    @IBOutlet weak var uiSubTitle: UILabel!
    @IBOutlet weak var emailnickinput: UITextField!
    @IBOutlet weak var resultview: UIView!
    
    @IBOutlet weak var uiFindMember: UILabel!
    @IBOutlet weak var sendpassbtn: UIButton!
    @IBOutlet weak var nicklabel: UILabel!
    @IBOutlet weak var emaillabel: UILabel!
    @IBOutlet weak var nonimg: UIImageView!
    @IBOutlet weak var nonresultlabel: UILabel!
    @IBOutlet weak var findbtn: UIButton!
    @IBOutlet weak var uiBottomLabel: UILabel!
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "")
        super.viewDidLoad()
        
        uiTitle.text = "비밀번호 찾기".localized;
        uiSubTitle.text = "이메일 혹은 닉네임을 검색해보세요.".localized
        uiFindMember.text = "검색된 회원".localized;
        nonresultlabel.text = "검색된 사용자가 존재하지 않습니다.".localized
        uiBottomLabel.text = "입력하신 이메일로 임시비밀번호가 발송됩니다.".localized
        sendpassbtn.setTitle("전송".localized, for: .normal)
        
        emailnickinput.layer.cornerRadius = 8.0;
        emailnickinput.layer.borderWidth = 1.0
        emailnickinput.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        emailnickinput.addLeftPadding()
        emailnickinput.placeholder = "정확한 이메일 혹은 닉네임을 입력하세요.".localized
        
        resultview.layer.cornerRadius = 10
        sendpassbtn.layer.cornerRadius = 8
        
        self.emailnickinput.returnKeyType = .done;
        self.emailnickinput.delegate = self

    }
    @IBAction func onFindBtn(_ sender: Any) {
        self.view.endEditing(true)
        FindUser();
    }
    @IBAction func onSendMail(_ sender: Any) {
        if let passfindtime = UserDefaults.standard.value(forKey: Single.DE_PASSFINDEMAILMINKEY)
        {
            let now = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.timeZone = NSTimeZone(name: "KST") as TimeZone?
            let date:Date = dateFormatter.date(from: (passfindtime as! String))!
            let calcday = now.timeIntervalSince(date)
            if Int(calcday / 60) >= Single.DE_LIMITREPORTSENDMIN{
                
            }else{
                self.view.makeToast("분 내에 1회 메일전송 가능 합니다.".localized(txt: "\(Single.DE_LIMITREPORTSENDMIN)"), duration: 1.0, position: .bottom)
                //MessagePop(msg: "\(Single.DE_LIMITREPORTSENDMIN)분 내에 1회 메일전송 가능 합니다.", btntype : 2)
                return;
            }
        }
        
        let fm_sFindEmail = self.emaillabel.text!;
        LoadingHUD.show()
        JS.PassFindPassInit(param: ["email" : fm_sFindEmail], callbackf: PassFindPassInitCallback)
    }
    func PassFindPassInitCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            //정상적으로 이메일이 전송 되면 등록된 시간을 저장
            let date:Date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateString:String = dateFormatter.string(from: date)
            UserDefaults.standard.set(dateString, forKey: Single.DE_PASSFINDEMAILMINKEY)
            MessagePop(msg: "이메일 전송되었습니다.".localized,btntype : 2,succallbackf: { ()-> Void in
                self.navigationController?.popViewController(animated: true);
            }, closecallbackf: { ()-> Void in
                
            })
        }
        LoadingHUD.hide()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        FindUser();
        return false
    }
    func FindUser(){
        
        
        let UserS = self.emailnickinput.text!;
        if UserS == "" {
            MessagePop(msg: "이메일 또는 닉네임을 입력하세요.".localized, btntype : 2)
            return;
        }
        LoadingHUD.show()
        JS.PassFindEmailORNick(param: ["keyword" : UserS], callbackf: PassFindEmailORNickCallback)
    }
    func PassFindEmailORNickCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.nonimg.isHidden = false;
            self.nonresultlabel.isHidden = false;
            self.nicklabel.isHidden = true;
            self.emaillabel.isHidden = true;
            self.sendpassbtn.isHidden = true;
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            self.nicklabel.text = alldata["data"]["name"].string;
            self.emaillabel.text = alldata["data"]["email"].string;
            self.nonimg.isHidden = true;
            self.nonresultlabel.isHidden = true;
            self.nicklabel.isHidden = false;
            self.emaillabel.isHidden = false;
            self.sendpassbtn.isHidden = false;
            
        }
        LoadingHUD.hide()
    }
}
