//
//  PrettyURLModel.h
//  SOIOEC
//
//  Created by sulier_J on 2014/3/28.
//  Copyright © 2014年 sulier_J. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PrettyURLModel : NSObject
@property(nonatomic,copy)NSString *errNO;
@property(nonatomic,copy)NSString *consume;
@property(nonatomic,copy)NSString *errmsg;
@property(nonatomic,copy)NSString *total;
@property(nonatomic,strong)NSArray *data;
@end
