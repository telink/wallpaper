//
//  ZLCWaterflowLayout.h
//  SOIOEC
//
//  Created by sulier_J on 2014/4/18.
//  Copyright © 2014年 sulier_J. All rights reserved.
//


#import <UIKit/UIKit.h>

@class ZLCWaterflowLayout;

@protocol YFWaterflowLayoutDelegate <NSObject>
- (CGFloat)waterflowLayout:(ZLCWaterflowLayout *)waterflowLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath itemWidth:(CGFloat)itemWidth;

@optional
/**
 *  返回四边的间距, 默认是UIEdgeInsetsMake(10, 10, 10, 10)
 */
- (UIEdgeInsets)insetsInWaterflowLayout:(ZLCWaterflowLayout *)waterflowLayout;
/**
 *  返回最大的列数, 默认是3
 */
- (int)maxColumnsInWaterflowLayout:(ZLCWaterflowLayout *)waterflowLayout;
/**
 *  返回每行的间距, 默认是10
 */
- (CGFloat)rowMarginInWaterflowLayout:(ZLCWaterflowLayout *)waterflowLayout;
/**
 *  返回每列的间距, 默认是10
 */
- (CGFloat)columnMarginInWaterflowLayout:(ZLCWaterflowLayout *)waterflowLayout;
@end



@interface ZLCWaterflowLayout : UICollectionViewLayout
@property (nonatomic, weak) id<YFWaterflowLayoutDelegate> delegate;
@end
