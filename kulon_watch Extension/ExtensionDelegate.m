//
//  ExtensionDelegate.m
//  POSH WatchKit Extension
//
//  Created by Mac on 8/9/18.
//  Copyright © 2018 OSSystem. All rights reserved.
//

#import "ExtensionDelegate.h"

@implementation ExtensionDelegate

- (void)applicationDidFinishLaunching {
    NSLog(@"[i] applicationDidFinishLaunching");
    // Perform any final initialization of your application.
}

- (void)applicationDidBecomeActive {
    self.isActive = YES;
    NSLog(@"[i] applicationDidBecomeActive");
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillResignActive {
    self.isActive = NO;
    NSLog(@"[i] applicationWillResignActive");
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, etc.
    
    
}
    

- (void)handleBackgroundTasks:(NSSet<WKRefreshBackgroundTask *> *)backgroundTasks {
    // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
    for (WKRefreshBackgroundTask * task in backgroundTasks) {
        NSLog(@"[i] ********* Bg task: %@", task);
        // Check the Class of each task to decide how to process it
        if ([task isKindOfClass:[WKApplicationRefreshBackgroundTask class]]) {
            // Be sure to complete the background task once you’re done.
            WKApplicationRefreshBackgroundTask *backgroundTask = (WKApplicationRefreshBackgroundTask*)task;
            [backgroundTask setTaskCompletedWithSnapshot:NO];
        } else if ([task isKindOfClass:[WKSnapshotRefreshBackgroundTask class]]) {
            // Snapshot tasks have a unique completion call, make sure to set your expiration date
            WKSnapshotRefreshBackgroundTask *snapshotTask = (WKSnapshotRefreshBackgroundTask*)task;
            [snapshotTask setTaskCompletedWithDefaultStateRestored:YES estimatedSnapshotExpiration:[NSDate distantFuture] userInfo:nil];
        } else if ([task isKindOfClass:[WKWatchConnectivityRefreshBackgroundTask class]]) {
            // Be sure to complete the background task once you’re done.
            WKWatchConnectivityRefreshBackgroundTask *backgroundTask = (WKWatchConnectivityRefreshBackgroundTask*)task;
            [backgroundTask setTaskCompletedWithSnapshot:NO];
        } else if ([task isKindOfClass:[WKURLSessionRefreshBackgroundTask class]]) {
            // Be sure to complete the background task once you’re done.
            WKURLSessionRefreshBackgroundTask *backgroundTask = (WKURLSessionRefreshBackgroundTask*)task;
            [backgroundTask setTaskCompletedWithSnapshot:NO];
        } else {
            // make sure to complete unhandled task types
            [task setTaskCompletedWithSnapshot:NO];
        }
    }
}

- (void)applicationDidEnterBackground {
    self.isActive = NO;
    NSLog(@"[i] applicationDidEnterBackground");
}

- (void)applicationWillEnterForeground {
    NSLog(@"[i] applicationWillEnterForeground");
}

/*
- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"[i] didReceiveRemoteNotification: %@", userInfo);
}

- (void)didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"[i] didReceiveLocalNotification: %@", notification);
}

- (void)handleActionWithIdentifier:(NSString *)identifier
              forLocalNotification:(UILocalNotification *)localNotification {
    NSLog(@"[i] handleActionWithIdentifier:forLocalNotification: %@ %@", identifier, localNotification);
}

- (void)handleActionWithIdentifier:(NSString *)identifier
              forLocalNotification:(UILocalNotification *)localNotification
                  withResponseInfo:(NSDictionary *)responseInfo {
    NSLog(@"[i] handleActionWithIdentifier:forLocalNotification:withResponseInfo: %@ %@ %@", identifier, localNotification, responseInfo);
}
*/

@end
