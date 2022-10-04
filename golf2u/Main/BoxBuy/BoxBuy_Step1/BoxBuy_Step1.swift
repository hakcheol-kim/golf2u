//
//  BoxBuy_Step1.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/20.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import InfiniteViewSlider
import AdvancedPageControl

class BoxBuy_Step1: UICollectionViewCell {
    public enum SCPageStyle: Int {
        case SCNormal = 100
        case SCJAMoveCircle // Design by Jardson Almeida
        case SCJAFillCircle // Design by Jardson Almeida
        case SCJAFlatBar // Design by Jardson Almeida
    }

    weak var m_tClickEvent: BoxBuyClickCellBtnDelegate? = nil;
    
    @IBOutlet weak var uiMainVIew: InfiniteViewSlider!
    
    private var m_Box_RandomPage : Box_RandomPage?;
    private var m_Box_EventPage : Box_EventPage?;
    
    @IBOutlet var CustomPageControl: AdvancedPageControlView!
    
    @IBOutlet weak var uiPageView: UIView!
    @IBOutlet weak var uiPage1Img: UIImageView!
    @IBOutlet weak var uiPage2Img: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        m_Box_RandomPage = Box_RandomPage(frame: self.bounds);
        m_Box_EventPage = Box_EventPage(frame: self.bounds);
        
        uiPageView.layer.zPosition = 9999;
        
        let indiwhite = UIColor.white
        let indigray = UIColor.lightGray
        let indigrayTrans = UIColor.withAlphaComponent(indigray)(0.5)
        CustomPageControl.drawer = ExtendedDotDrawer(numberOfPages: 2,
                                                     height: 10.0, width:10.0, space: 6.0,
                                                     indicatorColor: indiwhite,
                                                     dotsColor: indigrayTrans,
                                                     isBordered: false,
                                                     borderWidth: 0.0,
                                                     indicatorBorderColor: .clear,
                                                     indicatorBorderWidth: 0.0
        )
        CustomPageControl.layer.zPosition = 9999;
        
        
    }
    func setData(data : [String : String]){
        m_Box_RandomPage!.m_tClickEvent = m_tClickEvent;
        m_Box_EventPage!.m_tClickEvent = m_tClickEvent;
        m_Box_RandomPage!.setData(data: data)
        m_Box_EventPage!.setData(data: data)
        
        if data["eventbox_open"] == "0" {
            //uiPageView.isHidden = true;
            CustomPageControl.isHidden = true;
            uiMainVIew.slidingSubviews = [m_Box_RandomPage!]
        }else{
            //uiPageView.isHidden = false;
            CustomPageControl.isHidden = false;
            uiMainVIew.slidingSubviews = [m_Box_RandomPage!, m_Box_EventPage!]
        }
        uiMainVIew.delegate = self
        
        uiMainVIew.isAutoSlideEnabled = false
        uiMainVIew.autoSlideTimeInterval = 1.0
        
    }

}
extension BoxBuy_Step1: InfiniteViewSliderDelegate {
    
  func sliderDidSlide(_ slider: InfiniteViewSlider, progress: Double, numberOfViews: Int, currentViewIndex: Int) {
//    let bounds = UIScreen.main.bounds
//    let profilewidth = bounds.size.width
    CustomPageControl.setPageOffset(CGFloat(progress))
    if progress == 0.0 {
//        uiPage1Img.image = UIImage(named: "boxbuy_Rolling_on")
//        uiPage2Img.image = UIImage(named: "boxbuy_Rolling_off")
        m_tClickEvent?.HeaderSliderEvent(pageidx: 0)
    }else if progress == 1.0 {
//        uiPage1Img.image = UIImage(named: "boxbuy_Rolling_off")
//        uiPage2Img.image = UIImage(named: "boxbuy_Rolling_on")
        m_tClickEvent?.HeaderSliderEvent(pageidx: 1)
    }else{
    
    }
  }
}
