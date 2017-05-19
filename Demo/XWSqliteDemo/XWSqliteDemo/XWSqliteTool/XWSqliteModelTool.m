//
//  XWSqliteModelTool.m
//  XWSqliteTool
//
//  Created by 邱学伟 on 2017/2/8.
//  Copyright © 2017年 qxuewei@yeah.net. All rights reserved.
//

#import "XWSqliteModelTool.h"
#import "XWXModelTool.h"
#import "XWSqliteTool.h"
#import "XWSqliteTableTool.h"
@implementation XWSqliteModelTool
+(BOOL)createTableFromCls:(Class)cls uid:(NSString *)uid{
    //建表sql语句
    // create table if not exists 表名(字段1 : 字段1约束, 字段2 : 字段2约束, ... ,primary key(字段))
    NSString *tableName = [XWXModelTool tableNameWithCls:cls];
    if (![cls respondsToSelector:@selector(primaryKey)]) {
        NSLog(@"倘若希望使用 %@ 模型直接创建数据库,需要实现 +(NSString *)primaryKey; 类方法(准守XWXModelProtocol协议)",NSStringFromClass(cls));
        return NO;
    }
    NSString *primary = [cls primaryKey];
    NSString *createTableSql = [NSString stringWithFormat:@"create table if not exists %@(%@,primary key(%@))",tableName,[XWXModelTool createTableSql:cls],primary];
    return [XWSqliteTool deal:createTableSql uid:nil];
}

+(BOOL)isTableRequiredUpdate:(Class)cls uid:(NSString *)uid{
    NSArray *modelSortedNames = [XWXModelTool allTableSortedIvarNames:cls];
    NSArray *currentSqliteColumn = [XWSqliteTableTool tableSortedColumnNames:cls uid:uid];
    return ![modelSortedNames isEqualToArray:currentSqliteColumn];
}

+(BOOL)updateTableFromCls:(Class)cls uid:(NSString *)uid{
    //建表sql语句
    // create table if not exists 表名(字段1 : 字段1约束, 字段2 : 字段2约束, ... ,primary key(字段))
    NSString *tableName = [XWXModelTool tableNameWithCls:cls];
    NSString *tempTableName = [XWXModelTool tempTableNameWithCls:cls];
    
    if (![cls respondsToSelector:@selector(primaryKey)]) {
        NSLog(@"倘若希望使用 %@ 模型直接创建数据库,需要实现 +(NSString *)primaryKey; 类方法(准守XWXModelProtocol协议)",NSStringFromClass(cls));
        return NO;
    }
    NSString *primary = [cls primaryKey];
    NSMutableArray *sqls = [NSMutableArray array];
    //1.创建临时表
    NSString *createTableSql = [NSString stringWithFormat:@"create table if not exists %@(%@,primary key(%@))",tempTableName,[XWXModelTool createTableSql:cls],primary];
    [sqls addObject:createTableSql];
    //2.根据主键插入数据
    //insert into tem_table(stuNum) select stuNum from XWStuModel
    NSString *insertPrimaryKeyData = [NSString stringWithFormat:@"insert into %@(%@) select %@ from %@",tempTableName,primary,primary,tableName];
    [sqls addObject:insertPrimaryKeyData];
    //3.根据主键将老表所有数据更新到新表里面
    NSArray *oldTable = [XWSqliteTableTool tableSortedColumnNames:cls uid:uid];
    NSArray *newTable = [XWXModelTool allTableSortedIvarNames:cls];
    for (NSString *tableIvarName in newTable) {
        if (![oldTable containsObject:tableIvarName]) {
            continue;
        }
        //update tem_table set name = (select name from XWStuModel where tem_table.stuNum = XWStuModel.stuNum)
        NSString *updateSql = [NSString stringWithFormat:@"update %@ set %@ = (select %@ from %@ where %@.%@ = %@.%@)",tempTableName,tableIvarName,tableIvarName,tableName,tempTableName,primary,tableName,primary];
        [sqls addObject:updateSql];
    }
    NSString *dropTableSql = [NSString stringWithFormat:@"drop table if exists %@",tableName];
    [sqls addObject:dropTableSql];
    
    NSString *renameSql = [NSString stringWithFormat:@"alter table %@ rename to %@",tempTableName,tableName];
    [sqls addObject:renameSql];
    return [XWSqliteTool dealSqls:sqls uid:nil];
}

@end
