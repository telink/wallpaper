//
//  SearchViewController.m
//  SOIOEC
//
//  Created by sulier_J on 2014/3/25.
//  Copyright © 2014年 sulier_J. All rights reserved.
//

#import "SearchViewController.h"
#import "RightCollectionViewCell.h"
#import "LeftCollectionViewCell.h"
#import "ResultsViewController.h"
#import "IPhoneRelates.h"


@interface SearchViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    NSInteger flags;
}

@property(nonatomic,strong)UICollectionView *leftCollectionView;
@property(nonatomic,strong)UICollectionView *rightCollectionView;
@property(nonatomic,strong)UISegmentedControl *segmentControll;
@property(nonatomic,strong)NSMutableArray *datas;
@property(nonatomic,strong)NSMutableArray *segmentDatas;

@end

@implementation SearchViewController

static NSString *leftIndentifer = @"leftIndentiferCellID";
static NSString *RightIndentifer = @"RightIndentiferCellID";

-(UICollectionView *)leftCollectionView
{
    if (!_leftCollectionView) {
        float widht = [UIScreen mainScreen].bounds.size.width;
        float heith = [UIScreen mainScreen].bounds.size.height;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.itemSize = CGSizeMake(widht/4, widht/4);
        layout.minimumInteritemSpacing = 1;
        layout.minimumLineSpacing = 1;
        layout.sectionInset = UIEdgeInsetsMake(layout.minimumLineSpacing, 0, 0, 0);
        UICollectionView *collection = [[UICollectionView alloc] initWithFrame:CGRectMake(8, 5, (widht/5)+15, heith-100+44) collectionViewLayout:layout];
        collection.backgroundColor = [UIColor whiteColor];
        collection.showsVerticalScrollIndicator = false;
        collection.delegate = self;
        collection.dataSource = self;
        UINib *nib = [UINib nibWithNibName:@"LeftCollectionViewCell" bundle:nil];
        [collection registerNib:nib forCellWithReuseIdentifier:leftIndentifer];
        _leftCollectionView = collection;
    }
    return _leftCollectionView;
}

-(UICollectionView *)rightCollectionView
{
    if (!_rightCollectionView) {
        float widht = [UIScreen mainScreen].bounds.size.width;
        float heith = [UIScreen mainScreen].bounds.size.height;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.itemSize = CGSizeMake(widht/5,(widht/5)+20);
        layout.minimumInteritemSpacing = 1;
        layout.minimumLineSpacing = 1;
        layout.sectionInset = UIEdgeInsetsMake(layout.minimumLineSpacing, 0, 0, 0);
        UICollectionView *collection = [[UICollectionView alloc] initWithFrame:CGRectMake((widht/4)+25, 20+44+15+35, widht-((widht/4)+30), heith-100-55) collectionViewLayout:layout];
        collection.backgroundColor = [UIColor whiteColor];
        collection.delegate = self;
        collection.dataSource = self;
        UINib *nib = [UINib nibWithNibName:@"RightCollectionViewCell" bundle:nil];
        [collection registerNib:nib forCellWithReuseIdentifier:RightIndentifer];
        _rightCollectionView = collection;
    }
    return _rightCollectionView;
}

-(UISegmentedControl *)segmentControll
{
    if (!_segmentControll) {
        float widht = [UIScreen mainScreen].bounds.size.width;
        UISegmentedControl *segmentedControl = [[UISegmentedControl alloc]initWithItems:self.segmentDatas];
        segmentedControl.frame = CGRectMake((widht/4)+(widht*3/8-75),20+44+15,150,30);
        segmentedControl.selectedSegmentIndex = self.segmentDatas.count;
        segmentedControl.tintColor = [UIColor redColor];
        segmentedControl.selectedSegmentIndex = YES;
        segmentedControl.selectedSegmentIndex = 0;   //设置m
        [self.view addSubview:segmentedControl];
        _segmentControll = segmentedControl;
    }
    return _segmentControll;
}

-(NSMutableArray *)segmentDatas
{
    if (!_segmentDatas) {
        _segmentDatas = [[NSMutableArray alloc]init];
        [_segmentDatas addObjectsFromArray:@[@"壁纸",@"配图"]];
    }
    return _segmentDatas;
}


