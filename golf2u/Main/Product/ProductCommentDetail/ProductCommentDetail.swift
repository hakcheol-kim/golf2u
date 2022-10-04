//
//  ProductCommentDetail.swift
//  golf2u
//
//  Created by 이원영 on 2020/10/12.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SwiftyJSON
import ImageSlideshow
import NBBottomSheet
import Toast_Swift

class ProductCommentDetail: VariousViewController {
    private let SO = Single.getSO();
    private let JS = JsonC();
    
    private var m_ListData = Array<[String:String]>();
    
    private var m_nPageNum = 0;
    private var m_nNextNum = 0;
    private var m_nDataCnt = 0;

    private var m_sPSeq : String = "";
    private var m_sMyPSeq : String = "";
    private var m_sUserSeq : String = "";
    private var m_sOrder_by : String = "0";
    private var m_isWriteBtn : Bool = true;
    
    @IBOutlet weak var uiTopView: UIView!
    @IBOutlet weak var uiCommentCntLabel: UILabel!
    @IBOutlet weak var uiOrderbyBtn: UIButton!
    @IBOutlet weak var uiWriteBtn: UIButton!
    
    
    @IBOutlet weak var uiCommnetTable: UITableView!
    private var cellDeleteIndexPath: IndexPath? = nil
    
    private var refreshControl = UIRefreshControl()//테이블 아래로 당겨서 리프레쉬 해주는거
    
    private var m_isPagging = false;
    
