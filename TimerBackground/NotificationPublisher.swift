//
//  NotificationPublisher.swift
//  TimerBackground
//
//  Created by Miguel Planckensteiner on 13.05.20.
//  Copyright © 2020 Miguel Planckensteiner. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationPublisher: NSObject {
    
    func sendNotification(title: String, subtitle: String, body: String, delayInterval: Int?) {
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = title
        notificationContent.subtitle = subtitle
        notificationContent.body = body
        
        var delayTimeTrigger: UNTimeIntervalNotificationTrigger?
        
        if let delayInterval =  delayInterval {
            delayTimeTrigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(delayInterval), repeats: false)
        }
        
        notificationContent.sound = UNNotificationSound.init(named:UNNotificationSoundName(rawValue: "AlarmSound1.wav"))
        
        
        UNUserNotificationCenter.current().delegate = self
        
        let request = UNNotificationRequest(identifier: "TestLocalNotification", content: notificationContent, trigger: delayTimeTrigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print (error.localizedDescription)
            }
        }
        
    }

}


extension NotificationPublisher: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("The Notification is about to be presented")
        completionHandler([.badge, .alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let identifer = response.actionIdentifier
        
        switch identifer {
        case UNNotificationDismissActionIdentifier:
            print("The Notification was dismissed")
            completionHandler()
            
        case UNNotificationDefaultActionIdentifier:
            print("User opened the app from the notification")
            completionHandler()
       
        default:
            print("The default case was called")
            completionHandler()
        }
        
    }
}
