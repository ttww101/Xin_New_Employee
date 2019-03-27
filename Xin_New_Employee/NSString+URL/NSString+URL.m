//
//  NSString+URL.m
//  Xin_New_Employee
//
//  Created by Wu on 2019/3/26.
//  Copyright © 2019 Wu. All rights reserved.
//

#import "NSString+URL.h"

@implementation NSString (URL)

- (NSString *)trimForURL {
    NSString *trimURL = self;
    
    //white space
    trimURL = [trimURL stringByTrimmingCharactersInSet:[NSCharacterSet  whitespaceAndNewlineCharacterSet]];
    
    //http
    if(![trimURL containsString:@"://"]){
        trimURL = [@"http://" stringByAppendingString:trimURL];
    }
    
    return trimURL;
}

@end
