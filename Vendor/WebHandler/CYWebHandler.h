//
//  CYWebHandler.h
//  LuckyForever
//
//  Created by OD INTERNATIONAL 3 on 12/26/17.
//  Copyright © 2017 OD INTERNATIONAL 3. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CYWebHandler : NSObject
+(void) openWebWithURL:(NSURL *) url
       completeHandler: ( void (^)(BOOL success ) )successHandler;
+(void) openWebWithURL:(NSURL *) url;
@end
