//
//  XWSqliteModelToolFM.m
//  XWSqliteTool
//
//  Created by 邱学伟 on 2017/2/8.
//  Copyright © 2017年 qxuewei@yeah.net. All rights reserved.
//

#import "XWSqliteModelToolFM.h"
#import "XWXModelTool.h"
#import "XWSqliteTool.h"
#import "XWSqliteTableTool.h"

#import "XWFMDBTool.h"

@implementation XWSqliteModelToolFM
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
    NSArray *currentSqliteColumn = [XWSqliteTableTool fmdb_tableSortedColumnNames:cls uid:uid];
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
    NSArray *oldTable = [XWSqliteTableTool fmdb_tableSortedColumnNames:cls uid:uid];
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
 插入语句：insert into 表名(字段列表) values(值列表)。如： insert into person(name, age) values(‘学伟’,3)
 更新语句：update 表名 set 字段名=值 where 条件子句。如：update person set name=‘学伟‘ where id=10
 删除语句：delete from 表名 where 条件子句。如：delete from person  where id=10
 */

/**
 传入单个模型进行本地数据新增或更新 - 若存在则更新所以字段,所不存在则插入本条数据

 @param obj 要插入的模型
 @return 最终SQL语句
 */
+ (NSString *)sql_insertOrUpdateDataToSQLiteWithModel:(NSObject <XWXModelProtocol>*)obj uid:(NSString *)uid {
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
 @param isUpdateTable 是否检查数据库表更新
 @return 更新结果
 */
+ (BOOL)insertOrUpdateDataToSQLiteWithModels:(NSArray <NSObject <XWXModelProtocol>*>*)objs uid:(NSString *)uid isUpdateTable:(BOOL)isUpdateTable{
    if (objs.count == 0) {
        return NO;
    }
    Class objClass = [[objs firstObject] class];
    if (![objClass respondsToSelector:@selector(primaryKey)]) {
        NSLog(@"倘若希望使用 %@ 模型数组进行本地数据库新增或更新,需要实现 +(NSString *)primaryKey; 类方法(准守XWXModelProtocol协议)",NSStringFromClass(objClass));
        return NO;
    }
    
    if (![XWSqliteModelToolFM createTableFromCls:objClass uid:uid]) {
        NSLog(@"用 %@ 模型新建数据库失败!",NSStringFromClass(objClass));
        return NO;
    }
    if (isUpdateTable) {    
        if (![self toUpdateTable:objClass uid:uid]) {
            NSLog(@"检测到 %@ 模型字段更改,对应的数据库迁移失败!",NSStringFromClass(objClass));
            return NO;
        }
    }
    
    NSMutableArray *sqls = [NSMutableArray array];
    for (NSObject <XWXModelProtocol>*obj in objs) {
        [sqls addObject:[self sql_insertOrUpdateDataToSQLiteWithModel:obj uid:uid]];
    }
    return [XWSqliteTool dealSqls:sqls uid:uid];
}

/**
 对模型进行本地数据库新增或更新 - 若存在则更新所以字段,所不存在则插入本条数据
 
 @param objs 模型数组
 @param isUpdateTable 是否检查数据库表更新
 @return 更新结果
 */
+ (BOOL)insertOrUpdateDataToSQLiteWithModel:(NSObject <XWXModelProtocol>*)obj uid:(NSString *)uid isUpdateTable:(BOOL)isUpdateTable{
    if (!obj) {
        return NO;
    }
    Class objClass = [obj class];
    if (![objClass respondsToSelector:@selector(primaryKey)]) {
        NSLog(@"倘若希望使用 %@ 模型数组进行本地数据库新增或更新,需要实现 +(NSString *)primaryKey; 类方法(准守XWXModelProtocol协议)",NSStringFromClass(objClass));
        return NO;
    }
    
    if (![XWSqliteModelToolFM createTableFromCls:objClass uid:uid]) {
        NSLog(@"用 %@ 模型新建数据库失败!",NSStringFromClass(objClass));
        return NO;
    }
    if (isUpdateTable) {
        if (![self toUpdateTable:objClass uid:uid]) {
            NSLog(@"检测到 %@ 模型字段更改,对应的数据库迁移失败!",NSStringFromClass(objClass));
            return NO;
        }
    }
    return [XWSqliteTool deal:[self sql_insertOrUpdateDataToSQLiteWithModel:obj uid:uid] uid:uid];
}

/**
 更新数据库中某单独字段 (保证数据表库中此数据必须存在)

 @param propertyKey 要更新的属性字段
 @param propertyValue 属性值
 @param primaryKeyObject 主键值
 @param objClass 模型类
 @param uid UID
 @return 是否更新成功
 */
+ (BOOL)insertOrUpdateDataToSQLiteWithPropertyKey:(NSString *)propertyKey propertyValue:(id)propertyValue primaryKeyObject:(NSString *)primaryKeyObject modelCls:(Class)objClass uid:(NSString *)uid {
    if (!propertyValue || propertyKey.length == 0) {
        return NO;
    }
    if (![objClass respondsToSelector:@selector(primaryKey)]) {
        NSLog(@"倘若希望使用 %@ 模型数组进行本地数据库新增或更新,需要实现 +(NSString *)primaryKey; 类方法(准守XWXModelProtocol协议)",NSStringFromClass(objClass));
        return NO;
    }
    if (![XWSqliteModelToolFM createTableFromCls:objClass uid:uid]) {
        NSLog(@"用 %@ 模型新建数据库失败!",NSStringFromClass(objClass));
        return NO;
    }
    return [XWSqliteTool deal:[self sql_insertOrUpdateDataToSQLiteWithPropertyKey:propertyKey propertyValue:propertyValue primaryKeyObject:primaryKeyObject modelCls:objClass uid:uid] uid:uid];
}

/**
 传入模型主键值提取数据库中存储的此模型数据

 @param primaryValue 主键值
 @param cls 模型类
 @param uid uid
 @return 数据库主键为primaryKey的模型
 */
+ (id <XWXModelProtocol>)objectFromDatabaseWithPrimaryValue:(NSInteger)primaryValue  modelCls:(Class)cls uid:(NSString *)uid {
    if (![cls respondsToSelector:@selector(primaryKey)]) {
        NSLog(@"倘若希望使用 %@ 模型数组进行本地数据库新增或更新,需要实现 +(NSString *)primaryKey; 类方法(准守XWXModelProtocol协议)",NSStringFromClass(cls));
        return NULL;
    }
    // 成员属性 = 数据库对应类型
    NSDictionary *ivarNameTypeDict = [XWXModelTool classIvarNameTypeDic:cls];
    // 所有成员属性
    NSArray <NSString *>*allPropertyStrs = [ivarNameTypeDict allKeys];
    // 数据库表名
    NSString *tableName = [XWXModelTool tableNameWithCls:cls];
    // 主键
    NSString *primaryKeyStr = [cls primaryKey];
    NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM %@ where %@ = '%zd'",tableName,primaryKeyStr,primaryValue];
    NSMutableArray *queryResult = [XWSqliteTool querySql:querySql uid:uid];
    if (queryResult.count == 0) {
        return NULL;
    }
    // 模型数据字典
    NSDictionary *modelDict = [queryResult objectAtIndex:0];
    
    Class xxModelClass = [cls class];
    id object = [[xxModelClass alloc] init];
    [modelDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj && [allPropertyStrs containsObject:key]) {
            [object setValue:obj forKey:key];
        }
    }];
    return (id<XWXModelProtocol>)object;
}

