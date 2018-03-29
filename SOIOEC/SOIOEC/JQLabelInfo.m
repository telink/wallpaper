//
//  JQLabelInfo.m
//  SOIOEC
//
//  Created by sulier_J on 2014/4/18.
//  Copyright © 2014年 sulier_J. All rights reserved.
//

#import "JQLabelInfo.h"
#import "PicInfo.h"
#import "MJExtension.h"
@interface JQLabelInfo()<MJKeyValue>

@end
@implementation JQLabelInfo
+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"items":[PicInfo class]};
}
@end
