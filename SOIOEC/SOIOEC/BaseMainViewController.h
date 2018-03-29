//
//  BaseMainViewController.h
//  SOIOEC
//
//  Created by sulier_J on 2014/3/25.
//  Copyright © 2014年 sulier_J. All rights reserved.
//

#import "FoundationController.h"

typedef void (^SearchTextBlock)(NSString *serchText);

@interface BaseMainViewController : FoundationController

-(void)loadSearchBarInputBlock:(SearchTextBlock)textBlock;

@end
