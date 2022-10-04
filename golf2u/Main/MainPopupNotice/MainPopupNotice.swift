//
//  MainPopup.swift
//  golf2u
//
//  Created by 이원영 on 2020/12/08.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import InfiniteViewSlider
import SafariServices

class MainPopupNotice: VariousViewController {
    weak var m_tClickEvent: ClickBannerDelegate? = nil;
    private let SO = Single.getSO();
    private let JS = JsonC();
    
    @IBOutlet weak var uiSliderView: InfiniteViewSlider!
    
    @IBOutlet weak var uiViewPageCon: UIPageControl!
    @IBOutlet weak var uiNotTodayBtn: UIButton!
    @IBOutlet weak var uiAccBtn: UIButton!
    
    private var m_ArrData = Array<[String : String]>();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiNotTodayBtn.setTitle("오늘 그만 보기".localized, for: .normal)
        uiAccBtn.setTitle("확인".localized, for: .normal)

        m_ArrData = SO.getMainPop()
        
        var fm_tViews = [UIView]();
        for (i, v) in m_ArrData.enumerated(){
            let fm_tItem = MainPopupNoticeItem(frame: self.uiSliderView.bounds);
            fm_tItem.uiImg.tag = i;
            fm_tItem.uiImg.isUserInteractionEnabled = true
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(MainPopupNotice.didBannerTap(tapGesture:)))
            fm_tItem.uiImg.addGestureRecognizer(recognizer)
            fm_tItem.setData(data: v, row: i)
            fm_tViews.append(fm_tItem)
        }
        uiSliderView.slidingSubviews = fm_tViews
        uiSliderView.delegate = self
        uiSliderView.isAutoSlideEnabled = false
        uiSliderView.autoSlideTimeInterval = 1.0
        
        //페이지 컨트롤의 전체 페이지를 images 배열의 전체 개수 값으로 설정
        uiViewPageCon.numberOfPages = fm_tViews.count
        // 페이지 컨트롤의 현재 페이지를 0으로 설정
        uiViewPageCon.currentPage = 0
        // 페이지 표시 색상을 밝은 회색 설정
        uiViewPageCon.pageIndicatorTintColor = UIColor.lightGray
        // 현재 페이지 표시 색상을 검정색으로 설정
        uiViewPageCon.currentPageIndicatorTintColor = UIColor.white
        
        uiViewPageCon.layer.zPosition = 9999;
        
        uiViewPageCon.alpha = 0.5;
    }
    static func instantiate() -> MainPopupNotice? {
        return UIStoryboard(name: "MainPopupNotice", bundle: nil).instantiateViewController(withIdentifier: "\(MainPopupNotice.self)") as? MainPopupNotice
    }
    @objc func didBannerTap(tapGesture: UITapGestureRecognizer) {
        let imgView = tapGesture.view as! UIImageView
        dismiss(animated: true, completion: nil)
        m_tClickEvent?.ClickEventMainPopNotice(type : 0, data: m_ArrData[imgView.tag])
    }
    @IBAction func onDayBtn(_ sender: Any) {
        let date:Date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString:String = dateFormatter.string(from: date)
        UserDefaults.standard.set(dateString, forKey: Single.DE_MAINPOPUP)
        m_tClickEvent?.ClickEventMainPopNotice(type : 1, data: [:])
        dismiss(animated: true, completion: nil)
    }
    @IBAction func onAccBtn(_ sender: Any) {
        m_tClickEvent?.ClickEventMainPopNotice(type : 1, data: [:])
        dismiss(animated: true, completion: nil)
    }
    
}
extension MainPopupNotice: InfiniteViewSliderDelegate {
  func sliderDidSlide(_ slider: InfiniteViewSlider, progress: Double, numberOfViews: Int, currentViewIndex: Int) {
//    if progress == 0.0 {
//    }else if progress == 1.0 {
//    }
    uiViewPageCon.currentPage = currentViewIndex
  }
}
