//
//  WJItemsControlView.h
//  SOIOEC
//
//  Created by sulier_J on 2017/6/24.
//  Copyright © 2017年 sulier_J. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ZLCItemsConfig : NSObject

@property(nonatomic,assign)float itemWidth;        //default is 0
@property(nonatomic,strong)UIFont *itemFont;       //default is 16
@property(nonatomic,strong)UIColor *textColor;     //default is COLOR_Gray_Dark
@property(nonatomic,strong)UIColor *selectedColor; //default is COLOR_Green

@property(nonatomic,assign)float linePercent;  //default is 0.8
@property(nonatomic,assign)float lineHieght;   //default is 2.5


@end


typedef void (^ZLCItemsControlViewTapBlock)(NSInteger index,BOOL animation);

@interface ZLCItemsControlView : UIScrollView

@property(nonatomic,strong)ZLCItemsConfig *config;
@property(nonatomic,strong)NSArray *titleArray;
@property(nonatomic,assign)BOOL tapAnimation;//default is YES;
@property(nonatomic,readonly)NSInteger currentIndex;
@property(nonatomic,copy)ZLCItemsControlViewTapBlock tapItemWithIndex;

-(void)moveToIndex:(float)index; //called in scrollViewDidScroll

-(void)endMoveToIndex:(float)index;  //called in scrollViewDidEndDecelerating

@end
