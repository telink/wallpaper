//
//  BaseMainViewController.m
//  SOIOEC
//
//  Created by sulier_J on 2014/3/25.
//  Copyright © 2014年 sulier_J. All rights reserved.
//

#import "BaseMainViewController.h"
#import "ZLCCover.h"
#define HEX_COLOR(x_RGB) [UIColor colorWithRed:((float)((x_RGB & 0xFF0000) >> 16))/255.0 green:((float)((x_RGB & 0xFF00) >> 8))/255.0 blue:((float)(x_RGB & 0xFF))/255.0 alpha:1.0f]
@interface BaseMainViewController ()<UISearchBarDelegate,UICollectionViewDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    SearchTextBlock searchResults;
//    BOOL            isSearching;
}
@property (nonatomic,weak)UITextField *searchField;
@property (nonatomic,weak)UISearchBar *customSearchBar;
//@property (nonatomic,strong)NSArray *myArray;//搜索记录的数组
@property (nonatomic,strong)NSMutableArray *myMutableArray;
@property (nonatomic,weak)UITableView *tableView;
@property (nonatomic,strong)ZLCCover *coverView;
@end
static NSString *searchRecordCell = @"cell";

@implementation BaseMainViewController

-(ZLCCover *)coverView
{
    if (!_coverView) {
         _coverView = [[ZLCCover alloc]initWithFrame:self.view.bounds];
        [_coverView setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.3]];
        [_coverView setHidden:YES];
        __weak typeof (self)weakSelf = self;
        __weak typeof (ZLCCover *)weakCover = _coverView;
         _coverView.gesture = ^{
             [weakSelf.searchField resignFirstResponder];
             [weakCover setHidden:YES];
         };
    }
    return _coverView;
}

-(void)loadSearchBarInputBlock:(SearchTextBlock)textBlock
{
    searchResults = textBlock;
    [self loadNavItems];
    [self readNSUserDefaults];
}

-(void)loadNavItems
{
    self.navigationController.navigationBar.barTintColor=[UIColor redColor];
    self.view.backgroundColor = [UIColor whiteColor];
    UIView *BJView = [[UIView alloc]initWithFrame:CGRectMake(40, 33,self.view.frame.size.width-80,40)];
    self.navigationItem.titleView = BJView;
    
    UISearchBar *customSearchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0,BJView.bounds.size.width,40)];
    customSearchBar.delegate = self;
    customSearchBar.placeholder = @"请输入搜索内容";
    [customSearchBar becomeFirstResponder];
    [BJView addSubview:customSearchBar];
    self.customSearchBar = customSearchBar;
    customSearchBar.backgroundImage = [[UIImage alloc] init];
    customSearchBar.barTintColor =  HEX_COLOR(0xF2F2F2);
    UITextField *searchField = [customSearchBar valueForKey:@"searchField"];
    if (searchField) {
        [searchField setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:0.9]];
        searchField.layer.cornerRadius = 2.0f;
        searchField.frame  = CGRectMake(0, 0, customSearchBar.bounds.size.width, 40);
        searchField.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor blackColor]);
        searchField.layer.borderWidth = 1;
        searchField.layer.masksToBounds = YES;
    }
    self.searchField = searchField;
    //修正光标颜色
    [searchField setTintColor:[UIColor grayColor]];

    //修改搜索图标
    UIImageView *img = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"nav_search_icon"]];
    img.frame = CGRectMake(10, 0,20,20);
    self.searchField.leftView = img;
    self.searchField.leftViewMode = UITextFieldViewModeAlways;
    //修改clearButton
    self.searchField.clearButtonMode=UITextFieldViewModeWhileEditing;
    [self.view addSubview:self.coverView];
}




#pragma mark -tableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.myMutableArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:searchRecordCell];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:searchRecordCell];
    }
    return cell;

    return cell;
}
#pragma mark - tableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *hisView = [[UIView alloc]init];
    hisView.backgroundColor = [UIColor whiteColor];
    //搜索历史标题
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.text = @"搜索历史";
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.textColor = [UIColor colorWithRed:134.0/255 green:134.0/255 blue:134.0/255 alpha:1.0];
    [hisView addSubview:titleLabel];
    
    //删除历史记录
    UIButton *Deletbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [Deletbtn setImage:[UIImage imageNamed:@"历史删除"] forState:UIControlStateNormal];
    [hisView addSubview:Deletbtn];
    [Deletbtn addTarget:self action:@selector(deleteBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    if (self.myMutableArray.count == 0) {
        
        hisView.frame = CGRectZero;
        titleLabel.frame = CGRectZero;
        Deletbtn.frame = CGRectZero;
        
    }else{
        
        hisView.frame = CGRectMake(0, 0, self.view.frame.size.width, 45);
        titleLabel.frame = CGRectMake(20, 15, 60, 15);
        Deletbtn.frame = CGRectMake(self.view.frame.size.width-50,0,40, 45);
    }
    return hisView;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.searchField.text = self.myMutableArray[self.myMutableArray.count-1-indexPath.row];
    searchResults(self.searchField.text);
    
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        if (indexPath.row < [self.myMutableArray count]) {
            
            //删除单个记录的时候，也要按照之前的排序
            [self.myMutableArray removeObjectAtIndex:self.myMutableArray.count-1-indexPath.row];
            
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            
            [self saveNSUserDefaults];
            
        }
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (!self.myMutableArray.count) {
        return 0;
    }
    return 35;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    scrollView = self.tableView;
    [self.searchField resignFirstResponder];
}
//实时监听searchBar的输入框变化
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
//    isSearching = NO;
    [self.coverView setHidden:NO];
    NSLog(@"textDidChange:%@",searchText);
}


-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self.coverView setHidden:NO];
    NSLog(@"searchBarShouldBeginEditing:%@",searchBar);
    return YES;

}
-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    NSLog(@"searchBarShouldEndEditing:%@",searchBar);
    [_coverView setHidden:YES];

    return YES;

}


-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.coverView setHidden:NO];
    if (self.searchField.text.length > 0) {
        [self readNSUserDefaults];
        
    }
    
    //判断是否有相同记录，有就移除
    if (self.myMutableArray == nil) {
        
        self.myMutableArray = [[NSMutableArray alloc]init];
        
    }else if ([self.myMutableArray containsObject:self.searchField.text]){
        
        [self.myMutableArray removeObject:self.searchField.text];
    }
    [self.myMutableArray addObject:self.searchField.text];
    [self saveNSUserDefaults];
    searchResults(self.searchField.text);
    [searchBar resignFirstResponder];
    
}
/** 删除历史记录 */
- (void)deleteBtnAction:(UIButton *)sender{
    
    self.myMutableArray = nil;
    [self.tableView reloadData];
}
/** 本地保存 */
-(void)saveNSUserDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.myMutableArray forKey:@"myArray"];
    [defaults synchronize];
    [self.tableView reloadData];
}
/** 取出缓存的数据 */
-(void)readNSUserDefaults{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    //读取数组NSArray类型的数据
    NSArray * myArray = [userDefaultes arrayForKey:@"myArray"];
    
    //这里要把数组转换为可变数组
    NSMutableArray *myMutableArray = [NSMutableArray arrayWithArray:myArray];
    
    self.myMutableArray = myMutableArray;
    [self.tableView reloadData];
}






@end
