//
//  NetWorkManager.h
//  SOIOEC
//
//  Created by sulier_J on 2014/4/18.
//  Copyright © 2014年 sulier_J. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void( ^ PicsRespSuc)(id response);
typedef void( ^ PicsRespFai)(id errFail);


@interface NetWorkManager : NSObject
@property(nonatomic,assign)float allCacheSize;
+ (instancetype)netManager;

+(void)clearAllCache;

+(void)GET_PicListOfSearchWord:(NSString *)searchText startInd:(int)startIndex Response:(PicsRespSuc)picsResp FailsErr:(PicsRespFai)err;

+(void)GET_CatagrayPicListKeyWords:(NSString *)keyWord startInd:(int)startIndex Response:(PicsRespSuc)picsResp FailsErr:(PicsRespFai)err;

+(void)GET_PrettyPicCatagoryResponse:(PicsRespSuc)picResp FailsErr:(PicsRespFai)err;

+(void)GET_PrettyPicCatagoryDetailsAtStartIndex:(NSString *)startIndex CatagoriesID:(NSString *)ID Response:(PicsRespSuc)picResp FailsErr:(PicsRespFai)err;
@end
