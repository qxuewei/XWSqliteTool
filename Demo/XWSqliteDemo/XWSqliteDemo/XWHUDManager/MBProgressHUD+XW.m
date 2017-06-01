//
//  MBProgressHUD+XW.m
//  XWHUDManager
//
//  Created by 邱学伟 on 2017/4/27.
//  Copyright © 2017年 邱学伟. All rights reserved.
//

#import "MBProgressHUD+XW.h"

/// 隐藏蒙版默认时间
static const NSTimeInterval kHideHUDTimeInterval = 1.0f;
/// 提示框文字大小
static CGFloat FONT_SIZE = 14.0f;

@implementation MBProgressHUD (XW)
static MBProgressHUD *hud;

#pragma mark - 隐藏HUD
/// 隐藏蒙版(无论在view还是window)
+ (void)hide{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self hideHUDForView:[self getCurrentUIVC].view animated:YES];
        [self hideHUDForView:[self lastWindow] animated:YES];
        hud = NULL;
    }];
}
/// 延时隐藏蒙版(无论在view还是window)
+ (void)hideDelay:(int)delaySeconds{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delaySeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hide];
    });
}
/// 隐藏当前View上的HUD
+ (void)hideInView{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self hideHUDForView:[self getCurrentUIVC].view animated:YES];
    }];
}
/// 隐藏当前window上的HUD
+ (void)hideInWindow{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self hideHUDForView:[self lastWindow] animated:YES];
    }];
}

#pragma mark - 小菊花
/// 在window展示一个小菊花
+ (void)showHUD{
    
    [self showActivityMessage:@"" isWindow:YES timer:0];
}

/// 在当前View展示一个小菊花
+ (void)showHUDInView{
    
    [self showActivityMessage:@"" isWindow:NO timer:0];
}

/// 在window展示一个 loading... 小菊花
+ (void)showHUDLoadingEN {
    
    [self showActivityMessage:@"loading..." isWindow:YES timer:0];
}

/// 在window展示一个 加载中... 小菊花
+ (void)showHUDLoadingCH {
    
    [self showActivityMessage:@"加载中..." isWindow:YES timer:0];
}

/// 在window展示一个有文本小菊花
+ (void)showHUDMessage:(NSString *)message {
    
    [self showActivityMessage:message isWindow:YES timer:0];
}

/// 限时隐藏在window展示一个 loading... 小菊花
+ (void)showHUDLoadingAfterDelay:(int)afterSecond{
    
    [self showActivityMessage:@"loading..." isWindow:YES timer:afterSecond];
}

/// 限时隐藏在window展示一个有文本小菊花
+ (void)showHUDMessage:(NSString *)message afterDelay:(int)afterSecond{
    
    [self showActivityMessage:message isWindow:YES timer:afterSecond];
}

/// 限时隐藏在view展示一个有文本小菊花
+ (void)showHUDMessageInView:(NSString *)message afterDelay:(int)afterSecond{
    
    [self showActivityMessage:message isWindow:NO timer:afterSecond];
}

#pragma mark - 文本提示框
/// 在window上显示文本提示框
+ (void)showTipHUD:(NSString *)message {
    
    [self showTipMessage:message isWindow:YES timer:kHideHUDTimeInterval];
}

/// 在window上显示文本提示框
+ (void)showTipHUDInView:(NSString *)message {
    
    [self showTipMessage:message isWindow:NO timer:kHideHUDTimeInterval];
}

/// 限时隐藏在window展示一个有文本提示框
+ (void)showTipHUD:(NSString *)message afterDelay:(int)afterSecond{
    
    [self showTipMessage:message isWindow:YES timer:afterSecond];
}

/// 限时隐藏在view展示一个有文本提示框
+ (void)showTipHUDInView:(NSString *)message afterDelay:(int)afterSecond{
    
    [self showTipMessage:message isWindow:NO timer:afterSecond];
}

#pragma mark - 提示图片
/// 正确提示
+ (void)showSuccessHUD {
    
    [self showCustomIcon:@"right" message:@"" isWindow:YES];
}

/// 有文本正确提示
+ (void)showSuccessTipHUD:(NSString *)message {
    
    [self showCustomIcon:@"right" message:message isWindow:YES];
}

/// 在view展示有文本正确提示
+ (void)showSuccessTipHUDInView:(NSString *)message {
    
    [self showCustomIcon:@"right" message:message isWindow:NO];
}

/// 错误提示
+ (void)showErrorHUD {
    
    [self showCustomIcon:@"error" message:@"" isWindow:YES];
}

/// 有文本错误提示
+ (void)showErrorTipHUD:(NSString *)message {
    
    [self showCustomIcon:@"error" message:message isWindow:YES];
}

/// 在view有文本错误提示
+ (void)showErrorTipHUDInView:(NSString *)message {
    
    [self showCustomIcon:@"error" message:message isWindow:NO];
}

/// 信息提示
+ (void)showInfoTipHUD:(NSString *)message {
    
    [self showCustomIcon:@"info" message:message isWindow:YES];
}

