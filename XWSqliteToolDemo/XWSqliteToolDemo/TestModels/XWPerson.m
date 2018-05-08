//
//  XWPerson.m
//  XWSqliteToolDemo
//
//  Created by 邱学伟 on 2018/4/10.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

#import "XWPerson.h"

@implementation XWPerson

- (instancetype)init {
    if (self = [super init]) {
//        self.version = 1.0;
    }
    return self;
}

/// 主键
+(NSString *)primaryKey {
    return @"uid";
}

/// 版本号 (增删字段需更新此版本号)
//+(double)version {
//    return self.version;
//}

+ (NSArray<NSString *> *)ignoreColumnNames {
    return @[];
}

@end