/**
 传入排序字段获取数据库模型表中所有数据
 select * from person order by id desc
 asc是表示升序，desc表示降序。
 @param sortKey 排序按照的字段
 @param isOrderDesc 是否降序
 @param cls 模型类
 @param uid uid
 @return 排好序的数据库模型表中所有数据
 */
+ (NSArray <id<XWXModelProtocol>> *)objectsFromDatabaseWithSortKey:(NSString *)sortKey isOrderDesc:(BOOL)isOrderDesc modelCls:(Class)cls uid:(NSString *)uid {
    if (sortKey.length == 0 || sortKey == NULL || [sortKey isEqualToString:@"'(null)'"]) {
        NSLog(@"请传入排序字段");
        return NULL;
    }
    // 成员属性 = 数据库对应类型
    NSDictionary *ivarNameTypeDict = [XWXModelTool classIvarNameTypeDic:cls];
    // 所有成员属性
    NSArray <NSString *>*allPropertyStrs = [ivarNameTypeDict allKeys];
    // 数据库表名
    NSString *tableName = [XWXModelTool tableNameWithCls:cls];
    NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM %@ order by %@ %@ ",tableName,sortKey,isOrderDesc?@"desc":@""];
    NSMutableArray *queryResult = [XWSqliteTool querySql:querySql uid:uid];
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    [queryResult enumerateObjectsUsingBlock:^(NSDictionary *modelDict, NSUInteger idx, BOOL * _Nonnull stop) {
        Class xxModelClass = [cls class];
        id xxModelObject = [[xxModelClass alloc] init];
        // 模型数据字典
        [modelDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if (obj && [allPropertyStrs containsObject:key]) {
                [xxModelObject setValue:obj forKey:key];
            }
        }];
        [objects addObject:xxModelObject];
    }];
    return objects;
}


