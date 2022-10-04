//
//  TradeMain.swift
//  golf2u
//
//  Created by 이원영 on 2020/10/15.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import SideMenu
import SwiftyJSON
import Toast_Swift

class TradeMain: VariousViewController {
    private var SO:Single = Single.getSO();
    private let JS = JsonC();
    
    @IBOutlet weak var uiSearchSubBtn: UIImageView!
    @IBOutlet weak var uiSearchInput: UITextField!
    @IBOutlet weak var uiSearchNBtn: UIButton!
    
    private var m_ProductListView : ProductList?;
    private var m_MemberListView : MemberList?;
    
    private var m_nSelMenu = 0;
    
    @IBOutlet weak var uiTopTabView: ReportCustomSegmentedControl!{
        didSet{
            uiTopTabView.setButtonTitles(buttonTitles: ["상품".localized,"회원".localized])
            uiTopTabView.selectorViewColor = UIColor(rgb: 0x00BA87)
            uiTopTabView.selectorTextColor = UIColor(rgb: 0x00BA87)
            uiTopTabView.textColor = .black
            uiTopTabView.backgroundColor = .white
        }
    }
    
    @IBOutlet weak var uiContentsView: UIView!
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVIMAINNONELOGOINTITLE, title: "트레이드".localized)
        super.viewDidLoad()
        
        SO.setTradeMain(fTradeMain: self)
        
        uiTopTabView.delegate = self;
        //uiTopTabView.layer.addBorder([.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
        m_ProductListView = ProductList(frame: self.uiContentsView.bounds)
        m_MemberListView = MemberList(frame: self.uiContentsView.bounds)
        setContentsView(uiView: m_ProductListView!);
        
        m_ProductListView?.ItemCellClick = self;
        m_MemberListView?.ItemCellClick = self;
        
        uiSearchNBtn.setTitle("검색어를 입력해주세요.".localized, for: .normal)
        uiSearchNBtn.layer.cornerRadius = 8.0;
        uiSearchNBtn.layer.borderWidth = 1.0
        uiSearchNBtn.layer.borderColor = UIColor(rgb: 0xe4e4e4).cgColor
        
        uiSearchInput.addTarget(self, action: #selector(onSearchInput), for: .touchDown)
        
        if m_nSelMenu == 0{
            uiSearchNBtn.setTitle(getTradePSearchKeyword(), for: .normal)
            //uiSearchInput.text = SO.getTradePSearchKeyword()
        }else if m_nSelMenu == 1 {
            uiSearchNBtn.setTitle(getTradeMSearchKeyword(), for: .normal)
            //uiSearchInput.text = SO.getTradeMSearchKeyword()
        }
        
    }
    func getTradePSearchKeyword()->String{
        return SO.getTradePSearchKeyword() == "" ? "검색어를 입력해주세요.".localized : SO.getTradePSearchKeyword();
    }
    func getTradeMSearchKeyword()->String{
        return SO.getTradeMSearchKeyword() == "" ? "검색어를 입력해주세요.".localized : SO.getTradeMSearchKeyword();
    }
    @IBAction func onGoSearchBtn(_ sender: Any) {
        let Storyboard: UIStoryboard = UIStoryboard(name: "TradeSearchMain", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "tradesearchmainidx") as! TradeSearchMain
        viewController.ViewType(type: m_nSelMenu)
        viewController.onSearchbtnHandler = { (menu : Int)-> Void in
            self.uiTopTabView.setIndex(index: menu)
            self.changeToIndex(index: menu)
            self.onSearchBtn();
        }
        
        self.navigationController?.pushViewController(viewController, animated: true)
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
        if SO.getTradeTabIdx() == 0 {
            goToProductView()
        }else if SO.getTradeTabIdx() == 1 {
            goToMemberView()
        }
        SO.setTradeTabIdx(TabbarIndex: -1)
    }
    func goToProductView(){
        m_nSelMenu = 0;
        self.uiTopTabView.setIndex(index: m_nSelMenu)
        ChnageView()
    }
    func goToMemberView(){
        m_nSelMenu = 1;
        self.uiTopTabView.setIndex(index: m_nSelMenu)
        ChnageView()
    }
    func ChnageView(){
        for v in uiContentsView.subviews{
            v.removeFromSuperview()
        }
        if m_nSelMenu == 0 {
            setContentsView(uiView: m_ProductListView!);
            ReflashView()
        }else if m_nSelMenu == 1 {
            setContentsView(uiView: m_MemberListView!);
            ReflashView()
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
    @objc func onSearchInput(textField: UITextField){
        let Storyboard: UIStoryboard = UIStoryboard(name: "TradeSearchMain", bundle: nil)
        let viewController = Storyboard.instantiateViewController(withIdentifier: "tradesearchmainidx") as! TradeSearchMain
        viewController.ViewType(type: m_nSelMenu)
        viewController.onSearchbtnHandler = { (menu : Int)-> Void in
            self.uiTopTabView.setIndex(index: menu)
            self.changeToIndex(index: menu)
            self.onSearchBtn();
        }
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    func ReflashView(){
        if m_nSelMenu == 0 {
            m_ProductListView?.refresh();
        }else if m_nSelMenu == 1 {
            m_MemberListView?.refresh();
        }
    }
    func onSearchBtn(){
        if m_nSelMenu == 0 {
            //uiSearchInput.text = SO.getTradePSearchKeyword()
            uiSearchNBtn.setTitle(getTradePSearchKeyword(), for: .normal)
            //m_ProductListView?.refresh();
        }else if m_nSelMenu == 1 {
            uiSearchNBtn.setTitle(getTradeMSearchKeyword(), for: .normal)
            //uiSearchInput.text = SO.getTradeMSearchKeyword()
            //m_MemberListView?.refresh();
        }
        ReflashView()
    }
}
extension TradeMain : ReportCustomSegmentedControlDelegate{
    func changeToIndex(index: Int) {
        if m_nSelMenu == index{
            return;
        }
        m_nSelMenu = index;
        for v in uiContentsView.subviews{
            v.removeFromSuperview()
        }
        if m_nSelMenu == 0 {
            uiSearchNBtn.setTitle(getTradePSearchKeyword(), for: .normal)
            //uiSearchInput.text = SO.getTradePSearchKeyword()
            setContentsView(uiView: m_ProductListView!);
        }else if m_nSelMenu == 1 {
            uiSearchNBtn.setTitle(getTradeMSearchKeyword(), for: .normal)
            //uiSearchInput.text = SO.getTradeMSearchKeyword()
            setContentsView(uiView: m_MemberListView!);
        }
        ReflashView()
    }
}
extension TradeMain: ItemCellClickDelegate {
    func onItemClick(type : Int, Seq : String){
        if type == 0 {
            let Storyboard: UIStoryboard = UIStoryboard(name: "ProductMemberList", bundle: nil)
            let viewController = Storyboard.instantiateViewController(withIdentifier: "productmemberlistidx") as! ProductMemberList
            viewController.setPSeq(f_sPSeq: Seq)
            self.navigationController?.pushViewController(viewController, animated: true)
        }else if type == 1 {
            if super.getUserSeq() == "" {
                //self.view.makeToast("로그인 후 이용해주세요.", duration: 1.0, position: .bottom)
                super.LoginMove()
                return;
            }
            let Storyboard: UIStoryboard = UIStoryboard(name: "TradeApply", bundle: nil)
            let viewController = Storyboard.instantiateViewController(withIdentifier: "tradeapplyidx") as! TradeApply
            viewController.setData(selUSeq: Seq, selPSeq: "");                   
            self.navigationController?.pushViewController(viewController, animated: true)
        }else if type == 3 {
            //상품 검색 초기화
            onSearchBtn()
        }else if type == 4 {
            //멤버 검색 초기화
            onSearchBtn()
        }else if type == 5 {
            //상대방이 나를 블랙리스트를함
            MessagePop(msg: "트레이드가 불가능한 회원입니다".localized, btntype : 2);
        }
    }
}
