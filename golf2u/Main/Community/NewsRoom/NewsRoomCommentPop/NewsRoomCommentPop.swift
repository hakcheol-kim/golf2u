//
//  NewsRoomCommentPop.swift
//  golf2u
//
//  Created by 이원영 on 2020/10/22.
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

class NewsRoomCommentPop: VariousViewController {
    private let SO = Single.getSO();
    private let JS = JsonC();
    
    public var closeHandler: (()->())?//클로저
    
    
    @IBOutlet weak var uiImageFile1: UIImageView!
    @IBOutlet weak var uiImageFile2: UIImageView!
    @IBOutlet weak var uiContentInput: UITextField!
    
    private var selectedItems = [YPMediaItem]()
    private var uiImageFiles = [UIImageView]();
    
    private var m_selImages = [UIImage]();
    private var m_isSelImages = [false,false]
    
    private var m_sUserSeq : String = "";
    private var m_sMPSeq : String = "";
    private var m_sPrentSeq : String = "";
    
    private var keyboardShown:Bool = false // 키보드 상태 확인
    private var originY:CGFloat? // 오브젝트의 기본 위치
    
    private var m_isAcc : Bool = false;
    
    init(f_sMPSeq : String, f_sPrentSeq : String){
       super.init(nibName: nil, bundle: nil)
        self.m_sMPSeq = f_sMPSeq
        self.m_sPrentSeq = f_sPrentSeq;
        self.m_sUserSeq = getUserSeq();
   }
   

