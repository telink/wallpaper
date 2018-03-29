//
//  EnshireImage.h
//  SOIOEC
//
//  Created by sulier_J on 2014/4/18.
//  Copyright © 2014年 sulier_J. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface EnshireImage : NSObject

@property(nonatomic,copy)NSString *enshiredUrl;
@property(nonatomic,assign)NSInteger tag;
@property(nonatomic,assign)BOOL      isEnshired;  //是否已经被选择
@property(nonatomic,assign)CGFloat   width;
@property(nonatomic,assign)CGFloat   height;
@end
