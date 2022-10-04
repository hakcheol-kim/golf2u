//
//  DeliveryManageAddModi.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/16.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON

class DeliveryManageAddModi: VariousViewController {
    public var InsertModifyHandler: (()->())?
    weak var m_tClickEvent: DeliveryApplyClickCellBtnDelegate? = nil;
    
    private let SO = Single.getSO();
    private let JS = JsonC();
    
    private var uiPhone1DP: DownPickerSwift?
    
    @IBOutlet weak var uiTitle1lb: UILabel!
    @IBOutlet weak var uiTitle2lb: UILabel!
    @IBOutlet weak var uiTitle3lb: UILabel!
    @IBOutlet weak var uiTitle4lb: UILabel!
    @IBOutlet weak var uiTitle5lb: UILabel!
    @IBOutlet weak var uiTitle6lb: UILabel!
    
    @IBOutlet weak var uiDeliName: UITextField!
    @IBOutlet weak var uiUserNAme: UITextField!
    @IBOutlet weak var uiAddr1: UITextField!
    @IBOutlet weak var uiAddr2: UITextField!
    @IBOutlet weak var uiAddr3: UITextField!
    @IBOutlet weak var uiFindBtn: UIButton!
    @IBOutlet weak var uiPhone1: UITextField!{
        didSet {
            uiPhone1?.addDoneToolbar(onDone: (target: self, action: #selector(doneButtonTappedForMyNumericTextField)))
        }
    }
    @IBOutlet weak var uiPhone2: UITextField!{
        didSet {
            uiPhone2?.addDoneToolbar(onDone: (target: self, action: #selector(doneButtonTappedForMyNumericTextField)))
        }
    }
    @IBOutlet weak var uiPhone3: UITextField!{
        didSet {
            uiPhone3?.addDoneToolbar(onDone: (target: self, action: #selector(doneButtonTappedForMyNumericTextField)))
        }
    }
    @IBOutlet weak var uiCheckRect: RectCheckBoxBtn!
    @IBOutlet weak var uiArmyCheckRaect: RectCheckBoxBtn!
    @IBOutlet weak var uiAccBtn: UIButton!
    
    private var m_Data : [String: String]?;
    
    private var m_saPhone1 = [String]();
    private var m_sSelPhone1Type = "";
    
    
    private var m_nViewType = 0;//0:추가, 1:수정

    override func viewDidLoad() {
        if m_nViewType == 0{
            super.InitVC(type: Single.DE_INITNAVISUB, title: "배송지 추가".localized)
        }else {
            super.InitVC(type: Single.DE_INITNAVISUB, title: "배송지 수정".localized)
        }
        
        super.viewDidLoad()
        
        uiTitle1lb.text = "배송지 명칭".localized;
        uiTitle2lb.text = "수령인".localized;
        uiTitle3lb.text = "주소".localized;
        uiTitle4lb.text = "군부대 주소".localized;
        uiTitle5lb.text = "기본 배송지로 지정".localized;
        uiTitle6lb.text = "연락처".localized;
        
        uiDeliName.placeholder = "배송지 명칭 정보 입력".localized
        uiUserNAme.placeholder = "받는 사람 정보 입력".localized
        uiAddr1.placeholder = "주소를 검색하세요".localized
        uiAddr3.placeholder = "주소 상세 정보를 입력하세요.".localized
        uiFindBtn.setTitle("찾기".localized, for: .normal)
        uiAccBtn.setTitle("등록완료".localized, for: .normal)
        
        
        uiFindBtn.layer.roundCorners(corners: [.topRight, .bottomRight
        ], radius: 8.0)
        
        uiDeliName.layer.cornerRadius = 8.0;
        uiDeliName.layer.borderWidth = 1.0
        uiDeliName.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiDeliName.addLeftPadding();
        uiUserNAme.layer.cornerRadius = 8.0;
        uiUserNAme.layer.borderWidth = 1.0
        uiUserNAme.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiUserNAme.addLeftPadding();
        uiAddr1.layer.cornerRadius = 8.0;
        uiAddr1.layer.borderWidth = 1.0
        uiAddr1.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiAddr1.addLeftPadding();
        uiAddr2.layer.cornerRadius = 8.0;
        uiAddr2.layer.borderWidth = 1.0
        uiAddr2.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiAddr2.addLeftPadding();
        uiAddr3.layer.cornerRadius = 8.0;
        uiAddr3.layer.borderWidth = 1.0
        uiAddr3.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiAddr3.addLeftPadding();
        //uiPhone1.addLeftPadding()
        //uiPhone1.attributedPlaceholder = NSAttributedString(string: "선택", attributes: [NSAttributedString.Key.foregroundColor : UIColor.black])
        uiPhone1.layer.cornerRadius = 8.0;
        uiPhone1.layer.borderWidth = 1.0
        uiPhone1.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiPhone2.layer.cornerRadius = 8.0;
        uiPhone2.layer.borderWidth = 1.0
        uiPhone2.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiPhone3.layer.cornerRadius = 8.0;
        uiPhone3.layer.borderWidth = 1.0
        uiPhone3.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        self.uiPhone1.delegate = self;
        self.uiPhone2.delegate = self;
        self.uiPhone3.delegate = self;
        
        
        if m_nViewType == 0{
            uiAccBtn.setTitle("등록완료".localized, for: .normal)
        }else {
            if let data = m_Data {
                uiDeliName.text = data["title"];
                uiUserNAme.text = data["name"];
                uiAddr1.text = data["zipcode"];
                uiAddr2.text = data["address1"];
                uiAddr3.text = data["address2"];
                if data["is_default"] == "1" {
                    uiCheckRect.isChecked = true;
                }
                if data["military_address"] == "1" {
                    uiArmyCheckRaect.isChecked = true;
                }

                if let phonenumber = data["phone_number"] {
                    var fm_sLoacation = "XXX-XXXX-XXXX";
                    if phonenumber.count == 11 {
                        fm_sLoacation = "XXX-XXXX-XXXX";
                    }else if phonenumber.count == 10 {
                        fm_sLoacation = "XX-XXXX-XXXX";
                    }else if phonenumber.count == 12 {
                        fm_sLoacation = "XXXX-XXXX-XXXX";
                    }else if phonenumber.count == 9 {
                        fm_sLoacation = "XX-XXX-XXXX";
                    }
                    let fm_sPhoneF = phonenumber.PhoneFormat(with: fm_sLoacation);
                    let fm_sPhoneArr = fm_sPhoneF.components(separatedBy: "-")
                    if fm_sPhoneArr.count >= 3 {
                        m_sSelPhone1Type = fm_sPhoneArr[0];
                        uiPhone1.text = fm_sPhoneArr[0];
//                        if let firstIndex = m_saPhone1.firstIndex(of: fm_sPhoneArr[0]) {
//                            uiPhone1DP?.setValue(at: firstIndex)
//                        }
                        uiPhone2.text = fm_sPhoneArr[1];
                        uiPhone3.text = fm_sPhoneArr[2];
                    }
                }
            }
            uiAccBtn.setTitle("수정완료".localized, for: .normal)
        }
        
        LocationPhoneList();
    }
    func LocationPhoneList(){
        LoadingHUD.show()
        JS.getPhonePrefixes(param: [:], callbackf: getPhonePrefixesCallback)
    }
    func getPhonePrefixesCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            m_saPhone1.append("선택".localized)
            for (_, object) in alldata["data"] {
                m_saPhone1.append(object["num"].stringValue)
            }
        }
        //SettingUI();
        LoadingHUD.hide()
    }
    func SettingUI(){
        uiPhone1DP = DownPickerSwift(with: uiPhone1, with: m_saPhone1)
        uiPhone1DP?.showArrowImage(false)
        uiPhone1DP?.setToolbarDoneButton(with: "확인")
        uiPhone1DP?.setToolbarCancelButton(with: "취소")
        uiPhone1DP?.setPlaceholder(with: "선택".localized)
        uiPhone1DP?.addTarget(self, action: #selector(onSelPhone1(selectedValue:)), for: .valueChanged)
    }
    @objc private func onSelPhone1(selectedValue: DownPickerSwift) {
        m_sSelPhone1Type = selectedValue.getTextField().text!
    }
    @objc func doneButtonTappedForMyNumericTextField() {
        self.view.endEditing(true)
    }
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 11.0, *) {
            if (UIDevice.current.hasNotch) {
                //아이폰x 부터 하단 safe 영역 버튼이 있으면 여기서 처리
                //let topPadding = self.view.safeAreaInsets.top
                //let leftPadding = self.view.safeAreaInsets.left
                //let rightPadding = self.view.safeAreaInsets.right
                let bottomPadding = self.view.safeAreaInsets.bottom;
                uiAccBtn.frame = CGRect(x: 0, y: Int(uiAccBtn.frame.minY), width: Int(uiAccBtn.frame.size.width), height: Int(uiAccBtn.frame.size.height + bottomPadding))
                uiAccBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
            }

        }
    }
    func setViewType(viewtype:Int, data : [String : String]){
        m_nViewType = viewtype
        m_Data = data;
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func onArmyBtn(_ sender: Any) {
        MessagePop(title : "군부대 주소".localized, msg: "군부대 주소는 우체국배송만 가능합니다. 체크하지 않아 반송될 경우 재배송에 따른 배송비를 결제 하셔야 합니다.".localized, btntype: 2)
    }
    @IBAction func onFindBtn(_ sender: Any) {
        let Storyboard: UIStoryboard = UIStoryboard(name: "DeliveryManageAddrWeb", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "DeliveryManageAddrWebidx") as! DeliveryManageAddrWeb
        viewController.SelAddrHandler = { (data : [String : String])-> Void in
            self.setFindAddrSet(data: data);
        }
        viewController.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    func setFindAddrSet(data : [String : String]){
        self.uiAddr1.text = data["zipcode"] ?? ""
        self.uiAddr2.text = data["address1"] ?? ""
        self.uiAddr3.text = ""
    }
    @IBAction func onAccBtn(_ sender: Any) {
        let fm_DeliName = uiDeliName.text!;
        let fm_UserNAme = uiUserNAme.text!;
        let fm_Addr1 = uiAddr1.text!;
        let fm_Addr2 = uiAddr2.text!;
        let fm_Addr3 = uiAddr3.text!;
        m_sSelPhone1Type = uiPhone1.text!;
        let fm_Phone2 = uiPhone2.text!;
        let fm_Phone3 = uiPhone3.text!;
        if fm_DeliName == "" {
            MessagePop(msg: "배송지 명을 입력하세요".localized, btntype : 2)
            return;
        }else if fm_UserNAme == "" {
            MessagePop(msg: "수령인을 입력하세요.".localized, btntype : 2)
            return;
        }else if fm_UserNAme.count <= 1 {
            MessagePop(msg: "수령인은 2자 이상 입력해주세요.".localized, btntype : 2)
            return;
        }else if fm_Addr1 == "" {
            MessagePop(msg: "주소를 검색하세요.".localized, btntype : 2)
            return;
        }else if fm_Addr2 == "" {
            MessagePop(msg: "주소를 검색하세요.".localized, btntype : 2)
            return;
        }else if fm_Addr3 == "" {
            MessagePop(msg: "상세 주소를 입력하세요.".localized, btntype : 2)
            return;
        }else if m_sSelPhone1Type == "" || m_sSelPhone1Type == "선택".localized || fm_Phone2 == "" || fm_Phone3 == "" {
            MessagePop(msg: "연락처를 입력하세요.".localized, btntype : 2)
            return;
        }
        var dataF = [
            "account_seq":super.getUserSeq()
            ,"title":fm_DeliName
            ,"name":fm_UserNAme
            ,"zipcode":fm_Addr1
            ,"address1":fm_Addr2
            ,"address2":fm_Addr3
            ,"phone_number":"\(m_sSelPhone1Type)-\(fm_Phone2)-\(fm_Phone3)"
            ,"is_default":(uiCheckRect.isChecked ? "1" : "0")
            ,"military_address":(uiArmyCheckRaect.isChecked ? "1" : "0")
        ]
        LoadingHUD.show()
        if m_nViewType == 0 {
            //추가
            JS.InsertUserAddress(param: dataF, callbackf: UserAddressCallback)
        }else {
            //수정
            if let data = m_Data {
                dataF["address_seq"] = data["seq"]
            }
            JS.updateUserAddress(param: dataF, callbackf: UserAddressCallback)
        }
    }
    func UserAddressCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            InsertModifyHandler?();
            self.navigationController?.popViewController(animated: true);
        }
        LoadingHUD.hide()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForKeyboardNotifications()//키보드관련
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterForKeyboardNotifications()//키보드관련
    }
    func checkMaxLength(textField: UITextField!, maxLength: Int) {
        if (textField.text?.count ?? 0 > maxLength) {
            textField.deleteBackward()
        }
    }
    @IBAction func onPhone1(_ sender: Any) {
        checkMaxLength(textField: uiPhone1, maxLength: 3)
    }
    @IBAction func onPhone2(_ sender: Any) {
        checkMaxLength(textField: uiPhone2, maxLength: 4)
    }
    @IBAction func onPhone3(_ sender: Any) {
        checkMaxLength(textField: uiPhone3, maxLength: 4)
    }
}
extension DeliveryManageAddModi : UITextFieldDelegate{
    func registerForKeyboardNotifications() {
        // 옵저버 등록
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    func unregisterForKeyboardNotifications() {
        // 옵저버 등록 해제
        NotificationCenter.default.removeObserver(self, name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name:UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    @objc func keyboardWillShow(_ notification: NSNotification){
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame: NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        if uiPhone1.isEditing == true{
            keyboardAnimate(keyboardRectangle: keyboardRectangle, textField: uiPhone1)
        }
        else if uiPhone2.isEditing == true{
            keyboardAnimate(keyboardRectangle: keyboardRectangle, textField: uiPhone2)
        }
        else if uiPhone3.isEditing == true{
            keyboardAnimate(keyboardRectangle: keyboardRectangle, textField: uiPhone3)
        }
    }
    func keyboardAnimate(keyboardRectangle: CGRect ,textField: UITextField){
        if keyboardRectangle.height > (self.view.frame.height - textField.frame.maxY){
            self.view.transform = CGAffineTransform(translationX: 0, y: (self.view.frame.height - keyboardRectangle.height - textField.frame.maxY))
        }
    }
    @objc func keyboardWillHide(_ notification: NSNotification){
        self.view.transform = .identity
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //self.activeTextField = textField
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool{
        
        return true;
    }
}
