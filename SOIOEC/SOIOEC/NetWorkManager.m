//
//  NetWorkManager.m
//  SOIOEC
//
//  Created by sulier_J on 2014/4/18.
//  Copyright © 2014年 sulier_J. All rights reserved.
//

#import "NetWorkManager.h"
#import "BANetManager.h"
#import "BANetManagerCache.h"
#import "AFNetworking.h"
@interface NetWorkManager()

@end

@implementation NetWorkManager
+ (instancetype)netManager
{
    /*! 为单例对象创建的静态实例，置为nil，因为对象的唯一性，必须是static类型 */
    static id sharedBANetManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedBANetManager = [[super allocWithZone:NULL] init];
    });
    return sharedBANetManager;
    
}

-(float)allCacheSize
{
    return [BANetManagerCache ba_getAllHttpCacheSize];
}

+(void)clearAllCache
{
    [BANetManagerCache ba_clearAllHttpCache];
}



+(void)GET_PicListOfSearchWord:(NSString *)searchText startInd:(int)startIndex Response:(PicsRespSuc)picsResp FailsErr:(PicsRespFai)err
{
    NSString *baseUrl = @"http://pic.sogou.com/pics";
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:@"0" forKey:@"mood"];
    [params setValue:@"0" forKey:@"picformat"];
    [params setValue:@"1" forKey:@"mode"];
    [params setValue:@"2" forKey:@"di"];
    [params setValue:@"05009900" forKey:@"w"];
    [params setValue:@"1" forKey:@"dr"];
    [params setValue:@"pic.sogou.com" forKey:@"_asf"];
    [params setValue:@"ajax" forKey:@"reqType"];
    [params setValue:searchText forKey:@"query"];
    [params setValue:[NSString stringWithFormat:@"%d",startIndex] forKey:@"start"];
    [params setValue:@"1" forKey:@"tn"];
    
    [BANetManager ba_request_GETWithUrlString:baseUrl isNeedCache:YES parameters:params successBlock:picsResp failureBlock:err progress:nil];
}

+(void)GET_CatagrayPicListKeyWords:(NSString *)keyWord startInd:(int)startIndex Response:(PicsRespSuc)picsResp FailsErr:(PicsRespFai)err//NSISOLatin1StringEncoding
{
    [NetWorkManager GET_PicListOfSearchWord:keyWord startInd:startIndex Response:picsResp FailsErr:err];
}

+(void)GET_PrettyPicCatagoryResponse:(PicsRespSuc)picResp FailsErr:(PicsRespFai)err
{
    NSString *baseUrl = @"http://cdn.apc.360.cn/index.php?c=WallPaper&a=getAllCategoriesV2&from=360chrome";
    [BANetManager ba_request_GETWithUrlString:baseUrl isNeedCache:YES parameters:nil successBlock:picResp failureBlock:err progress:nil];

}

+(void)GET_PrettyPicCatagoryDetailsAtStartIndex:(NSString *)startIndex CatagoriesID:(NSString *)ID Response:(PicsRespSuc)picResp FailsErr:(PicsRespFai)err
{
    NSString *baseUrl = @"http://wallpaper.apc.360.cn/index.php";
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:@"WallPaper" forKey:@"c"];
    [params setValue:@"getAppsByCategory" forKey:@"a"];
    [params setValue:ID forKey:@"cid"];
    [params setValue:startIndex forKey:@"start"];
    [params setValue:@"10" forKey:@"count"];
    [params setValue:@"360chrome" forKey:@"from"];
    [BANetManager ba_request_GETWithUrlString:baseUrl isNeedCache:YES parameters:params successBlock:picResp failureBlock:err progress:nil];
}

@end
