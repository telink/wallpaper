//
//  ValueModel.m
//  SOIOEC
//
//  Created by sulier_J on 2014/3/28.
//  Copyright © 2014年 sulier_J. All rights reserved.
//

#import "ValueModel.h"
#import "MJExtension.h"
@interface ValueModel()<MJKeyValue>
@end
@implementation ValueModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"ID": @"id"};
}
@end
