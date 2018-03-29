//
//  ResultsViewController.m
//  SOIOEC
//
//  Created by sulier_J on 2014/3/25.
//  Copyright © 2014年 sulier_J. All rights reserved.
//

#import "ResultsViewController.h"
#import "ZLCWaterflowLayout.h"

#import "MJExtension.h"
#import "MJRefresh.h"

#import "JQLabelInfo.h"
#import "PicInfo.h"
#import "ZLCModel.h"

#import "KSPhotoBrowser.h"
#import "NetWorkManager.h"

#import "ZLCShopCell.h"

@interface ResultsViewController ()<YFWaterflowLayoutDelegate,UICollectionViewDelegate,UICollectionViewDataSource,KSPhotoBrowserDelegate>
{
    MJRefreshNormalHeader           *header;
    MJRefreshAutoStateFooter       *footer;
    NSInteger maxNum;

}
@property (weak,   nonatomic) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray   *picLists;
@property (nonatomic, strong) JQLabelInfo     *jqItem;
@property (nonatomic, strong) NSMutableArray   *itemAddedLists;@end

@implementation ResultsViewController
static long limitMinSize = 50*1000;
-(NSMutableArray *)picLists
{
    if (!_picLists) {
        _picLists = [[NSMutableArray alloc]init];
    }
    return _picLists;
}

-(NSMutableArray *)itemAddedLists
{
    if (!_itemAddedLists) {
        _itemAddedLists = [[NSMutableArray alloc]init];
    }
    return _itemAddedLists;
}

static NSString * const CellId = @"shop";



- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadNewThumbPic];
//    self.title = @"搜索";
    
    // 初始化数据
    //    [self.picLists addObjectsFromArray:[YFShop mj_objectArrayWithFilename:@"1.plist"]];
    
    // 创建布局
    ZLCWaterflowLayout *layout = [[ZLCWaterflowLayout alloc] init];
    layout.delegate = self;
    
    // 创建UICollectionView
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.backgroundColor = [UIColor whiteColor];
    [collectionView registerNib:[UINib nibWithNibName:@"YFShopCell" bundle:nil] forCellWithReuseIdentifier:CellId];
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
    
    header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadNewThumbPic];
    }];
    collectionView.mj_header = header;
    
    footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
        [self loadMoreThumbPic];
    }];
    collectionView.mj_footer = footer;
}

- (void)loadNewThumbPic
{
    [NetWorkManager GET_CatagrayPicListKeyWords:self.relateText startInd:0 Response:^(id response) {
        NSString *results = [[NSString alloc]initWithData:response encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSChineseSimplif)];
        if (results)
        {
            NSData *jsonData = [results dataUsingEncoding:NSUTF8StringEncoding];
            NSError *resErr;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&resErr];
            if (resErr)
            {
                NSLog(@"%@",resErr);
            }
            JQLabelInfo *item = [JQLabelInfo mj_objectWithKeyValues:dic];
            maxNum = (maxNum == 0)?(item.items.count):(maxNum);
            maxNum = item.items.count;
            BOOL flags = false;
            for (JQLabelInfo *info in self.picLists) {
                if (item.startIndex <= info.startIndex) {
                    flags = true;
                    break;
                }
            }
            if (!flags) {
                item = [self rebuildSource:item];
                if (item)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.picLists insertObject:item atIndex:0];
                        [self.itemAddedLists insertObjects:item.items atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, item.items.count)]];
                        [header endRefreshing];
                        [footer endRefreshing];
                        [self.collectionView reloadData];
                        self.jqItem = item;
                    });
                }
            }else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [header endRefreshing];
                    [footer endRefreshing];
                });
            }
            
        }else
        {
            NSLog(@"数据为空");
        }

    } FailsErr:^(id errFail) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [header endRefreshing];
        });
    }];
    
    
}

- (void)loadMoreThumbPic
{
    [NetWorkManager GET_CatagrayPicListKeyWords:self.relateText startInd:(int)maxNum+1 Response:^(id response) {
        NSString *results = [[NSString alloc]initWithData:response encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSChineseSimplif)];
        NSData *jsonData = [results dataUsingEncoding:NSUTF8StringEncoding];
        NSError *resErr;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&resErr];
        if (resErr)
        {
            NSLog(@"%@",resErr);
        }
        JQLabelInfo *item = [JQLabelInfo mj_objectWithKeyValues:dic];
        maxNum += item.items.count;
        BOOL flags = false;
        for (JQLabelInfo *info in self.picLists) {
            if (item.startIndex <= info.startIndex) {
                flags = true;
                break;
            }
        }
        if (!flags) {
            item = [self rebuildSource:item];
            if (item) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.picLists addObject:item];
                    [self.itemAddedLists addObjectsFromArray:item.items];
                    [footer endRefreshing];
                    [self.collectionView reloadData];
                    self.jqItem = item;
                });
            }
        }else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [header endRefreshing];
                [footer endRefreshing];
            });
        }
        
    } FailsErr:^(id errFail) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [footer endRefreshing];
        });
    }];
}

