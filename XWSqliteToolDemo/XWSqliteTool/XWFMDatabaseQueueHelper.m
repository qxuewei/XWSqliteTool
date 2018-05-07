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

- (BOOL)executeUpdate:(NSString *)sql {
    if ([_db open]) {
        return [_db executeUpdate:sql];
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

- (void)updateWithSqls:(NSArray<NSString*>*)sqls callBack:(void(^)(BOOL isSuccess))callBack {
    if (sqls.count == 0) {
        NSLog(@"请传入您要操作的Sql 语句");
        callBack ? callBack(NO) : nil;
        return ;
    }
    [self inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [sqls enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![db executeUpdate:obj]) {
                callBack ? callBack(NO) : nil;
            }
            if (idx == (sqls.count - 1) && callBack) {
                callBack(YES);
                [db close];
            }
        }];
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
