//
//  ViewController.swift
//  myNotifications
//
//  Created by Tom Tsiliopoulos on 2017-04-11.
//  Copyright © 2017 Tom Tsiliopoulos. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {
    var messageNumber = 0
    var isGrantedNotificationAccess = false

    func makeContent() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "A Time Action"
        content.body = "Making Notifications"
        content.userInfo = ["step":0]
        return content
    }
    
    func addNotification(trigger:UNNotificationTrigger?, content: UNMutableNotificationContent, identifier: String) {
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request){
            (error) in
            if(error != nil) {
                print("error adding notification:\(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    @IBAction func ScheduleAction(_ sender: UIButton) {
        if(isGrantedNotificationAccess) {
            let content = UNMutableNotificationContent()
            content.title = "A Scheduled Action"
            content.body = "Time to make noise!"
            
            let unitFlags:Set<Calendar.Component> = [.minute, .hour, .second]
            var date = Calendar.current.dateComponents(unitFlags, from: Date())
            date.second = date.second! + 15
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
            addNotification(trigger: trigger, content: content, identifier: "action.scheduled")
            
        }
    }
    
    @IBAction func MakeAction(_ sender: UIButton) {
        if(isGrantedNotificationAccess) {
            let content = makeContent()
            messageNumber += 1
            content.subtitle = "Message \(messageNumber)"
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10.0, repeats: false)
            addNotification(trigger: trigger, content: content, identifier: "action.made.\(messageNumber)")
        }
    }
    
    @IBAction func NextAction(_ sender: UIButton) {
    }

    @IBAction func ViewPendingNotifications(_ sender: UIButton) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requestList) in
            print("\(Date()) --> \(requestList.count) requests pending")
            for request in requestList {
                print("\(request.identifier) body: \(request.content.body)")
            }
        }
    }
    
    @IBAction func ViewDeliveredNotifications(_ sender: UIButton) {
        UNUserNotificationCenter.current().getDeliveredNotifications { (notifications) in
            print("\(Date()) ---> \(notifications.count) delivered")
            for notification in notifications {
                print("\(notification.request.identifier)  \(notification.request.content.body)")
            }
        }
    }
    
    @IBAction func RemoveNotification(_ sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            self.isGrantedNotificationAccess = granted
            if(!granted) {
                // add alert to complain to user
            }
        }
    }

    //MARK: - Delegates
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }

}

