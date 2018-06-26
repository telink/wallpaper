//
//  APPObject.m
//  SOIOEC
//
//  Created by sulier_J on 2014/4/18.
//  Copyright © 2014年 sulier_J. All rights reserved.
//

#import "APPDataEntity.h"

@implementation APPDataEntity
-(CGFloat)width
{
    if (!_width) {
        _width = [UIScreen mainScreen].bounds.size.width;
    }
    return _width;
}


-(CGFloat)height
{
    if (!_height) {
        _height = [UIScreen mainScreen].bounds.size.height;
    }
    return _height;
}

-(CGRect)rect
{
    if (CGRectIsEmpty(_rect)) {
        _rect = CGRectMake(0, 0, self.width, self.height);
    }
    return _rect;

}

+(APPDataEntity *)defaultApp
{
    static APPDataEntity *manager = nil;
    static dispatch_once_t token;
    dispatch_once(&token,^{
        if(manager == nil){
           manager = [[APPDataEntity alloc]init];
        }
    } );
    return manager;
}


@end
