//
//  InputCover.h
//  SOIOEC
//
//  Created by sulier_J on 2014/3/25.
//  Copyright © 2014年 sulier_J. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^TapGesture)();
@interface ZLCCover : UIView
@property(nonatomic,copy)TapGesture gesture;
@end
