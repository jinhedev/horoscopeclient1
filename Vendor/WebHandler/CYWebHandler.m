//
//  CYWebHandler.m
//  LuckyForever
//
//  Created by OD INTERNATIONAL 3 on 12/26/17.
//  Copyright © 2017 OD INTERNATIONAL 3. All rights reserved.
//

#import "CYWebHandler.h"

@implementation CYWebHandler
+(void) openWebWithURL:(NSURL *) url
       completeHandler: ( void (^)(BOOL success ) )successHandler{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //[CYNotificationHandler addEventToCoredata:[CYNotificationHandler configEventDict:userInfo]];
        //NSLog(@"%@",userInfo);
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:successHandler];
    });
}
+(void) openWebWithURL:(NSURL *) url{
    dispatch_async(dispatch_get_main_queue(), ^{
        //[CYNotificationHandler addEventToCoredata:[CYNotificationHandler configEventDict:userInfo]];
        //NSLog(@"%@",userInfo);
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    });
}

@end