    private let m_isUserPZoom = ImageSlideshow()
    
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "상품후기".localized)
        super.viewDidLoad()

        uiOrderbyBtn.layer.cornerRadius = 5.0
        uiOrderbyBtn.backgroundColor = .clear
        uiOrderbyBtn.layer.borderWidth = 1
        uiOrderbyBtn.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        self.uiTopView.layer.addBorder([.top,.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
        
        //table setting
        self.uiCommnetTable.tableFooterView = UIView(frame: .zero)
        self.uiCommnetTable.dataSource = self
        self.uiCommnetTable.delegate = self
        self.uiCommnetTable.separatorStyle = .none//셀간 줄 없애기
        self.uiCommnetTable.cellLayoutMarginsFollowReadableWidth = false
        self.uiCommnetTable.separatorInset.left = 0
        //self.uiCommnetTable.rowHeight = UITableView.automaticDimension;
        //self.uiCommnetTable.estimatedRowHeight = 123;


        //테이블뷰 리프레쉬
        if #available(iOS 10.0, *) {
          self.uiCommnetTable.refreshControl = refreshControl
        } else {
          self.uiCommnetTable.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)//리프레시 이벤트
        //refreshControl.attributedTitle = NSAttributedString(string: "H2Care")
        
        let nibName = UINib(nibName: "ProductCommnetDetailCell", bundle: nil)
        self.uiCommnetTable.register(nibName, forCellReuseIdentifier: "productcommnetdetailcellidx")
        
        uiWriteBtn.isHidden = m_isWriteBtn
        
        refresh();
        
    }
    func setWriteBtn(isv : Bool){
        m_isWriteBtn = isv
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    func setInitData(seq : String, myseq : String = ""){
        self.m_sPSeq = seq;
        self.m_sMyPSeq = myseq
        
    }
    @objc func refresh(){
        m_nPageNum = 0;
        m_ListData.removeAll();
        LoadItem();
    }
    func LoadItem(){
        LoadingHUD.show()
        m_isPagging = true;
        m_sUserSeq = getUserSeq();
        m_nPageNum += 1;
        JS.ProductCommentDetail(param: ["pagenum":"\(m_nPageNum)","product_seq":m_sPSeq, "account_seq" : m_sUserSeq, "order_type" : m_sOrder_by, "include_2nd" : "1"], callbackf: ProductCommentDetailCallback)
    }
    func ProductCommentDetailCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            if let val = alldata["nextpage"].string{
                m_nNextNum = Int(val)!;
            }
            if let val = alldata["datacnt"].string{
                m_nDataCnt = Int(val)!;
                uiCommentCntLabel.text = "건".localized(txt: "\(String(m_nDataCnt).DecimalWon())");
                uiCommentCntLabel.TextPartColor(partstr: "\(m_nDataCnt)", Color: UIColor(rgb: 0x00BA87))
            }
            for (_, object) in alldata["data"] {
                var item = [String:String]()
                item["seq"] = object["seq"].stringValue;
                item["title"] = object["title"].stringValue;
                item["contents"] = object["contents"].stringValue;
                item["file1"] = object["file1"].stringValue;
                item["file2"] = object["file2"].stringValue;
                item["created_at"] = object["created_at"].stringValue;
                item["name"] = object["name"].stringValue;
                item["profile_image_url"] = object["profile_image_url"].stringValue;
                item["like_cnt"] = object["like_cnt"].stringValue;
                item["liked"] = object["liked"].stringValue;
                item["comments_cnt"] = object["comments_cnt"].stringValue;
                item["account_seq"] = object["account_seq"].stringValue;
                item["comments_cnt"] = object["comments_cnt"].stringValue;
                item["level"] = object["level"].stringValue;
                m_ListData.append(item)
            }
        }
        DispatchQueue.main.async {
            self.uiCommnetTable.reloadData()
            self.refreshControl.endRefreshing();
        }
        m_isPagging = false
        LoadingHUD.hide()
    }
    
    @IBAction func onOderByBtn(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: "정렬".localized, preferredStyle: .actionSheet)
        //옵션 초기화
        let alertacop1 = UIAlertAction(title: "최신순".localized, style: .default, handler: alertHandleOp1)
        let alertacop2 = UIAlertAction(title: "도움순".localized, style: .default, handler: alertHandleOp1)
        let cancelAction = UIAlertAction(title: "닫기".localized, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(alertacop1)
        optionMenu.addAction(alertacop2)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    func alertHandleOp1(alertAction: UIAlertAction!) -> Void {
        if alertAction.title! == "최신순".localized {
            uiOrderbyBtn.setTitle("최신순".localized, for: .normal);
            m_sOrder_by = "0";
        }else if alertAction.title! == "도움순".localized {
            uiOrderbyBtn.setTitle("도움순".localized, for: .normal);
            m_sOrder_by = "1";
        }
        refresh();
    }
    @IBAction func onWriteBtn(_ sender: Any) {
        if m_sUserSeq == ""{
            //self.view.makeToast("로그인 후 이용해주세요.", duration: 1.0, position: .bottom)
            super.LoginMove()
            return;
        }
        let configuration = NBBottomSheetConfiguration(animationDuration: 0.4, sheetSize: .fixed(143))
        let bottomSheetController = NBBottomSheetController(configuration:configuration)
        let viewController = ProductCommnetPop(pseq: m_sPSeq, myseq: m_sMyPSeq)
        viewController.closeHandler = { (pointtype : String, point : String)-> Void in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.EndComment(pointtype : pointtype, point : point )
            }
        }
        bottomSheetController.present(viewController, on: self)
    }
    func EndComment(pointtype : String, point : String){
        self.refresh();
        //print(pointtype, point);
        if pointtype == "2" {
            //첫후기
            MessagePop(title : "첫 후기 등록 완료".localized, msg: "첫 후기를 등록해주셔서 감사합니다. 클로버를 드립니다.".localized(txt: "\(point.DecimalWon())"), lbtn: "클로버내역".localized, rbtn: "확인".localized,succallbackf: {  ()-> Void in
                super.AppReview()
            }, closecallbackf: {  ()-> Void in
                let Storyboard: UIStoryboard = UIStoryboard(name: "CloverInfo", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "CloverInfoidx") as! CloverInfo
                self.navigationController?.pushViewController(viewController, animated: true)
                
            })
        }else if pointtype == "1" {
            //후기
            MessagePop(title : "후기 등록 완료".localized, msg: "후기를 등록해주셔서 감사합니다. 클로버를 드립니다.".localized(txt: "\(point.DecimalWon())"), lbtn: "클로버내역".localized, rbtn: "확인".localized,succallbackf: {  ()-> Void in
                super.AppReview()
            }, closecallbackf: {  ()-> Void in
                
                let Storyboard: UIStoryboard = UIStoryboard(name: "CloverInfo", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "CloverInfoidx") as! CloverInfo
                self.navigationController?.pushViewController(viewController, animated: true)
            })
        }else{
            //super.AppReview()
        }
        
    }
    @objc func onProPhoto(tapGesture: UITapGestureRecognizer){
        let imgView = tapGesture.view as! UIImageView
        let fm_sUserImgUrl = "\(Single.DE_URLIMGSERVER)\(m_ListData[imgView.tag]["profile_image_url"] ?? "")"
        super.ProfileImagePlus(UserImgUrl: fm_sUserImgUrl)
        
    }
    
}
    
