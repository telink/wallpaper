//
//  ZLCShop.h
//  SOIOEC
//
//  Created by sulier_J on 2014/4/18.
//  Copyright © 2014年 sulier_J. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@interface ZLCModel : NSObject
/** 宽度 */
@property (nonatomic, assign) CGFloat w;
/** 高度 */
@property (nonatomic, assign) CGFloat h;
/** 价格 */
@property (nonatomic, copy) NSString *price;
/** 图片的url地址 */
@property (nonatomic, copy) NSString *img;
/** 小图片的url地址 */
@property (nonatomic, copy) NSString *smallImg;

@end
