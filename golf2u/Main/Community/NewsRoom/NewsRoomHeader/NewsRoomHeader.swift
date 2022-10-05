//
//  NewsRoomHeader.swift
//  golf2u
//
//  Created by 이원영 on 2020/10/22.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import MarqueeLabel
import Kingfisher

class NewsRoomHeader: UICollectionReusableView {
    private let SO = Single.getSO();
    @IBOutlet weak var uiBannerIMg: UIImageView!
    @IBOutlet weak var uiLabelView: UIView!
    @IBOutlet weak var uiSlideLabel: MarqueeLabel!
    //@IBOutlet weak var uiSlideLabel: UILabel!
    
    @IBOutlet weak var uiUProfileIMg: UIImageView!
    @IBOutlet weak var uiUProductIMg: UIImageView!
    private var m_nUserProfileX = 0;
    
    private var m_sTopBannerUrl = "";
    private var m_sStrSlider = "";
    private var m_nLandomBanneridx = 0;
    
//    private var m_tGifBanner  = [UIImage.gif(name: "Community_newsroom_01"), UIImage.gif(name: "Community_newsroom_02"), UIImage.gif(name: "Community_newsroom_03"), UIImage.gif(name: "Community_newsroom_04")]
    private var m_tGifBanner  = [UIImage.gif(name: "Community_newsroom_04")]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        uiUProfileIMg.layer.cornerRadius = uiUProfileIMg.frame.height/2
        uiUProductIMg.layer.cornerRadius = 8
        
        
    }
    func setBanner(topurl : String, slidertxt : String, producturl : String, profileurl : String){
        m_sTopBannerUrl = topurl;
        m_sStrSlider = slidertxt;
        //uiBannerIMg.kf.setImage(with: URL(string: "\(Single.DE_URLIMGSERVER)\(m_sTopBannerUrl)"))
       
//        repeat{
////            let fm_nLandomBanneridx = Int(arc4random_uniform(4));
////            if fm_nLandomBanneridx == m_nLandomBanneridx {
////
////            }else{
////                m_nLandomBanneridx = fm_nLandomBanneridx;
////                break;
////            }
//        }while true
        uiBannerIMg.image = m_tGifBanner[m_nLandomBanneridx]
        uiSlideLabel.text = m_sStrSlider;
        //uiSlideLabel.lineBreakMode = .byWordWrapping
        //uiSlideLabel.numberOfLines = 0
        //uiSlideLabel.translatesAutoresizingMaskIntoConstraints = true
        //uiSlideLabel.sizeToFit()
//        uiSlideLabel.leftAnchor.constraint(equalTo: self.uiLabelView.leftAnchor, constant: 8).isActive = true
//        uiSlideLabel.topAnchor.constraint(equalTo: uiLabelView.topAnchor, constant: 8).isActive = true
//        uiSlideLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        //DispatchQueue.main.async(execute: {
//            UIView.animate(withDuration: 7, delay: 0.0, options: ([.curveLinear, .repeat]), animations: {() -> Void in
//
//                self.uiSlideLabel.center = CGPoint(x:  self.frame.width - (self.uiSlideLabel.frame.width * 2), y: self.uiSlideLabel.center.y + 2)
//
//            }, completion:  nil)
        //})
        
        self.uiSlideLabel.type = .continuous
        self.uiSlideLabel.speed = .duration(8)
        self.uiSlideLabel.animationDelay = 0.0
        //self.uiSlideLabel.animationCurve = .easeInOut
        self.uiSlideLabel.lineBreakMode = .byTruncatingTail
        self.uiSlideLabel.textAlignment = .center
        self.uiSlideLabel.fadeLength = 0.0
        self.uiSlideLabel.leadingBuffer = self.frame.width
        self.uiSlideLabel.trailingBuffer = self.frame.width
        //self.uiSlideLabel.holdScrolling = true;
        //self.uiSlideLabel.restartLabel()
        
//        demoLabel2.tag = 201
//                demoLabel2.type = .continuousReverse
//                demoLabel2.textAlignment = .right
//                demoLabel2.lineBreakMode = .byTruncatingHead
//                demoLabel2.speed = .duration(8.0)
//                demoLabel2.fadeLength = 15.0
//                demoLabel2.leadingBuffer = 40.0
//        demoLabel4.tapToScroll = true
        
        
        let gradi = CAGradientLayer()
        gradi.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: uiLabelView.frame.height);
        gradi.colors = [UIColor(rgb: 0x00BA87).cgColor, UIColor(rgb: 0x00BA87).cgColor]
        gradi.startPoint = CGPoint(x: 0, y: 0.5)
        gradi.endPoint = CGPoint(x: 1, y: 0.5)
        uiLabelView.layer.addSublayer(gradi)
        
        uiSlideLabel.layer.zPosition = 9999;
        
