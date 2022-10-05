//
//  AppDelegate.swift
//  golf2u
//
//  Created by 이원영 on 2020/09/16.
//  Copyright © 2020 이원영. All rights reserved.
//

import UIKit
import KakaoSDKCommon

import FBSDKCoreKit

import Firebase
import GoogleSignIn
import FirebaseMessaging
import FirebaseDynamicLinks
import UserNotifications

import AppsFlyerLib

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, MessagingDelegate, UNUserNotificationCenterDelegate, AppsFlyerLibDelegate {
    
    var window: UIWindow?
    
    private var SO:Single = Single.getSO();
    private let JS = JsonC();
    
    var GooglesignInCallback: (() -> ())?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        SO.TAKUUIDKeyChainUUID();
        
        KakaoSDK.initSDK(appKey: "8ae0b53d87cac2a26da0ce34dfa2d59a")
        
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        FirebaseApp.configure();
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        Messaging.messaging().delegate = self
        
        //앱서플라이
        AppsFlyerLib.shared().appsFlyerDevKey = "bpyxadhpjyt8yFX5p2HqMf"
        AppsFlyerLib.shared().appleAppID = "1237544150"
        AppsFlyerLib.shared().delegate = self
        AppsFlyerLib.shared().isDebug = false
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
        NotificationCenter.default.addObserver(self, selector: NSSelectorFromString("sendLaunch"), name:UIApplication.didBecomeActiveNotification, object: nil)
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current() .requestAuthorization(options: [.alert, .sound, .badge]) {
            granted, error in
            print("Permission granted: \(granted)")
            
        }
        // APNS 등록
        application.registerForRemoteNotifications()
        
        
        
        
        return true
    }
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
//        let deeplinkPath = "/deeplink/"
//        print("aaa : ",url);
//        SO.m_nDeepLinkType = 2;
//        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
//              let path = components.path,
//              let params = components.queryItems else {
//            return false
//        }
//        guard path == deeplinkPath else {
//            return false
//        }
//        
//        // 3. 쿼리확인
//        if let value = params.first(where: { $0.name == "scene" })?.value {
//            //processDeeplink(with: value)
//            return true
//        } else {
//            print("index missing")
//            return false
//        }
//    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
      if let error = error {
        // ...
        return
      }
        GooglesignInCallback!();
      guard let authentication = user.authentication else { return }
        //print(user.userID);
      let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                        accessToken: authentication.accessToken)
      // ...
    }
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    //MARK: Notifycation
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Error in registration. Error: \(error)")
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
      print("[Log] deviceToken :", deviceTokenString)
        
      Messaging.messaging().apnsToken = deviceToken
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //포그라운드
        let userInfo = notification.request.content.userInfo
        let fm_sType : String = userInfo["type"] as! String;
        let fm_sSubType : String = userInfo["subtype"] as! String;
        if fm_sType == "5" && fm_sSubType == "0" {
            //클로버 초기화
            let fm_sClover : String = userInfo["point"] as! String;
            //SO.setPushClover(clover: fm_sClover)
            SO.getStartMain()?.setPushUserClover(clover: fm_sClover)
        }else if fm_sType == "10"{
            SO.getStartMain()?.BlackListMemberPush();
        }
        
        completionHandler([.alert, .badge, .sound])
        print("[Log] willPresent", userInfo)
    }
    
    func userNotificationCenter(_ centerf: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //푸시 응답에대한처리
        //리스폰스 매개변수받아서 처리
        //1.사용자가 푸시를 종료했을때
        //2.사용자가 푸시를 클릭 했을때
        let userInfo = response.notification.request.content.userInfo
        if response.actionIdentifier == UNNotificationDismissActionIdentifier {
            print ("Message Closed")
        }
        else if response.actionIdentifier == UNNotificationDefaultActionIdentifier {                      
            print ("푸시 메시지 클릭 했을 때")
        }
        completionHandler()
        /*
         target_seq
         type
         subtype
         */
        let fm_sType : String = userInfo["type"] as! String;
        let fm_sSubType : String = userInfo["subtype"] as! String;
        let fm_sSeq : String = userInfo["target_seq"] as! String;
        print("210 pushclick type : \(fm_sType), subtype : ",fm_sSubType);
        if let main = SO.getStartMain() {
            print("210 pushclick 1")
            main.MoveDetailView(type: fm_sType, subtype: fm_sSubType, seq: fm_sSeq)
        }else{
            print("210 pushclick 2")
            SO.setPushData(type: fm_sType, subtype: fm_sSubType, seq: fm_sSeq)
        }
        
        print("[Log] didReceive ", userInfo)
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      let dataDict: [String: String] = ["token": fcmToken ?? ""]
      print("[Log] fcmToken :", fcmToken ?? "")
      /*
       1. 새 기기에서 앱 복원

       2. 사용자가 앱 삭제/재설치

       3. 사용자가 앱 데이터 소거
       */
      SO.setPushToken(key: fcmToken ?? "")
      NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
    
//    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
//      print("[Log] didReceive :", messaging)
//    }
    
    //MARK: 앱서플라이
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        AppsFlyerLib.shared().handlePushNotification(userInfo)
    }
    @objc func sendLaunch() {
        AppsFlyerLib.shared().start()
    }
    @objc func onConversionDataSuccess(_ installData: [AnyHashable: Any]) {
        print("onConversionDataSuccess data:")
        for (key, value) in installData {
            print(key, ":", value)
        }
        if let status = installData["af_status"] as? String {
            if (status == "Non-organic") {
                if let sourceID = installData["media_source"],
                   let campaign = installData["campaign"] {
                    print("This is a Non-Organic install. Media source: \(sourceID)  Campaign: \(campaign)")
                }
            } else {
                print("This is an organic install.")
            }
            if let is_first_launch = installData["is_first_launch"] as? Bool,
               is_first_launch {
                print("First Launch")
            } else {
                print("Not First Launch")
            }
        }
    }
    @objc func onConversionDataFail(_ error: Error) {
        print(error)
    }
    func onAppOpenAttribution(_ attributionData: [AnyHashable : Any]) {
        print("\(attributionData)")
    }
    func onAppOpenAttributionFailure(_ error: Error) {
        print(error)
    }
}
