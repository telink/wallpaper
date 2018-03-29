//
//  PrettyCollectionView.h
//  SOIOEC
//
//  Created by sulier_J on 2017/6/24.
//  Copyright © 2017年 sulier_J. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ValueModel.h"
@interface PrettyCollectionView : UICollectionView
@property(nonatomic,strong)ValueModel *model;
@end
