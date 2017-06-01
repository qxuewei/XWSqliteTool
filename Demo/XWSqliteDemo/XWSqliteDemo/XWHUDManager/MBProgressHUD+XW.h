//
//  MBProgressHUD+XW.h
//  XWHUDManager
//
//  Created by 邱学伟 on 2017/4/27.
//  Copyright © 2017年 邱学伟. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (XW)

#pragma mark - 隐藏HUD
/// 隐藏蒙版
+ (void)hide;
/// 隐藏当前View上的HUD
+ (void)hideInView;
/// 隐藏当前window上的HUD
+ (void)hideInWindow;
/// 延时隐藏蒙版(无论在view还是window)
+ (void)hideDelay:(int)delaySeconds;

#pragma mark - 小菊花
/// 在window展示一个小菊花
+ (void)showHUD;
/// 在当前View展示一个小菊花
+ (void)showHUDInView;
/// 在window展示一个 loading... 小菊花
+ (void)showHUDLoadingEN;
/// 在window展示一个 加载中... 小菊花
+ (void)showHUDLoadingCH;
/// 在window展示一个有文本小菊花
+ (void)showHUDMessage:(NSString *)message;
/// 限时隐藏在window展示一个 loading... 小菊花
+ (void)showHUDLoadingAfterDelay:(int)afterSecond;
/// 限时隐藏在window展示一个有文本小菊花
+ (void)showHUDMessage:(NSString *)message afterDelay:(int)afterSecond;
/// 限时隐藏在view展示一个有文本小菊花
+ (void)showHUDMessageInView:(NSString *)message afterDelay:(int)afterSecond;

#pragma mark - 文本提示框
/// 在window上显示文本提示框
+ (void)showTipHUD:(NSString *)message;
/// 在window上显示文本提示框
+ (void)showTipHUDInView:(NSString *)message;
/// 限时隐藏在window展示一个有文本提示框
+ (void)showTipHUD:(NSString *)message afterDelay:(int)afterSecond;
/// 限时隐藏在view展示一个有文本提示框
+ (void)showTipHUDInView:(NSString *)message afterDelay:(int)afterSecond;

#pragma mark - 提示图片
/// 正确提示
+ (void)showSuccessHUD;
/// 有文本正确提示
+ (void)showSuccessTipHUD:(NSString *)message;
/// 在view展示有文本正确提示
+ (void)showSuccessTipHUDInView:(NSString *)message;
/// 错误提示
+ (void)showErrorHUD;
/// 有文本错误提示
+ (void)showErrorTipHUD:(NSString *)message;
/// 在view有文本错误提示
+ (void)showErrorTipHUDInView:(NSString *)message;
/// 信息提示
+ (void)showInfoTipHUD:(NSString *)message;
/// 在view信息提示
+ (void)showInfoTipHUDInView:(NSString *)message;
/// 警告提示
+ (void)showWarningTipHUD:(NSString *)message;
/// 在view警告提示
+ (void)showWarningTipHUDInView:(NSString *)message;

/// 展示自定义图片 - 图片需要导入 'XWHUDImages.bundle' 包中
+ (void)showCustomIconHUD:(NSString *)iconName message:(NSString *)message;
/// 在view上展示自定义图片 - 图片需要导入 'XWHUDImages.bundle' 包中
+ (void)showCustomIconHUDInView:(NSString *)iconName message:(NSString *)message;
@end
