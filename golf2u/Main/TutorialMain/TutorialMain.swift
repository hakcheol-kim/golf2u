//
//  TutorialMain.swift
//  golf2u
//
//  Created by 이원영 on 2020/12/08.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import WebKit

class TutorialMain: VariousViewController, WKUIDelegate, WKNavigationDelegate {

    public var closeHandler: (()->())?
    
    @IBOutlet weak var uiMainView: UIView!
    private var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    private var webview: WKWebView!
    private let m_sUserAgent : String = "Version/8.0.2 Safari/600.2.5"
    private var m_sUrl : String = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Tutorial/main";
    private var m_sTitle : String = "";
    @IBOutlet weak var uiLoading: UIActivityIndicatorView!
    @IBOutlet weak var onCloseBtn: UIButton!
    @IBOutlet weak var uiBoxBuyBtn: UIButton!
    @IBOutlet weak var uiBottomView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        onCloseBtn.setTitle("둘러보기".localized, for: .normal)
        uiBoxBuyBtn.setTitle("박스 구매하기".localized, for: .normal)
        
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
        
        
        self.uiMainView.addSubview(webview)
        
        if let urlm = URL(string: m_sUrl){
            let request = URLRequest(url: urlm)
            webview.load(request)
        }
        
        uiLoading.layer.zPosition = 9999;
        
        
        //self.onCloseBtn.layer.addBorder([.right], color: UIColor(rgb: 0xe4e4e4), width: 1.0)

    }
    
    @IBAction func onCloseBtn(_ sender: Any) {
        UserDefaults.standard.set("1", forKey: Single.DE_TUTORIALMAIN)
        dismiss(animated: true, completion: nil)
    }
    @IBAction func onBoxbuyBtn(_ sender: Any) {
        UserDefaults.standard.set("1", forKey: Single.DE_TUTORIALMAIN)
        dismiss(animated: true, completion: nil)
        closeHandler?()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webview.frame = CGRect(x: 0 , y: 0, width: self.uiMainView.frame.width, height: self.uiMainView.frame.height )
        if #available(iOS 11.0, *) {
            if (UIDevice.current.hasNotch) {
                //아이폰x 부터 하단 safe 영역 버튼이 있으면 여기서 처리
                //let topPadding = self.view.safeAreaInsets.top
                //let leftPadding = self.view.safeAreaInsets.left
                //let rightPadding = self.view.safeAreaInsets.right
                let bottomPadding = self.view.safeAreaInsets.bottom;
                uiBottomView.frame = CGRect(x: 0, y: Int(uiBottomView.frame.minY), width: Int(uiBottomView.frame.size.width), height: Int(uiBottomView.frame.size.height + bottomPadding))
            }

        }
        
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
extension TutorialMain: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        
    }
}
