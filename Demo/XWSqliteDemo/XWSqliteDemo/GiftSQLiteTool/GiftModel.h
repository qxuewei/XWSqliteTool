//
//  GiftModel.h
//  LiveShow
//
//  Created by 刘爱环 on 16/5/4.
//  Copyright © 2016年 MiYou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XWXModelProtocol.h"
@interface GiftModel : NSObject <XWXModelProtocol>

/// 礼物ID
@property (strong, nonatomic) NSString *giftID;
/// 礼物键盘静态图片
@property (strong, nonatomic) NSString *giftUrl;
/// 礼物名称
@property (strong, nonatomic) NSString *giftName;
/// 礼物价格
@property (strong, nonatomic) NSString *giftPrice;
/// 礼物类型  0: 红包  1: 小礼物  2: 中礼物  3: 大特效
@property (strong, nonatomic) NSString *giftType;
/// 这次展示多少个礼物数
@property (strong, nonatomic) NSString *giftNums;
/// 这次从第几个开始展示
@property (strong, nonatomic) NSString *giftIndex;

/// 版本号
@property (nonatomic, copy) NSString *giftVersion;
/// 键盘AE动画名
@property (nonatomic, copy) NSString *kb_lottieAnimationName;
/// AE大动画名
@property (nonatomic, copy) NSString *lottieAnimationName;
/// 序列帧持续时间
@property (nonatomic, copy) NSString *sequentialImageAnimationDuration;
/// 序列帧动画名
@property (nonatomic, copy) NSString *sequentialImageName;
/// 序列帧持续图片数组数量
@property (nonatomic, copy) NSString *sequentialImagesCount;

//****
//远程更新动态礼物效果用  giftVersion 跟之前不一致时不为空
/// 远程更新的键盘AE动画压缩包路径
@property (nonatomic, copy) NSString *kb_lottieAnimationNameUpdateZipUrl;
/// 远程更新的键盘AE大动画压缩包路径
@property (nonatomic, copy) NSString *lottieAnimationNameUpdateZipUrl;

@end
