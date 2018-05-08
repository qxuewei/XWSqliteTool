//
//  XWFMDatabaseQueueHelper.m
//  XWSqliteToolDemo
//
//  Created by 邱学伟 on 2018/5/7.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

#import "XWFMDatabaseQueueHelper.h"

#define xw_DB_CachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject

@interface XWFMDatabaseQueueHelper () {
    FMDatabaseQueue * queue;
    FMDatabase * _db;
}

@end

@implementation XWFMDatabaseQueueHelper

static NSString *xw_dbUid;

#pragma mark - public
+ (XWFMDatabaseQueueHelper *) sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (void)closeDB {
    [_db close];
}

- (BOOL)executeUpdate:(NSString *)sql {
    if ([_db open]) {
        BOOL isSuccess = [_db executeUpdate:sql];
        if (isSuccess) {
            [_db close];
        }
        return isSuccess;
    }else{
        NSLog(@"open error!!!!");
        return NO;
    }
}

- (FMResultSet *)executeQuery:(NSString *)sql {
    if ([_db open]) {
        return [_db executeQuery:sql];
    }else{
        NSLog(@"open error!!!!");
        return NULL;
    }
}

- (void)inDatabase:(void(^)(FMDatabase *db))block {
    [queue inDatabase:^(FMDatabase *db){
        block(db);
    }];
}

- (void)queryWithSqls:(NSArray<NSString*>*)sqls callBack:(void(^)(NSArray <FMResultSet *>*resultSets))callBack {
    if (sqls.count == 0) {
        NSLog(@"请传入您要操作的Sql 语句");
        callBack ? callBack(NULL) : nil;
        return ;
    }
    [self inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if ([db open]) {
            __block NSMutableArray <FMResultSet *>*results = [NSMutableArray array];
            [sqls enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FMResultSet *set = [db executeQuery:obj];
                if (set) {
                    [results addObject:set];
                }
            }];
            callBack ? callBack(results) : nil;
        }else{
            callBack ? callBack(NULL) : nil;
        }
    }];
}

- (void)updateWithSqls:(NSArray<NSString*>*)sqls callBack:(void(^)(BOOL isSuccess))callBack {
    if (sqls.count == 0) {
        NSLog(@"请传入您要操作的Sql 语句");
        callBack ? callBack(NO) : nil;
        return ;
    }
    [self inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if ([db open]) {
            [sqls enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (![db executeUpdate:obj]) {
                    callBack ? callBack(NO) : nil;
                    *rollback = YES;
                }
                if (idx == (sqls.count - 1) && callBack) {
                    callBack ? callBack(YES) : nil;
                }
            }];
        }else{
            callBack ? callBack(NO) : nil;
        }
    }];
}

#pragma mark - 私有
-(id) init  {
    self = [super init];
    if(self){
        queue = [FMDatabaseQueue databaseQueueWithPath:[XWFMDatabaseQueueHelper dbPath]];
        _db = [FMDatabase databaseWithPath:[XWFMDatabaseQueueHelper dbPath]];
    }
    return self;
}

/// 根据UID获取当前操作数据库路径
+ (NSString *)dbPath {
    return [xw_DB_CachePath stringByAppendingPathComponent:@"XWCommon.sqlite"];
}

- (void)inTransaction:(void(^)(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback))block {
    [queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        block(db,rollback);
    }];
}
@end