extension ProductCommentDetail :  UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if m_ListData.count > 0 {
            uiCommnetTable.backgroundView = nil;
            return m_ListData.count;
        } else {
            ListViewHelper.TableViewEmptyMessage(message: "데이터가 없습니다.".localized, viewController: self, tableviewController: uiCommnetTable)
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productcommnetdetailcellidx", for: indexPath) as! ProductCommnetDetailCell
        if m_ListData.count > indexPath.row{
            cell.setData(data: m_ListData[indexPath.row], row:indexPath.row)
            let tapGestureRecognizer1 = UITapGestureRecognizer(target:self, action: #selector(self.onPCPhoto(tapGesture:)))
            tapGestureRecognizer1.numberOfTapsRequired = 1
            cell.uiProductImg.isUserInteractionEnabled = true
            cell.uiProductImg.addGestureRecognizer(tapGestureRecognizer1)
            cell.LikeBtnHandler = { ()-> Void in
                super.LoginMove()
            }
            let tapGestureRecognizer2 = UITapGestureRecognizer(target:self, action: #selector(self.onProPhoto(tapGesture:)))
            tapGestureRecognizer2.numberOfTapsRequired = 1
            cell.uiProfileImg.isUserInteractionEnabled = true
            cell.uiProfileImg.addGestureRecognizer(tapGestureRecognizer2)
        }else{
        }
        
       
        return cell
        
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (m_ListData.count - 1) == indexPath.row && m_nNextNum > 0 && !m_isPagging{
            
           self.LoadItem();
        }
    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return 123;
    //    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //return UITableView.automaticDimension;
        if m_ListData.count > indexPath.row{
            if m_ListData[indexPath.row]["file1"] != "" || m_ListData[indexPath.row]["file2"] != ""{
                var heightT : CGFloat = 103;
                
                let bounds = UIScreen.main.bounds
                let width = bounds.size.width //화면 너비
                //let height = bounds.size.height //화면 높이
                
                //74 를 뺀이유는 스토리보드 컨텐츠 레이블 에서 양쪽 여백 을 더한 숫자다 화면 크기 를 구한다면 양쪽 여백을빼면 실제 콘텐츠 넓이가 나온다
                heightT += m_ListData[indexPath.row]["contents"]!.heightT(withConstrainedWidth: (width - 74), font: UIFont.systemFont(ofSize: CGFloat(12)))
                return heightT
            }else{
                var heightT : CGFloat = 61;
                
                let bounds = UIScreen.main.bounds
                let width = bounds.size.width //화면 너비
                //let height = bounds.size.height //화면 높이
                //74 를 뺀이유는 스토리보드 컨텐츠 레이블 에서 양쪽 여백 을 더한 숫자다 화면 크기 를 구한다면 양쪽 여백을빼면 실제 콘텐츠 넓이가 나온다
                heightT += m_ListData[indexPath.row]["contents"]!.heightT(withConstrainedWidth: (width - 74), font: UIFont.systemFont(ofSize: CGFloat(12)))
                return heightT
            }
        }
        return 132
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //셀 선택시
        
        self.view.endEditing(true)
//        let Storyboard: UIStoryboard = UIStoryboard(name: "StationDetail", bundle: nil)
//        let viewController = Storyboard.instantiateViewController(withIdentifier: "station_detail") as! StationDetail
//        viewController.modalPresentationStyle = .fullScreen
//        viewController.InitSetting(stuid: m_ListData[indexPath.row][2]);
//        self.navigationController?.pushViewController(viewController, animated: true)
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        var isEditCell : Bool = false;
        if m_ListData.count <= indexPath.row{
            return isEditCell
        }
        
        let m_US = m_ListData[indexPath.row]["account_seq"];
        if m_US == m_sUserSeq{
            isEditCell = true;
        }
        return isEditCell
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "삭제";
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        cellDeleteIndexPath = indexPath
        //let planetToDelete = m_ListData[indexPath.row]
        confirmDelete()
    }

    
    func confirmDelete() {
        if let indexPath = cellDeleteIndexPath {
            LoadingHUD.show()
            JS.ProductCommentDelete(param: ["seq":m_ListData[indexPath.row]["seq"]!], callbackf: ProductCommentDeleteCallback)
            uiCommnetTable.beginUpdates()
            m_ListData.remove(at: indexPath.row)
            uiCommnetTable.deleteRows(at: [indexPath], with: .automatic)
            cellDeleteIndexPath = nil
            uiCommnetTable.endUpdates()
            self.m_nDataCnt -= 1;
            uiCommentCntLabel.text = String(m_nDataCnt).DecimalWon();
        }
    }
    func ProductCommentDeleteCallback(alldata: JSON)->Void {
        
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
        }
        LoadingHUD.hide()
    }
    @objc func onPCPhoto(tapGesture: UITapGestureRecognizer){
        let imgView = tapGesture.view as! UIImageView
        if (imgView.tag >= 0) //Give your image View tag
        {
            m_isUserPZoom.removeFromSuperview()
            self.view.addSubview(m_isUserPZoom)
            var m_tPicArr = [KingfisherSource]();
            var tumpimgcnt = 0;
            for i in 1...2{
                if let imgurl = m_ListData[imgView.tag]["file\(i)"] {
                    if imgurl == "" {
                        continue;
                    }
                    tumpimgcnt += 1;
                    let fm_sUrlS = "\(Single.DE_URLIMGSERVER)\(imgurl)";
                    if let URLString = KingfisherSource(urlString: fm_sUrlS){
                        m_tPicArr.append(URLString)
                    }
                }
            }
            if tumpimgcnt <= 0{
                return;
            }
            m_isUserPZoom.setImageInputs(m_tPicArr)
            let fullScreenController = m_isUserPZoom.presentFullScreenController(from: self)
            fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .medium, color: nil)
        }
        else{

        }
    }
    
}




