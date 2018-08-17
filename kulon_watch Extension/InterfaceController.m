//
//  InterfaceController.m
//  POSH WatchKit Extension
//
//  Created by Mac on 8/9/18.
//  Copyright © 2018 OSSystem. All rights reserved.
//

#import "InterfaceController.h"
#import "UIImage+animatedGIF.h"

@interface InterfaceController ()

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    //activate session
    if ([WCSession isSupported]) {
        WCSession* session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
        self.wcSession = session;
    }

    
    //request ntf perms
    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        UNAuthorizationStatus st = [settings authorizationStatus];
        NSLog(@"[i] Ntf auth status %i", st);
        if (st != UNAuthorizationStatusAuthorized) {
            UNAuthorizationOptions opts = UNAuthorizationOptionBadge | UNAuthorizationOptionAlert;
            [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:opts completionHandler:^(BOOL granted, NSError * error) {
                if (granted)
                    NSLog(@"[i] Ntf granted");
                else
                    NSLog(@"[!] Ntf not granted %@", error);
            }];
        }
    }];
    
    //ntf center
    [[UNUserNotificationCenter currentNotificationCenter] setDelegate:self];
    
    //get last img url
    NSString* lastUrlStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"putOnUrl"];
    if (lastUrlStr != nil) {
        [self.imageView setImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:lastUrlStr]]];
    }
    
    // Configure interface objects here.
}

- (ExtensionDelegate*) appDelegate {
    return [WKExtension sharedExtension].delegate;
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}


// TODO: copy not to temp, but store + load at app start

#pragma mark - <WCSessionDelegate> used

/** Called on the delegate of the receiver. Will be called on startup if the file finished transferring when the receiver was not running. The incoming file will be located in the Documents/Inbox/ folder when being delivered. The receiver must take ownership of the file by moving it to another location. The system will remove any content that has not been moved when this delegate method returns. */
- (void)session:(WCSession *)session
 didReceiveFile:(WCSessionFile *)file {
    NSLog(@"[i] Received sesion file: %@", file.fileURL);
    
    //need to copy received file coz it will be deleted soon
    NSError* copyErr = nil;
    NSString* copyFilename = [NSString stringWithFormat:@"%@_%i_%f.%@", @"putonImg", self->imgId++, [[NSDate date] timeIntervalSince1970], [file.fileURL pathExtension]];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSURL* documentsUrl = [NSURL URLWithString:documentsDirectory];
    NSURL* tmpUrl = [[NSFileManager defaultManager] temporaryDirectory];
    NSURL* copyUrl = nil;
    //copyUrl = [NSURL URLWithString:copyFilename relativeToURL:documentsUrl];
    copyUrl = [NSURL URLWithString:copyFilename relativeToURL:tmpUrl];
    [[NSFileManager defaultManager] copyItemAtURL:file.fileURL toURL:copyUrl error:&copyErr];
    if (copyErr != nil)
        NSLog(@"[!] Error copying session file to temp: %@ %@", copyUrl, copyErr);
    else
        NSLog(@"[i] Copied file to: %@", copyUrl);
    
    if (copyErr != nil)
        return;
    
    //set image to image view
    //UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:copyUrl]];
    [self.imageView stopAnimating];
    UIImage* image = [UIImage animatedImageWithAnimatedGIFData:[NSData dataWithContentsOfURL:copyUrl]];
    BOOL isAnimated = image.images && image.images.count > 1;
    [self.imageView setImage:image];
    if (isAnimated)
        [self.imageView startAnimating];
    
    //save for next app run
    [[NSUserDefaults standardUserDefaults] setObject:[copyUrl absoluteString] forKey:@"putOnUrl"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //img for ntf
    NSURL* attUrl = copyUrl;
    if (isAnimated) {
        NSString* oneFrameExt = @"png";
        copyFilename = [NSString stringWithFormat:@"%@_%i_%f.%@", @"putonImgFrame", self->imgId, [[NSDate date] timeIntervalSince1970], oneFrameExt];
        //attUrl = [NSURL URLWithString:copyFilename relativeToURL:documentsUrl];
        attUrl = [NSURL URLWithString:copyFilename relativeToURL:tmpUrl];
        NSData* frameData = UIImagePNGRepresentation([image.images objectAtIndex:0]);
        [frameData writeToURL:attUrl atomically:YES];
    }
    
    //create content
    NSError* attErr = nil;
    NSString* attIdStr = [NSString stringWithFormat:@"%@:%i:%f", @"putonAtt", self->attId++, [[NSDate date] timeIntervalSince1970]];
    UNNotificationAttachment* att = [UNNotificationAttachment attachmentWithIdentifier:attIdStr URL:attUrl options:nil error:&attErr];
    if (attErr != nil) {
        NSLog(@"[!] Error creating ntf attachment: %@", attErr);
        return;
    }
    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    content.title = @"POSH";
    //content.body = @"body1";
    content.attachments = @[att];
    content.categoryIdentifier = @"myCategory";
    
    if ([self appDelegate].isActive)
        return;
    
    //post ntf
    UNTimeIntervalNotificationTrigger* trigger = nil;
    NSString* ntfIdStr = [NSString stringWithFormat:@"%@:%i:%f", @"putonNtf", self->ntfId++, [[NSDate date] timeIntervalSince1970]];
    UNNotificationRequest* req = [UNNotificationRequest requestWithIdentifier:ntfIdStr content:content trigger:trigger];
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:req withCompletionHandler:^(NSError* ntfErr) {
        if (ntfErr != nil)
            NSLog(@"[!] Error posting ntf: %@", ntfErr);
        else
            NSLog(@"[i] Ntf #%i posted", self->ntfId);
    }];
    
}


