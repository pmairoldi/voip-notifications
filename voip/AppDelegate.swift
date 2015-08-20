//
//  AppDelegate.swift
//  Voip
//
//  Created by Pierre-Marc Airoldi on 2015-02-15.
//  Copyright (c) 2015 Pierre-Marc Airoldi. All rights reserved.
//

import UIKit
import PushKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        //Enable all notification type. VoIP Notifications don't present a UI but we will use this to show local nofications later
        let notificationSettings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound , categories: nil)
        
        //register the notification settings
        application.registerUserNotificationSettings(notificationSettings)

        //output what state the app is in. This will be used to see when the app is started in the background
        println("app launched with state \(application.applicationState.stringValue)")
        
        return true
    }

    func applicationWillTerminate(application: UIApplication) {

        //output to see when we terminate the app
        println("app terminated")
    }
}

extension AppDelegate {
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        
        //register for voip notifications
        let voipRegistry = PKPushRegistry(queue: dispatch_get_main_queue())
        voipRegistry.desiredPushTypes = Set([PKPushTypeVoIP])
        voipRegistry.delegate = self;
    }
}

extension AppDelegate: PKPushRegistryDelegate {

    
    func pushRegistry(registry: PKPushRegistry!, didUpdatePushCredentials credentials: PKPushCredentials!, forType type: String!) {
    
        //print out the VoIP token. We will use this to test the nofications.
        println("voip token: \(credentials.token)")
    }
    
    func pushRegistry(registry: PKPushRegistry!, didReceiveIncomingPushWithPayload payload: PKPushPayload!, forType type: String!) {
    
        let payloadDict = payload.dictionaryPayload["aps"] as? Dictionary<String, String>
        let message = payloadDict?["alert"]
        
        //present a local notifcation to visually see when we are recieving a VoIP Notification
        if UIApplication.sharedApplication().applicationState == UIApplicationState.Background {
        
            let localNotification = UILocalNotification();
            localNotification.alertBody = message
            localNotification.applicationIconBadgeNumber = 1;
            localNotification.soundName = UILocalNotificationDefaultSoundName;

            UIApplication.sharedApplication().presentLocalNotificationNow(localNotification);
        }
        
        else {
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                let alert = UIAlertView(title: "VoIP Notification", message: message, delegate: nil, cancelButtonTitle: "Ok");
                alert.show()
            })
        }
        
        println("incoming voip notfication: \(payload.dictionaryPayload)")
    }
    
    func pushRegistry(registry: PKPushRegistry!, didInvalidatePushTokenForType type: String!) {
        
        println("token invalidated")
    }
}

extension UIApplicationState {
    
    //help to output a string instead of an enum number
    var stringValue : String {
        get {
            switch(self) {
            case .Active:
                return "Active"
            case .Inactive:
                return "Inactive"
            case .Background:
                return "Background"
            }
        }
    }
}
