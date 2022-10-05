//
//  SceneDelegate.swift
//  golf2u
//
//  Created by 이원영 on 2020/09/16.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import KakaoSDKAuth
import FBSDKLoginKit
import GoogleSignIn
import AppsFlyerLib
import FirebaseDynamicLinks

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private var SO:Single = Single.getSO();
    private let JS = JsonC();

    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        /*
         딥링크로 앱을 오픈 할때 백그라운드에 앱이 있을경우는
         scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
         해당 메서드로 가겠지만
         메모리까지 삭제되어 딥링크로 앱을 재시작 한다면 여기서 다시 위 메서드로 이동시켜줘야 한다
         */
        if let userActivity = connectionOptions.userActivities.first {
          self.scene(scene, continue: userActivity)
        } else {
          self.scene(scene, openURLContexts: connectionOptions.urlContexts)
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        //print("ergerg : ",URLContexts.first?.url);
        //앱이 실행시 넘어오는 스키마 를 판단하여 이전에 어디서온 건지 구분할수있다
        
        if let url = URLContexts.first?.url {
            AppsFlyerLib.shared().handleOpen(url, options: nil)
            print("scene openurl: \(url)")
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.handleOpenUrl(url: url)
            }else if url.scheme!.contains("com.googleusercontent.apps") {
                GIDSignIn.sharedInstance().handle(url)
            }else if url.absoluteString == "golf2u://schememainintent" {//여기서 부터 자체 딥링크
                //메인
                SO.m_nDeepLinkType = 1
            }else if url.absoluteString == "golf2u://schemetradepdintent" {
                //트레이드 > 상품
                SO.m_nDeepLinkType = 2
            }else if url.absoluteString == "golf2u://schemenewsroomintent" {
                //커뮤니티 > 뉴스룸
                SO.m_nDeepLinkType = 3
            }else if url.absoluteString == "golf2u://schemeeventpdintent" {
                //햄버거 > 고객센터 > 이벤트
                SO.m_nDeepLinkType = 4
            }else if url.absoluteString == "golf2u://schemeinvenpdintent" {
                //인벤토리 > 상품보관함
                SO.m_nDeepLinkType = 5
            }else if url.absoluteString == "golf2u://schemepapercouponintent" {
                //햄버거 > 획득가능쿠폰 > 지류쿠폰 등록하기 > 지류쿠폰 등록
                SO.m_nDeepLinkType = 6
            }else if url.absoluteString == "golf2u://schemecouponintent" {
                //햄버거 > 쿠폰함 > 획득가능쿠폰
                SO.m_nDeepLinkType = 7
            }else if url.absoluteString.contains("golf2u://schemepdinfointent?seq=") {
                //상품 상세
                let fm_sUrlAb = url.absoluteString;
                SO.m_nDeepLinkType = 8
                if let findstr = fm_sUrlAb.range(of: "="){
                    //print(findstr.lowerBound)
                    let fm_sSeq = fm_sUrlAb[(findstr.upperBound)...];
                    SO.m_nDeepLinkSeq = String(fm_sSeq)
                }
                
            }else if url.absoluteString == "golf2u://schemeboxbuyintent" {
                //랜투샵> 랜덤박스 구매하기> 랜덤박스구매
                SO.m_nDeepLinkType = 9
            }else if url.absoluteString == "golf2u://schemebuypdlistintent" {
                //"랜투샵> 랜덤박스 구매하기> 랜덤박스 상품보기 *현재 당첨 가능한 상품 썸네일 노출되는 페이지"
                SO.m_nDeepLinkType = 10
            }
            else if url.absoluteString.hasSuffix("kakaolink") {
                SO.m_nDeepLinkType = 11
            }
            else{
                ApplicationDelegate.shared.application( UIApplication.shared, open: url, sourceApplication: nil, annotation: [UIApplication.OpenURLOptionsKey.annotation] )
            }
        }
    }
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
        
        if let incomingURL = userActivity.webpageURL {
            print("Incoming URL is \(incomingURL)")
            let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { dynamicLink, error in
                guard error == nil else {
                    print("Found an error \(error!.localizedDescription)")
                    return
                }
                guard let dynamicLink = dynamicLink, let linkUrl =  dynamicLink.url else {
                    return
                }
                self.parsingDynamiclink(linkUrl)
            }
            print(linkHandled)
        }
    }

    func parsingDynamiclink(_ url: URL) {
        print("dynamic link url: \(url)")
    }
  
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
        //print("sceneDidDisconnect")
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        //print("sceneDidBecomeActive 백그라운드에서 활성화 됬을때")
        SO.getStartMain()?.setForeground();
        //AppEvents.activateApp()
        AppEvents.activateApp()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        //print("sceneWillResignActive")
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        //print("sceneWillEnterForeground")
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        //print("sceneDidEnterBackground 백그라운드 로 갔을때")
    }


}

