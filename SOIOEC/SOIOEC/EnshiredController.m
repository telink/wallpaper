//
//  EnshiredController.m
//  SOIOEC
//
//  Created by sulier_J on 2014/4/18.
//  Copyright © 2014年 sulier_J. All rights reserved.
//

#import "EnshiredController.h"
#import "ZLCItemsControlView.h"
#import "NetWorkManager.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "ZLCShopCell.h"
#import "ZLCModel.h"
#import "ResponseObject.h"
#import "PrettyCollectionView.h"
#import "PrettyCollectionCell.h"
#import "SDImageCache.h"
#import "KSPhotoItem.h"
#import "KSPhotoBrowser.h"
#import "ZLCErrorAlert.h"
#import "IPhoneRelates.h"
#import "EnshireImage.h"
#import "DataObject.h"
#import "ZLCWaterflowLayout.h"
@interface EnshiredController ()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,KSPhotoBrowserDelegate,YFWaterflowLayoutDelegate>
{
    ZLCItemsControlView              *_itemControlView;
    MJRefreshNormalHeader           *header;
    MJRefreshAutoStateFooter        *footer;
    ZLCWaterflowLayout               *layoutWallpaper;
    ZLCWaterflowLayout               *layoutOthers;
}

@property(nonatomic,strong)NSMutableArray *wallPapers;
@property(nonatomic,strong)NSMutableArray *charts;
@property(nonatomic,strong)NSMutableArray *others;
@property(nonatomic,strong)NSArray *titles;


@end

@implementation EnshiredController


-(NSArray *)titles
{
    if (!_titles) {
        _titles = @[@"壁纸",@"配图",@"其他"];
    }
    return _titles;
}

-(NSMutableArray *)wallPapers
{
    if (!_wallPapers) {
        _wallPapers = [[NSMutableArray alloc]init];
    }
    return _wallPapers;
}
-(NSMutableArray *)charts
{
    if (!_charts) {
        _charts = [[NSMutableArray alloc]init];
    }
    return _charts;
}

-(NSMutableArray *)others
{
    if (!_others) {
        _others = [[NSMutableArray alloc]init];
    }
    return _others;
}

-(void)setSource:(NSMutableArray *)source
{
    _source = source;
        [self.wallPapers removeAllObjects];
        [self.charts removeAllObjects];
        [self.others removeAllObjects];
        for (EnshireImage *model in source) {
            if (model.tag == 1) {
                [self.wallPapers addObject:model];
            }else if(model.tag == 2)
            {
                [self.charts addObject:model];
            }else if(model.tag == 3)
            {
                [self.others addObject:model];
            }
        }


}


static NSString * const CellId = @"shop";

