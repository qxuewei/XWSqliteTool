//
//  XWXModelProtocol.h
//  XWSqliteTool
//
//  Created by 邱学伟 on 2017/2/8.
//  Copyright © 2017年 qxuewei@yeah.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XWXModelProtocol <NSObject>

/// 主键
+(NSString *)primaryKey;

/// 忽略的成员变量
+(NSArray<NSString *> *)ignoreColumnNames;

@end
