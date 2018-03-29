//
//  ZLCShopCell.h
//  SOIOEC
//
//  Created by sulier_J on 2014/4/18.
//  Copyright © 2014年 sulier_J. All rights reserved.
//


#import <UIKit/UIKit.h>
@class ZLCModel;
@interface ZLCShopCell : UICollectionViewCell
@property (nonatomic, strong) ZLCModel *shop;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;

@end
