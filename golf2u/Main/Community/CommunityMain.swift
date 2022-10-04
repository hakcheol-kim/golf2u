//
//  CommunityMain.swift
//  golf2u
//
//  Created by 이원영 on 2020/10/21.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class CommunityMain: VariousViewController {
    private var SO:Single = Single.getSO();
    private let JS = JsonC();
    
    @IBOutlet weak var uiTopTabView: ReportCustomSegmentedControl!{
        didSet{
            uiTopTabView.setButtonTitles(buttonTitles: ["뉴스룸".localized,"위클리 랭킹전".localized])
            uiTopTabView.selectorViewColor = UIColor(rgb: 0x00BA87)
            uiTopTabView.selectorTextColor = UIColor(rgb: 0x00BA87)
            uiTopTabView.textColor = .black
            uiTopTabView.backgroundColor = .white
        }
    }
    @IBOutlet weak var uiContentsView: UIView!
    
    private var m_nSelMenu = 0;
    
    private var  m_tNR : NewsRoom?;
    private var m_tWR : WeeklyRank?;
    
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVIMAINNONELOGOINTITLE, title: "커뮤니티".localized)
        super.viewDidLoad()
        SO.setCommunityMain(fCommunityMain: self)
        uiTopTabView.delegate = self;
        
        //uiTopTabView.layer.addBorder([.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
        m_tNR = NewsRoom(frame: self.uiContentsView.bounds)
        m_tNR?.CellClickHandler = { (type : Int, seq : String)-> Void in
            if type == 0 {
                let Storyboard: UIStoryboard = UIStoryboard(name: "ProductDetail", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "productdetailide") as! ProductDetailNew
                viewController.InitSetting(seq: seq);
                self.navigationController?.pushViewController(viewController, animated: true)
            }else if type == 1{
                let Storyboard: UIStoryboard = UIStoryboard(name: "NewsRoomComment", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "newsroomcommentidx") as! NewsRoomComment
                viewController.setData(my_product_seq: seq)
                self.navigationController?.pushViewController(viewController, animated: true)
            }else if type == 2{
                //프로필 확대
                super.ProfileImagePlus(UserImgUrl: seq)
            }
        }
        m_tWR = WeeklyRank(frame: self.uiContentsView.bounds)
        m_tWR?.WeeklyHeaderBtnClickHandler = { (type : Int, data : String)-> Void in
            if type == 0{
                let Storyboard: UIStoryboard = UIStoryboard(name: "WeeklyRankList", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "weeklyranklistidx") as! WeeklyRankList
                //viewController.setData(my_product_seq: seq)
                self.navigationController?.pushViewController(viewController, animated: true)
            }else if type == 1{
                let Storyboard: UIStoryboard = UIStoryboard(name: "WeeklyRankRule", bundle: nil)
                let viewController = Storyboard.instantiateViewController(withIdentifier: "weeklyrankruleidx") as! WeeklyRankRule
                //viewController.setData(my_product_seq: seq)
                self.navigationController?.pushViewController(viewController, animated: true)
            }else if type == 2{
                super.LoginMove()
            }else if type == 3{
                //프로필 확대
                super.ProfileImagePlus(UserImgUrl: data)
            }
            
        }
        setContentsView(uiView: m_tNR!);
        

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            //탭 인덱스가 화면 로딩후 바로 안떠서 0.3초 정도 딜레이 주고 바꿈
            //앱 첫시작하고 인벤토리를 한번도 안누르면 탭 객체가 없기때문에 인벤토리 이동후
            //해당 생명주기 함수에서 0.3초 정도있다가 싱글톤에 값을 보고 탭을 바꿔줌
            self.goTabIndexCalc();
        }
    }
    func goTabIndexCalc(){
        if SO.getComueTabIdx() == 0 {
            goToNewsRoomView()
        }else if SO.getComueTabIdx() == 1 {
            goToWeeklyView()
        }
        SO.setComueTabIdx(TabbarIndex: -1)
    }
    func goToNewsRoomView(){
        m_nSelMenu = 0;
        self.uiTopTabView.setIndex(index: m_nSelMenu)
        ChnageView()
    }
    func goToWeeklyView(){
        m_nSelMenu = 1;
        self.uiTopTabView.setIndex(index: m_nSelMenu)
        ChnageView()
    }
    func ChnageView(){
        for v in uiContentsView.subviews{
            v.removeFromSuperview()
        }
        if m_nSelMenu == 0 {
            setContentsView(uiView: m_tNR!);
            m_tNR?.refresh()
        }else if m_nSelMenu == 1 {
            setContentsView(uiView: m_tWR!);
            m_tWR?.refresh()
        }
    }
    func LoginResetView(){
        if m_nSelMenu == 1 {
            m_tWR?.refresh()
        }
    }
    func setContentsView(uiView : UIView){
        self.uiContentsView.addSubview(uiView)
        
        uiView.translatesAutoresizingMaskIntoConstraints = false
        uiView.topAnchor.constraint(equalTo: uiContentsView.topAnchor,constant: 0).isActive = true
        uiView.leftAnchor.constraint(equalTo:uiContentsView.leftAnchor,constant: 0).isActive = true
        uiView.rightAnchor.constraint(equalTo: uiContentsView.rightAnchor, constant: 0).isActive = true
        uiView.bottomAnchor.constraint(equalTo: uiContentsView.bottomAnchor, constant: 0).isActive = true
    }
}

extension CommunityMain : ReportCustomSegmentedControlDelegate{
    func changeToIndex(index: Int) {
        if m_nSelMenu == index{
            return;
        }
        m_nSelMenu = index;
        for v in uiContentsView.subviews{
            v.removeFromSuperview()
        }
        if m_nSelMenu == 0 {
            setContentsView(uiView: m_tNR!);
            m_tNR?.refresh()
        }else if m_nSelMenu == 1 {
            setContentsView(uiView: m_tWR!);
            m_tWR?.refresh()
        }
        
        
    }
}