/// 在view信息提示
+ (void)showInfoTipHUDInView:(NSString *)message {
    
    [self showCustomIcon:@"info" message:message isWindow:NO];
}

/// 警告提示
+ (void)showWarningTipHUD:(NSString *)message {
    [self showCustomIcon:@"tip" message:message isWindow:YES];
}

/// 在view警告提示
+ (void)showWarningTipHUDInView:(NSString *)message {
    [self showCustomIcon:@"tip" message:message isWindow:NO];
}


/// 展示自定义图片 - 图片需要导入 'XWHUDImages.bundle' 包中
+ (void)showCustomIconHUD:(NSString *)iconName message:(NSString *)message {
    
    [self showCustomIcon:iconName message:message isWindow:YES];
}

/// 在view上展示自定义图片 - 图片需要导入 'XWHUDImages.bundle' 包中
+ (void)showCustomIconHUDInView:(NSString *)iconName message:(NSString *)message {
    
    [self showCustomIcon:iconName message:message isWindow:NO];
}
#pragma mark - setter
/// 文本框
+ (void)showTipMessage:(NSString*)message isWindow:(BOOL)isWindow timer:(int)aTimer {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        hud = [self createMBProgressHUDviewWithMessage:message isWindiw:isWindow];
        hud.mode = MBProgressHUDModeText;
        if (aTimer > 0) {
            [hud hideAnimated:YES afterDelay:aTimer];
        }else{
            [hud hideAnimated:YES afterDelay:kHideHUDTimeInterval];
        }
        hud.bezelView.color = [UIColor blackColor];
        hud.label.textColor = [UIColor whiteColor];
    }];
}

/// 小菊花
+ (void)showActivityMessage:(NSString*)message isWindow:(BOOL)isWindow timer:(int)aTimer {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        hud  =  [self createMBProgressHUDviewWithMessage:message isWindiw:isWindow];
        hud.mode = MBProgressHUDModeIndeterminate;
        if (aTimer > 0) {
            [hud hideAnimated:YES afterDelay:aTimer];
        }
    }];
}

/// 自定义图片
+ (void)showCustomIcon:(NSString *)iconName message:(NSString *)message isWindow:(BOOL)isWindow
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{        
        hud  =  [self createMBProgressHUDviewWithMessage:message isWindiw:isWindow];
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[@"XWHUDImages.bundle" stringByAppendingPathComponent:iconName]]];
        [hud hideAnimated:YES afterDelay:kHideHUDTimeInterval];
    }];
    
}

#pragma mark - private
+ (UIViewController *)currentViewController {
    UIViewController *vc = [self lastWindow].rootViewController;
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
        
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = [(UINavigationController *)vc visibleViewController];
        } else if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = [(UITabBarController *)vc selectedViewController];
        }
    }
    return vc;
}

/// 获取最顶层window
+ (UIWindow *)lastWindow {
    NSArray *windows = [UIApplication sharedApplication].windows;
    for(UIWindow *window in [windows reverseObjectEnumerator]) {
        if ([window isKindOfClass:[UIWindow class]] &&
            CGRectEqualToRect(window.bounds, [UIScreen mainScreen].bounds))
            return window;
    }
    return [UIApplication sharedApplication].keyWindow;
}

+ (MBProgressHUD *)createMBProgressHUDviewWithMessage:(NSString*)message isWindiw:(BOOL)isWindow {
    UIView *view = isWindow ? [self lastWindow] : [self getCurrentUIVC].view;
    hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    hud.label.text = message ? message : @"加载中...";
    hud.label.font = [UIFont systemFontOfSize:FONT_SIZE];
    hud.backgroundView.color = [UIColor clearColor];
    hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.style = MBProgressHUDBackgroundStyleBlur;
    // 注释下面配置代码默认显示浅灰->
//    hud.bezelView.color = [UIColor blackColor];
//    hud.label.textColor = [UIColor whiteColor];
//    hud.contentColor = [UIColor whiteColor];
    return hud;
}

/// 获取当前屏幕显示的viewcontroller
+ (UIViewController *)getCurrentUIVC {
     
    UIViewController  *superVC = [[self class]  getCurrentWindowViewController ];
    if ([superVC isKindOfClass:[UITabBarController class]]) {
        UIViewController  *tabSelectVC = ((UITabBarController*)superVC).selectedViewController;
        if ([tabSelectVC isKindOfClass:[UINavigationController class]]) {
            return ((UINavigationController*)tabSelectVC).viewControllers.lastObject;
        }
        return tabSelectVC;
    }
    return superVC;
}

/// 获取当前窗口跟控制器
+ (UIViewController *)getCurrentWindowViewController {
    
    UIViewController *currentWindowVC = nil;
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for (UIWindow *tempWindow in windows) {
            if (tempWindow.windowLevel == UIWindowLevelNormal) {
                window = tempWindow;
                break;
            }
        }
    }
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        currentWindowVC = nextResponder;
    }else{
        currentWindowVC = window.rootViewController;
    }
    return currentWindowVC;
}

@end