   required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
   }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiImageFile1.layer.cornerRadius = 8.0;
        uiImageFile1.layer.borderWidth = 1.0
        uiImageFile1.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiImageFile2.layer.cornerRadius = 8.0;
        uiImageFile2.layer.borderWidth = 1.0
        uiImageFile2.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor

        self.uiContentInput.delegate = self;
        uiContentInput.layer.cornerRadius = 8.0;
        uiContentInput.layer.borderWidth = 1.0
        uiContentInput.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        uiContentInput.addLeftPadding()
        self.uiContentInput.returnKeyType = .done;
        uiContentInput.placeholder = "축하메세지".localized
        
        uiImageFile1.isUserInteractionEnabled = true
        let subimgevntg1 = UITapGestureRecognizer(target: self, action: #selector(self.onFileTab(tapGesture:)))
        uiImageFile1.addGestureRecognizer(subimgevntg1)
        
        uiImageFile2.isUserInteractionEnabled = true
        let subimgevntg2 = UITapGestureRecognizer(target: self, action: #selector(self.onFileTab(tapGesture:)))
        uiImageFile2.addGestureRecognizer(subimgevntg2)
        
        uiImageFiles.append(uiImageFile1)
        uiImageFiles.append(uiImageFile2)
        
        m_selImages.append(UIImage())
        m_selImages.append(UIImage())
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        registerForKeyboardNotifications()//키보드관련
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterForKeyboardNotifications()//키보드관련
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.roundCorners([.topLeft, .topRight], radius: 15)
    }
    @IBAction func onPicBtn(_ sender: Any) {
        if !isSendImgTump(){
            return;
        }
        showPicker(screen: .library, title: "사진".localized);
    }
    @IBAction func onCameraBtn(_ sender: Any) {
        if !isSendImgTump(){
            return;
        }
        showPicker(screen: .photo, title: "카메라".localized);
    }
    @objc func onFileTab(tapGesture: UITapGestureRecognizer) {
        let imgView = tapGesture.view as! UIImageView
        if imgView == uiImageFile1 {
            uiImageFile1.image = nil;
            self.m_isSelImages[0] = false
        }else if imgView == uiImageFile2 {
            uiImageFile2.image = nil;
            self.m_isSelImages[1] = false
        }
    }
    func showPicker(screen : YPPickerScreen, title : String) {
        
        var config = YPImagePickerConfiguration()
        
        /* Uncomment and play around with the configuration 👨‍🔬 🚀 */
        
        /* Set this to true if you want to force the  library output to be a squared image. Defaults to false */
        //         config.library.onlySquare = true
        /* Set this to true if you want to force the camera output to be a squared image. Defaults to true */
        // config.onlySquareImagesFromCamera = false
        /* Ex: cappedTo:1024 will make sure images from the library or the camera will be
         resized to fit in a 1024x1024 box. Defaults to original image size. */
        // config.targetImageSize = .cappedTo(size: 1024)
        /* Choose what media types are available in the library. Defaults to `.photo` */
        config.library.mediaType = .photo
        config.library.itemOverlayType = .grid
        /* Enables selecting the front camera by default, useful for avatars. Defaults to false */
        // config.usesFrontCamera = true
        /* Adds a Filter step in the photo taking process. Defaults to true */
        config.showsPhotoFilters = false
        /* Manage filters by yourself */
        //        config.filters = [YPFilter(name: "Mono", coreImageFilterName: "CIPhotoEffectMono"),
        //                          YPFilter(name: "Normal", coreImageFilterName: "")]
        //        config.filters.remove(at: 1)
        //        config.filters.insert(YPFilter(name: "Blur", coreImageFilterName: "CIBoxBlur"), at: 1)
        /* Enables you to opt out from saving new (or old but filtered) images to the
         user's photo library. Defaults to true. */
        config.shouldSaveNewPicturesToAlbum = false
        
        /* Choose the videoCompression. Defaults to AVAssetExportPresetHighestQuality */
        //config.video.compression = AVAssetExportPresetMediumQuality
        
        /* Defines the name of the album when saving pictures in the user's photo library.
         In general that would be your App name. Defaults to "DefaultYPImagePickerAlbumName" */
        // config.albumName = "ThisIsMyAlbum"
        /* Defines which screen is shown at launch. Video mode will only work if `showsVideo = true`.
         Default value is `.photo` */
        config.startOnScreen = screen
        
        /* Defines which screens are shown at launch, and their order.
         Default value is `[.library, .photo]` */
        config.screens = [screen]
        
        /* Can forbid the items with very big height with this property */
        //        config.library.minWidthForItem = UIScreen.main.bounds.width * 0.8
        /* Defines the time limit for recording videos.
         Default is 30 seconds. */
        // config.video.recordingTimeLimit = 5.0
        /* Defines the time limit for videos from the library.
         Defaults to 60 seconds. */
        //config.video.libraryTimeLimit = 500.0
        
        /* Adds a Crop step in the photo taking process, after filters. Defaults to .none */
        //config.showsCrop = .rectangle(ratio: (16/9))
        config.showsCrop = .none
        
        /* Defines the overlay view for the camera. Defaults to UIView(). */
        // let overlayView = UIView()
        // overlayView.backgroundColor = .red
        // overlayView.alpha = 0.3
        // config.overlayView = overlayView
        /* Customize wordings */
        config.wordings.libraryTitle = title
        
        /* Defines if the status bar should be hidden when showing the picker. Default is true */
        config.hidesStatusBar = false
        
        /* Defines if the bottom bar should be hidden when showing the picker. Default is false */
        config.hidesBottomBar = false
        
        config.maxCameraZoomFactor = 2.0
        
        config.library.maxNumberOfItems = 2
        config.gallery.hidesRemoveButton = false
        
        /* Disable scroll to change between mode */
        // config.isScrollToChangeModesEnabled = false
        //        config.library.minNumberOfItems = 2
        /* Skip selection gallery after multiple selections */
        // config.library.skipSelectionsGallery = true
        /* Here we use a per picker configuration. Configuration is always shared.
         That means than when you create one picker with configuration, than you can create other picker with just
         let picker = YPImagePicker() and the configuration will be the same as the first picker. */
        
        /* Only show library pictures from the last 3 days */
        //let threDaysTimeInterval: TimeInterval = 3 * 60 * 60 * 24
        //let fromDate = Date().addingTimeInterval(-threDaysTimeInterval)
        //let toDate = Date()
        //let options = PHFetchOptions()
        // options.predicate = NSPredicate(format: "creationDate > %@ && creationDate < %@", fromDate as CVarArg, toDate as CVarArg)
        //
        ////Just a way to set order
        //let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        //options.sortDescriptors = [sortDescriptor]
        //
        //config.library.options = options
        config.library.preselectedItems = selectedItems
        
        
        // Customise fonts
        //config.fonts.menuItemFont = UIFont.systemFont(ofSize: 22.0, weight: .semibold)
        //config.fonts.pickerTitleFont = UIFont.systemFont(ofSize: 22.0, weight: .black)
        //config.fonts.rightBarButtonFont = UIFont.systemFont(ofSize: 22.0, weight: .bold)
        //config.fonts.navigationBarTitleFont = UIFont.systemFont(ofSize: 22.0, weight: .heavy)
        //config.fonts.leftBarButtonFont = UIFont.systemFont(ofSize: 22.0, weight: .heavy)
        let picker = YPImagePicker(configuration: config)
        
        picker.imagePickerDelegate = self
        
        /* Change configuration directly */
        // YPImagePickerConfiguration.shared.wordings.libraryTitle = "Gallery2"
        /* Multiple media implementation */
        picker.didFinishPicking { [unowned picker] items, cancelled in
            
            if cancelled {
                //print("Picker was canceled")
                picker.dismiss(animated: true, completion: nil)
                return
            }
            //_ = items.map { print("🧀 \($0)") }
            
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
        
        /* Single Photo implementation. */
        // picker.didFinishPicking { [unowned picker] items, _ in
        //     self.selectedItems = items
        //     self.selectedImageV.image = items.singlePhoto?.image
        //     picker.dismiss(animated: true, completion: nil)
        // }
        /* Single Video implementation. */
        //picker.didFinishPicking { [unowned picker] items, cancelled in
        //    if cancelled { picker.dismiss(animated: true, completion: nil); return }
        //
        //    self.selectedItems = items
        //    self.selectedImageV.image = items.singleVideo?.thumbnail
        //
        //    let assetURL = items.singleVideo!.url
        //    let playerVC = AVPlayerViewController()
        //    let player = AVPlayer(playerItem: AVPlayerItem(url:assetURL))
        //    playerVC.player = player
        //
        //    picker.dismiss(animated: true, completion: { [weak self] in
        //        self?.present(playerVC, animated: true, completion: nil)
        //        print("😀 \(String(describing: self?.resolutionForLocalVideo(url: assetURL)!))")
        //    })
        //}
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
// YPImagePickerDelegate
extension NewsRoomCommentPop: YPImagePickerDelegate {
    func imagePickerHasNoItemsInLibrary(_ picker: YPImagePicker) {
        
    }
    func noPhotos() {}

    func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool {
        return true// indexPath.row != 2
    }
}
// Support methods
extension NewsRoomCommentPop {
    /* Gives a resolution for the video by URL */
    func resolutionForLocalVideo(url: URL) -> CGSize? {
        guard let track = AVURLAsset(url: url).tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
}
extension NewsRoomCommentPop:UITextFieldDelegate{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
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
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if keyboardSize.height == 0.0 || keyboardShown == true {
                return
            }
            if originY == nil { originY = self.view.frame.origin.y }
            self.view.frame.origin.y = originY! - keyboardSize.height
            keyboardShown = true
        }
    }
    @objc func keyboardWillHide(_ notification: NSNotification){
        if let _ = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
          if keyboardShown == false {
              return
          }
        guard let originY = originY else { return }
            self.view.frame.origin.y = originY
            keyboardShown = false
          
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if m_isAcc {
            return false;
        }
        var imgs = [String : UIImage]();
        let fm_sCon = uiContentInput.text!;
        if fm_sCon == "" {
            MessagePop(msg: "메세지를 입력해주세요.".localized, btntype : 2);
            return false
        }
        var KeyName = 1;
        for (i, bools) in m_isSelImages.enumerated(){
            if bools{
                imgs["file\(KeyName)"] = m_selImages[i];
                KeyName += 1;
            }
        }
        LoadingHUD.show()
        m_isAcc = true;
        JS.NewsRoomCommentInsert(param: ["account_seq":m_sUserSeq, "my_product_seq":m_sMPSeq, "contents":fm_sCon, "parent_comment_seq" : m_sPrentSeq], imgs: imgs, callbackf: NewsRoomCommentInsertCallback)
        
        self.view.endEditing(true)
        self.uiContentInput.text = "";
        self.uiImageFile1.image = nil;
        self.m_isSelImages[0] = false
        self.uiImageFile2.image = nil;
        self.m_isSelImages[1] = false
        return false
    }
    func NewsRoomCommentInsertCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            closeHandler?()
        }
        LoadingHUD.hide()
        dismiss(animated: true, completion: nil)
    }
}
private extension UIView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        var rect = bounds

        // Increase height (only useful for the iPhone X for now)
        if #available(iOS 11.0, *) {
            if let window = UIWindow.key {
                rect.size.height += window.safeAreaInsets.bottom
            }
        }

        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
