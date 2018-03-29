//
//  ZLCHaleyPlugin.m
//  SOIOEC
//
//  Created by sulier_J on 2017/6/10.
//  Copyright © 2017年 sulier_J. All rights reserved.
//

#import "ZLCHaleyPlugin.h"
#import <UIKit/UIKit.h>
#import "APPObject.h"

@implementation ZLCHaleyPlugin
    
-(void)guidegotolabel:(CDVInvokedUrlCommand *)command
{
    NSLog(@"command = %@",command);
    NSMutableDictionary *infos = [[NSMutableDictionary alloc]init];
    NSString *localPart=command.arguments[0];
    NSString *localType=command.arguments[1];
    [infos setValue:localPart forKey:@"part"];
    [infos setValue:localType forKey:@"type"];
    [self.commandDelegate runInBackground:^{
        [[NSNotificationCenter defaultCenter]postNotificationName:guideNotification object:infos];
    }];
}


@end
