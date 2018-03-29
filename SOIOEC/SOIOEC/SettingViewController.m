//
//  SettingViewController.m
//  SOIOEC
//
//  Created by sulier_J on 2014/4/18.
//  Copyright © 2014年 sulier_J. All rights reserved.
//

#import "SettingViewController.h"
#import "EnshiredController.h"
#import "APPObject.h"
#import "NetWorkManager.h"
#import "IPhoneRelates.h"
#import <UMSocialCore/UMSocialCore.h>
#import <UShareUI/UMSocialUIManager.h>
#import "AppDelegate.h"
#import "SudokuViewController.h"
#import "GuideController.h"
#import "ZLCCirclePieProgressView.h"
static CGFloat maxCache = 20;  //10M
@interface SettingViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    ZLCCirclePieProgressView *circle;
}

@property(nonatomic,strong)NSMutableArray *items;
@property(nonatomic,strong)UITableView *moreTableView;
@property(nonatomic,strong)NSMutableArray *enshiredDatas;
@property (nonatomic, assign) BOOL gestureOpen;
@end

@implementation SettingViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self getPlistData];
    [self loadMoreUIs];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.moreTableView) {
        [self.moreTableView reloadData];
    }
}

-(void)getPlistData
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"morelist" ofType:@"plist"];
    NSMutableArray *data = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    self.items = data;
}
-(void)loadMoreUIs
{
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [APPObject defaultApp].width, [APPObject defaultApp].height) style:UITableViewStyleGrouped];
    tableView.dataSource = self;
    tableView.delegate   = self;
    self.moreTableView = tableView;
    [self.view addSubview:tableView];

}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title = [self.items objectAtIndex:section][@"name"];
    UILabel *header = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, [APPObject defaultApp].width, 35)];
    [header setText:title];
    [header setTextAlignment:NSTextAlignmentCenter];
    return header;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    
    return 0.001f;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *detArr = [self.items objectAtIndex:section][@"details"];
    return detArr.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.items.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}


/**
  *cell_Description
   1:description_group
   2:description_listView
  */

static NSString *groupCellID = @"description_group";
static NSString *listCellID = @"description_listView";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *groups = self.items[indexPath.section];
    NSArray *items = groups[@"details"];
    NSDictionary *item = items[indexPath.row];
    NSString *description = item[@"description"];
    NSString *name = item[@"item"];
    BOOL     indicate = [item[@"indicate"] boolValue];
    UITableViewCell *cell = nil;
    if ([description isEqualToString:groupCellID])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:description];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:description];
        }else
        {
            for (UIView *su in cell.contentView.subviews) {
                [su removeFromSuperview];
            }
        }
        [self cell:cell IndexPath:indexPath];
        cell.textLabel.text = name;
        
    }else if([description isEqualToString:listCellID])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:description];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:description];
        }else
        {
            for (UIView *su in cell.contentView.subviews) {
                [su removeFromSuperview];
            }
        }

        [self cell:cell IndexPath:indexPath];

        cell.textLabel.text = name;
    }
    cell.accessoryType = indicate? UITableViewCellAccessoryDisclosureIndicator:UITableViewCellAccessoryNone;
    cell.imageView.image = [UIImage imageNamed:item[@"iconName"]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self didClickcell:[tableView cellForRowAtIndexPath:indexPath] IndexPath:indexPath];
}

-(void)didClickcell:(UITableViewCell *)cell IndexPath:(NSIndexPath *)indexpath
{
    switch ((indexpath.section+1)*10+indexpath.row) {
        case 10:  //常见问题解答
        {
            [self settingGuide];
        }
            break;
        case 11:  //分享此软件
        {
            [self shareMyApp];
        }
            break;
        case 12:  //清除缓存
        {
            [self clearAllCache];
            [NSTimer scheduledTimerWithTimeInterval:0.3 repeats:YES block:^(NSTimer * _Nonnull timer) {
                [cell.detailTextLabel setText:[self getAppCache]];
                circle.progress = (CGFloat)([[self getAppCache] floatValue]/maxCache);
                if (circle.progress == 0) {
                    [timer invalidate];
                }
            }];
            [cell.detailTextLabel performSelector:@selector(setText:) withObject:[self getAppCache] afterDelay:4];
        }
            break;
        case 13:  //设置密码
        {
        }
            break;
        case 14:  //检查软件版本
        {
            [cell.detailTextLabel setText:[self getAppVersion]];
        }
            break;
        case 20:  //收藏
        {
            NSArray *datas = [IPhoneRelates enshiredManager].enshiredDatas;
            EnshiredController *enshire = [[EnshiredController alloc]init];
            enshire.source = (NSMutableArray *)datas;
            enshire.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:enshire animated:YES];
        }
            break;

        case 30: //app推荐
        {
            
        }
            break;

        default:
            break;
    }
}

