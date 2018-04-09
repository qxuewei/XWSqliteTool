//
//  XWFMDBTool.m
//  XWSqliteTool_Example
//
//  Created by 邱学伟 on 2018/4/4.
//  Copyright © 2018年 qxuewei@yeah.net. All rights reserved.
//

#import "XWFMDBTool.h"

#define kCachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject

@implementation XWFMDBTool
/// 更新
+(BOOL)updateWithSql:(NSString *)sql uid:(NSString *)uid{
    FMDatabase *db = [self fmdbWithUid:uid];
    if ([db open]) {
        return [db executeUpdate:sql];
    }else{
        return NO;
    }
}

/// 查询
+(FMResultSet *)querySql:(NSString *)sql uid:(NSString *)uid{
    FMDatabase *db = [self fmdbWithUid:uid];
    if ([db open]) {
        return [db executeQuery:sql];
    }else{
        return NULL;
    }
}

/// 更新事务操作
+(void)updateWithSqls:(NSArray<NSString*>*)sqls uid:(NSString *)uid callBack:(void(^)(BOOL isSuccess))callBack {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 8), ^{
        FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:[self dbPathWithUid:uid]];
        [queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
            [sqls enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (![db executeUpdate:obj]) {
                    if (callBack) {
                        callBack(NO);
                    }
                }
                if (stop && callBack) {
                    callBack(YES);
                }
            }];
        }];
    });
}

#pragma mark - 私有
/// 根据UID获取当前操作数据库
+ (FMDatabase *)fmdbWithUid:(NSString *)uid {
    return [FMDatabase databaseWithPath:[self dbPathWithUid:uid]];
}

/// 根据UID获取当前操作数据库路径
+ (NSString *)dbPathWithUid:(NSString *)uid {
    NSString *sqliteName = @"XWCommon.sqlite";
    if (uid) {
        /// 若传入UID, 创建当前用户对应的数据库
        sqliteName = [NSString stringWithFormat:@"%@.sqlite",uid];
    }
    return [kCachePath stringByAppendingPathComponent:sqliteName];
}

@end
