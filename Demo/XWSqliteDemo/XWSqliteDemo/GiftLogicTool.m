//
//  GiftLogicTool.m
//  XWSqliteDemo
//
//  Created by 邱学伟 on 2017/5/18.
//  Copyright © 2017年 邱学伟. All rights reserved.
//

#import "GiftLogicTool.h"

@implementation GiftLogicTool

+ (NSArray *)testGiftArr {
    NSMutableArray *newTestArrM = [[NSMutableArray alloc] init];
    //$ 模拟添加两个flash礼物
    //红包
    NSDictionary *hongbao = [self giftDictWithID:@"" type:@"0" name:@"红包" url:@"https://liveimg.beijing.com//redpacket.png" animName:@"" price:@""];
    [newTestArrM addObject:hongbao];
    //
    //糖葫芦
    NSDictionary *no1_TANGHULU = [self giftDictWithID:@"1" type:@"1" name:@"糖葫芦" url:@"https://raw.githubusercontent.com/qxuewei/XWResources/master/lottieAnimKeyboardIcon/xlw_tb_thl.png" animName:@"xlw_tb_thl" price:@"1"];
    [newTestArrM addObject:no1_TANGHULU];
    
    //汽水
    NSDictionary *no2_BEIBINGYANG = [self giftDictWithID:@"2" type:@"1" name:@"汽水" url:@"https://github.com/qxuewei/XWResources/blob/master/lottieAnimKeyboardIcon/xlw_tb_bjy.png?raw=true" animName:@"xlw_tb_bjy" price:@"2"];
    [newTestArrM addObject:no2_BEIBINGYANG];
    
    //果脯
    NSDictionary *no3_guofu = [self giftDictWithID:@"3" type:@"1" name:@"果脯" url:@"https://github.com/qxuewei/XWResources/blob/master/lottieAnimKeyboardIcon/xlw_tb_gp.png?raw=true" animName:@"xlw_tb_gp" price:@"3"];
    [newTestArrM addObject:no3_guofu];
    
    //二锅头
    NSDictionary *no4_erguotou = [self giftDictWithID:@"4" type:@"1" name:@"二锅头" url:@"https://github.com/qxuewei/XWResources/blob/master/lottieAnimKeyboardIcon/zlw_tb_egt.png?raw=true" animName:@"zlw_tb_egt" price:@"10"];
    [newTestArrM addObject:no4_erguotou];
    
    //炸酱面
    NSDictionary *no5_zhajiangmian = [self giftDictWithID:@"5" type:@"1" name:@"炸酱面" url:@"https://github.com/qxuewei/XWResources/raw/master/lottieAnimKeyboardIcon/zlw_tb_zjm.png" animName:@"zlw_tb_zjm" price:@"20"];
    [newTestArrM addObject:no5_zhajiangmian];
    
    //铜火锅
    NSDictionary *no6_tonghuohuo = [self giftDictWithID:@"6" type:@"2" name:@"铜火锅" url:@"https://github.com/qxuewei/XWResources/raw/master/lottieAnimKeyboardIcon/zlw_tb_thg.png" animName:@"zlw_tb_thg" price:@"50"];
    [newTestArrM addObject:no6_tonghuohuo];
    
    //烤鸭
    NSDictionary *no7_kaoya = [self giftDictWithID:@"7" type:@"2" name:@"北京烤鸭" url:@"https://github.com/qxuewei/XWResources/raw/master/lottieAnimKeyboardIcon/zlw_tb_ky.png" animName:@"zlw_tb_ky" price:@"100"];
    [newTestArrM addObject:no7_kaoya];
    
    //666
    NSDictionary *no8_manshanhong = [self giftDictWithID:@"8" type:@"3" name:@"666" url:@"https://github.com/qxuewei/XWResources/blob/master/lottieAnimKeyboardIcon/xlw_tb_666.png?raw=true" animName:@"xlw_tb_666" price:@"520"];
    [newTestArrM addObject:no8_manshanhong];
    
    //月季花束
    NSDictionary *no9_manshanhong = [self giftDictWithID:@"9" type:@"3" name:@"月季花束" url:@"https://github.com/qxuewei/XWResources/raw/master/lottieAnimKeyboardIcon/manshanhong.png" animName:@"dlw_tb_yjh" price:@"520"];
    [newTestArrM addObject:no9_manshanhong];
    
    //    //666
    //    NSDictionary *no10_manshanhong = [self giftDictWithID:@"6" type:@"2" name:@"666" url:@"https://github.com/qxuewei/XWResources/blob/master/lottieAnimKeyboardIcon/xlw_tb_666.png?raw=true" animName:@"xlw_tb_666" price:@"520"];
    //    [newTestArrM addObject:no10_manshanhong];
    
    //    //月季花束
    //    NSDictionary *no11_manshanhong = [self giftDictWithID:@"6" type:@"2" name:@"月季花束" url:@"https://github.com/qxuewei/XWResources/raw/master/lottieAnimKeyboardIcon/manshanhong.png" animName:@"dlw_tb_yjh" price:@"520"];
    //    [newTestArrM addObject:no11_manshanhong];
    
    return newTestArrM;
}

+ (NSDictionary *)giftDictWithID:(NSString *)id type:(NSString *)type name:(NSString *)name url:(NSString *)url animName:(NSString *)animName price:(NSString *)price{
    NSMutableDictionary *giftDict = [NSMutableDictionary dictionary];
    [giftDict setObject:id forKey:@"id"];
    [giftDict setObject:name forKey:@"name"];
    [giftDict setObject:type forKey:@"type"];
    [giftDict setObject: url forKey:@"url"];
    [giftDict setObject:animName forKey:@"animName"];
    [giftDict setObject:price forKey:@"price"];
    return giftDict.copy;
}

@end