-(JQLabelInfo *)rebuildSource:(JQLabelInfo *)infos
{
    NSMutableArray *picsArrs = [[NSMutableArray alloc]init];
    for (PicInfo *pics in infos.items) {
        if (pics.width/pics.height < 0.7 && pics.size >= limitMinSize) {
            [picsArrs addObject:pics];
        }
    }
    infos.items = picsArrs;
    return infos;
}

#pragma mark - <YFWaterflowLayoutDelegate>
- (CGFloat)waterflowLayout:(ZLCWaterflowLayout *)waterflowLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath itemWidth:(CGFloat)itemWidth
{
    PicInfo *info = self.itemAddedLists[indexPath.item];
    return info.height*(itemWidth/info.width);
}


#pragma mark - <UICollectionViewDataSource>
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZLCShopCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellId forIndexPath:indexPath];
    PicInfo *info = self.itemAddedLists[indexPath.item];
    ZLCModel *shop = [[ZLCModel alloc]init];
    shop.w = info.width;
    shop.h = info.height;
    shop.price = info.markedTitle;
    shop.img = info.pic_url_noredirect;
    shop.smallImg = info.thumbUrl;
    cell.shop = shop;
    return cell;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
//    return 69;
    return self.itemAddedLists.count;
}

#pragma mark - <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
#pragma mark 跳转备选方案
#pragma mark 跳转第一方案

    NSMutableArray *items = @[].mutableCopy;
    for (int i = 0; i < self.itemAddedLists.count; i++) {
        ZLCShopCell *cell = (ZLCShopCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        PicInfo *info = self.itemAddedLists[i];

        NSString    *url  = info.pic_url_noredirect;
        UIImageView *inputImgV = nil;
        if (!cell.iconView) {
            inputImgV = [[UIImageView alloc]initWithFrame:self.view.bounds];
            [inputImgV setImage:[UIImage imageNamed:@"place_holder_prettyPic"]];
            [inputImgV setBackgroundColor:[UIColor redColor]];
        }else
        {
            inputImgV = cell.iconView;
        }
        KSPhotoItem *item = [KSPhotoItem itemWithSourceView:inputImgV imageUrl:[NSURL URLWithString:url]];
        item.tag = 3;
        item.thumbUrl = info.thumbUrl;
        item.width = info.width;
        item.height = info.height;
        [items addObject:item];
    }
    KSPhotoBrowser *browser = [KSPhotoBrowser browserWithPhotoItems:items selectedIndex:indexPath.row];
    browser.delegate = self;
    browser.dismissalStyle = KSPhotoBrowserInteractiveDismissalStyleScale;
    browser.backgroundStyle = KSPhotoBrowserBackgroundStyleBlack;
    browser.loadingStyle = KSPhotoBrowserImageLoadingStyleIndeterminate;
    browser.pageindicatorStyle = KSPhotoBrowserPageIndicatorStyleText;
    [browser showFromViewController:self];
}

//#pragma mark KSPhotoBrowserDelegate
- (void)ks_photoBrowser:(KSPhotoBrowser *)browser didSelectItem:(KSPhotoItem *)item atIndex:(NSUInteger)index {
    NSLog(@"selected index: %ld", index);
}
//
- (UIEdgeInsets)insetsInWaterflowLayout:(ZLCWaterflowLayout *)waterflowLayout
{
    return UIEdgeInsetsMake(2, 2, 2, 2);
}

- (int)maxColumnsInWaterflowLayout:(ZLCWaterflowLayout *)waterflowLayout
{
    return 3;
}

//- (CGFloat)rowMarginInWaterflowLayout:(YFWaterflowLayout *)waterflowLayout
//{
//    return 30;
//}

//- (CGFloat)columnMarginInWaterflowLayout:(YFWaterflowLayout *)waterflowLayout
//{
//    return 50;
//}


@end
