//
//  APPObject.h
//  SOIOEC
//
//  Created by sulier_J on 2014/4/18.
//  Copyright © 2014年 sulier_J. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
static NSString *guideNotification   = @"Cordova_Guide_Notification";
static NSString *myAPPUrl = @"itms-apps://itunes.apple.com/app/?id=1250294940";
static NSString *commentAPPUrl = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=1250294940";
static NSString *QQ_Umeng_redirectUrl = @"http://mobile.umeng.com/social";
static NSString *Sina_Umeng_redirectUrl = @"https://sns.whalecloud.com/sina2/callback";
static NSString *Umeng_AppKey = @"5955c57882b6356a050017dc";
static NSString *QQ_AppID = @"1106257172";
static NSString *QQ_AppKey = @"VbGI4fUvvNKnpTZ5";
static NSString *Sina_AppID = @"4071289178";
static NSString *Sina_AppSecret = @"4d67d453b149200d2983576b1861daf2";
@interface APPObject : NSObject
@property(nonatomic,assign)CGFloat width;
@property(nonatomic,assign)CGFloat height;
@property(nonatomic,assign)CGRect  rect;
+(APPObject *)defaultApp;
@end
