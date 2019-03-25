//
//  ViewController.m
//  Xin_New_Employee
//
//  Created by Wu on 2019/3/25.
//  Copyright © 2019 Wu. All rights reserved.
//

#define kAVOS_ID @"BCW1aEd3HHSOkU5zuKQt0h3M-gzGzoHsz"
#define kAVOS_KEY @"0F8Pnm6F1SWqgYqqcHcyVRQO"
#define kAVOS_CLASS_NAME @"LCData"
#define kAVOS_OBJECT_ID @"5c98c22112215f00728a07a3"

#import "ViewController.h"
#import <AVOSCloud/AVOSCloud.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [AVOSCloud setApplicationId:kAVOS_ID clientKey:kAVOS_KEY];
    [AVOSCloud setAllLogsEnabled:YES];
    
    AVQuery *dataQuery =  [AVQuery queryWithClassName:kAVOS_CLASS_NAME];
    
    [dataQuery getObjectInBackgroundWithId:kAVOS_OBJECT_ID block:^(AVObject * _Nullable avObject, NSError * _Nullable error) {
        //print
        NSLog(@"%@", avObject);
        
        //get value
        BOOL control = ((NSNumber *)[avObject objectForKey:@"control"]).boolValue;
        NSString *url_ad = [avObject objectForKey:@"url_ad"];
        NSString *url_hide = [avObject objectForKey:@"url_hide"];
        
        if (!control) {
            
        } else {
            
        }
    }];
}


@end
