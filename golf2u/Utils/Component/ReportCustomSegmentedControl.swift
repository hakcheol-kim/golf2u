//
//  CustomSegmentedControl.swif
//
//
//  Created by Bruno Faganello on 05/07/18.
//  Copyright © 2018 Code With Coffe . All rights reserved.
//

import UIKit
protocol ReportCustomSegmentedControlDelegate:class {
    func changeToIndex(index:Int)
}

class ReportCustomSegmentedControl: UIView {
    private var buttonTitles:[String]!
    private var buttons: [UIButton]!
    private var selectorView: UIView!
    
    var textColor:UIColor = .gray
    var selectorViewColor: UIColor = .white
    var selectorTextColor: UIColor = .white
    
    private var m_selectorPosition : CGFloat = 0.0//화면이 새로고침되면 draw 가 발생되서 탭이 첨으로 돌아가는걸 방지하기위해마지막 클릭한곳 저장
    
    weak var delegate:ReportCustomSegmentedControlDelegate?
    
    public private(set) var seletedIndex : Int = 0
    //private var seletedIndex = 0;
    
    convenience init(frame:CGRect,buttonTitle:[String]) {
        self.init(frame: frame)
        self.buttonTitles = buttonTitle
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.backgroundColor = UIColor.white
        updateView()
    }
    
    func setButtonTitles(buttonTitles:[String]) {
        self.buttonTitles = buttonTitles
        self.updateView()
    }
    
    func setIndex(index:Int) {
        buttons.forEach({ $0.setTitleColor(textColor, for: .normal) })
        let button = buttons[index]
        seletedIndex = index
        button.setTitleColor(selectorTextColor, for: .normal)
        let selectorPosition = frame.width/CGFloat(buttonTitles.count) * CGFloat(index)
        UIView.animate(withDuration: 0.2) {
            self.selectorView.frame.origin.x = selectorPosition
        }
    }
    
    @objc func buttonAction(sender:UIButton) {
        for (buttonIndex, btn) in buttons.enumerated() {
            btn.setTitleColor(textColor, for: .normal)
            if btn == sender {
                m_selectorPosition = frame.width/CGFloat(buttonTitles.count) * CGFloat(buttonIndex)
                seletedIndex = buttonIndex
                delegate?.changeToIndex(index: seletedIndex)
                UIView.animate(withDuration: 0.3) {
                    self.selectorView.frame.origin.x = self.m_selectorPosition
                }
                btn.setTitleColor(selectorTextColor, for: .normal)
            }
        }
    }
}

//Configuration View
extension ReportCustomSegmentedControl {
    private func updateView() {
        createButton()
        configSelectorView()
        configStackView()
    }
    
    private func configStackView() {
        let stack = UIStackView(arrangedSubviews: buttons)
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stack.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        stack.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        stack.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }
    
    private func configSelectorView() {
        let selectorWidth = frame.width / CGFloat(self.buttonTitles.count)
        selectorView = UIView(frame: CGRect(x: m_selectorPosition, y: self.frame.height, width: selectorWidth, height: 2))
        selectorView.backgroundColor = selectorViewColor
        addSubview(selectorView)
    }
    
    private func createButton() {
        buttons = [UIButton]()
        buttons.removeAll()
        subviews.forEach({$0.removeFromSuperview()})
        for buttonTitle in buttonTitles {
            let button = UIButton(type: .system)
            button.setTitle(buttonTitle, for: .normal)
            button.addTarget(self, action:#selector(ReportCustomSegmentedControl.buttonAction(sender:)), for: .touchUpInside)
            button.setTitleColor(textColor, for: .normal)
            button.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 14)
            buttons.append(button)
        }
        buttons[seletedIndex].setTitleColor(selectorTextColor, for: .normal)
    }
    
    
}
