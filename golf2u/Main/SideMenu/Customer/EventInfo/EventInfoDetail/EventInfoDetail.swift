//
//  EventInfoDetail.swift
//  golf2u
//
//  Created by 이원영 on 2020/12/03.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import WebKit
import SwiftyJSON

class EventInfoDetail: VariousViewController, WKUIDelegate, WKNavigationDelegate {
    private let SO = Single.getSO();
    private let JS = JsonC();
    @IBOutlet weak var uiLoading: UIActivityIndicatorView!

    @IBOutlet weak var uiConBtn: UIButton!
    private var webview: WKWebView!
    private let m_sUserAgent : String = "Version/8.0.2 Safari/600.2.5"
    private var m_sUrl : String = "";
    private var m_sTitle : String = "";
    private var m_Data = [String : String]();
    private var m_sSeq = "";
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "이벤트 상세".localized)
        super.viewDidLoad()
        
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
        
        
        
        
        LoadItem()
        
    }
    func LoadItem(){
        JS.getEvent(param: ["seq":m_sSeq], callbackf: getEventCallback)
    }
    func getEventCallback(alldata: JSON)->Void {
        if alldata["errorcode"] != "0"{
            self.MessagePop(msg: alldata["errormessage"].string!, btntype : 2)
        }else{
            m_Data["seq"] = alldata["data"]["seq"].stringValue;
            m_Data["title"] = alldata["data"]["title"].stringValue;
            m_Data["type"] = alldata["data"]["type"].stringValue;
            m_Data["image_url"] = alldata["data"]["image_url"].stringValue;
            m_Data["out_link"] = alldata["data"]["out_link"].stringValue;
            m_Data["begin_at"] = alldata["data"]["begin_at"].stringValue;
            m_Data["end_at"] = alldata["data"]["end_at"].stringValue;
            m_Data["period_txt"] = alldata["data"]["period_txt"].stringValue;
            m_Data["available"] = alldata["data"]["available"].stringValue;
            m_Data["event_randing_type"] = alldata["data"]["event_randing_type"].stringValue;
            m_Data["event_btn_type"] = alldata["data"]["event_btn_type"].stringValue;
            m_Data["created_at"] = alldata["data"]["created_at"].stringValue;
            
            if m_Data["type"] == "0" {
                m_sUrl = m_Data["out_link"] ?? "";
            }else if m_Data["type"] == "1" {
                m_sUrl = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Cs/webviewEvent/\(m_Data["seq"] ?? "")";
            }
            
            if let urlm = URL(string: m_sUrl){
                let request = URLRequest(url: urlm)
                webview.load(request)
            }
            let btnbackcolor = m_Data["event_btn_type"] ?? "#00BA87";
            
            uiConBtn.backgroundColor = btnbackcolor.hexStringToUIColor();
            
            uiLoading.layer.zPosition = 9999;
            
            viewDidLayoutSubviews()
        }
    }
    func setData(seq : String){
        m_sSeq = seq;
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        /*if UIDevice.current.hasNotch {
           webview.frame = CGRect(x: 0 , y: 0, width: self.webviewmain.frame.width, height: self.webviewmain.frame.height )
        } else {
            webview.frame = CGRect(x: 0 , y: 0, width: self.webviewmain.frame.width, height: self.webviewmain.frame.height )
        }*/
        viewSetting()
    }
    func viewSetting(){
        if #available(iOS 11.0, *) {
            if (UIDevice.current.hasNotch) {
                //아이폰x 부터 하단 safe 영역 버튼이 있으면 여기서 처리
                //let topPadding = self.view.safeAreaInsets.top
                //let leftPadding = self.view.safeAreaInsets.left
                //let rightPadding = self.view.safeAreaInsets.right
                let bottomPadding = self.view.safeAreaInsets.bottom;
                uiConBtn.frame = CGRect(x: 0, y: Int(uiConBtn.frame.minY), width: Int(uiConBtn.frame.size.width), height: Int(uiConBtn.frame.size.height + bottomPadding))
                uiConBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
            }

        }
        //webview.frame = CGRect(x: 0 , y: 0, width: self.view.frame.width, height: self.view.frame.height - uiConBtn.frame.height )
        
        webview.translatesAutoresizingMaskIntoConstraints = false
        
        webview.topAnchor.constraint(equalTo: self.view.topAnchor,constant: 0).isActive = true
        webview.leftAnchor.constraint(equalTo:self.view.leftAnchor,constant: 0).isActive = true
        webview.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        if m_Data["type"] == "0" || m_Data["available"] == "0" {
            webview.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        }else if m_Data["type"] == "1"  && m_Data["available"] == "1"{
            webview.bottomAnchor.constraint(equalTo: self.uiConBtn.topAnchor, constant: 0).isActive = true
        }
    }
    @IBAction func onConBtn(_ sender: Any) {
        if super.getUserSeq() == "" {
            //친구 초대 로그인이 아니라면 접근불가
            LoginMove();
            return;
        }
        if m_Data["event_randing_type"] == "coupone" {
            let Storyboard: UIStoryboard = UIStoryboard(name: "CuponInfo", bundle: nil)
            let viewController = Storyboard.instantiateViewController(withIdentifier: "CuponInfoidx") as! CuponInfo
            self.navigationController?.pushViewController(viewController, animated: true)
        }else if m_Data["event_randing_type"] == "point" {
            let Storyboard: UIStoryboard = UIStoryboard(name: "CloverInfo", bundle: nil)
            let viewController = Storyboard.instantiateViewController(withIdentifier: "CloverInfoidx") as! CloverInfo
            self.navigationController?.pushViewController(viewController, animated: true)
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
extension EventInfoDetail: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        
    }
}
