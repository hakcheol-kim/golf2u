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
        uiBannerIMg.image = m_tGifBanner[m_nLandomBanneridx]
        uiSlideLabel.text = m_sStrSlider;
    
        
        self.uiSlideLabel.type = .continuous
        self.uiSlideLabel.speed = .duration(8)
        self.uiSlideLabel.animationDelay = 0.0
        //self.uiSlideLabel.animationCurve = .easeInOut
        self.uiSlideLabel.lineBreakMode = .byTruncatingTail
        self.uiSlideLabel.textAlignment = .center
        self.uiSlideLabel.fadeLength = 0.0
        self.uiSlideLabel.leadingBuffer = self.frame.width
        self.uiSlideLabel.trailingBuffer = self.frame.width
        
        let gradi = CAGradientLayer()
        gradi.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: uiLabelView.frame.height);
        gradi.colors = [UIColor(rgb: 0x00BA87).cgColor, UIColor(rgb: 0x00BA87).cgColor]
        gradi.startPoint = CGPoint(x: 0, y: 0.5)
        gradi.endPoint = CGPoint(x: 1, y: 0.5)
        uiLabelView.layer.addSublayer(gradi)
        
        uiSlideLabel.layer.zPosition = 9999;
        
        uiUProfileIMg.setImage(with: "\(Single.DE_URLIMGSERVER)\(profileurl)")
        uiUProductIMg.setImage(with: "\(Single.DE_URLIMGSERVER)\(producturl)")
    }
    
}
