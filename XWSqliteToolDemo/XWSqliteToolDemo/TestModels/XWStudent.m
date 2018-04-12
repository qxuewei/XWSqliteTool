//
//  XWStudent.m
//  XWSqliteToolDemo
//
//  Created by 邱学伟 on 2018/4/11.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

#import "XWStudent.h"

@implementation XWStudent
/// 主键
+(NSString *)primaryKey {
    return @"uid";
}

+ (NSArray<NSString *> *)ignoreColumnNames {
    return @[];
}
@end
