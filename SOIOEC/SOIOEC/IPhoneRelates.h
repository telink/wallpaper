//
//  iPhoneRelateVersion.h
//  SOIOEC

//  Created by sulier_J on 2014/3/25.
//  Copyright © 2014年 sulier_J. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPhoneRelates : NSObject
@property(nonatomic,strong)NSMutableArray *enshiredDatas;
+ (instancetype)enshiredManager;

+ (NSString *)getiphoneType;
@end
