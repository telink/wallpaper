//
//  ResponseObject.m
//  SOIOEC
//
//  Created by sulier_J on 2014/3/28.
//  Copyright © 2014年 sulier_J. All rights reserved.
//

#import "ResponseObject.h"
#import "DataObject.h"
#import "MJExtension.h"
@interface ResponseObject()<MJKeyValue>

@end

@implementation ResponseObject
+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"errNO": @"errno"};
}
+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"data": [DataObject class]};
}
@end
