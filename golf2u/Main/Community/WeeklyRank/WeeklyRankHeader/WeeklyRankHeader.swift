//
//  WeeklyRankHeader.swift
//  golf2u
//
//  Created by 이원영 on 2020/10/23.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import Kingfisher
class WeeklyRankHeader: UICollectionReusableView {
    private let SO = Single.getSO();
    @IBOutlet weak var uiTopView: UIView!
    @IBOutlet weak var uiImage: UIImageView!
    @IBOutlet weak var uiRankLabel: UILabel!
    @IBOutlet weak var uiCloverLabel: UILabel!
    @IBOutlet weak var uiTimerLabel: UILabel!
    @IBOutlet weak var uiRankUpLabel: UILabel!
    @IBOutlet weak var uiRankUpdateDate: UILabel!
    private var mTimer : Timer?
    @IBOutlet weak var uiUProfileIMg: UIImageView!
    private var m_nUserProfileX = 0;
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        uiUProfileIMg.layer.cornerRadius = uiUProfileIMg.frame.height/2
        
        
        
        
        //if let test1 = test.image{
        //uiImage.image = UIImage().imageByCombiningImage(firstImage: UIImage(named: "bg_02.png")!, withImage: test1, seconpoX: -100, seconpoY: -180)
        //}
        
        
    }
    func setBanner(rank : String, clover : String){
        uiRankLabel.text = "위".localized(txt: rank.DecimalWon());
        uiCloverLabel.text = clover.DecimalWon();
        
        if let timer = mTimer {
            //timer 객체가 nil 이 아닌경우에는 invalid 상태에만 시작한다
            if !timer.isValid {
                /** 1초마다 timerCallback함수를 호출하는 타이머 */
                mTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
            }
        }else{
            //timer 객체가 nil 인 경우에 객체를 생성하고 타이머를 시작한다
            /** 1초마다 timerCallback함수를 호출하는 타이머 */
            mTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
        }
        
        uiUProfileIMg.setImage(with: "\(Single.DE_URLIMGSERVER)\(SO.getUserInfoKey(key: "profile_image_url"))")

        let fm_nUserRank = Int(rank) ?? 0
        let fm_nNowRank = SO.getNowRank()
        if fm_nNowRank != 0{
            if fm_nNowRank > fm_nUserRank {
                uiRankUpLabel.text = "랭킹이 계단\n상승했습니다!".localized(txt: "\(fm_nNowRank-fm_nUserRank)")
                
            }else if fm_nNowRank < fm_nUserRank {
                uiRankUpLabel.text = "랭킹이 계단\n하락했습니다.".localized(txt: "\(fm_nUserRank - fm_nNowRank)")
            }else{
                uiRankUpLabel.text = "랭킹을 유지중입니다.\n좀더 힘을내세요!"
            }
        }else{
            uiRankUpLabel.text = "랭킹이 계단\n상승했습니다!".localized(txt: "\(Single.DE_DEFAULTRANK-fm_nUserRank)")
        }
        SO.setNowRank(rank: fm_nUserRank)
        
        
        let NowDate = DateFormatter()
        NowDate.locale = Locale(identifier: "ko_KR")
        NowDate.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let fm_sNowDate = NowDate.string(from: Date());
        uiRankUpdateDate.text = """
            랭킹 업데이트 시간
            \(fm_sNowDate)
            """
    }
    @objc func timerCallback(){
        let NowDate = DateFormatter()
        NowDate.locale = Locale(identifier: "ko_KR")
        NowDate.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let fm_sNowDate = NowDate.string(from: Date());
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "KST") as TimeZone?
        
        let fm_tNowDate:Date = dateFormatter.date(from: fm_sNowDate)!
        
        let cal = Calendar(identifier: .gregorian)
        let comps = cal.dateComponents([.weekday], from: fm_tNowDate)
        let nowWeek : Int = ((9 - comps.weekday!));
        
        var dateComponent = DateComponents()
        dateComponent.day = nowWeek
        let endDate = Calendar.current.date(byAdding: dateComponent, to: fm_tNowDate)
        
        
        
        let calendar = Calendar.current
        let enddateYear = calendar.component(.year, from: endDate!)
        let enddateMonth = calendar.component(.month, from: endDate!)
        let enddateDay = calendar.component(.day, from: endDate!)
        let date:Date = dateFormatter.date(from: "\(enddateYear)-\(enddateMonth)-\(enddateDay) 00:00:1")!
        
        let dateGap = calendar.dateComponents([.day,.hour,.minute,.second], from: fm_tNowDate, to: date)
        if case let (d?, h?, mm1?, ss1?) = (dateGap.day, dateGap.hour, dateGap.minute, dateGap.second)
        {
            self.uiTimerLabel.text = "\(d)D \(h):\(mm1):\(ss1)"
        }
    }
}
