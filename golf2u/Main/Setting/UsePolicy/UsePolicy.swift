//
//  UsePolicy.swift
//  golf2u
//
//  Created by 이원영 on 2020/12/04.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import WebKit

class UsePolicy: VariousViewController, WKUIDelegate, WKNavigationDelegate {

    @IBOutlet weak var uiTopTabView: ReportCustomSegmentedControl!{
        didSet{
            uiTopTabView.setButtonTitles(buttonTitles: ["이용약관".localized,"개인정보처리방침".localized])
            uiTopTabView.selectorViewColor = UIColor(rgb: 0x00BA87)
            uiTopTabView.selectorTextColor = UIColor(rgb: 0x00BA87)
            uiTopTabView.textColor = .black
            uiTopTabView.backgroundColor = .white
        }
    }
    private var m_nSelMenu = 0;
    private var webview: WKWebView!
    private let m_sUserAgent : String = "Version/8.0.2 Safari/600.2.5"
    private var m_sUrl = "";
    private var m_sUrlStep1 : String = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Policy/Policy";
    private var m_sUrlStep2 : String = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Policy/Privacy";
    private var m_sTitle : String = "";
    @IBOutlet weak var uiLoading: UIActivityIndicatorView!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = m_sTitle
        
        uiTopTabView.delegate = self;
        
        let contentController = WKUserContentController()
        contentController.add(self, name: "iosrandom2u")
        
        let userScript = WKUserScript(source: "initIOSNative()", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        contentController.addUserScript(userScript)
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = contentController
        configuration.applicationNameForUserAgent = m_sUserAgent
        
        webview = WKWebView(frame: view.frame, configuration: configuration)
        webview.uiDelegate = self
        webview.navigationDelegate = self
        webview.backgroundColor = .black;
        
        
        self.view.addSubview(webview)
        
        if let urlm = URL(string: m_sUrl){
            let request = URLRequest(url: urlm)
            webview.load(request)
        }
        
        uiLoading.layer.zPosition = 9999;
        
        
    }
    
    func setUrl(url : String, f_sTitle : String, menuidx : Int){
        m_sUrl = url
        m_sTitle = f_sTitle
        m_nSelMenu = menuidx
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //webview.frame = CGRect(x: 0 , y: 121, width: self.view.frame.width, height: self.view.frame.height )
        
        webview.translatesAutoresizingMaskIntoConstraints = false
        webview.topAnchor.constraint(equalTo: uiTopTabView.bottomAnchor,constant: 2).isActive = true
        webview.leftAnchor.constraint(equalTo:view.leftAnchor,constant: 0).isActive = true
        webview.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        webview.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        /*if UIDevice.current.hasNotch {
           webview.frame = CGRect(x: 0 , y: 0, width: self.webviewmain.frame.width, height: self.webviewmain.frame.height )
        } else {
            webview.frame = CGRect(x: 0 , y: 0, width: self.webviewmain.frame.width, height: self.webviewmain.frame.height )
        }*/
        self.uiTopTabView.setIndex(index: m_nSelMenu)
        
    }
    //alert 처리
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인".localized, style: .default, handler: { (action) in completionHandler() }))
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    //confirm 처리
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인".localized, style: .default, handler: { (action) in completionHandler(true) }))
        alertController.addAction(UIAlertAction(title: "취소".localized, style: .default, handler: { (action) in completionHandler(false) }))
        self.present(alertController, animated: true, completion: nil)
    }
    //confirm 처리2
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: "", message: prompt, preferredStyle: .alert)
        alertController.addTextField { (textField) in textField.text = defaultText }
        alertController.addAction(UIAlertAction(title: "확인".localized, style: .default, handler: {
            (action) in if let text = alertController.textFields?.first?.text {
                completionHandler(text)
                
            } else {
                completionHandler(defaultText)
                
            } }))
        alertController.addAction(UIAlertAction(title: "취소".localized, style: .default, handler: { (action) in completionHandler(nil) }))
        self.present(alertController, animated: true, completion: nil)
        
    }
    // href="_blank" 처리
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
            
        }
        return nil
        
    }
    // 중복 리로드 방지
    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
        
    }
    //MARK: 웹뷰에서 결제 관련
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        //print("@@@ decidePolicyFor navigationAction")
        guard let requestURL = navigationAction.request.url else {return}
        let url = requestURL.absoluteString
        let hostAddress = navigationAction.request.url?.host
        // To connnect app store
        if hostAddress == "itunes.apple.com" {
            if UIApplication.shared.canOpenURL(requestURL) {
                //print("210 : \(requestURL)")
                UIApplication.shared.open(requestURL, options: [:], completionHandler: nil)
                
                decisionHandler(.cancel)
                return
                
            }
            
        }
        #if DEBUG
        //print("url = \(url), host = \(hostAddress?.description ?? "")")
        #endif
        let url_elements = url.components(separatedBy: ":")
        if url_elements[0].contains("http") == false && url_elements[0].contains("https") == false {
            if UIApplication.shared.canOpenURL(requestURL) {
                //print("210_2 : \(requestURL)")
            UIApplication.shared.open(requestURL, options: [:], completionHandler: nil)
            
        } else {
            // 만약 Info.plist의 white list에 등록되지 않은 앱 스키마가 있는 경우를 위해 사용, 신용카드 결제화면등을 위해 필요, 해당 결제앱 스키마 호출
            if url.contains("about:blank") == true {
                //print("@@@ Browser can't be opened, about:blank !! @@@")
                
            }else{
                //print("@@@ Browser can't be opened, but Scheme try to call !! @@@")
                UIApplication.shared.open(requestURL, options: [:], completionHandler: nil)
                
            }
            
            }
            decisionHandler(.cancel)
            return
            
        }
        decisionHandler(.allow)
            
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        uiLoading.isHidden = false;
        uiLoading.startAnimating();
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        uiLoading.stopAnimating();
        uiLoading.isHidden = true;
        webView.evaluateJavaScript("document.documentElement.style.webkitUserSelect='none'", completionHandler: nil)
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
    }

}
extension UsePolicy: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        
    }
}
extension UsePolicy : ReportCustomSegmentedControlDelegate{
    func changeToIndex(index: Int) {
        if m_nSelMenu == index{
            return;
        }
        m_nSelMenu = index;
        if m_nSelMenu == 0{
            m_sTitle = "이용약관".localized;
            m_sUrl = m_sUrlStep1
        }else if m_nSelMenu == 1{
            m_sTitle = "개인정보처리방침".localized;
            m_sUrl = m_sUrlStep2
        }
        self.title = m_sTitle
        if let urlm = URL(string: m_sUrl){
            let request = URLRequest(url: urlm)
            webview.load(request)
        }
        
    }
}
