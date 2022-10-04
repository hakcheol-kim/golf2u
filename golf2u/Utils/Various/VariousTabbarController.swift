//
//  VariousTabbarController.swift
//  golf2u
//
//  Created by 이원영 on 2020/10/26.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit

class VariousTabbarController: UITabBarController {
    private var SO:Single = Single.getSO();
    
    private var m_sUserSeq = "";

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func LoginMove(){
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "LoginMg", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginView") as! UINavigationController
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true, completion: nil)
        //self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func getUserSeq() -> String{
        m_sUserSeq = SO.getUserInfoKey(key: "seq");
        return m_sUserSeq;
    }
}
