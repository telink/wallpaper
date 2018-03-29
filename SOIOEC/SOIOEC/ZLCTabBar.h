//
//  ZLCTabBar.h
//  SOIOEC
//
//  Created by sulier_J on 2014/4/18.
//  Copyright © 2014年 sulier_J. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ZHTabBarAnimation)
{
    ZHTabBarAnimationStyleScale,
    ZHTabBarAnimationStyleTranslation
};

@class ZLCTabBar;

@protocol ZHTabBarDelegate <NSObject>

@optional
- (void)tabBar:(ZLCTabBar *)tabBar didSelectedItemFrom:(NSInteger)from to:(NSInteger)to;

@end

@interface ZLCTabBar : UIView

/** 子控制器的tabBarItem数组*/
@property (nonatomic, strong) NSArray *items;

@property (nonatomic, weak) id<ZHTabBarDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame style:(ZHTabBarAnimation)style;

@end
