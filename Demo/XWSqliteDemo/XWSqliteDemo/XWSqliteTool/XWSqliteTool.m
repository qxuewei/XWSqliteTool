//
//  XWSqliteTool.m
//  XWSqliteTool
//
//  Created by 邱学伟 on 2017/2/7.
//  Copyright © 2017年 qxuewei@yeah.net. All rights reserved.
//

#import "XWSqliteTool.h"
#import "sqlite3.h"
#define kCachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
//#define kCachePath @"/Users/carayfire-develop/Desktop"
@implementation XWSqliteTool
sqlite3 *ppDb = nil;
+(BOOL)deal:(NSString *)sql uid:(NSString *)uid{
    if ([self openDBWithUid:uid]) {
        BOOL result = sqlite3_exec(ppDb, sql.UTF8String, nil, nil, nil) == SQLITE_OK;
        sqlite3_close(ppDb);
        return result;
    }else{
        return NO;
    }
}

+(NSMutableArray<NSMutableDictionary *> *)querySql:(NSString *)sql uid:(NSString *)uid{
    [self openDBWithUid:uid];
    //创建准备语句
    // 参数3: 参数2取出多少字节的长度 -1 自动计算 \0
    // 参数4: 准备语句
    // 参数5: 通过参数3, 取出参数2的长度字节之后, 剩下的字符串
    sqlite3_stmt *ppStmt = nil;
    if(sqlite3_prepare_v2(ppDb, sql.UTF8String, -1, &ppStmt, nil) != SQLITE_OK){
        NSLog(@"预编译失败");
        return nil;
    }
    NSMutableArray *array = [NSMutableArray array];
    //取数据库每行数据
    while (sqlite3_step(ppStmt) == SQLITE_ROW) {
        //1.获取列数
        int columnCount = sqlite3_column_count(ppStmt);
        //2.遍历所有列
        NSMutableDictionary *columnDict = [NSMutableDictionary dictionary];
        for (int i = 0; i < columnCount; i++) {
            const char *columnName = sqlite3_column_name(ppStmt, i);
            NSString *columnNameStr = [NSString stringWithUTF8String:columnName];
            int columnType = sqlite3_column_type(ppStmt, i);
            id value = nil;
            switch (columnType) {
                case SQLITE_INTEGER:
                    value = @(sqlite3_column_int(ppStmt, i));
                    break;
                case SQLITE_FLOAT:
                    value = @(sqlite3_column_double(ppStmt, i));
                    break;
                case SQLITE_BLOB:
                    value = CFBridgingRelease(sqlite3_column_blob(ppStmt, i));
                    break;
                case SQLITE_NULL:
                    value = @"";
                    break;
                case SQLITE3_TEXT:
                    value = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(ppStmt, i)];
                    break;
                default:
                    break;
            }
            [columnDict setValue:value forKey:columnNameStr];
        }
        [array addObject:columnDict];
    }
    //释放资源
    sqlite3_finalize(ppStmt);
    //关闭数据库
    [self closeDBWithUid:uid];
    return array;
}

+(BOOL)dealSqls:(NSArray<NSString*>*)sqls uid:(NSString *)uid{
    [self beginTransaction:uid];
    for (NSString *sql in sqls) {
        BOOL result = [self deal:sql uid:uid];
        if (result == NO) {
            [self rollBackTransaction:uid];
            return NO;
        }
    }
    [self commitTransaction:uid];
    return YES;
}

+(void)beginTransaction:(NSString *)uid{
    [self deal:@"begin transaction" uid:uid];
}
+(void)commitTransaction:(NSString *)uid{
    [self deal:@"commit transaction" uid:uid];
}
+(void)rollBackTransaction:(NSString *)uid{
    [self deal:@"rollback tramsaction" uid:uid];
}

#pragma mark - 私有
+(BOOL)openDBWithUid:(NSString *)uid{
    NSString *sqliteName = @"XWCommon.sqlite";
    if (uid) {
        sqliteName = [NSString stringWithFormat:@"%@.sqlite",uid];
    }
    NSString *filename = [kCachePath stringByAppendingPathComponent:sqliteName];
    BOOL openResult = sqlite3_open(filename.UTF8String, &ppDb) == SQLITE_OK;
    if (!openResult) {
        NSLog(@"数据库打开失败");
        return NO;
    }else{
        return YES;
    }
}
+(void)closeDBWithUid:(NSString *)uid{
    sqlite3_close(ppDb);
}
@end
