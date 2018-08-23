//
//  NotificationController.m
//  POSH WatchKit Extension
//
//  Created by Mac on 8/9/18.
//  Copyright © 2018 OSSystem. All rights reserved.
//

#import "NotificationController.h"
#import "UIImage+animatedGIF.h"


@interface NotificationController ()

@end


@implementation NotificationController

- (instancetype)init {
    self = [super init];
    if (self){
        // Initialize variables here.
        // Configure interface objects here.
        
    }
    return self;
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}


- (void)didReceiveNotification:(UNNotification *)notification withCompletion:(void(^)(WKUserNotificationInterfaceType interface)) completionHandler {
    // This method is called when a notification needs to be presented.
    // Implement it if you use a dynamic notification interface.
    // Populate your dynamic notification interface as quickly as possible.
    
    UIImage* image = nil;
    if (notification.request.content.attachments.count > 0) {
        UNNotificationAttachment* att = [notification.request.content.attachments objectAtIndex:0];
        NSData* data = [NSData dataWithContentsOfURL:att.URL];
        NSLog(@"(from ntf) data len = %u", data.length);
        image = [UIImage imageWithData:data scale:1.0];
        NSLog(@"image created %u", image.images.count);
    }
    [self.imageView setImage:image];
    
    // After populating your dynamic notification interface call the completion block.
    completionHandler(WKUserNotificationInterfaceTypeCustom);
}


@end



