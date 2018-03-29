//
//  PicInfo.h
//  SOIOEC
//
//  Created by sulier_J on 2014/4/18.
//  Copyright © 2014年 sulier_J. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PicInfo : NSObject
@property(nonatomic,assign)long cacheIndex;
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *markedTitle;
@property(nonatomic,assign)long size;
@property(nonatomic,copy)NSString *docid;
@property(nonatomic,copy)NSString *thumbUrl;
@property(nonatomic,copy)NSString *smallThumbUrl;
@property(nonatomic,copy)NSString *page_url;
@property(nonatomic,assign)long width;
@property(nonatomic,assign)long height;
@property(nonatomic,assign)long thumb_width;
@property(nonatomic,assign)long thumb_height;
@property(nonatomic,copy)NSString *title1;
@property(nonatomic,copy)NSString *title2;
@property(nonatomic,copy)NSString *surr1;
@property(nonatomic,copy)NSString *surr2;
@property(nonatomic,copy)NSString *pic_url_noredirect;
@property(nonatomic,copy)NSString *onTitle;
@end
