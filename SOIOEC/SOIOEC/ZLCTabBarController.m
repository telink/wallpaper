//
//  ZLCTabBarController.m
//  SOIOEC
//
//  Created by sulier_J on 2014/4/18.
//  Copyright © 2014年 sulier_J. All rights reserved.
//


#import "ZLCTabBarController.h"
#import "ZLCTabBar.h"

#import "SearchViewController.h"
#import "WallPagesViewController.h"
#import "RecommendController.h"
#import "SettingViewController.h"

#import "BaseNavigationController.h"




@interface ZLCTabBarController () <ZHTabBarDelegate>

/** 所有子控制器的tabBarItem*/
@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation ZLCTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.items = [NSMutableArray array];
    
    // 添加子控制器
    [self setUpAllChildViewController];
    
    // 设置tabBar
    [self setUpTabBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 删除系统自带的tabBarButton
    for (UIView *tabBarButton in self.tabBar.subviews) {
        if (![tabBarButton isKindOfClass:[ZLCTabBar class]]) {
            [tabBarButton removeFromSuperview];
        }
    }
}

- (void)setUpAllChildViewController
{
    RecommendController *friends = [[RecommendController alloc] init];
    friends.view.backgroundColor = [UIColor whiteColor];
    [self setOneChildViewController:friends withImage:[UIImage imageNamed:@"tab_icon_friend_normal"] selectedImage:[UIImage imageNamed:@"tab_icon_friend_press"] title:@"推荐" addNavigationBar:YES];
    
    WallPagesViewController *quiz = [[WallPagesViewController alloc] init];
    quiz.view.backgroundColor = [UIColor whiteColor];
    [self setOneChildViewController:quiz withImage:[UIImage imageNamed:@"tab_icon_quiz_normal"] selectedImage:[UIImage imageNamed:@"tab_icon_quiz_press"] title:@"美图" addNavigationBar:NO];
    
    SearchViewController *news = [[SearchViewController alloc] init];
    news.view.backgroundColor = [UIColor whiteColor];
    [self setOneChildViewController:news withImage:[UIImage imageNamed:@"tab_icon_news_normal"] selectedImage:[UIImage imageNamed:@"tab_icon_news_press"] title:@"搜索" addNavigationBar:YES];

    SettingViewController *more = [[SettingViewController alloc] init];
    more.view.backgroundColor = [UIColor whiteColor];
    [self setOneChildViewController:more withImage:[UIImage imageNamed:@"tab_icon_more_normal"] selectedImage:[UIImage imageNamed:@"tab_icon_more_press"] title:@"设置" addNavigationBar:YES];
}

- (void)setOneChildViewController:(UIViewController *)viewController withImage:(UIImage *)image selectedImage:(UIImage *)selectedImage title:(NSString *)title addNavigationBar:(BOOL)isAdd
{
    
    if (isAdd) {
        viewController.title = title;
        viewController.tabBarItem.title = title;
        viewController.tabBarItem.image = image;
        viewController.tabBarItem.selectedImage = selectedImage;
        
        [self.items addObject:viewController.tabBarItem];
        
        BaseNavigationController *nvg = [[BaseNavigationController alloc] initWithRootViewController:viewController];
        [self addChildViewController:nvg];
    }else
    {
        viewController.title = title;
        viewController.tabBarItem.title = title;
        viewController.tabBarItem.image = image;
        viewController.tabBarItem.selectedImage = selectedImage;
        [self.items addObject:viewController.tabBarItem];
//        BaseNavigationController *nvg = [[BaseNavigationController alloc] initWithRootViewController:viewController];
        [self addChildViewController:viewController];


    }

    
}

- (void)setUpTabBar
{
    ZLCTabBar *tabBar = [[ZLCTabBar alloc] initWithFrame:self.tabBar.bounds style:ZHTabBarAnimationStyleTranslation];
    
    tabBar.delegate = self;
    
    tabBar.items = self.items;
    
    [self.tabBar addSubview:tabBar];
}
- (void)tabBar:(ZLCTabBar *)tabBar didSelectedItemFrom:(NSInteger)from to:(NSInteger)to
{
    self.selectedIndex = to;
}
@end
