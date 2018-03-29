//
//  PrettyCollectionCell.h
//  SOIOEC
//
//  Created by sulier_J on 2017/6/24.
//  Copyright © 2017年 sulier_J. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataObject.h"
@interface PrettyCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *urlImageView;
@property(nonatomic,weak)DataObject *model;
@end
