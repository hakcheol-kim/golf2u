//
//  BoxOpen.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/06.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON

class BoxOpen: VariousViewController {
    private var SO:Single = Single.getSO();
    private let JS = JsonC();
    
    @IBOutlet weak var uiTitlelb: UILabel!
    @IBOutlet weak var uiSubTItle: UILabel!
    @IBOutlet weak var uiBoxCountLabel: UILabel!
    @IBOutlet weak var uiAllOpenBtn: CircleCheckBoxBtn!
    
    private var m_Data = [String : String]();
    
    private var m_sBoxType = "1";
    private var m_sBoxSeq = "";
    @IBOutlet weak var uiImgPanda: UIImageView!
    private var m_isOpen = false;
    private var m_isStep2Data = false;
    
    private var m_Step2ListData = Array<[String:String]>()
    private var m_Step2ListSubData = [String : String]()
    
    @IBOutlet weak var uiBottomView: UIView!
    //로딩
    private var backgroundView: UIView?
    private var popupView: UIImageView?
    private var mTimer : Timer?
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "박스 오픈".localized)
        super.viewDidLoad()
        
        uiTitlelb.text = "당신에게 찾아온 뜻밖의 행운!".localized
        uiSubTItle.text = "판다이스의 박스를 터치하여\n오늘의 행운을 만나보세요!".localized
        
        if m_sBoxType == "1" {
            //uiBgImg.image = UIImage(named: "inven_random_bg1")
            //uiBoxOpenBtn.setImage(UIImage(named: "inven_random_open"), for: .normal)
            //uiBoxTitleLabel.text = "랜덤박스".localized;
        }else{
            //uiBgImg.image = UIImage(named: "inven_eventbox_bg1")
            //uiBoxOpenBtn.setImage(UIImage(named: "inven_event_open"), for: .normal)
            //uiBoxTitleLabel.text = "이벤트박스".localized;
        }
        
        let tapGestureRecognizer1 = UITapGestureRecognizer(target:self, action: #selector(self.onBoxOpen(tapGesture:)))
        tapGestureRecognizer1.numberOfTapsRequired = 1
        uiImgPanda.isUserInteractionEnabled = true
        uiImgPanda.addGestureRecognizer(tapGestureRecognizer1)
        
        backgroundView = UIView(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        backgroundView?.backgroundColor = UIColor(rgb: 0x56b4f8 )
        
        popupView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        //popupView?.contentMode = .scaleAspectFill
        popupView?.contentMode = .scaleAspectFit
        //popupView?.contentMode = .scaleToFill
        popupView?.animationImages = BoxOpen.getAnimationImageArray()
        popupView?.animationDuration = 2
        popupView?.animationRepeatCount = 1//0 은 무한
        popupView?.image = popupView?.animationImages![29]//프레임이 다돌고 나면 마지막에 띄울 마지막 프레임 이미지 이거안하면 그냥 이미지 사라짐
        
        view.backgroundColor = UIColor(rgb: 0x56b4f8)
        LoadBoxCnt();
    }
    override func viewWillAppear(_ animated: Bool) {

            super.viewWillAppear(animated)
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 11.0, *) {
            if (UIDevice.current.hasNotch) {
                
                let bottomPadding = self.view.safeAreaInsets.bottom;
                uiBottomView.frame = CGRect(x: 0, y: Int(uiBottomView.frame.minY), width: Int(uiBottomView.frame.size.width), height: Int(uiBottomView.frame.size.height + bottomPadding))
                //uiBottomBtnView.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
            }

        }
    }
    @objc func onBoxOpen(tapGesture: UITapGestureRecognizer){
        if m_isOpen {
            return;
        }
        LoadingHUD.show()
        m_isOpen = true;
        JS.BoxOpen(param: ["account_seq":super.getUserSeq(), "random_box_seq":m_sBoxSeq, "box_type":m_sBoxType, "open_multiple":(uiAllOpenBtn.isChecked ? "1" : "0")], callbackf: BoxOpenCallback)
        show()
    }
    func setData(boxtype : String, boxseq : String, data : [String : String]){
        m_sBoxType = boxtype
        m_sBoxSeq = boxseq
        m_Data = data
    }
    func LoadBoxCnt(){
        LoadingHUD.show()
        JS.getMyBoxCnt(param: ["account_seq":super.getUserSeq(), "box_type":m_sBoxType], callbackf: getMyBoxCntCallback)
    }
    func getMyBoxCntCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.navigationController?.popViewController(animated: true);
        }else{
            if m_sBoxType == "1" {
                uiBoxCountLabel.text = "랜덤박스 (개) 한 번에 열기".localized(txt: "\(alldata["data"].stringValue)");
            }else{
                uiBoxCountLabel.text = "이벤트박스 (개) 한 번에 열기".localized(txt: "\(alldata["data"].stringValue)");
            }
        }
        LoadingHUD.hide()
    }
    @IBAction func onBackBtn(_ sender: Any) {
        //SO.getInventoryMain()?.ViewRefrashEvent()
        dismiss(animated: true, completion: nil)
    }
    func BoxOpenCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            //self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
            MessagePop(msg: alldata["errormessage"].string!, btntype : 2,succallbackf: { ()-> Void in
                self.stopTimerTest(isError: true)
            }, closecallbackf: { ()-> Void in
            })
        }else{
            var fm_ListData = Array<[String:String]>();
            for (_, object) in alldata["data"]["data_arr"] {
                var item = [String:String]()
                item["my_product_seq"] = object["my_product_seq"].stringValue;
                item["product_seq"] = object["product_seq"].stringValue;
                item["category_seq"] = object["category_seq"].stringValue;
                item["name"] = object["name"].stringValue;
                item["brand"] = object["brand"].stringValue;
                item["price"] = object["price"].stringValue;
                item["thumbnail"] = object["thumbnail"].stringValue;
                item["delivery_gauge"] = object["delivery_gauge"].stringValue;
                item["expired_at"] = object["expired_at"].stringValue;
                item["random_box_seq"] = object["random_box_seq"].stringValue;
                item["md_comment"] = object["md_comment"].stringValue;
                fm_ListData.append(item)
            }
            m_Step2ListData = fm_ListData;
            m_sBoxSeq = ""//다음 화면시 갖고있던 박스 seq 초기화 돌아왔을때 박스 선택하지않은 상태이 기 때문
            let fm_sRemainCnt = alldata["data"]["remain_cnt"].stringValue;
            let fm_sPoint_payback_expired = alldata["data"]["point_payback_expired"].stringValue;
            let fm_sExpired_at_txt = alldata["data"]["expired_at_txt"].stringValue;
            let fm_sExpire_due_date = alldata["data"]["expire_due_date"].stringValue;
            let fm_sMax_grade = alldata["data"]["max_grade"].stringValue;
            let fm_sSubData = [
                "remain_cnt" : fm_sRemainCnt
                ,"point_payback_expired" : fm_sPoint_payback_expired
                ,"expired_at_txt" : fm_sExpired_at_txt
                ,"expire_due_date" : fm_sExpire_due_date
                ,"max_grade" : fm_sMax_grade
            ]
            m_Step2ListSubData = fm_sSubData
            if m_sBoxType == "1" {
                uiBoxCountLabel.text = "랜덤박스 (개) 한 번에 열기".localized(txt: "\(fm_sRemainCnt)");
            }else{
                uiBoxCountLabel.text = "이벤트박스 (개) 한 번에 열기".localized(txt: "\(fm_sRemainCnt)");
            }
//            self.dismiss(animated: false, completion: nil)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
//                let Storyboard: UIStoryboard = UIStoryboard(name: "BoxOpenStep2", bundle: nil)
//                let viewController = Storyboard.instantiateViewController(withIdentifier: "boxopenstep2idx") as! BoxOpenStep2
//                viewController.setDate(boxtype: m_sBoxType, data: fm_ListData, subdata:fm_sSubData)
//                //self.navigationController?.pushViewController(viewController, animated: true)
//                viewController.modalPresentationStyle = .fullScreen
//                self.present(viewController, animated: true, completion: nil)
//            }
            
//            self.view.window?.rootViewController?.dismiss(animated: false, completion: {
//                let Storyboard: UIStoryboard = UIStoryboard(name: "BoxOpenStep2", bundle: nil)
//                let viewController = Storyboard.instantiateViewController(withIdentifier: "boxopenstep2idx") as! BoxOpenStep2
//                viewController.setDate(boxtype: self.m_sBoxType, data: fm_ListData, subdata:fm_sSubData)
//                //self.navigationController?.pushViewController(viewController, animated: true)
//                viewController.modalPresentationStyle = .fullScreen
//
//              let appDelegate = UIApplication.shared.delegate as! AppDelegate
//              appDelegate.window?.rootViewController?.present(viewController, animated: true, completion: nil)
//            })
            m_isStep2Data = true;
            
        }
        LoadingHUD.hide()
    }
    func show() {
        if let popupView = popupView,
        let backgroundView = backgroundView {
            if let window = UIWindow.key {
                window.addSubview(backgroundView)
                window.addSubview(popupView)
                
                //backgroundView.frame = CGRect(x: 0, y: 0, width: window.frame.maxX, height: window.frame.maxY)
                //backgroundView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
                
                //popupView.center = window.center
                popupView.startAnimating()
                if let timer = mTimer {
                    //timer 객체가 nil 이 아닌경우에는 invalid 상태에만 시작한다
                    if !timer.isValid {
                        /** 1초마다 timerCallback함수를 호출하는 타이머 */
                        mTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
                    }
                }else{
                    //timer 객체가 nil 인 경우에 객체를 생성하고 타이머를 시작한다
                    /** 1초마다 timerCallback함수를 호출하는 타이머 */
                    mTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
                }
                
                
            }
        }
    }
    @objc func timerCallback(){
        if let popupView = popupView {
            if !popupView.isAnimating &&  m_isStep2Data {
                //애니메이션 이 한바퀴 다돌앗을경우 를 체크 하는 타이머
                stopTimerTest()
            }
        }
        
    }
    func stopTimerTest(isError : Bool = false) {
        if let ftimer = mTimer {
            ftimer.invalidate()
            mTimer = nil
            hide();
            m_isOpen = false
            m_isStep2Data = false
            guard let pvc = self.presentingViewController else { return }
            self.modalTransitionStyle = .crossDissolve
            self.dismiss(animated: false) {
                if !isError {
                    let Storyboard: UIStoryboard = UIStoryboard(name: "BoxOpenStep2", bundle: nil)
                    let viewController = Storyboard.instantiateViewController(withIdentifier: "boxopenstep2idx") as! BoxOpenStep2
                    viewController.setDate(boxtype: self.m_sBoxType, data: self.m_Step2ListData, subdata:self.m_Step2ListSubData, step1data: self.m_Data)
                    //self.navigationController?.pushViewController(viewController, animated: true)
                    viewController.modalPresentationStyle = .fullScreen
                    viewController.modalTransitionStyle = .crossDissolve
                    pvc.present(viewController, animated: true, completion: nil)
                }
            }
        }
      
    }
    func hide() {
        if let popupView = popupView,
        let backgroundView = backgroundView {
            popupView.stopAnimating()
            backgroundView.removeFromSuperview()
            popupView.removeFromSuperview()
        }
//        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: { [self] in
//            if let backgroundView = backgroundView {
//                backgroundView.alpha = 0.0
//            }
//        }, completion: { [self]
//            (finished: Bool) -> Void in
//            if let popupView = popupView,
//            let backgroundView = backgroundView {
//                popupView.stopAnimating()
//                backgroundView.removeFromSuperview()
//                popupView.removeFromSuperview()
//            }
//            guard let pvc = self.presentingViewController else { return }
//            self.dismiss(animated: false) {
//                let Storyboard: UIStoryboard = UIStoryboard(name: "BoxOpenStep2", bundle: nil)
//                let viewController = Storyboard.instantiateViewController(withIdentifier: "boxopenstep2idx") as! BoxOpenStep2
//                viewController.setDate(boxtype: self.m_sBoxType, data: self.m_Step2ListData, subdata:self.m_Step2ListSubData, step1data: self.m_Data)
//                //self.navigationController?.pushViewController(viewController, animated: true)
//                viewController.modalPresentationStyle = .fullScreen
//                pvc.present(viewController, animated: false, completion: nil)
//            }
//        })
    }
    private class func getAnimationImageArray() -> [UIImage] {
        var animationArray: [UIImage] = []
        
        for i in 1 ..< (30 + 1) {
            var fm_sNum = "\(i)";
            if i < 10 {
                fm_sNum = "0\(i)";
            }
            if let img = UIImage(named: "box_open_\(fm_sNum)"){
                animationArray.append(img);
            }
        }
        return animationArray
    }
}
