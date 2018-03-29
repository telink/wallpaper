//
//  KSPhotoView.h
//  SOIOEC
//
//  Created by sulier_J on 2014/3/25.
//  Copyright © 2014年 sulier_J. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "KSProgressLayer.h"

NS_ASSUME_NONNULL_BEGIN

extern const CGFloat kKSPhotoViewPadding;

@protocol KSImageManager;
@class KSPhotoItem;

@interface KSPhotoView : UIScrollView

@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) KSProgressLayer *progressLayer;
@property (nonatomic, strong, readonly) KSPhotoItem *item;

- (instancetype)initWithFrame:(CGRect)frame imageManager:(id<KSImageManager>)imageManager;
- (void)setItem:(KSPhotoItem *)item determinate:(BOOL)determinate;
- (void)resizeImageView;
- (void)cancelCurrentImageLoad;

@end

NS_ASSUME_NONNULL_END