-(void)setUpUIs
{
    [self.view setBackgroundColor:[UIColor whiteColor]];
    float widht = [UIScreen mainScreen].bounds.size.width;
    float heith = [UIScreen mainScreen].bounds.size.height;
    float itmeWidth = (widht/3)-2;
    float itemHeight = itmeWidth*900/1600;
    UIScrollView *scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 44, widht, heith-44)];
    scroll.delegate = self;
    scroll.pagingEnabled = YES;
    scroll.contentSize = CGSizeMake(widht*self.titles.count, 100);
    for (int i=0; i<3; i++) {
        UICollectionView *collections;
        if (i == 0 || i == 2) {   //流水布局
            ZLCWaterflowLayout *layout = [[ZLCWaterflowLayout alloc] init];
            layout.delegate = self;
            UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(i*widht, 0, widht, heith-100) collectionViewLayout:layout];
            collectionView.dataSource = self;
            collectionView.delegate = self;
            collectionView.backgroundColor = [UIColor whiteColor];
            [collectionView registerNib:[UINib nibWithNibName:@"YFShopCell" bundle:nil] forCellWithReuseIdentifier:CellId];
            [scroll addSubview:collectionView];
            collections = collectionView;
            (i == 0)?(layoutWallpaper = layout):(layoutOthers = layout);
        }else                     //普通布局
        {
            NSString *cellID = [NSString stringWithFormat:@"identifer_%d",i+1000];
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            layout.scrollDirection = UICollectionViewScrollDirectionVertical;
            layout.itemSize = CGSizeMake(itmeWidth, itemHeight);
            layout.minimumInteritemSpacing = 1;
            layout.minimumLineSpacing = 1;
            layout.sectionInset = UIEdgeInsetsMake(layout.minimumLineSpacing, 0, 0, 0);
            PrettyCollectionView *collection = [[PrettyCollectionView alloc] initWithFrame:CGRectMake(i*widht, 0, widht, heith-100) collectionViewLayout:layout];
            collection.backgroundColor = [UIColor whiteColor];
//            collection.model = self.source[i];
            collection.delegate = self;
            collection.dataSource = self;
            UINib *nib = [UINib nibWithNibName:@"PrettyCollectionCell" bundle:nil];
            [collection registerNib:nib forCellWithReuseIdentifier:cellID];
            [scroll addSubview:collection];
            collections = collection;;
        }
        collections.tag = i+1000;
    }
    [self.view addSubview:scroll];
    
    //头部控制的segMent
    ZLCItemsConfig *config = [[ZLCItemsConfig alloc]init];
    config.itemWidth = widht/3.0;
    
    _itemControlView = [[ZLCItemsControlView alloc]initWithFrame:CGRectMake(0, 60, widht, 44)];
    _itemControlView.tapAnimation = YES;
    _itemControlView.config = config;
    _itemControlView.titleArray = self.titles;
    __weak typeof (scroll)weakScrollView = scroll;
    [_itemControlView setTapItemWithIndex:^(NSInteger index,BOOL animation){
        [weakScrollView scrollRectToVisible:CGRectMake(index*weakScrollView.frame.size.width, 0.0, weakScrollView.frame.size.width,weakScrollView.frame.size.height) animated:animation];
        NSLog(@"%ld",index);
    }];
    [self.view addSubview:_itemControlView];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUIs];
//    [self getCatagoryList];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isKindOfClass:[UICollectionView class]]) {
        return;
    }
    float offset = scrollView.contentOffset.x;
    offset = offset/CGRectGetWidth(scrollView.frame);
    [_itemControlView moveToIndex:offset];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView isKindOfClass:[UICollectionView class]]) {
        return;
    }
    float offset = scrollView.contentOffset.x;
    offset = offset/CGRectGetWidth(scrollView.frame);
    [_itemControlView endMoveToIndex:offset];
    int cur = offset;
    if (self.source.count > cur) {

    }
}
#pragma mark - <YFWaterflowLayoutDelegate>
- (CGFloat)waterflowLayout:(ZLCWaterflowLayout *)waterflowLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath itemWidth:(CGFloat)itemWidth
{
    if (waterflowLayout == layoutWallpaper) {
        EnshireImage *image = self.wallPapers[indexPath.row];
        return image.height*(itemWidth/image.width);
    }else if(waterflowLayout == layoutOthers)
    {
        EnshireImage *image = self.others[indexPath.row];
        return image.height*(itemWidth/image.width);

    }
    return 0;
}

