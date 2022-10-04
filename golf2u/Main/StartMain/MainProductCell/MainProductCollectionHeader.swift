//
//  MainProductCollectionHeader.swift
//  golf2u
//
//  Created by 이원영 on 2020/09/24.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import ImageSlideshow
//import SafariServices
protocol ClickBannerDelegate: class {
    func ClickEvent(type:Int, BannerCurrent:Int)
    func ClickFiltter(type:Int)
    func ClickEventMainPopNotice(type:Int, data : [String : String])
}

class MainProductCollectionHeader: UICollectionReusableView {
    weak var m_tClickEvent: ClickBannerDelegate? = nil;
    
    @IBOutlet weak var topBannerView: ImageSlideshow!
    @IBOutlet weak var bottmBannerView: ImageSlideshow!
    
    private var m_TopBanner = Array<[String:String]>();
    private var m_BottomBanner = Array<[String:String]>();
    private var m_TopBannerIS = [KingfisherSource]();
    private var m_BottomBannerIS = [KingfisherSource]();
    @IBOutlet weak var topPageview: UIView!
    @IBOutlet weak var topPageLabel: UILabel!
    @IBOutlet weak var SortBtn: UIButton!
    @IBOutlet weak var uiFiltterBtn: UIButton!
    @IBOutlet weak var uidataCntLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        topPageview.layer.cornerRadius = 10.0
        
        SortBtn.layer.cornerRadius = 5.0
        SortBtn.backgroundColor = .clear
        SortBtn.layer.borderWidth = 1
        SortBtn.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
    }
    func dataCount(cnt : Int){
        uidataCntLabel.text = "전체 개".localized(txt: "\(cnt)");
        uidataCntLabel.TextPartColor(partstr: "\(cnt)", Color: UIColor(rgb: 0x00BA87))
    }
    func setBanner(f_TopBanner : Array<[String:String]>, f_BottomBanner : Array<[String:String]>){
        m_TopBannerIS.removeAll();
        m_BottomBannerIS.removeAll();
        self.m_TopBanner = f_TopBanner;
        self.m_BottomBanner = f_BottomBanner;
        
        
        if m_TopBanner.count <= 0 {
            topPageLabel.text = "0 | \(m_TopBanner.count)";
        }else{
            topPageLabel.text = "1 | \(m_TopBanner.count)";
        }
        
        for banner in self.m_TopBanner{
            let fm_sUrlS = "\(Single.DE_URLIMGSERVER)\(banner["image_url"]!)";
            guard let URLString = KingfisherSource(urlString: fm_sUrlS) else { return; }
            m_TopBannerIS.append(URLString)
        }
        for banner in self.m_BottomBanner{
            let fm_sUrlS = "\(Single.DE_URLIMGSERVER)\(banner["image_url"]!)";
            
            guard let URLString = KingfisherSource(urlString: fm_sUrlS) else { return; }
            m_BottomBannerIS.append(URLString)
        }
        
        topBannerView.contentScaleMode = UIViewContentMode.scaleToFill
        topBannerView.slideshowInterval = 3.0
        //topBannerView.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
        bottmBannerView.pageIndicatorPosition = PageIndicatorPosition(horizontal: .center, vertical: .bottom)

        //let ToppageControl = UIPageControl()
        //ToppageControl.currentPageIndicatorTintColor = UIColor.black
        //ToppageControl.pageIndicatorTintColor = UIColor.white
        topBannerView.pageIndicator = nil

        topBannerView.activityIndicator = DefaultActivityIndicator()
        topBannerView.delegate = self
        topBannerView.setImageInputs(m_TopBannerIS)
        var recognizer = UITapGestureRecognizer(target: self, action: #selector(MainProductCollectionHeader.didTopBannerTap))
        topBannerView.addGestureRecognizer(recognizer)
        
        
        bottmBannerView.contentScaleMode = UIViewContentMode.scaleToFill
        bottmBannerView.pageIndicatorPosition = PageIndicatorPosition(horizontal: .center, vertical: .bottom)
        bottmBannerView.slideshowInterval = 3.0
        //bottmBannerView.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
        
        let BottompageControl = UIPageControl()
        BottompageControl.currentPageIndicatorTintColor = UIColor.black
        BottompageControl.pageIndicatorTintColor = UIColor.white
        BottompageControl.alpha = 0.5;
        bottmBannerView.pageIndicator = BottompageControl

        bottmBannerView.activityIndicator = DefaultActivityIndicator()
        bottmBannerView.delegate = self
        bottmBannerView.setImageInputs(m_BottomBannerIS)
        recognizer = UITapGestureRecognizer(target: self, action: #selector(MainProductCollectionHeader.didBottomBannerTap))
        bottmBannerView.addGestureRecognizer(recognizer)
 
        
    }
    @objc func didTopBannerTap() {
        //let fullScreenController = slideshow.presentFullScreenController(from: self)
        // set the activity indicator for full screen controller (skipping the line will show no activity indicator)
        //fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
        
        /*guard let url = m_TopBanner[topBannerView.currentPage]["landing"] else { return }
        guard let urlS = URL(string: url) else { return }
        let safariViewController = SFSafariViewController(url: urlS)
        present(safariViewController, animated: true, completion: nil)*/
        if m_TopBanner.count <= 0 {
            return;
        }
        if let event = m_tClickEvent{
            event.ClickEvent(type: 0, BannerCurrent: topBannerView.currentPage);
        }
        //print("top current page:", topBannerView.currentPage)
    }
    @objc func didBottomBannerTap() {
        if m_BottomBanner.count <= 0 {
            return;
        }
        if let event = m_tClickEvent{
            event.ClickEvent(type: 1, BannerCurrent: bottmBannerView.currentPage);
        }
        //print("bottom current page:", bottmBannerView.currentPage)
    }
    @IBAction func onSortBtn(_ sender: Any) {
        if let event = m_tClickEvent{
            event.ClickFiltter(type: 1)
        }
    }
    @IBAction func onFiltterBtn(_ sender: Any) {
        if let event = m_tClickEvent{
            event.ClickFiltter(type: 2)
        }
    }
    func setSortBtnTxt(msg : String){
        self.SortBtn.setTitle(msg, for: .normal)
    }
}
extension MainProductCollectionHeader: ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        if imageSlideshow == topBannerView{
            topPageLabel.text = "\((page + 1)) | \(m_TopBanner.count)";
        }else if imageSlideshow == bottmBannerView{
            //print("bottom current page:", page)
        }
    }
}
