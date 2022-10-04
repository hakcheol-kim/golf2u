//
//  UserConAdd.swift
//  golf2u
//
//  Created by 이원영 on 2020/12/03.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import ImageSlideshow
import YPImagePicker
import AVFoundation
import AVKit
import Photos
import SwiftyJSON
import EzPopup

//import DownPickerSwift

class UserConAdd: VariousViewController {
    private let SO = Single.getSO();
    private let JS = JsonC();
    
    @IBOutlet weak var uiTitlelb1: UILabel!
    @IBOutlet weak var uiTitlelb2: UILabel!
    @IBOutlet weak var uiTitlelb3: UILabel!
    
    @IBOutlet weak var uiCategory: UITextField!
    private var uiCategoryDP: DownPickerSwift?
    @IBOutlet weak var uiTitle: UITextField!
    @IBOutlet weak var uiContents: UITextView!
    @IBOutlet weak var uiImgView: UIView!
    @IBOutlet weak var uiAreeView: UIView!
    @IBOutlet weak var uiAgreeBtn: CircleCheckBoxBtn!
    @IBOutlet weak var uiAccBtn: UIButton!
    @IBOutlet weak var uiImg1: UIImageView!
    @IBOutlet weak var uiImg2: UIImageView!
    @IBOutlet weak var uiImg3 : UIImageView!
    @IBOutlet weak var uiImg4: UIImageView!
    @IBOutlet weak var uiImg5: UIImageView!
    @IBOutlet weak var uiUpBtn: UIButton!
    
    private var m_ListData = Array<[String:String]>();
    
    private var selectedItems = [YPMediaItem]()
    private var uiImageFiles = [UIImageView]();
    
    private var m_selImages = [UIImage]();
    private var m_isSelImages = [false,false,false,false,false]
    
    private var m_sSelCaType = "";
    private var m_sUserSeq : String = "";
    private var m_isAcc : Bool = false;
    