#pragma mark - <UICollectionViewDataSource>
//自定义
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView.tag-1000 == 0)       //壁纸
    {
        ZLCShopCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellId forIndexPath:indexPath];
        EnshireImage *image = self.wallPapers[indexPath.row];
        ZLCModel *shop = [[ZLCModel alloc]init];
        shop.w = image.width;
        shop.h = image.height;
        shop.img = image.enshiredUrl;
        shop.smallImg = image.enshiredUrl;
        cell.shop = shop;
        return cell;

        
    }else if(collectionView.tag-1000 == 1)   //配图
    {
        NSString *cellID = [NSString  stringWithFormat:@"identifer_%ld",(long)collectionView.tag];
        EnshireImage *image = self.charts[indexPath.row];
        PrettyCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
        DataObject *model = [[DataObject alloc]init];
        model.img_1600_900 = image.enshiredUrl;
        cell.model =model;
        return cell;

        
    }else if(collectionView.tag-1000 == 2)   //其他
    {
        ZLCShopCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellId forIndexPath:indexPath];
        EnshireImage *image = self.others[indexPath.row];
        ZLCModel *shop = [[ZLCModel alloc]init];
        shop.w = image.width;
        shop.h = image.height;
        shop.img = image.enshiredUrl;
        shop.smallImg = image.enshiredUrl;
        cell.shop = shop;
        return cell;
    }
//    cell.model = obj;
    return nil;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *sources = nil;
    if (collectionView.tag == 1000) {
        sources = self.wallPapers;
    }else if(collectionView.tag == 1001)
    {
        sources = self.charts;
    }else if(collectionView.tag == 1002)
    {
        sources = self.others;
    }
    NSMutableArray *items = @[].mutableCopy;
    for (int i = 0; i < sources.count; i++) {
        if (collectionView.tag == 1001) {
            PrettyCollectionCell *cell = (PrettyCollectionCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            EnshireImage *model = sources[i];
            UIImageView *inputImgV = nil;
            if (!cell.urlImageView) {
                inputImgV = [[UIImageView alloc]initWithFrame:self.view.bounds];
                [inputImgV setImage:[UIImage imageNamed:@"place_holder_recomment"]];
                [inputImgV setBackgroundColor:[UIColor redColor]];
            }else
            {
                inputImgV = cell.urlImageView;
            }
            NSString *url = model.enshiredUrl;
            KSPhotoItem *item = [KSPhotoItem itemWithSourceView:inputImgV imageUrl:[NSURL URLWithString:url]];
            item.tag = collectionView.tag-100+1;
            [items addObject:item];
        }else if(collectionView.tag == 1000 || collectionView.tag == 1002)
        {
            ZLCShopCell *cell = (ZLCShopCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            EnshireImage *model = sources[i];
            UIImageView *inputImgV = nil;
            if (!cell.iconView) {
                inputImgV = [[UIImageView alloc]initWithFrame:self.view.bounds];
                [inputImgV setImage:[UIImage imageNamed:@"place_holder_recomment"]];
                [inputImgV setBackgroundColor:[UIColor redColor]];
            }else
            {
                inputImgV = cell.iconView;
            }
            NSString *url = model.enshiredUrl;
            KSPhotoItem *item = [KSPhotoItem itemWithSourceView:inputImgV imageUrl:[NSURL URLWithString:url]];
            item.tag = collectionView.tag-100+1;
            [items addObject:item];
        }
        
        
        

    }
    KSPhotoBrowser *browser = [KSPhotoBrowser browserWithPhotoItems:items selectedIndex:indexPath.row];
    browser.delegate = self;
    browser.dismissalStyle = KSPhotoBrowserInteractiveDismissalStyleScale;
    browser.backgroundStyle = KSPhotoBrowserBackgroundStyleBlack;
    browser.loadingStyle = KSPhotoBrowserImageLoadingStyleIndeterminate;
    browser.pageindicatorStyle = KSPhotoBrowserPageIndicatorStyleText;
    [browser showFromViewController:self];
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 3;
}

//分区数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
//个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView.tag == 1000) {
        return self.wallPapers.count;
    }else if(collectionView.tag == 1001)
    {
        return self.charts.count;
    }
    return self.others.count;
}

#pragma mark KSPhotoBrowserDelegate
- (void)ks_photoBrowser:(KSPhotoBrowser *)browser didSelectItem:(KSPhotoItem *)item atIndex:(NSUInteger)index
{
    NSLog(@"clickItem = %ld",index);
}

@end
