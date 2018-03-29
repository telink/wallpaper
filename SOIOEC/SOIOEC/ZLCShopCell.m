//
//  ZLCShopCell.m
//  SOIOEC
//
//  Created by sulier_J on 2014/4/18.
//  Copyright © 2014年 sulier_J. All rights reserved.
//


#import "ZLCShopCell.h"
#import "ZLCModel.h"
#import "UIImageView+WebCache.h"

@interface ZLCShopCell()
//@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@end


@implementation ZLCShopCell

- (void)setShop:(ZLCModel *)shop
{
    _shop = shop;
    
    self.priceLabel.text = shop.price;
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:shop.smallImg] placeholderImage:[UIImage imageNamed:@"place_holder_prettyPic"]];
}

@end
