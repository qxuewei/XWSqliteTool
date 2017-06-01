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

/*
 查询语句：select * from 表名 where 条件子句 group by 分组字句 having ... order by 排序子句
 如：   select * from person
 select * from person order by id desc
 select name from person group by name having count(*)>1
 分页SQL与mysql类似，下面SQL语句获取5条记录，跳过前面3条记录
 select * from Account limit 5 offset 3 或者 select * from Account limit 3,5
 插入语句：insert into 表名(字段列表) values(值列表)。如： insert into person(name, age) values(‘传智’,3)
 更新语句：update 表名 set 字段名=值 where 条件子句。如：update person set name=‘传智‘ where id=10
 删除语句：delete from 表名 where 条件子句。如：delete from person  where id=10
 */

/**
 传入单个模型进行本地数据新增或更新 - 若存在则更新所以字段,所不存在则插入本条数据

 @param obj 要插入的模型
 @return 最终SQL语句
 */
+ (NSString *)insertOrUpdateDataToSQLiteWithModel:(NSObject <XWXModelProtocol>*)obj {
    if (!obj) {
        return NULL;
    }
    Class objClass = [obj class];
    // 成员属性 = 数据库对应类型
    NSDictionary *ivarNameTypeDict = [XWXModelTool classIvarNameTypeDic:objClass];
    // 所有成员属性
    NSArray <NSString *>*allPropertyStrs = [ivarNameTypeDict allKeys];
    // 主键
    NSString *primaryKeyStr = [objClass primaryKey];
    // 模型主键对应的数据
    NSString *primaryKeyObject = [NSString stringWithFormat:@"%@",[obj valueForKey:primaryKeyStr]];
    // 数据库表名
    NSString *tableName = [XWXModelTool tableNameWithCls:objClass];
    // 查询当前数据表中是否存在此数据
    NSString *queryIsExistThisDataSql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@'",tableName,primaryKeyStr,primaryKeyObject];
    NSMutableDictionary *sqlDict = [XWSqliteTool querySql:queryIsExistThisDataSql uid:nil].lastObject;
    
    if (sqlDict.allKeys.count == 0) {
        // 不存在此数据 - 单条插入
        NSMutableDictionary *insertSqlDict = [NSMutableDictionary dictionary];
        for (NSString *primaryKeyStr in allPropertyStrs) {
            NSString *currentObjectStr = [NSString stringWithFormat:@"'%@'",[obj valueForKey:primaryKeyStr]];
            if (currentObjectStr.length == 0 || currentObjectStr == NULL || [currentObjectStr isEqualToString:@"'(null)'"]) {
                continue;
            }
            [insertSqlDict setObject:currentObjectStr forKey:primaryKeyStr];
        }
        NSString *insertSql = [NSString stringWithFormat:@"insert into %@(%@) values(%@)",tableName,[insertSqlDict.allKeys componentsJoinedByString:@","],[insertSqlDict.allValues componentsJoinedByString:@","]];
        return insertSql;
    }else{
        // 已存在此数据 - 全部字段更新
        NSMutableArray *updateArrM = [NSMutableArray array];
        for (NSString *primaryKeyStr in allPropertyStrs) {
            NSString *currentObjectStr = [NSString stringWithFormat:@"'%@'",[obj valueForKey:primaryKeyStr]];
            if (currentObjectStr.length == 0 || currentObjectStr == NULL || [currentObjectStr isEqualToString:@"'(null)'"]) {
                continue;
            }
            [updateArrM addObject:[NSString stringWithFormat:@"%@ = %@",primaryKeyStr,currentObjectStr]];
        }
        NSString *updateSql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@ = '%@'",tableName,[updateArrM componentsJoinedByString:@","],primaryKeyStr,primaryKeyObject];
        return updateSql;
    }
}


/**
 对模型数组进行本地数据库新增或更新 - 若存在则更新所以字段,所不存在则插入本条数据

 @param objs 模型数组
 @return 更新结果
 */
+ (BOOL)insertOrUpdateDataToSQLiteWithModels:(NSArray <NSObject <XWXModelProtocol>*>*)objs uid:(NSString *)uid{
    if (objs.count == 0) {
        return NO;
    }
    Class cls = [[objs firstObject] class];
    if (![cls respondsToSelector:@selector(primaryKey)]) {
        NSLog(@"倘若希望使用 %@ 模型数组进行本地数据库新增或更新,需要实现 +(NSString *)primaryKey; 类方法(准守XWXModelProtocol协议)",NSStringFromClass(cls));
        return NO;
    }
    
    if (![XWSqliteModelTool createTableFromCls:cls uid:uid]) {
        NSLog(@"用 %@ 模型新建数据库失败!",NSStringFromClass(cls));
        return NO;
    }
    if (![self toUpdateTable:cls uid:uid]) {
        NSLog(@"检测到 %@ 模型字段更改,对应的数据库迁移失败!",NSStringFromClass(cls));
        return NO;
    }
    NSMutableArray *sqls = [NSMutableArray array];
    for (NSObject <XWXModelProtocol>*obj in objs) {
        [sqls addObject:[self insertOrUpdateDataToSQLiteWithModel:obj]];
    }
    return [XWSqliteTool dealSqls:sqls uid:nil];
}

#pragma mark - private
+ (BOOL)toUpdateTable:(Class)cls uid:(NSString *)uid {
    if (![self isTableRequiredUpdate:cls uid:uid]) {
        return YES;
    }
    return [self updateTableFromCls:cls uid:uid];
}


@end