//        let bounds = UIScreen.main.bounds
//        let profilewidth = bounds.size.width
//        //let heighttt =  41 - (160 - 187.5) / 2 ;
//        let profileheightt = 57.0 * (profilewidth / 320) + (160 - (187.5 * (profilewidth / 320))) / 2;
//        uiUProfileIMg.setImage(with: "\(Single.DE_URLIMGSERVER)\(profileurl)")
//        uiUProfileIMg.frame = CGRect(x: 216 * (profilewidth/320), y:  profileheightt, width: uiUProfileIMg.frame.width, height: uiUProfileIMg.frame.height);
//        //print(uiBannerIMg.contentClippingRect.height)
//        //({아이폰8 프로필 위에서부터 위치} - ({파란영역높이} - {아이폰8이미지세로높이})/2) * (profilewidth/{아이폰8이미지가로너비}) + ({파란영역높이} - ({아이폰8이미지세로높이} * (profilewidth/{아이폰8이미지가로너비})))/2
//
//
//
//        //let heighttt =  27 - (160 - 187.5) / 2 ;
//        let productheightt = 50 * (profilewidth / 320) + (160 - (187.5 * (profilewidth / 320))) / 2;
//        uiUProductIMg.setImage(with: "\(Single.DE_URLIMGSERVER)\(producturl)")
//        uiUProductIMg.frame = CGRect(x: 150 * (profilewidth/320), y:  productheightt, width: uiUProfileIMg.frame.width, height: uiUProfileIMg.frame.height);
        let bounds = UIScreen.main.bounds
        let profilewidth = bounds.size.width
        
        let fm_nProfPointBX = 252 * (profilewidth / 375)
        let fm_nProfPointBY = 50 * (profilewidth / 375)
        uiUProfileIMg.setImage(with: "\(Single.DE_URLIMGSERVER)\(profileurl)")
        uiUProfileIMg.frame = CGRect(x: fm_nProfPointBX, y:  fm_nProfPointBY, width: uiUProfileIMg.frame.width, height: uiUProfileIMg.frame.height);
        
        
        let fm_nProdPointBX = 166 * (profilewidth / 375)
        let fm_nProdPointBY = 36 * (profilewidth / 375)
        uiUProductIMg.setImage(with: "\(Single.DE_URLIMGSERVER)\(producturl)")
        uiUProductIMg.frame = CGRect(x: fm_nProdPointBX, y:  fm_nProdPointBY, width: uiUProductIMg.frame.width, height: uiUProductIMg.frame.height);
        
        //let heighttt =  75 - (239 - 187.5) / 2 ;
//        let profileheightt = 39.45 * (profilewidth / 375) + (239 - (187.5 * (profilewidth / 375))) / 2;
//        uiUProfileIMg.setImage(with: "\(Single.DE_URLIMGSERVER)\(profileurl)")
//        uiUProfileIMg.frame = CGRect(x: 253 * (profilewidth/375), y:  profileheightt, width: uiUProfileIMg.frame.width, height: uiUProfileIMg.frame.height);
        
        
        //let heighttt =  55 - (239 - 187.5) / 2 ;
//        let productheightt = 34 * (profilewidth / 375) + (239 - (187.5 * (profilewidth / 375))) / 2;
//        uiUProductIMg.setImage(with: "\(Single.DE_URLIMGSERVER)\(producturl)")
//        uiUProductIMg.frame = CGRect(x: 178 * (profilewidth/375), y:  productheightt, width: uiUProfileIMg.frame.width, height: uiUProfileIMg.frame.height);

    }
    
}
