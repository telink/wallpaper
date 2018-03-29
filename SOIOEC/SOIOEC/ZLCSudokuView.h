//
//  WTSudokuView.h
//  DirectBank
//
//  Created by sulier_J on 2014/4/18.
//  Copyright © 2014年 sulier_J. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - WTSudokuView

@class WTTouchView;
@interface ZLCSudokuView : UIView

- (instancetype)initWithFrame:(CGRect)frame;

@property (nonatomic, strong) WTTouchView *touchView;

- (void)showTitle:(NSString *)title;

- (void)showAvatar:(UIImage *)image;

@end

#pragma mark - WTSudokuButton

typedef NS_ENUM(NSInteger, WTSudokuButtonType) {
    WTSudokuButtonTypeNormal = 1,
    WTSudokuButtonTypeSelected,
    WTSudokuButtonTypeError
};

@interface ZLCSudokuButton : UIView

- (instancetype)initWithFrame:(CGRect)frame;

@property (nonatomic, assign) WTSudokuButtonType type;

@end

#pragma mark - WTTouchView

@protocol WTTouchSettingDelegate <NSObject>

- (BOOL)settingPassword:(NSString *)password;

@end

@protocol WTTouchVerifyDelegate <NSObject>

- (BOOL)verifyPassword:(NSString *)password;

@end

typedef NS_ENUM(NSInteger, WTTouchViewType) {
    WTTouchViewTypeSetting = 1,
    WTTouchViewTypeVerify
};

@interface WTTouchView : UIView

@property (nonatomic, strong) NSArray *btnArray;

@property (nonatomic, assign) BOOL success;

@property (nonatomic, assign) WTTouchViewType type;

@property (nonatomic, assign) id<WTTouchSettingDelegate> settingDelegate;

@property (nonatomic, assign) id<WTTouchVerifyDelegate> verifyDelegate;

- (instancetype)initWithFrame:(CGRect)frame;

@end
