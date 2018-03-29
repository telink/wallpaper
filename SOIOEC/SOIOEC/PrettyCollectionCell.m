//
//  PrettyCollectionCell.m
//  SOIOEC
//
//  Created by sulier_J on 2017/6/24.
//  Copyright © 2017年 sulier_J. All rights reserved.
//

#import "PrettyCollectionCell.h"
#import "UIImageView+WebCache.h"
@interface PrettyCollectionCell()

//@property (weak, nonatomic) IBOutlet UIImageView *urlImageView;
@end
@implementation PrettyCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setModel:(DataObject *)model
{
    _model = model;
    [self.urlImageView sd_setImageWithURL:[NSURL URLWithString:model.img_1600_900] placeholderImage:[UIImage imageNamed:@"place_holder_recomment"]];
}

@end
