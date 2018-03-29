//
//  WallPagesViewController.m
//  SOIOEC
//
//  Created by sulier_J on 2014/3/28.
//  Copyright © 2014年 sulier_J. All rights reserved.
//

#import "WallPagesViewController.h"
#import "ZLCItemsControlView.h"
#import "NetWorkManager.h"
#import "PrettyURLModel.h"
#import "ValueModel.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "ZLCShopCell.h"
#import "ZLCModel.h"
#import "ResponseObject.h"
#import "DataObject.h"
#import "PrettyCollectionView.h"
#import "PrettyCollectionCell.h"
#import "SDImageCache.h"
#import "KSPhotoItem.h"
#import "KSPhotoBrowser.h"
#import "ZLCErrorAlert.h"
@interface WallPagesViewController ()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,KSPhotoBrowserDelegate>
{
    ZLCItemsControlView              *_itemControlView;
    MJRefreshNormalHeader           *header;
    MJRefreshAutoStateFooter        *footer;
}

@property(nonatomic,strong)NSMutableArray *source;
@property(nonatomic,strong)UITableView    *blankTableView;
@end
static NSString * const CellId = @"shop";

@implementation WallPagesViewController

-(NSMutableArray *)source
{
    if (!_source) {
        _source = [[NSMutableArray alloc]init];
    }
    return _source;
}

-(UITableView *)blankTableView
{
    if (!_blankTableView) {
        _blankTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 50, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)) style:UITableViewStylePlain];
        [_blankTableView setBackgroundColor:[UIColor clearColor]];
        [_blankTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        __block typeof (self)weakSelf = self;
        _blankTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [weakSelf getCatagoryList];
            [_blankTableView.mj_header performSelector:@selector(endRefreshing) withObject:nil afterDelay:3];
        }];
        [_blankTableView setHidden:NO];

    }
    return _blankTableView;
}

-(void)endRefresh
{
    
}

-(void)setUpUIs
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.blankTableView setHidden:YES];
    });
    float widht = [UIScreen mainScreen].bounds.size.width;
    float heith = [UIScreen mainScreen].bounds.size.height;
    float itmeWidth = (widht/2)-2;
    float itemHeight = itmeWidth*900/1600;
    UIScrollView *scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 60, widht, heith-100)];
    scroll.delegate = self;
    scroll.pagingEnabled = YES;
    scroll.contentSize = CGSizeMake(widht*self.source.count, 100);
    for (int i=0; i<self.source.count; i++) {
        ValueModel *vm = self.source[i];
        NSString *cellID = [NSString stringWithFormat:@"identifer_%@",vm.ID];
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.itemSize = CGSizeMake(itmeWidth, itemHeight);
        layout.minimumInteritemSpacing = 1;
        layout.minimumLineSpacing = 1;
        layout.sectionInset = UIEdgeInsetsMake(layout.minimumLineSpacing, 0, 0, 0);
        PrettyCollectionView *collection = [[PrettyCollectionView alloc] initWithFrame:CGRectMake(i*widht, 0, widht, heith-100) collectionViewLayout:layout];
        collection.backgroundColor = [UIColor whiteColor];
        collection.tag = [vm.ID integerValue];
        collection.model = self.source[i];
        collection.delegate = self;
        collection.dataSource = self;
        UINib *nib = [UINib nibWithNibName:@"PrettyCollectionCell" bundle:nil];
        [collection registerNib:nib forCellWithReuseIdentifier:cellID];
        [scroll addSubview:collection];
        __block typeof (self)weakSelf = self;
        header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [weakSelf getNewPartData:vm];
        }];
        collection.mj_header = header;
        footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
            [weakSelf getMorePartData:vm];
        }];
        collection.mj_footer = footer;
    }
    [self.view addSubview:scroll];
    
    //头部控制的segMent
    ZLCItemsConfig *config = [[ZLCItemsConfig alloc]init];
    config.itemWidth = widht/4.0;
    
    _itemControlView = [[ZLCItemsControlView alloc]initWithFrame:CGRectMake(0, 60-44, widht, 44)];
    _itemControlView.tapAnimation = YES;
    _itemControlView.config = config;
    NSMutableArray *titleArray = [[NSMutableArray alloc]init];
    for (ValueModel *vm in self.source) {
        [titleArray addObject:vm.name];
    }
    _itemControlView.titleArray = titleArray;
    __weak typeof (scroll)weakScrollView = scroll;
    __weak typeof (self)weakself = self;
    [_itemControlView setTapItemWithIndex:^(NSInteger index,BOOL animation){
        [weakScrollView scrollRectToVisible:CGRectMake(index*weakScrollView.frame.size.width, 0.0, weakScrollView.frame.size.width,weakScrollView.frame.size.height) animated:animation];
        NSLog(@"%ld",index);
        if (index < self.source.count)
        {
            ValueModel *vm = weakself.source[index];
            if (!vm.contains.data.count) {
                [weakself launchRefreshAndGetData:vm];
            }
        }
    }];
    [self.view addSubview:_itemControlView];
}