/**
 传入模型主键值提取数据库中存储的此模型某字段数据
 
 @param primaryKey 主键值
 @param cls 模型类
 @param propertyKey 将要查询的属性字段
 @param uid uid
 @return 数据库主键为primaryKey的模型
 */
+ (id)valueFromDatabaseWithPrimaryKey:(NSString *)primaryKey modelCls:(Class)cls propertyKey:(NSString *)propertyKey uid:(NSString *)uid {
    if (primaryKey.length == 0 || primaryKey == NULL || [primaryKey isEqualToString:@"'(null)'"]) {
        NSLog(@"请传入主键");
        return NULL;
    }
    if (propertyKey.length == 0 || propertyKey == NULL || [propertyKey isEqualToString:@"'(null)'"]) {
        NSLog(@"请传入要查询的属性字段");
        return NULL;
    }
    if (![cls respondsToSelector:@selector(primaryKey)]) {
        NSLog(@"倘若希望使用 %@ 模型数组进行本地数据库新增或更新,需要实现 +(NSString *)primaryKey; 类方法(准守XWXModelProtocol协议)",NSStringFromClass(cls));
        return NULL;
    }
    // 成员属性 = 数据库对应类型
    NSDictionary *ivarNameTypeDict = [XWXModelTool classIvarNameTypeDic:cls];
    // 所有成员属性
    NSArray <NSString *>*allPropertyStrs = [ivarNameTypeDict allKeys];
    if (![allPropertyStrs containsObject:propertyKey]) {
        NSLog(@"模型中不存在您要查询的属性");
        return NULL;
    }
    // 数据库表名
    NSString *tableName = [XWXModelTool tableNameWithCls:cls];
    // 主键
    NSString *primaryKeyStr = [cls primaryKey];
    NSString *querySql = [NSString stringWithFormat:@"SELECT %@ FROM %@ where %@ = '%@'",propertyKey,tableName,primaryKeyStr,primaryKey];
    NSMutableArray *queryResult = [XWSqliteTool querySql:querySql uid:uid];
    if (queryResult.count == 0) {
        return NULL;
    }
    // 模型数据字典
    NSDictionary *modelDict = [queryResult objectAtIndex:0];
    return modelDict.allValues[0];
}

