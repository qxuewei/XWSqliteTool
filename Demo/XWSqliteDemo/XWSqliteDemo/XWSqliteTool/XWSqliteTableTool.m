//
//  XWSqliteTableTool.m
//  XWSqliteTool
//
//  Created by 邱学伟 on 2017/2/8.
//  Copyright © 2017年 qxuewei@yeah.net. All rights reserved.
//

#import "XWSqliteTableTool.h"
#import "XWXModelTool.h"
#import "XWSqliteTool.h"
@implementation XWSqliteTableTool
+(NSArray *)tableSortedColumnNames:(Class)cls uid:(NSString *)uid{
    NSString *tableName = [XWXModelTool tableNameWithCls:cls];
    //SELECT sql FROM sqlite_master WHERE type = 'table' AND name = 'XWStuModel'
    NSString *queryCreateTableSql = [NSString stringWithFormat:@"SELECT sql FROM sqlite_master WHERE type = 'table' AND name = '%@'",tableName];
    NSMutableDictionary *sqlDict = [XWSqliteTool querySql:queryCreateTableSql uid:nil].lastObject;
    NSString *createTableSql = sqlDict[@"sql"];
    if (createTableSql.length == 0) {
        return nil;
    }
    // @"CREATE TABLE XWStuModel(age integer,stuNum integer,name text,primary key(stuNum))"
    //1.age integer,stuNum integer,name text,primary key
    NSString *nameTypeStr = [createTableSql componentsSeparatedByString:@"("][1];
    NSArray *nameTypeArr = [nameTypeStr componentsSeparatedByString:@","];
    NSMutableArray *columnNames = [NSMutableArray array];
    for (NSString *nameTypeCase in nameTypeArr) {
        if ([nameTypeCase containsString:@"primary"]) {
            continue;
        }
        //age integer
        NSString *nameType = [nameTypeCase componentsSeparatedByString:@" "][0];
        [columnNames addObject:nameType];
    }
    [columnNames sortUsingComparator:^NSComparisonResult(NSString *obj1,NSString *obj2) {
        //排序
        return [obj1 compare:obj2];
    }];
    return columnNames;
    
}
@end
