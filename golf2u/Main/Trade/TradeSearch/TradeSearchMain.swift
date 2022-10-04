//
//  TradeSearchMain.swift
//  golf2u
//
//  Created by 이원영 on 2020/10/16.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class TradeSearchMain: VariousViewController {
    public var onSearchbtnHandler: ((Int)->())?//클로저
    private let SO = Single.getSO();
    @IBOutlet weak var uiTopTabView: ReportCustomSegmentedControl!{
        didSet{
            uiTopTabView.setButtonTitles(buttonTitles: ["상품 검색".localized,"회원 검색".localized])
            uiTopTabView.selectorViewColor = UIColor(rgb: 0x00BA87)
            uiTopTabView.selectorTextColor = UIColor(rgb: 0x00BA87)
            uiTopTabView.textColor = .black
            uiTopTabView.backgroundColor = .white
        }
    }
    
    @IBOutlet weak var uiSearchBtn: UIButton!
    @IBOutlet weak var uiContentsView: UIView!
    @IBOutlet weak var uiImgSearchBtn: UIImageView!
    
    private var m_nSelMenu = 0;
    
    private var m_ProductListView : TradeSearchProduct?;
    private var m_MemberListView : TradeSearchMember?;
    @IBOutlet weak var uiKeyword: UITextField!{
        didSet {
            uiKeyword?.addCancelToolbar(onDone: (target: self, action: #selector(doneButtonTappedForMyNumericTextField)))
        }
    }
    
    private var m_nViewType : Int = 0;
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "트레이드검색".localized)
        super.viewDidLoad()
        
        uiSearchBtn.setTitle("검색하기".localized, for: .normal)
        
        uiTopTabView.delegate = self;
        //uiTopTabView.layer.addBorder([.bottom], color: UIColor(rgb: 0xe4e4e4), width: 1.0)
        
        let tapGestureRecognizer1 = UITapGestureRecognizer(target:self, action: #selector(self.onImgSearchBtn(tapGesture:)))
        tapGestureRecognizer1.numberOfTapsRequired = 1
        uiImgSearchBtn.isUserInteractionEnabled = true
        uiImgSearchBtn.addGestureRecognizer(tapGestureRecognizer1)
        
        m_ProductListView = TradeSearchProduct(frame: self.uiContentsView.bounds)
        m_MemberListView = TradeSearchMember(frame: self.uiContentsView.bounds)
        
        setContentsView(uiView: m_ProductListView!);
        
        self.uiKeyword.returnKeyType = .done;
        self.uiKeyword.delegate = self;
        if m_nSelMenu == 0{
            self.uiKeyword.text = SO.getTradePSearchKeyword();
        }else if m_nSelMenu == 1 {
            self.uiKeyword.text = SO.getTradeMSearchKeyword();
        }
        
        self.uiKeyword.becomeFirstResponder()//텍스트필드에 포커스
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    @objc func doneButtonTappedForMyNumericTextField() {
        self.view.endEditing(true)
    }
    func ViewType(type : Int){
        self.m_nViewType = type;
        self.m_nSelMenu = type;
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            //탭 인덱스가 화면 로딩후 바로 안떠서 0.3초 정도 딜레이 주고 바꿈
            self.uiTopTabView.setIndex(index: self.m_nViewType)
            if self.m_nViewType == 0 {
                self.setContentsView(uiView: self.m_ProductListView!);
            }else if self.m_nViewType == 1 {
                self.setContentsView(uiView: self.m_MemberListView!);
            }
        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            self.uiKeyword.becomeFirstResponder()
//        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if #available(iOS 11.0, *) {
            if (UIDevice.current.hasNotch) {
                //아이폰x 부터 하단 safe 영역 버튼이 있으면 여기서 처리
                //let topPadding = self.view.safeAreaInsets.top
                //let leftPadding = self.view.safeAreaInsets.left
                //let rightPadding = self.view.safeAreaInsets.right
                let bottomPadding = self.view.safeAreaInsets.bottom;
                uiSearchBtn.frame = CGRect(x: 0, y: Int(uiSearchBtn.frame.minY), width: Int(uiSearchBtn.frame.size.width), height: Int(uiSearchBtn.frame.size.height + bottomPadding))
                uiSearchBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
            }

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
    @objc func onImgSearchBtn(tapGesture: UITapGestureRecognizer){
        SearchCalc()
    }
    @IBAction func onSearchBtn(_ sender: Any) {
        SearchCalc()
    }
    func SearchCalc(){
        let keyword = uiKeyword.text!;
        if m_nSelMenu == 0{
            SO.setTradePSearchKeyword(keyword: keyword)
        }else{
            SO.setTradeMSearchKeyword(keyword: keyword)
        }
        onSearchbtnHandler?(m_nSelMenu)
        self.navigationController?.popViewController(animated: true)
    }

}
extension TradeSearchMain : ReportCustomSegmentedControlDelegate{
    func changeToIndex(index: Int) {
        if m_nSelMenu == index{
            return;
        }
        m_nSelMenu = index;
        for v in uiContentsView.subviews{
            v.removeFromSuperview()
        }
        if m_nSelMenu == 0 {
            self.uiKeyword.text = SO.getTradePSearchKeyword();
            setContentsView(uiView: m_ProductListView!);
        }else if m_nSelMenu == 1 {
            self.uiKeyword.text = SO.getTradeMSearchKeyword();
            setContentsView(uiView: m_MemberListView!);
        }
        
    }
}

extension TradeSearchMain : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        SearchCalc()
        return false
    }
}