-(void)cell:(UITableViewCell *)cell IndexPath:(NSIndexPath *)indexpath
{

    switch ((indexpath.section+1)*10+indexpath.row) {
        case 10:
        {
            
        }
            break;
        case 11:
        {
            
        }
            break;
        case 12:
        {
            circle = [[ZLCCirclePieProgressView alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - 50, 4, cell.bounds.size.height-8, cell.bounds.size.height-8)];
            [cell.contentView addSubview:circle];
            if ([[self getAppCache] floatValue] >= maxCache) {
                [cell.detailTextLabel setText:[NSString stringWithFormat:@"缓存数据(%@):请清理缓存",[self getAppCache]]];
                circle.progress = 1;
            }else
            {
                [cell.detailTextLabel setText:[self getAppCache]];
                NSLog(@"cacheDataSize = %f",(CGFloat)([[self getAppCache] floatValue]/maxCache));
                circle.progress = (CGFloat)([[self getAppCache] floatValue]/maxCache);
            }
        }
            break;
        case 13:
        {
            UISwitch *sw = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - 60, 5, 50, 30)];
            [sw addTarget:self action:@selector(swChange:) forControlEvents:UIControlEventValueChanged];
            sw.on = [[NSUserDefaults standardUserDefaults] boolForKey:kGesture];
            [cell.contentView addSubview:sw];

        }
            break;
        case 14:
        {
            [cell.detailTextLabel setText:[self getAppVersion]];

        }
            break;
        case 20:
        {
            
        }
            break;
        case 21:
        {
            
        }
            break;
        case 22:
        {
            
        }
            break;
        case 23:
        {
            
        }
            break;
        case 30:
        {
            
        }
            break;
        default:
            break;
    }
}



/**
 壁纸设置引导
 */
-(void)settingGuide
{
    GuideController *guide = [[GuideController alloc]init];
    guide.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:guide animated:YES];
}


/**
 密码设置
 @param sw 切换
 */
- (void)swChange:(UISwitch *)sw{
    if(sw.isOn){
        _gestureOpen = YES;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kGesture];

        SudokuViewController *vc = [[SudokuViewController alloc]init];
        vc.type = WTSudokuViewTypeSetting;
        [self presentViewController:vc animated:YES completion:nil];
    }else{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kGesture];
        _gestureOpen = NO;
        [self.moreTableView reloadData];
    }
}

/**
 获取app版本
 */
-(NSString *)getAppVersion
{
   return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}
/**
 获取所有缓存大小
 @return ad
 */
-(NSString *)getAppCache
{
    float cache = [NetWorkManager netManager].allCacheSize;
    return [NSString stringWithFormat:@"%fM",cache];
}

/**
 清除所有缓存
 */
-(void)clearAllCache
{
    [NetWorkManager clearAllCache];
}

-(void)shareMyApp
{
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        [self shareWebPageToPlatformType:platformType];
        NSLog(@"userInfo = %@",userInfo);
    }];
}


/**
 以何种方式分享

 @param platformType 分享平台
 */
-(void)shareWebPageToPlatformType:(UMSocialPlatformType)platformType
{
    UIImage *shareImage = [UIImage imageNamed:@"share_addtion_picture"];
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    //创建网页内容对象
    NSString* thumbURL = myAPPUrl;
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:@"我一直想跟你说:" descr:@"" thumImage:shareImage];
    //设置网页地址
    shareObject.webpageUrl = thumbURL;
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        if (error) {
            UMSocialLogInfo(@"************Share fail with error %@*********",error);
        }else{
            if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                UMSocialShareResponse *resp = data;
                UMSocialLogInfo(@"response message is %@",resp.message);
                //第三方原始返回的数据
                UMSocialLogInfo(@"response originalResponse data is %@",resp.originalResponse);
                
            }else{
                UMSocialLogInfo(@"response data is %@",data);
            }
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"保存失败" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
        [alert show];    }];
}

@end