#pragma mark - <UNUserNotificationCenterDelegate>

// The method will be called on the delegate only if the application is in the foreground. If the method is not implemented or the handler is not called in a timely manner then the notification will not be presented. The application can choose to have the notification presented as a sound, badge, alert and/or in the notification list. This decision should be based on whether the information in the notification is otherwise visible to the user.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    //NSLog(@"[i] userNotificationCenter:willPresentNotification: %@", notification);
}

// The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from application:didFinishLaunchingWithOptions:.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler {
    //NSLog(@"[i] userNotificationCenter:didReceiveNotificationResponse: %@", response);
}


#pragma mark - <WCSessionDelegate>

/** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
- (void)session:(WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(nullable NSError *)error  {
    NSLog(@"[i] session:activationDidCompleteWithState: %li %@", (long)activationState, error);
}

/** Called when the reachable state of the counterpart app changes. The receiver should check the reachable property on receiving this delegate callback. */
- (void)sessionReachabilityDidChange:(WCSession *)session {
    NSLog(@"[i] session:sessionReachabilityDidChange: %i", session.reachable);
}


/** Called on the delegate of the receiver. Will be called on startup if the incoming message caused the receiver to launch. */
- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message {
    NSLog(@"[i] session:didReceiveMessage: %@", message);
}

/** Called on the delegate of the receiver when the sender sends a message that expects a reply. Will be called on startup if the incoming message caused the receiver to launch. */
- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message replyHandler:(void(^)(NSDictionary<NSString *, id> *replyMessage))replyHandler {
    NSLog(@"[i] session:didReceiveMessage:replyHandler: %@", message);
}

/** Called on the delegate of the receiver. Will be called on startup if the incoming message data caused the receiver to launch. */
- (void)session:(WCSession *)session didReceiveMessageData:(NSData *)messageData {
    NSLog(@"[i] session:didReceiveMessageData: %@", messageData);
}

/** Called on the delegate of the receiver when the sender sends message data that expects a reply. Will be called on startup if the incoming message data caused the receiver to launch. */
- (void)session:(WCSession *)session didReceiveMessageData:(NSData *)messageData replyHandler:(void(^)(NSData *replyMessageData))replyHandler {
    NSLog(@"[i] session:didReceiveMessageData:replyHandler: %@", messageData);
}


/** Called on the delegate of the receiver. Will be called on startup if an applicationContext is available. */
- (void)session:(WCSession *)session didReceiveApplicationContext:(NSDictionary<NSString *, id> *)applicationContext {
    NSLog(@"[i] session:didReceiveApplicationContext: %@", applicationContext);
}


/** Called on the delegate of the receiver. Will be called on startup if the user info finished transferring when the receiver was not running. */
- (void)session:(WCSession *)session didReceiveUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    NSLog(@"[i] session:didReceiveUserInfo: %@", userInfo);
}



@end



