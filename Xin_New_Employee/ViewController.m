//
//  ViewController.m
//  Xin_New_Employee
//
//  Created by Wu on 2019/3/25.
//  Copyright © 2019 Wu. All rights reserved.
//

#define AD_DURATION 5

#import "ViewController.h"
#import <AVOSCloud/AVOSCloud.h>
#import "ADWebViewController/ADWKWebViewController.h"
#import "UIVIew+Constraint/UIView+Constraint.h"
#import "NSString+URL/NSString+URL.h"

@interface ViewController ()

@property (strong, nonatomic) ADWKWebViewController *temporaryWebVC;
@property (assign, nonatomic) BOOL control;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (hasNotificationEnterInURL) { return; }
    
    [AVOSCloud setApplicationId:kAVOS_ID clientKey:kAVOS_KEY];
    [AVOSCloud setAllLogsEnabled:YES];
    
    AVQuery *dataQuery =  [AVQuery queryWithClassName:kAVOS_CLASS_NAME];
    
    __block ViewController *weakSelf = self;
    [dataQuery getObjectInBackgroundWithId:kAVOS_OBJECT_ID block:^(AVObject * _Nullable avObject, NSError * _Nullable error) {
        //print
        NSLog(@"%@", avObject);
        
        //get value
        weakSelf.control = ((NSNumber *)[avObject objectForKey:@"control"]).boolValue;
        NSString *url_ad = [avObject objectForKey:@"url_ad"];
        NSString *url_hide = [avObject objectForKey:@"url_hide"];
        
        //web vc
        NSString *webURL;
        if (![self isChangeToHideView]) {
            webURL = url_ad;
        } else {
            webURL = url_hide;
        }
        weakSelf.temporaryWebVC = [ADWKWebViewController initWithURL:[webURL trimForURL]];
        
        if (![self isChangeToHideView]) {
            //ad
            [weakSelf.temporaryWebVC layoutBottomBarHeight:0];
            [weakSelf.view addSubview:weakSelf.temporaryWebVC.view];
            [weakSelf.temporaryWebVC.view constraints:weakSelf.view];
            [weakSelf performSelector:@selector(adWebViewDismiss) withObject:nil afterDelay:AD_DURATION];
        } else {
            //hide
            [weakSelf performSelector:@selector(changeToHideView) withObject:nil afterDelay:AD_DURATION];
        }
    }];
}

#pragma mark - Private

- (void)changeToHideView {
    [[UIApplication sharedApplication].keyWindow setRootViewController:self.temporaryWebVC];
}

- (void)adWebViewDismiss {
    if (self.temporaryWebVC != nil) {
        [self.temporaryWebVC.view removeAllConstraints];
        [self.temporaryWebVC.view removeFromSuperview];
        self.temporaryWebVC = nil;
    }
}

- (BOOL)isChangeToHideView {
    if (self.control && [self isChinaArea]) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isChinaArea {
    NSString * language = [[NSLocale preferredLanguages] firstObject];
    if ([language isEqualToString:@"zh-Hans-CN"]) {
        return YES;
    } else {
        return NO;
    }
}

@end
