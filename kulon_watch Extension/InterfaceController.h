//
//  InterfaceController.h
//  POSH WatchKit Extension
//
//  Created by Mac on 8/9/18.
//  Copyright © 2018 OSSystem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchConnectivity/WatchConnectivity.h>
#import <WatchKit/WatchKit.h>
#import <UserNotifications/UserNotifications.h>
#import "ExtensionDelegate.h"

@interface InterfaceController : WKInterfaceController <WCSessionDelegate, UNUserNotificationCenterDelegate> {
    NSInteger attId;
    NSInteger ntfId;
    NSInteger imgId;
}



@property (nonatomic, weak) IBOutlet WKInterfaceImage *imageView;
@property (nonatomic, strong) WCSession* wcSession;

@end
