//
//  AppDelegate.m
//  SealMic
//
//  Created by lichenfeng on 2020/5/20.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "AppDelegate.h"
#import "RCMicRoomListViewController.h"
#import "RCMicAppService.h"
#import "RCMicLoginViewController.h"
#import <Bugly/Bugly.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#ifndef DEBUG
    //release 模式下日志重定向到本地文件
    [RCMicUtil redirectLogToLocal];
    [Bugly startWithAppId:BuglyKey];
#endif
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    
    RCMicRoomListViewController *roomListVC = [[RCMicRoomListViewController alloc] init];
    UINavigationController *rootNC = [[UINavigationController alloc] initWithRootViewController:roomListVC];
    rootNC.navigationBar.hidden = YES;
    self.window.rootViewController = rootNC;
    
    [self checkEnvironment];
    [self updateIfNeeded];
    [self visitorLogin];
    [self addNotificationObserver];

    return YES;
}

- (void)checkEnvironment {
    if ([RCMicHTTPUtility demoServer].length == 0) {
        UIAlertController *tipAlert = [UIAlertController alertControllerWithTitle:@"提示" message:@"运行前请先将您应用的相关环境填写到 RCMicMacro 头文件中，否则无法正常使用" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [tipAlert addAction:confirmAction];
        [self.window.rootViewController presentViewController:tipAlert animated:YES completion:nil];
    }
}

- (void)updateIfNeeded {
    [[RCMicAppService sharedService] checkVersion:^(RCMicVersionInfo * _Nullable newVersion) {
        //有新版本时
        if (newVersion) {
            NSString *finalURL = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@", newVersion.downloadUrl];
            RCMicMainThread(^{
                UIAlertController *updateController = [UIAlertController alertControllerWithTitle:RCMicLocalizedNamed(@"update_title") message:newVersion.releaseNote preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:RCMicLocalizedNamed(@"update_cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                }];
                
                UIAlertAction *agreeAction = [UIAlertAction actionWithTitle:RCMicLocalizedNamed(@"update_agree") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    if (@available(iOS 10.0, *)) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:finalURL] options:@{} completionHandler:^(BOOL success) {
                            exit(0);
                        }];
                    } else {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:finalURL]];
                        exit(0);
                    }
                }];
                [updateController addAction:agreeAction];
                if (!newVersion.forceUpgrade) {
                    [updateController addAction:cancelAction];
                }
                [self.window.rootViewController presentViewController:updateController animated:YES completion:nil];
            })
        }
    }];
}

- (void)visitorLogin {
    //查询是否登录过
    RCMicCachedUserInfo *userInfo = [RCMicAppService sharedService].currentUser;
    if (userInfo) {
        //配置当前登录用户信息
        [[RCMicAppService sharedService] configUserEnvironment:userInfo];
    } else {
        //请求游客登录接口
        [self requestVisitorLogin];
    }
}

- (void)addNotificationObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginRefresh) name:RCMicUserNotLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kickedOffLineAction) name:RCMicKickedOfflineNotification object:nil];
}

- (void)requestVisitorLogin {
    NSString *uuid = [UIDevice currentDevice].identifierForVendor.UUIDString;
    NSString *name = [RCMicUtil randomName];
    NSString *portrait = [RCMicUtil randomPortrait];
    [[RCMicAppService sharedService] visitorLogin:name portrait:portrait deviceId:uuid success:^(RCMicCachedUserInfo * _Nonnull userInfo) {
        //配置当前登录用户信息
        [[RCMicAppService sharedService] configUserEnvironment:userInfo];
    } error:^(RCMicHTTPCode errorCode) {
        //这里根据具体产品需求进行处理，比如提示用户登录失败或者根据具体错误码类型处理不同场景
    }];
}

- (void)loginRefresh {
    //清空当前登录用户信息
    [[RCMicAppService sharedService] configUserEnvironment:nil];
    [self requestVisitorLogin];
}

/// 用户在别处登录，被挤掉提示
- (void)kickedOffLineAction {
    [self loginRefresh];
    
    //弹出提示框被挤下线
    UIAlertController *loginAlertController = [UIAlertController alertControllerWithTitle:nil message:RCMicLocalizedNamed(@"another_login_alert") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *agreeAction = [UIAlertAction actionWithTitle:RCMicLocalizedNamed(@"another_login_agree") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        RCMicLoginViewController *loginVC = [[RCMicLoginViewController alloc] init];
        UINavigationController *currentNavigationController = (UINavigationController*) (self.window.rootViewController);
        [currentNavigationController pushViewController:loginVC animated:YES];
    }];
    [loginAlertController addAction:agreeAction];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:loginAlertController animated:true completion:nil];
}
@end
