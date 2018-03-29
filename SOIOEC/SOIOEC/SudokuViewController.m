//
//  SudokuViewController.m
//  SOIOEC
//
//  Created by sulier_J on 2014/4/18.
//  Copyright © 2014年 sulier_J. All rights reserved.
//


#import "SudokuViewController.h"
#import "ZLCSudokuView.h"
#import "KeychainItemWrapper.h"

@interface SudokuViewController ()<WTTouchSettingDelegate,WTTouchVerifyDelegate>

@property (nonatomic, strong) ZLCSudokuView *sudokuview;

@property (nonatomic, copy) NSString *tempPassword;

@property (nonatomic, assign) NSInteger repeatTime;

@end

@implementation SudokuViewController

@synthesize sudokuview;

- (void)viewDidLoad {
    [super viewDidLoad];
    _tempPassword = @"";
    _repeatTime = 5;
    if(_type == WTSudokuViewTypeSetting){
        if([[self keychainPassword] isEqualToString:@""]){
            [self setting];
        }else{
            [self resetting];
        }
    }else{
        if([[self keychainPassword] isEqualToString:@""]){
//            NSLog(@"未设置手势密码");
            
        }else{
            [self verity];
        }
    }
}

- (void)setting{
     sudokuview = [[ZLCSudokuView alloc]initWithFrame:self.view.bounds];
    [sudokuview.touchView setType:WTTouchViewTypeSetting];
    sudokuview.touchView.settingDelegate = self;
    [sudokuview showTitle:@"设置您的手势密码"];
    [self.view addSubview:sudokuview];
}

- (void)resetting{
    sudokuview = [[ZLCSudokuView alloc]initWithFrame:self.view.bounds];
    [sudokuview.touchView setType:WTTouchViewTypeVerify];
    sudokuview.touchView.verifyDelegate = self;
    [sudokuview showTitle:@"验证您的手势密码"];
    [self.view addSubview:sudokuview];
}

- (void)verity{
    sudokuview = [[ZLCSudokuView alloc]initWithFrame:self.view.bounds];
    [sudokuview.touchView setType:WTTouchViewTypeVerify];
    sudokuview.touchView.verifyDelegate = self;
    [sudokuview showTitle:@"验证您的手势密码"];
    [self.view addSubview:sudokuview];
}

- (BOOL)settingPassword:(NSString *)password{
    if([_tempPassword isEqualToString:@""]){
        _tempPassword = password;
        [sudokuview showTitle: @"确认您的手势密码"];
    }else {
        if([_tempPassword isEqualToString:password]){
            [sudokuview showTitle:@"手势密码设置成功"];
             [self saveKeychainPassword:password];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kGesture];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:nil];
//                [self.navigationController popViewControllerAnimated:YES];
            });
        }else{
            [sudokuview showTitle:@"与上次绘制不一致，请重新绘制"];
            return NO;
        }
    }
    return YES;
}

- (BOOL)verifyPassword:(NSString *)password{
    if([[self keychainPassword] isEqualToString:password]){
        if(_type == WTSudokuViewTypeSetting){
            [sudokuview showTitle:@"设置新的手势密码"];
            [sudokuview.touchView setType:WTTouchViewTypeSetting];
            sudokuview.touchView.verifyDelegate = nil;
            sudokuview.touchView.settingDelegate = self;
            [self clearKeychainPassword];
        }else{
            [sudokuview showTitle:@"验证成功"];
            _vertifyResults(YES);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        }
        
    }else {
        _repeatTime--;
        if(_repeatTime > 0)
            [sudokuview showTitle:[NSString stringWithFormat:@"密码错误，还可以再输入%ld次",_repeatTime]];
        else{
            _vertifyResults(NO);
            [sudokuview showTitle:@"启动自动毁灭模式，请扔掉你的手机！"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                abort();
            });
        }
        return NO;
    }
    return YES;
    
}

- (NSString *)keychainPassword{
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc]initWithIdentifier:@"Gesture" accessGroup:nil];
    return [keychain objectForKey:(__bridge id)kSecValueData];
}

- (BOOL)saveKeychainPassword:(NSString *)password{
    KeychainItemWrapper * keychin = [[KeychainItemWrapper alloc]initWithIdentifier:@"Gesture" accessGroup:nil];
    [keychin setObject:@"<帐号>" forKey:(__bridge id)kSecAttrAccount];
    [keychin setObject:password forKey:(__bridge id)kSecValueData];
    return YES;
}

- (void)clearKeychainPassword{
    KeychainItemWrapper * keychin = [[KeychainItemWrapper alloc]initWithIdentifier:@"Gesture" accessGroup:nil];
    [keychin resetKeychainItem];
}


@end
