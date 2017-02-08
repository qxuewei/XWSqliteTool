//
//  XWStuModel.m
//  XWSqliteTool
//
//  Created by 邱学伟 on 2017/2/8.
//  Copyright © 2017年 qxuewei@yeah.net. All rights reserved.
//

#import "XWStuModel.h"

@implementation XWStuModel
+(NSString *)primaryKey{
    return @"stuNum";
}
+(NSArray <NSString *>*)ignoreColumnNames{
    return @[@"array",@"score2"];
}
@end