/**
 传入模型主键值提取数据库中存储的此模型某些字段数据
 
 @param primaryKey 主键值
 @param cls 模型类
 @param propertyKeys 将要查询的属性字段数组
 @param uid uid
 @return 数据库主键为primaryKey的模型
 */
+ (id <XWXModelProtocol>)valuesFromDatabaseWithPrimaryKey:(NSString *)primaryKey modelCls:(Class)cls propertyKeys:(NSArray<NSString *>*)propertyKeys uid:(NSString *)uid {
    if (primaryKey.length == 0 || primaryKey == NULL || [primaryKey isEqualToString:@"'(null)'"]) {
        NSLog(@"请传入主键");
        return NULL;
    }
    if (propertyKeys.count == 0 || propertyKeys == NULL) {
        NSLog(@"请传入要查询的属性字段数组");
        return NULL;
    }
    if (![cls respondsToSelector:@selector(primaryKey)]) {
        NSLog(@"倘若希望使用 %@ 模型数组进行本地数据库新增或更新,需要实现 +(NSString *)primaryKey; 类方法(准守XWXModelProtocol协议)",NSStringFromClass(cls));
        return NULL;
    }
    // 成员属性 = 数据库对应类型
    NSDictionary *ivarNameTypeDict = [XWXModelTool classIvarNameTypeDic:cls];
    // 所有成员属性
    NSArray <NSString *>*allPropertyStrs = [ivarNameTypeDict allKeys];
    for (NSString *propertyKey in propertyKeys) {
        if (![allPropertyStrs containsObject:propertyKey]) {
            NSLog(@"模型中不存在您要查询的属性");
            return NULL;
        }
    }
    NSString *propertyKeysStr = [propertyKeys componentsJoinedByString:@","];
    // 数据库表名
    NSString *tableName = [XWXModelTool tableNameWithCls:cls];
    // 主键
    NSString *primaryKeyStr = [cls primaryKey];
    NSString *querySql = [NSString stringWithFormat:@"SELECT %@ FROM %@ where %@ = '%@'",propertyKeysStr,tableName,primaryKeyStr,primaryKey];
    NSMutableArray *queryResult = [XWSqliteTool querySql:querySql uid:uid];
    if (queryResult.count == 0) {
        return NULL;
    }
    // 模型数据字典
    NSDictionary *modelDict = [queryResult objectAtIndex:0];
    
    Class xxModelClass = [cls class];
    id object = [[xxModelClass alloc] init];
    [modelDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj && [allPropertyStrs containsObject:key]) {
            [object setValue:obj forKey:key];
        }
    }];
    return object;
}

#pragma mark - private
+ (BOOL)toUpdateTable:(Class)cls uid:(NSString *)uid {
    if (![self isTableRequiredUpdate:cls uid:uid]) {
        return YES;
    }
    return [self updateTableFromCls:cls uid:uid];
}
/**
 
 
 @param obj 要插入的模型
 @return 最终SQL语句
 */

/**
 更新单个模型某属性值

 @param propertyKey 要更新的属性
 @param propertyValue 要更新的属性值
 @param primaryKeyObject 主键值
 @param objClass 模型类
 @param uid 用户ID
 @return 更新的sql语句
 */
+ (NSString *)sql_insertOrUpdateDataToSQLiteWithPropertyKey:(NSString *)propertyKey propertyValue:(id)propertyValue primaryKeyObject:(NSString *)primaryKeyObject modelCls:(Class)objClass uid:(NSString *)uid {
    // 主键
    NSString *primaryKeyStr = [objClass primaryKey];
    // 数据库表名
    NSString *tableName = [XWXModelTool tableNameWithCls:objClass];
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@ = '%@'",tableName,[NSString stringWithFormat:@"%@ = '%@'",propertyKey,propertyValue],primaryKeyStr,primaryKeyObject];
    return sql;
}


@end
