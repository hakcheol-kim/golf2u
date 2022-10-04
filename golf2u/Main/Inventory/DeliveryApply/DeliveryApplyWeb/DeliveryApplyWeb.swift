//
//  DeliveryApply.swift
//  golf2u
//
//  Created by 이원영 on 2020/11/17.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import WebKit
import SwiftyJSON
class DeliveryApplyWeb:  VariousViewController , WKUIDelegate, WKNavigationDelegate {
    private let SO = Single.getSO()
    weak var m_tClickEvent: InventoryMainClickCellBtnDelegate? = nil;
    private var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    private var webview: WKWebView!
    private let m_sUserAgent : String = "Version/8.0.2 Safari/600.2.5"
    private var m_sUrl : String = "\(Single.DE_WEBAPIPROTOCOL)://\(Single.DE_URLSERVER)/api/Order/startDelivery";
    @IBOutlet weak var uiLoading: UIActivityIndicatorView!
    
    private var m_Data = [String: Any]();
    
    override func viewDidLoad() {
        super.InitVC(type: Single.DE_INITNAVISUB, title: "배송 신청".localized)
        super.viewDidLoad()
        
        let contentController = WKUserContentController()
        contentController.add(self, name: "iosr2DAW")
        
        //let userScript = WKUserScript(source: "setData('\(string)'", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        //contentController.addUserScript(userScript)
        
        
        
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
    func setData(data : [String: Any]){
        m_Data = data;
    }
    class CompletionHandlerWrapper<Element> {
      private var completionHandler: ((Element) -> Void)?
      private let defaultValue: Element

      init(completionHandler: @escaping ((Element) -> Void), defaultValue: Element) {
        self.completionHandler = completionHandler
        self.defaultValue = defaultValue
      }

      func respondHandler(_ value: Element) {
        completionHandler?(value)
        completionHandler = nil
      }

      deinit {
        respondHandler(defaultValue)
      }
    }
    //alert 처리
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let completionHandlerWrapper = CompletionHandlerWrapper(completionHandler: completionHandler, defaultValue: Void())
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인".localized, style: .default, handler: { (action) in completionHandlerWrapper.respondHandler(Void()) }))
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
        //로딩이 끝난후 스크립트 데이터 전송
        if let string = JSON(m_Data).rawString() {
            webview.evaluateJavaScript("setData(\(string))", completionHandler: {result, error in
                if let _ = error{
                    
                }else{
                }
            })
        }
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
    }
}
extension DeliveryApplyWeb: WKScriptMessageHandler {
    func goResult(Point : String = "0", deliseq : String = "", isError : Bool = true){
        if !isError {
            SO.setUserInfoKey(key: "point_total", value: Point);
            m_Data["deliseq"] = deliseq;
            m_tClickEvent?.ClickEvent(viewtype : 1, type: 10, data: m_Data)
            var fm_sPTitle = "배송신청 완료".localized;
            var fm_sPContents = "배송신청이 완료되었습니다.".localized;
            if m_Data["payment_method"] as! String  == "4" {
                fm_sPTitle = "입금안내".localized;
                fm_sPContents = "문자와 이메일로 안내드린 계좌번호로 입금완료 시 박스가 지급됩니다.".localized;
            }
            MessagePop(title : fm_sPTitle, msg: fm_sPContents, btntype: 2, ostuch: false,succallbackf: { [self] ()-> Void in
                pageGo();
            }, closecallbackf: { [self] ()-> Void in
                pageGo();
            })
        }else{
            pageGo()
        }
        
    }
    func pageGo(){
        let fm_Contrllers = self.navigationController?.viewControllers
        if let val = fm_Contrllers{
            for VC in val{
                if VC is InventoryMain {
                    let IM = VC as! InventoryMain
                    //IM.goToProductInven()
                    //IM.DeliveryFinishCallback();
                    self.navigationController?.popToViewController(VC, animated: true)
                    break;
                }
            }
        }
    }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "iosr2DAW" {
            if let dictionary: [String: String] = message.body as? Dictionary {
                if dictionary["errorcode"] == "0"{
                    goResult(Point : dictionary["point"] ?? "0", deliseq : dictionary["purchase_seq"] ?? "0", isError : false)
                }else{
                    MessagePop(title : "안내".localized, msg: dictionary["errormessage"] ?? "Error Code \(dictionary["errorcode"] ?? "1 ")", btntype: 2,succallbackf: { ()-> Void in
                        self.goResult()
                    }, closecallbackf: { ()-> Void in
                        self.goResult()
                    })
                }
            }
        }
    }
}
