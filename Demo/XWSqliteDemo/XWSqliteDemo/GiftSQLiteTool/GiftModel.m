//
//  GiftModel.m
//  LiveShow
//
//  Created by 刘爱环 on 16/5/4.
//  Copyright © 2016年 MiYou. All rights reserved.
//

#import "GiftModel.h"

@implementation GiftModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    
    return @{@"giftID" : @"id",
             @"giftName" : @"name",
             @"giftPrice" : @"price",
             @"giftType" : @"type",
             @"giftUrl" : @"url"
             };
}

+(NSString *)primaryKey{
    return @"giftID";
}

@end
