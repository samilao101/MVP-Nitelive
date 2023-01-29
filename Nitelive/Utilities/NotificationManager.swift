//
//  NotificationManager.swift
//  Nitelive
//
//  Created by Sam Santos on 8/31/22.
//

import Foundation
import UserNotifications
import CoreLocation

class NotificationManager {
    
    static let instance = NotificationManager()
    
    func requestNotification() {
        
        let options : UNAuthorizationOptions = [.alert, .sound, .badge]
        
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
            
            if let error = error {
                print("error:\(error)")
            } else {
                print("success")
            }
            
        }
    }
    
    func scheduleLocationNotification(clubId: String, clubLocation: CLLocation) {
        print("Creating notification")
        let content = UNMutableNotificationContent()
        content.title = "Sharing is Caring"
        content.subtitle = "Welcome to the club. Post a video so others can see what's going on."
        content.sound = .default
        content.badge = 1
        
        let clubCoordinate = CLLocationCoordinate2D(latitude: clubLocation.coordinate.latitude, longitude: clubLocation.coordinate.longitude)
        
        let region = CLCircularRegion(center: clubCoordinate, radius: 160.9, identifier: clubId)
   
        region.notifyOnExit = false
        region.notifyOnEntry = true
        
        let trigger = UNLocationNotificationTrigger(region: region, repeats: true)
        
        let request = UNNotificationRequest(identifier: clubId, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("error adding notification request: \(error.localizedDescription)")
            } else {
                print("Successfully added notificationr request.")
            }
        }
    }
    
}
