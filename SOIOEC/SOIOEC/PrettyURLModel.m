//
//  PrettyURLModel.m
//  SOIOEC
//
//  Created by sulier_J on 2014/3/28.
//  Copyright © 2014年 sulier_J. All rights reserved.//

#import "PrettyURLModel.h"
#import "ValueModel.h"
#import "MJExtension.h"
@interface PrettyURLModel()<MJKeyValue>
@end
@implementation PrettyURLModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"errNO": @"errno"};
}
+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"data": [ValueModel class]};
}



@end
