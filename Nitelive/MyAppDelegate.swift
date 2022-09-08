//
//  MyAppDelegate.swift
//  Nitelive
//
//  Created by Sam Santos on 9/1/22.
//

import Foundation
import Firebase
import FirebaseMessaging
import UIKit
import GoogleSignIn


class MyAppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        NotificationManager.instance.requestNotification()
        
        application.registerForRemoteNotifications()
        
        Messaging.messaging().subscribe(toTopic: "Videos") { error in
          print("Subscribed to Videos topic")
        }
        
        return true 
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("App is Terminating")
        if UserManager.instance.currentClub != nil {
            print("Checking out user out firebase")
            UserManager.instance.checkOutCurrentClub()
        }
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        messaging.token { token, _ in
            guard let token = token else {
                return
            }
            print("Token: \(token)")
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
        
        
    ) {
        print("RECEIVED NOTIFICATION")   
    }

//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//      var handled: Bool
//
//      handled = GIDSignIn.sharedInstance.handle(url)
//      if handled {
//        return true
//      }
//
//      // Handle other custom URL types.
//
//      // If not handled by this app, return false.
//      return false
//    }
    
    
}

extension MyAppDelegate {
  // Receive displayed notifications for iOS 10 devices.
 

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse) async {
    let userInfo = response.notification.request.content.userInfo

    // ...

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)

    // Print full message.
      let id = userInfo["videoId"] as? String
     
      
      if let id = id {

          print(id)

          FirebaseData.instance.getNotificationShot(id: id)

      }
  }
}
