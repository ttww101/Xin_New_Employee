//
//  AppDelegate.m
//  Xin_New_Employee
//
//  Created by Wu on 2019/3/25.
//  Copyright © 2019 Wu. All rights reserved.
//

#define kJPushAppKey @"edd4c8c74add69d6451fdf28"
#define kJPushChannel @"Publish channel"
#define kJPushProduction YES

#import "AppDelegate.h"
#import "JPUSHService.h"
#import <UserNotifications/UserNotifications.h>
#import "JANALYTICSService.h"
#import "ADWebViewController/ADWKWebViewController.h"
#import "NSString+URL/NSString+URL.h"
#import <AdSupport/AdSupport.h>
#import "ViewController.h"
#import <AVOSCloud/AVOSCloud.h>

@interface AppDelegate () <JPUSHRegisterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    hasNotificationEnterInURL = 0;
    
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    if (@available(iOS 12.0, *)) {
        entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound|JPAuthorizationOptionProvidesAppNotificationSettings;
    } else {
        // Fallback on earlier versions
        entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    }
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 可以添加自定义 categories
        // NSSet<UNNotificationCategory *> *categories for iOS10 or later
        // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
    }
    
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    [JPUSHService setupWithOption:launchOptions appKey:kJPushAppKey
                          channel:kJPushChannel
                 apsForProduction:kJPushProduction
            advertisingIdentifier:idfa];
    [JPUSHService setAlias:idfa completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
        
    } seq:0];
    
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        if(resCode == 0){
            NSLog(@"registrationID获取成功：%@",registrationID);
        }
        else{
            NSLog(@"registrationID获取失败，code：%d",resCode);
        }
    }];
    
    JANALYTICSLaunchConfig * config = [[JANALYTICSLaunchConfig alloc] init];
    config.appKey = kJPushAppKey;
    config.channel = kJPushChannel;
    [JANALYTICSService setupWithConfig:config];
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    //set badge number to 0
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}


#pragma mark - Push Service

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"%@", [NSString stringWithFormat:@"Device Token: %@", deviceToken]);
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(UNNotification *)notification{
    if (notification && [notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //从通知界面直接进入应用
    }else{
        //从通知设置界面进入应用
    }
}

//背景觸發
- (void)jpushNotificationCenter :(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    NSLog(@"%@", userInfo);
    if ([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        [AVOSCloud setApplicationId:kAVOS_ID clientKey:kAVOS_KEY];
        [AVOSCloud setAllLogsEnabled:YES];
        
        AVQuery *dataQuery =  [AVQuery queryWithClassName:kAVOS_CLASS_NAME];
        
        [dataQuery getObjectInBackgroundWithId:kAVOS_OBJECT_ID block:^(AVObject * _Nullable avObject, NSError * _Nullable error) {
            //print
            NSLog(@"%@", avObject);
            
            //get value
            BOOL control = ((NSNumber *)[avObject objectForKey:@"control"]).boolValue;
            NSString *url_home = [avObject objectForKey:@"url_hide"];
            NSString *url_push = [userInfo objectForKey:@"url"];
            
            //distinguish route ways
            if (control) {
                
                ADWKWebViewController *webVC = [ADWKWebViewController initWithURL:[url_home trimForURL]];
                
                //has push url
                if (url_push != nil) {
                    [webVC loadURL:[url_push trimForURL]];
                } //or nothing
                
                [[UIApplication sharedApplication].delegate.window setRootViewController:webVC];
                
                hasNotificationEnterInURL = 1;
                
            } else { //control == false
                
                if (url_push != nil) { //load url & dismiss
                    
                    ADWKWebViewController *webVC = [ADWKWebViewController initWithURL:[url_push trimForURL]];
                    [webVC layoutBottomBarHeight:0];
                    UIViewController *vc = [UIApplication sharedApplication].delegate.window.rootViewController;
                    [vc presentViewController:webVC animated:YES completion:^{
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [webVC dismissViewControllerAnimated:YES completion:nil];
                        });
                    }];
                    
                } else {
                    //do nothing
                }
                
                hasNotificationEnterInURL = 0;
            }
        }];
    }
    completionHandler();
}

//前景觸發
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    
    NSDictionary * userInfo = notification.request.content.userInfo;
    NSLog(@"%@", userInfo);
    if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        
        completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert);
    }
}

@end