-(void)launchRefreshAndGetData:(ValueModel *)model
{
    [self getNewPartData:model];
}

-(void)endRefresh:(ValueModel *)model
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UICollectionView *colV = [self.view viewWithTag:[model.ID integerValue]];
        [colV.mj_header endRefreshing];
        [colV.mj_footer endRefreshing];
    });
}



- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.blankTableView];
    [self getCatagoryList];
}


-(void)getCatagoryList
{
    [NetWorkManager GET_PrettyPicCatagoryResponse:^(id response) {
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *retStr = [[NSString alloc] initWithData:response encoding:enc];
        NSData *jsonData = [retStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError *resErr;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&resErr];
        if (resErr) {
            NSLog(@"err = %@",resErr);
        }
        PrettyURLModel *urlModel = [PrettyURLModel mj_objectWithKeyValues:dic];
        if (urlModel && urlModel.data.count) {
            self.source = (NSMutableArray *)urlModel.data;
            [self getNewPartData:self.source.firstObject];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setUpUIs];
            });
        }
    } FailsErr:^(id errFail) {
        NSLog(@"%@",errFail);
        NSError *err = (NSError *)errFail;
        if (err.code == -1009) {
            [ZLCErrorAlert showAlert:@"请检查网络状况" Message:@"当前网络未连接"];
        }
    }];
}



-(void)getNewPartData:(ValueModel *)model
{
    NSString *startIndex = [NSString stringWithFormat:@"%ld",(long)model.contains.minCol];
    [NetWorkManager GET_PrettyPicCatagoryDetailsAtStartIndex:startIndex CatagoriesID:model.ID Response:^(id response) {
        NSLog(@"%@",response);
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *retStr = [[NSString alloc] initWithData:response encoding:enc];
        NSData *jsonData = [retStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError *resErr;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&resErr];
        ResponseObject *urlModel = [ResponseObject mj_objectWithKeyValues:dic];
        for (ValueModel *vm in self.source) {
            if ([vm.ID isEqualToString:model.ID]) {
                BOOL flags = false;
                for (DataObject *obj in urlModel.data) {
                    DataObject *s = vm.contains.data.firstObject;
                    if ([obj.ID isEqualToString:s.ID]) {
                        flags = true;
                        break;
                    }
                }
                if (!flags) {
                    NSMutableArray *tmpArrs = [NSMutableArray arrayWithArray:urlModel.data];
                    [tmpArrs addObjectsFromArray:vm.contains.data];
                    urlModel.maxCol += 10;
                    urlModel.minCol = 0;
                    urlModel.data = tmpArrs;
                    vm.contains = urlModel;
                    break;
                }
                [self endRefresh:vm];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            UICollectionView *col = [self.view viewWithTag:[model.ID integerValue]];
            [col reloadData];
        });
    } FailsErr:^(id errFail) {
        
        NSLog(@"%@",errFail);
 
    }];
}


