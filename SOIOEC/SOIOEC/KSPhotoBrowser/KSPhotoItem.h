//
//  KSPhotoItem.h
//  SOIOEC
//
//  Created by sulier_J on 2014/3/25.
//  Copyright © 2014年 sulier_J. All rights reserved.
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KSPhotoItem : NSObject

@property (nonatomic, strong, readonly) UIView *sourceView;
@property (nonatomic, strong, readonly) UIImage *thumbImage;
@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, strong, readonly) NSURL *imageUrl;
@property (nonatomic, strong) NSString *thumbUrl;
@property (nonatomic, assign)           NSInteger tag;
@property (nonatomic, assign) BOOL finished;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

- (instancetype)initWithSourceView:(UIView *)view
                        thumbImage:(UIImage *)image
                          imageUrl:(NSURL *)url;
- (instancetype)initWithSourceView:(UIImageView *)view
                          imageUrl:(NSURL *)url;
- (instancetype)initWithSourceView:(UIImageView *)view
                             image:(UIImage *)image;

+ (instancetype)itemWithSourceView:(UIView *)view
                         thumbImage:(UIImage *)image
                           imageUrl:(NSURL *)url;
+ (instancetype)itemWithSourceView:(UIImageView *)view
                           imageUrl:(NSURL *)url;
+ (instancetype)itemWithSourceView:(UIImageView *)view
                              image:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