    private var m_sTitlePlaceTxt = "문의 제목을 입력하세요(1000자 이내)\n\n*산업안전보건법에 따라 고객응대근로자 보호 조치를 시행하고 있습니다.\n고객센터 문의내용에 폭언, 욕설 등을 하실 경우 상담이 제한될 수 있습니다.\n따뜻한 말 한마디가 모두를 행복하게 합니다.";
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "문의 작성".localized)
        super.viewDidLoad()
        
        uiTitlelb1.text = "문의 유형".localized
        uiTitlelb2.text = "문의 내용".localized
        uiTitlelb3.text = "답변 내용을 랜덤투유 계정 이메일로 발송합니다.(선택)".localized
        uiTitle.placeholder = "문의 제목을 입력하세요(50자 이내)".localized
        uiAccBtn.setTitle("문의하기".localized, for: .normal)
        uiUpBtn.setTitle("첨부파일".localized, for: .normal)
        
        m_sUserSeq = super.getUserSeq()
        
        uiAreeView.layer.addBorder([.top], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
        uiCategory.layer.cornerRadius = 8.0;
        uiCategory.layer.borderWidth = 1.0
        uiCategory.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiCategory.addLeftPadding();
        
        uiTitle.layer.cornerRadius = 8.0;
        uiTitle.layer.borderWidth = 1.0
        uiTitle.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiTitle.addLeftPadding();
        
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
        uiUpBtn.layer.cornerRadius = 8.0;
        uiUpBtn.layer.borderWidth = 1.0
        uiUpBtn.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        uiContents.layer.cornerRadius = 8.0;
        uiContents.layer.borderWidth = 1.0
        uiContents.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiContents.delegate = self;
        uiContents.text = m_sTitlePlaceTxt.localized;
        uiContents.textColor = UIColor.lightGray
        
        uiImageFiles.append(uiImg1)
        uiImageFiles.append(uiImg2)
        uiImageFiles.append(uiImg3)
        uiImageFiles.append(uiImg4)
        uiImageFiles.append(uiImg5)
        
        m_selImages.append(UIImage())
        m_selImages.append(UIImage())
        m_selImages.append(UIImage())
        m_selImages.append(UIImage())
        m_selImages.append(UIImage())
        
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

        CategoryList();
    }
    @objc func onFileTab(tapGesture: UITapGestureRecognizer) {
        let imgView = tapGesture.view as! UIImageView
        if imgView == uiImg1 {
            uiImg1.image = nil;
            self.m_isSelImages[0] = false
        }else if imgView == uiImg2 {
            uiImg2.image = nil;
            self.m_isSelImages[1] = false
        }else if imgView == uiImg3 {
            uiImg3.image = nil;
            self.m_isSelImages[2] = false
        }else if imgView == uiImg4 {
            uiImg4.image = nil;
            self.m_isSelImages[3] = false
        }else if imgView == uiImg5 {
            uiImg5.image = nil;
            self.m_isSelImages[4] = false
        }
    }
    func CategoryList(){
        LoadingHUD.show()
        JS.getAllQnaCategory(param: [:], callbackf: getAllQnaCategoryCallback)
    }
    func getAllQnaCategoryCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            for (_, object) in alldata["data"] {
                var item = [String:String]()
                item["seq"] = object["seq"].stringValue;
                item["title"] = object["title"].stringValue;
                m_ListData.append(item)
            }
            var fm_arrCupon = [String]()
            for val in m_ListData{
                fm_arrCupon.append(val["title"] ?? "")
            }
            uiCategoryDP = DownPickerSwift(with: uiCategory, with: fm_arrCupon)
            uiCategoryDP?.showArrowImage(false)
            uiCategoryDP?.setToolbarDoneButton(with: "확인")
            uiCategoryDP?.setToolbarCancelButton(with: "취소")
            uiCategoryDP?.setPlaceholder(with: "문의 유형을 선택하세요.".localized)
            uiCategoryDP?.addTarget(self, action: #selector(onCategory(selectedValue:)), for: .valueChanged)
        }
        LoadingHUD.hide()
    }
    @objc private func onCategory(selectedValue: DownPickerSwift) {
        m_sSelCaType = selectedValue.getTextField().text!
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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
    
    @IBAction func onAccBtn(_ sender: Any) {
        if m_isAcc {
            return;
        }
        var fm_sCaTypeSeq : String = "";
        for val in m_ListData{
            if val["title"] == m_sSelCaType {
                fm_sCaTypeSeq = val["seq"] ?? "";
                break;
            }
        }
        let fm_sTitle = uiTitle.text!
        var fm_sCon = uiContents.text!
        if uiContents.textColor == UIColor.lightGray {
            fm_sCon = ""
        }
        if fm_sCaTypeSeq == "" {
            MessagePop(msg: "문의 유형을 선택하세요.".localized, btntype : 2)
            return;
        }else if fm_sTitle == "" {
            MessagePop(msg: "문의 제목을 입력하세요.".localized, btntype : 2)
            return;
        }else if fm_sTitle.count <= 1 {
            MessagePop(msg: "제목은 2자 이상 입력해주세요.".localized, btntype : 2)
            return;
        }else if fm_sCon == "" {
            MessagePop(msg: "문의 내욕을 입력하세요.".localized, btntype : 2)
            return;
        }
        var imgs = [String : UIImage]();
        var KeyName = 1;
        for (i, bools) in m_isSelImages.enumerated(){
            if bools{
                imgs["file\(KeyName)"] = m_selImages[i];
                KeyName += 1;
            }
        }
        m_isAcc = true;
        LoadingHUD.show()
        JS.setQna(param: ["account_seq":m_sUserSeq, "qna_category_seq":fm_sCaTypeSeq, "title":fm_sTitle, "contents":fm_sCon, "send_mail":(!uiAgreeBtn.isChecked ? "0" : "1")], imgs: imgs, callbackf: setQnaCallback)
    }
    func setQnaCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            MessagePop(msg: alldata["errormessage"].stringValue, btntype : 2)
        }else{
            MessagePop(title : "문의가 정상 접수 되었습니다.".localized, msg: "1:1 문의 내역에서 문의내용 및 답변을 확인 하실 수 있습니다.".localized, btntype : 2,succallbackf: { ()-> Void in
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
            }, closecallbackf: { ()-> Void in
                
            })
            
            
        }
        LoadingHUD.hide()
    }
    @IBAction func onUpBtn(_ sender: Any) {
        if !isSendImgTump(){
            return;
        }
        showPicker(screen: .library, title: "사진".localized);
    }
    func showPicker(screen : YPPickerScreen, title : String) {
        
        var config = YPImagePickerConfiguration()
        config.library.mediaType = .photo
        config.library.itemOverlayType = .grid
        config.showsPhotoFilters = false
        config.shouldSaveNewPicturesToAlbum = false
        config.startOnScreen = screen
        config.screens = [screen]
        config.showsCrop = .none
        config.wordings.libraryTitle = title
        config.hidesStatusBar = false
        config.hidesBottomBar = false
        
        config.maxCameraZoomFactor = 2.0
        
        config.library.maxNumberOfItems = 5
        config.gallery.hidesRemoveButton = false
        
        config.library.preselectedItems = selectedItems
        
        
        
        let picker = YPImagePicker(configuration: config)
        
        picker.imagePickerDelegate = self
        
        picker.didFinishPicking { [unowned picker] items, cancelled in
            if cancelled {
                picker.dismiss(animated: true, completion: nil)
                return
            }
           
            self.selectedItems = items
            for (_, val) in items.enumerated(){
                switch val {
                case .photo(let photo):
                    self.SendImgArrSet(image: photo.image)
//                    if i == 0{
//                        self.uiImageFile1.image = photo.image;
//                        self.m_selImages[0] = photo.image
//                        self.m_isSelImages[0] = true
//                    }else if i == 1{
//                        self.uiImageFile2.image = photo.image;
//                        self.m_selImages[1] = photo.image
//                        self.m_isSelImages[1] = true
//                    }
                    picker.dismiss(animated: true, completion: nil)
                case .video(let video):
                    //self.selectedImageV.image = video.thumbnail
                    
                    let assetURL = video.url
                    let playerVC = AVPlayerViewController()
                    let player = AVPlayer(playerItem: AVPlayerItem(url:assetURL))
                    playerVC.player = player
                    picker.dismiss(animated: true, completion: { [weak self] in
                        self?.present(playerVC, animated: true, completion: nil)
                        //print("😀 \(String(describing: self?.resolutionForLocalVideo(url: assetURL)!))")
                    })
                }
            }
        }
        present(picker, animated: true, completion: nil)
    }
    func isSendImgTump() -> Bool{
        var isTump = false;
        for isB in m_isSelImages{
            if !isB {
                isTump = true;
                break;
            }
        }
        return isTump;
    }
    func SendImgArrSet(image : UIImage ){
        for (i,isB) in m_isSelImages.enumerated(){
            if !isB {
                self.uiImageFiles[i].image = image;
                self.m_selImages[i] = image
                self.m_isSelImages[i] = true
                break;
            }
        }
    }
}
extension UserConAdd : UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = m_sTitlePlaceTxt.localized
            textView.textColor = UIColor.lightGray
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let str = textView.text else {return true}
        let newLength = str.count + text.count - range.length;
        return newLength <= 1000
    }
    
}
// YPImagePickerDelegate
extension UserConAdd: YPImagePickerDelegate {
    func imagePickerHasNoItemsInLibrary(_ picker: YPImagePicker) {
        
    }
    
    func noPhotos() {}

    func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool {
        return true// indexPath.row != 2
    }
}
