//
//  NotificationController.h
//  POSH WatchKit Extension
//
//  Created by Mac on 8/9/18.
//  Copyright © 2018 OSSystem. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

@interface NotificationController : WKUserNotificationInterfaceController

@property (nonatomic, weak) IBOutlet WKInterfaceImage *imageView;

@end