-(NSMutableArray *)datas
{
    if (!_datas) {
        _datas = [[NSMutableArray alloc]init];
    }
    return _datas;
}

-(NSString *)searchKeyText:(NSString *)text
{
    NSString *rets = nil;
    if (_segmentControll.selectedSegmentIndex == 0) {
        rets = [NSString stringWithFormat:@"%@高清%@%@",[IPhoneRelates getiphoneType],text,_segmentDatas[_segmentControll.selectedSegmentIndex]];

    }else if(_segmentControll.selectedSegmentIndex == 1)
    {
        rets = [NSString stringWithFormat:@"高清%@%@",text,_segmentDatas[_segmentControll.selectedSegmentIndex]];
    }
    NSLog(@"searchKeyText = %@",rets);
    return rets;
}



- (void)viewDidLoad {
    [self getPlistData];
    [self.view addSubview:self.leftCollectionView];
    [self.view addSubview:self.rightCollectionView];
    [self.view addSubview:self.segmentControll];
    [self loadSearchBarInputBlock:^(NSString *serchText) {
        [self pushToResultsViewControllerWithText:serchText];
    }];
    [super viewDidLoad];
}

-(void)getPlistData
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"searchlist" ofType:@"plist"];
    NSDictionary *dataDic = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSArray *data = dataDic[@"list"];
    self.datas = [NSMutableArray arrayWithArray:data];
}

#pragma mark - <UICollectionViewDataSource>
//自定义
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = nil;
    if (collectionView == self.leftCollectionView) {
        NSDictionary *dic = self.datas[indexPath.row];
        NSArray *a = dic[@"rightItems"];
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:leftIndentifer forIndexPath:indexPath];
        ((LeftCollectionViewCell *)cell).leftImage.image = [UIImage imageNamed:a.firstObject];
        ((LeftCollectionViewCell *)cell).leftLabel.font = [UIFont boldSystemFontOfSize:17];
        ((LeftCollectionViewCell *)cell).leftLabel.text = dic[@"leftItem"];
        UIColor *color = (flags == indexPath.row)?[UIColor redColor]:[UIColor blackColor];
        ((LeftCollectionViewCell *)cell).leftLabel.backgroundColor = color;

        
    }else if(collectionView == self.rightCollectionView)
    {
        NSDictionary *item = self.datas[flags];
        NSArray *names = item[@"rightItems"];
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:RightIndentifer forIndexPath:indexPath];
        NSLog(@",names[indexPath.row] = %@",names[indexPath.row]);
        ((RightCollectionViewCell *)cell).rightImage.image = [UIImage imageNamed:names[indexPath.row]];
        ((RightCollectionViewCell *)cell).itemNameLb.text = names[indexPath.row];
    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.leftCollectionView) {
        flags = indexPath.row;
        for (int i =0; i < self.datas.count; i++) {
            LeftCollectionViewCell *leCell = (LeftCollectionViewCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if (i == flags) {
                [leCell.leftLabel setBackgroundColor:[UIColor redColor]];
            }else
            {
                [leCell.leftLabel setBackgroundColor:[UIColor blackColor]];
            }
        }
        [self.rightCollectionView reloadData];

    }else if(collectionView == self.rightCollectionView)
    {
        NSDictionary *item = self.datas[flags];
        NSArray *names = item[@"rightItems"];
        [self pushToResultsViewControllerWithText:names[indexPath.row]];
    }
    NSInteger a=indexPath.row;
    NSLog(@"a=%ld",(long)a);
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
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
    if (collectionView == self.leftCollectionView) {
        return self.datas.count;
    }else
    {
        NSArray *right = self.datas[flags][@"rightItems"];
        return right.count;
    }
}



-(void)pushToResultsViewControllerWithText:(NSString *)text
{
    if ([NSThread currentThread] == [NSThread mainThread]) {
        ResultsViewController *results = [[ResultsViewController alloc]init];
        results.hidesBottomBarWhenPushed = YES;
        results.relateText = [self searchKeyText:text];
        [self.navigationController pushViewController:results animated:YES];
    }else
    {
        __block typeof (self)weakSelf = self;
        __block typeof (NSString *)weakText = text;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf pushToResultsViewControllerWithText:weakText];
        });
    }
}

@end