-(void)getMorePartData:(ValueModel *)model
{
    NSString *startIndex = [NSString stringWithFormat:@"%ld",model.contains.maxCol];
    [NetWorkManager GET_PrettyPicCatagoryDetailsAtStartIndex:startIndex CatagoriesID:model.ID Response:^(id response) {
        NSLog(@"%@",response);
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *retStr = [[NSString alloc] initWithData:response encoding:enc];
        NSData *jsonData = [retStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError *resErr;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&resErr];
        ResponseObject *urlModel = [ResponseObject mj_objectWithKeyValues:dic];
        for (ValueModel *vm in self.source) {
            if ([vm.ID isEqualToString:model.ID]) {
                BOOL flags = false;
                for (DataObject *obj in self.source) {
                    DataObject *s = urlModel.data.firstObject;
                    if ([obj.ID isEqualToString:s.ID]) {
                        flags = true;
                        break;
                    }
                }
                if (!flags) {
                    NSMutableArray *tmpArrs = [NSMutableArray arrayWithArray:vm.contains.data];
                    [tmpArrs addObjectsFromArray:urlModel.data];
                    urlModel.maxCol += 10;
                    urlModel.minCol = 0;
                    vm.contains.maxCol += 10;
                    vm.contains.minCol = 0;
                    vm.contains.data = tmpArrs;
                }
                [self endRefresh:vm];
                break;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            UICollectionView *col = [self.view viewWithTag:[model.ID integerValue]];
            [col reloadData];
        });
        NSLog(@"%@",dic);
    } FailsErr:^(id errFail) {
        NSLog(@"%@",errFail);
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isKindOfClass:[PrettyCollectionView class]]) {
        return;
    }
    float offset = scrollView.contentOffset.x;
    offset = offset/CGRectGetWidth(scrollView.frame);
    [_itemControlView moveToIndex:offset];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView isKindOfClass:[PrettyCollectionView class]]) {
        return;
    }
    float offset = scrollView.contentOffset.x;
    offset = offset/CGRectGetWidth(scrollView.frame);
    [_itemControlView endMoveToIndex:offset];
    int cur = offset;
    if (self.source.count > cur) {
        ValueModel *vm = self.source[cur];
        if (!vm.contains.data.count) {
            [self launchRefreshAndGetData:self.source[cur]];
//            [self getPartData:self.source[cur]];
        }
    }
}

#pragma mark - <UICollectionViewDataSource>
//自定义
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellID = [NSString  stringWithFormat:@"identifer_%ld",(long)collectionView.tag];
    ValueModel *model = ((PrettyCollectionView *)collectionView).model;
    PrettyCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell.model = model.contains.data[indexPath.row];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger a=indexPath.row;
    NSLog(@"a=%ld",a);
    ValueModel *model = ((PrettyCollectionView *)collectionView).model;
    NSMutableArray *items = @[].mutableCopy;
    for (int i = 0; i < model.contains.data.count; i++) {
        PrettyCollectionCell *cell = (PrettyCollectionCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        DataObject *dobc = model.contains.data[i];
        UIImageView *inputImgV = nil;
        if (!cell.urlImageView) {
            inputImgV = [[UIImageView alloc]initWithFrame:self.view.bounds];
            [inputImgV setImage:[UIImage imageNamed:@"place_holder_recomment"]];
            [inputImgV setBackgroundColor:[UIColor redColor]];
        }else
        {
            inputImgV = cell.urlImageView;
        }
        NSString *url = dobc.img_1600_900;
        KSPhotoItem *item = [KSPhotoItem itemWithSourceView:cell.urlImageView imageUrl:[NSURL URLWithString:url]];
        item.tag = 2;//配图
        [items addObject:item];
    }
    KSPhotoBrowser *browser = [KSPhotoBrowser browserWithPhotoItems:items selectedIndex:indexPath.row];
    browser.delegate = self;
    browser.dismissalStyle = KSPhotoBrowserInteractiveDismissalStyleScale;
    browser.backgroundStyle = KSPhotoBrowserBackgroundStyleBlack;
    browser.loadingStyle = KSPhotoBrowserImageLoadingStyleIndeterminate;
    browser.pageindicatorStyle = KSPhotoBrowserPageIndicatorStyleText;
    //    browser.bounces = _bounces;
    [browser showFromViewController:self];
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 2;
}

//分区数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
//个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    ValueModel *model = ((PrettyCollectionView *)collectionView).model;
    return model.contains.data.count;
}

#pragma mark KSPhotoBrowserDelegate
- (void)ks_photoBrowser:(KSPhotoBrowser *)browser didSelectItem:(KSPhotoItem *)item atIndex:(NSUInteger)index
{
    NSLog(@"clickItem = %ld",index);
}





@end
