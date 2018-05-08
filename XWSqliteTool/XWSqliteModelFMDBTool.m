//
//  XWSqliteModelFMDBTool.m
//  XWSqliteTool
//
//  Created by 邱学伟 on 2017/2/8.
//  Copyright © 2017年 qxuewei@yeah.net. All rights reserved.
//

#import "XWSqliteModelFMDBTool.h"
#import "XWXModelTool.h"
#import "XWFMDatabaseQueueHelper.h"
#import <objc/runtime.h>

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

@interface XWSqliteTableTool : NSObject
+ (NSArray *)fmdb_tableSortedColumnNames:(Class)cls;
@end
@implementation XWSqliteTableTool
+ (NSArray *)fmdb_tableSortedColumnNames:(Class)cls {
    NSString *tableName = [XWXModelTool tableNameWithCls:cls];
    //SELECT sql FROM sqlite_master WHERE type = 'table' AND name = 'XWStuModel'
    NSString *queryCreateTableSql = [NSString stringWithFormat:@"SELECT * FROM sqlite_master WHERE type = 'table' AND name = '%@'",tableName];
    FMResultSet *resultSet = [[XWFMDatabaseQueueHelper sharedInstance] executeQuery:queryCreateTableSql];
    
    NSString *createTableSql;
    // 遍历查询结果
    while (resultSet.next) {
        createTableSql = [resultSet stringForColumnIndex:4];
    }
    
    /// 查询结束后关闭数据库
    [[XWFMDatabaseQueueHelper sharedInstance] closeDB];
    
    if (createTableSql.length == 0) {
        return NULL;
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

@implementation XWSqliteModelFMDBTool
#pragma mark - public
/// 创建新表
+(void)createTableFromClass:(Class)cls callBack:(XWSqliteModelFMDBToolCallBack)callBack{
    //建表sql语句
    // create table if not exists 表名(字段1 : 字段1约束, 字段2 : 字段2约束, ... ,primary key(字段))
    NSString *tableName = [XWXModelTool tableNameWithCls:cls];
    if (![cls respondsToSelector:@selector(primaryKey)]) {
        NSLog(@"倘若希望使用 %@ 模型直接创建数据库,需要实现 +(NSString *)primaryKey; 类方法(准守XWXModelProtocol协议)",NSStringFromClass(cls));
        callBack ? callBack(NO) : nil;
    }
    NSString *primary = [cls primaryKey];
    NSString *createTableSql = [NSString stringWithFormat:@"create table if not exists %@(%@,primary key(%@))",tableName,[XWXModelTool createTableSql:cls],primary];

    [[XWFMDatabaseQueueHelper sharedInstance] updateWithSqls:@[createTableSql] callBack:^(BOOL isSuccess) {
        callBack ? callBack(isSuccess) : nil;
    }];
}

/// 判断是否需要更新模型字段
+(BOOL)isTableRequiredUpdate:(Class)cls {
    NSArray *array = [XWSqliteTableTool fmdb_tableSortedColumnNames:cls];
    if (array.count == 0) {
        return NO;
    }
    NSArray *modelSortedNames = [XWXModelTool allTableSortedIvarNames:cls];
    return ![modelSortedNames isEqualToArray:array];
}

//倘若需要更新,则更新已有数据库表
+(void)updateTableFromCls:(Class)cls updateSqls:(NSArray <NSString *>*)updateSqls callBack:(XWSqliteModelFMDBToolCallBack)callBack{
    //建表sql语句
    // create table if not exists 表名(字段1 : 字段1约束, 字段2 : 字段2约束, ... ,primary key(字段))
    NSString *tableName = [XWXModelTool tableNameWithCls:cls];
    NSString *tempTableName = [XWXModelTool tempTableNameWithCls:cls];
    
    if (![cls respondsToSelector:@selector(primaryKey)]) {
        NSLog(@"倘若希望使用 %@ 模型直接创建数据库,需要实现 +(NSString *)primaryKey; 类方法(准守XWXModelProtocol协议)",NSStringFromClass(cls));
        callBack ? callBack(NO) : nil;
        return;
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
    NSArray *oldTable = [XWSqliteTableTool fmdb_tableSortedColumnNames:cls];
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
    
    if (updateSqls.count > 0) {
        [sqls addObjectsFromArray:updateSqls];
    }
    
    [[XWFMDatabaseQueueHelper sharedInstance] updateWithSqls:sqls callBack:^(BOOL isSuccess) {
        callBack ? callBack(isSuccess) : nil;
    }];
}

/// 对单个模型进行本地数据库新增或更新 - 若存在则更新所以字段,所不存在则插入本条数据
+ (void)insertOrUpdateDataToSQLiteWithModel:(NSObject <XWXModelProtocol>*)obj uid:(NSString *)uid isUpdateTable:(BOOL)isUpdateTable callBack:(XWSqliteModelFMDBToolCallBack)callback{
    if (!obj) {
        callback ? callback(NO) : nil;
        return;
    }
    Class objClass = [obj class];
    if (![objClass respondsToSelector:@selector(primaryKey)]) {
        NSLog(@"倘若希望使用 %@ 模型数组进行本地数据库新增或更新,需要实现 +(NSString *)primaryKey; 类方法(准守XWXModelProtocol协议)",NSStringFromClass(objClass));
        callback ? callback(NO) : nil;
        return;
    }
    
    
    [self createTableFromClass:objClass callBack:^(BOOL isSuccess) {
        if (!isSuccess) {
            NSLog(@"用 %@ 模型新建数据库失败!",NSStringFromClass(objClass));
            callback ? callback(NO) : nil;
            return;
        }
    }];
    
    if (isUpdateTable) {
        /// 需要判断是否需要动态更新表结构
        WS(weakSelf);
        /// 先判断是否需要更新!
        BOOL isRequired = [self isTableRequiredUpdate:objClass];
        if (isRequired) {
            /// 需要更新表结构
            NSString *sql = [weakSelf sql_insertOrUpdateDataToSQLiteWithModel:obj];
            [weakSelf updateTableFromCls:objClass updateSqls:@[sql] callBack:^(BOOL isSuccess) {
                callback ? callback(isSuccess) : nil;
            }];
        }else{
            NSString *sql = [weakSelf sql_insertOrUpdateDataToSQLiteWithModel:obj];
            [[XWFMDatabaseQueueHelper sharedInstance] updateWithSqls:@[sql] callBack:^(BOOL isSuccess) {
                callback ? callback(isSuccess) : nil;
            }];
        }
    }else{
        NSString *sql = [self sql_insertOrUpdateDataToSQLiteWithModel:obj];
        [[XWFMDatabaseQueueHelper sharedInstance] updateWithSqls:@[sql] callBack:^(BOOL isSuccess) {
            callback ? callback(isSuccess) : nil;
        }];
    }
}


/**
 对模型数组进行本地数据库新增或更新 - 若存在则更新所以字段,所不存在则插入本条数据

 @param objs 模型数组
 @param isUpdateTable 是否检查数据库表更新

 */
+ (void)insertOrUpdateDataToSQLiteWithModels:(NSArray <NSObject <XWXModelProtocol>*>*)objs uid:(NSString *)uid isUpdateTable:(BOOL)isUpdateTable callBack:(XWSqliteModelFMDBToolCallBack)callback{
    
    if (objs.count == 0) {
        callback ? callback(NO) : nil;
        return;
    }
    
    Class objClass = [[objs firstObject] class];
    if (![objClass respondsToSelector:@selector(primaryKey)]) {
        NSLog(@"倘若希望使用 %@ 模型数组进行本地数据库新增或更新,需要实现 +(NSString *)primaryKey; 类方法(准守XWXModelProtocol协议)",NSStringFromClass(objClass));
        callback ? callback(NO) : nil;
        return;
    }
    
    [XWSqliteModelFMDBTool createTableFromClass:objClass callBack:^(BOOL isSuccess) {
        if (!isSuccess) {
            NSLog(@"用 %@ 模型新建数据库失败!",NSStringFromClass(objClass));
            callback ? callback(NO) : nil;
            return;
        }
    }];
    
    if (isUpdateTable) {
        /// 需要判断是否需要动态更新表结构
        BOOL isRequired = [self isTableRequiredUpdate:objClass];
        if (isRequired) {
            /// 需要更新表结构
            NSMutableArray *sqls = [NSMutableArray array];
            for (NSObject <XWXModelProtocol>*obj in objs) {
                [sqls addObject:[self sql_insertOrUpdateDataToSQLiteWithModel:obj]];
            }
            [self updateTableFromCls:objClass updateSqls:sqls callBack:^(BOOL isSuccess) {
                callback ? callback(isSuccess) : nil;
            }];
            
        }else{
            NSMutableArray *sqls = [NSMutableArray array];
            for (NSObject <XWXModelProtocol>*obj in objs) {
                [sqls addObject:[self sql_insertOrUpdateDataToSQLiteWithModel:obj]];
            }
            [[XWFMDatabaseQueueHelper sharedInstance] updateWithSqls:sqls callBack:^(BOOL isSuccess) {
                callback ? callback(isSuccess) : nil;
            }];
        }
        
    }else{
        
        NSMutableArray *sqls = [NSMutableArray array];
        for (NSObject <XWXModelProtocol>*obj in objs) {
            [sqls addObject:[self sql_insertOrUpdateDataToSQLiteWithModel:obj]];
        }
        [[XWFMDatabaseQueueHelper sharedInstance] updateWithSqls:sqls callBack:^(BOOL isSuccess) {
            callback ? callback(isSuccess) : nil;
        }];
    }
}

/**
 更新数据库中某单独字段 (保证数据表库中此数据必须存在)

 @param propertyKey 要更新的属性字段
 @param propertyValue 属性值
 @param primaryKeyObject 主键值
 @param objClass 模型类


 */
+ (void)updateDataToSQLiteWithPropertyKey:(NSString *)propertyKey propertyValue:(id)propertyValue primaryKeyObject:(NSString *)primaryKeyObject modelCls:(Class)objClass callBack:(XWSqliteModelFMDBToolCallBack)callback {
    
    if (!propertyValue || propertyKey.length == 0) {
        callback ? callback(NO) : nil;
    }
    if (![objClass respondsToSelector:@selector(primaryKey)]) {
        NSLog(@"倘若希望使用 %@ 模型数组进行本地数据库新增或更新,需要实现 +(NSString *)primaryKey; 类方法(准守XWXModelProtocol协议)",NSStringFromClass(objClass));
        callback ? callback(NO) : nil;
    }
   
    [XWSqliteModelFMDBTool createTableFromClass:objClass callBack:^(BOOL isSuccess) {
        if (!isSuccess) {
            NSLog(@"用 %@ 模型新建数据库失败!",NSStringFromClass(objClass));
            callback ? callback(NO) : nil;
            return;
        }
    }];
    
    NSString *sql = [self sql_updateDataToSQLiteWithPropertyKey:propertyKey propertyValue:propertyValue primaryKeyObject:primaryKeyObject modelCls:objClass];
    
    [[XWFMDatabaseQueueHelper sharedInstance] updateWithSqls:@[sql] callBack:^(BOOL isSuccess) {
        callback ? callback(isSuccess) : nil;
    }];
}

/**
 传入模型主键值提取数据库中存储的此模型数据

 @param primaryValue 主键值
 @param cls 模型类
 */
+ (void)objectFromDatabaseWithPrimaryValue:(NSInteger)primaryValue  modelCls:(Class)cls resultCallBack:(XWSqliteModelFMDBToolResultCallBack)resultCallBack {
    if (![cls respondsToSelector:@selector(primaryKey)]) {
        NSLog(@"倘若希望使用 %@ 模型数组进行本地数据库新增或更新,需要实现 +(NSString *)primaryKey; 类方法(准守XWXModelProtocol协议)",NSStringFromClass(cls));
        resultCallBack ? resultCallBack(NULL) : nil;
        return;
    }
    
    // 成员属性 = 数据库对应类型
    NSDictionary *ivarNameTypeDict = [XWXModelTool classIvarNameTypeDic:cls];
    // 数据库表名
    NSString *tableName = [XWXModelTool tableNameWithCls:cls];
    // 主键
    NSString *primaryKeyStr = [cls primaryKey];
    // sql
    NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM %@ where %@ = '%zd'",tableName,primaryKeyStr,primaryValue];
    WS(weakSelf);
    [[XWFMDatabaseQueueHelper sharedInstance] queryWithSqls:@[querySql] callBack:^(NSArray<FMResultSet *> *resultSets) {
        if (resultSets.count == 0) {
            resultCallBack ? resultCallBack(NULL) : nil;
            return ;
        }
        FMResultSet *result = resultSets[0];
        Class xModelClass = [cls class];
        id xObject = [[xModelClass alloc] init];
        while (result.next) {
            [ivarNameTypeDict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *type, BOOL * _Nonnull stop) {
                [weakSelf setProperty:xObject value:result columnName:key propertyName:key firstType:type];
            }];
        }
        resultCallBack ? resultCallBack((id<XWXModelProtocol>)xObject) : nil;
    }];
}

/**
 传入排序字段获取数据库模型表中所有数据
 select * from person order by id desc
 asc是表示升序，desc表示降序。
 @param sortKey 排序按照的字段
 @param isOrderDesc 是否降序
 @param cls 模型类
 @modelsCallBack 排好序的数据库模型表中所有数据
 */
+ (void)objectsFromDatabaseWithSortKey:(NSString *)sortKey isOrderDesc:(BOOL)isOrderDesc modelCls:(Class)cls modelsCallBack:(void(^)(NSArray <id<XWXModelProtocol>>*models))modelsCallBack {
    
    if (sortKey.length == 0 || sortKey == NULL || [sortKey isEqualToString:@"'(null)'"]) {
        NSLog(@"请传入排序字段");
        modelsCallBack ? modelsCallBack(NULL) : nil;
        return;
    }
    
    // 成员属性 = 数据库对应类型
    NSDictionary *ivarNameTypeDict = [XWXModelTool classIvarNameTypeDic:cls];
    
    // 数据库表名
    NSString *tableName = [XWXModelTool tableNameWithCls:cls];
    NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM %@ order by %@ %@ ",tableName,sortKey,isOrderDesc?@"desc":@""];
    
    WS(weakSelf);
    [[XWFMDatabaseQueueHelper sharedInstance] queryWithSqls:@[querySql] callBack:^(NSArray<FMResultSet *> *resultSets) {
        if (resultSets.count == 0) {
            modelsCallBack ? modelsCallBack(NULL) : nil;
            return ;
        }
        FMResultSet *result = resultSets[0];
        NSMutableArray *objects = [[NSMutableArray alloc] init];
        while (result.next) {
            Class xModelClass = [cls class];
            id xObject = [[xModelClass alloc] init];
            [ivarNameTypeDict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *type, BOOL * _Nonnull stop) {
                [weakSelf setProperty:xObject value:result columnName:key propertyName:key firstType:type];
            }];
            [objects addObject:xObject];
        }
        modelsCallBack ? modelsCallBack(objects) : nil;
    }];
}


/**
 传入模型主键值提取数据库中存储的此模型某字段数据
 
 @param primaryKey 主键值
 @param cls 模型类
 @param propertyKey 将要查询的属性字段
 @valueCallBack 数据库主键为primaryKey的模型
 */
+ (void)valueFromDatabaseWithPrimaryKey:(NSString *)primaryKey modelCls:(Class)cls propertyKey:(NSString *)propertyKey valueCallBack:(void(^)(id value))valueCallBack {
    if (primaryKey.length == 0 || primaryKey == NULL || [primaryKey isEqualToString:@"'(null)'"]) {
        NSLog(@"请传入主键");
        valueCallBack ? valueCallBack(NULL) : nil;
        return ;
    }
    if (propertyKey.length == 0 || propertyKey == NULL || [propertyKey isEqualToString:@"'(null)'"]) {
        NSLog(@"请传入要查询的属性字段");
        valueCallBack ? valueCallBack(NULL) : nil;
        return ;
    }
    if (![cls respondsToSelector:@selector(primaryKey)]) {
        NSLog(@"倘若希望使用 %@ 模型数组进行本地数据库新增或更新,需要实现 +(NSString *)primaryKey; 类方法(准守XWXModelProtocol协议)",NSStringFromClass(cls));
        valueCallBack ? valueCallBack(NULL) : nil;
        return ;
    }
    
    // 成员属性 = 数据库对应类型
    NSDictionary *ivarNameTypeDict = [XWXModelTool classIvarNameTypeDic:cls];
    // 所有成员属性
    NSArray <NSString *>*allPropertyStrs = [ivarNameTypeDict allKeys];
    if (![allPropertyStrs containsObject:propertyKey]) {
        NSLog(@"模型中不存在您要查询的属性");
        valueCallBack ? valueCallBack(NULL) : nil;
        return ;
    }
    // 数据库表名
    NSString *tableName = [XWXModelTool tableNameWithCls:cls];
    // 主键
    NSString *primaryKeyStr = [cls primaryKey];
    NSString *querySql = [NSString stringWithFormat:@"SELECT %@ FROM %@ where %@ = '%@'",propertyKey,tableName,primaryKeyStr,primaryKey];
    
     [[XWFMDatabaseQueueHelper sharedInstance] queryWithSqls:@[querySql] callBack:^(NSArray<FMResultSet *> *resultSets) {
         if (resultSets.count == 0) {
             valueCallBack ? valueCallBack(NULL) : nil;
             return ;
         }
         FMResultSet *rs = resultSets[0];
         while (rs.next) {
             valueCallBack ? valueCallBack([rs objectForColumn:propertyKey]) : nil;
             return;
         }
     }];
}

/**
 传入模型主键值提取数据库中存储的此模型某些字段数据
 
 @param primaryKey 主键值
 @param cls 模型类
 @param propertyKeys 将要查询的属性字段数组
 @resultCallBack 数据库主键为primaryKey的模型
 */
+ (void)valuesFromDatabaseWithPrimaryKey:(NSString *)primaryKey modelCls:(Class)cls propertyKeys:(NSArray<NSString *>*)propertyKeys resultCallBack:(XWSqliteModelFMDBToolResultCallBack)resultCallBack {
    
    if (primaryKey.length == 0 || primaryKey == NULL || [primaryKey isEqualToString:@"'(null)'"]) {
        NSLog(@"请传入主键");
        resultCallBack ? resultCallBack(NULL) : nil;
        return ;
    }
    if (propertyKeys.count == 0 || propertyKeys == NULL) {
        NSLog(@"请传入要查询的属性字段数组");
        resultCallBack ? resultCallBack(NULL) : nil;
        return ;
    }
    if (![cls respondsToSelector:@selector(primaryKey)]) {
        NSLog(@"倘若希望使用 %@ 模型数组进行本地数据库新增或更新,需要实现 +(NSString *)primaryKey; 类方法(准守XWXModelProtocol协议)",NSStringFromClass(cls));
        resultCallBack ? resultCallBack(NULL) : nil;
        return ;
    }
    // 成员属性 = 数据库对应类型
    NSDictionary *ivarNameTypeDict = [XWXModelTool classIvarNameTypeDic:cls];
    // 所有成员属性
    NSArray <NSString *>*allPropertyStrs = [ivarNameTypeDict allKeys];
    for (NSString *propertyKey in propertyKeys) {
        if (![allPropertyStrs containsObject:propertyKey]) {
            NSLog(@"模型中不存在您要查询的属性");
            resultCallBack ? resultCallBack(NULL) : nil;
            return ;
        }
    }
    NSString *propertyKeysStr = [propertyKeys componentsJoinedByString:@","];
    // 数据库表名
    NSString *tableName = [XWXModelTool tableNameWithCls:cls];
    // 主键
    NSString *primaryKeyStr = [cls primaryKey];
    NSString *querySql = [NSString stringWithFormat:@"SELECT %@ FROM %@ where %@ = '%@'",propertyKeysStr,tableName,primaryKeyStr,primaryKey];
    WS(weakSelf);
    [[XWFMDatabaseQueueHelper sharedInstance] queryWithSqls:@[querySql] callBack:^(NSArray<FMResultSet *> *resultSets) {
        if (resultSets.count == 0) {
            resultCallBack ? resultCallBack(NULL) : nil;
            return ;
        }
        FMResultSet *result = resultSets[0];
        Class xModelClass = [cls class];
        id xObject = [[xModelClass alloc] init];
        while (result.next) {
            [ivarNameTypeDict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *type, BOOL * _Nonnull stop) {
                if ([propertyKeys containsObject:key]) {
                    [weakSelf setProperty:xObject value:result columnName:key propertyName:key firstType:type];
                }
            }];
        }
        resultCallBack ? resultCallBack((id<XWXModelProtocol>)xObject) : nil;
    }];
}

#pragma mark - private
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
 */
+ (NSString *)sql_insertOrUpdateDataToSQLiteWithModel:(NSObject <XWXModelProtocol>*)obj {
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
    
    FMResultSet *resultSet = [[XWFMDatabaseQueueHelper sharedInstance] executeQuery:queryIsExistThisDataSql];
    
    NSString *sql;
    if (!resultSet.next) {
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
        sql = insertSql;
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
        sql = updateSql;
    }
    
    [[XWFMDatabaseQueueHelper sharedInstance] closeDB];
    return sql;
}

/**
 更新单个模型某属性值

 @param propertyKey 要更新的属性
 @param propertyValue 要更新的属性值
 @param primaryKeyObject 主键值
 @param objClass 模型类
 @return 更新的sql语句
 */
+ (NSString *)sql_updateDataToSQLiteWithPropertyKey:(NSString *)propertyKey propertyValue:(id)propertyValue primaryKeyObject:(NSString *)primaryKeyObject modelCls:(Class)objClass {
    // 主键
    NSString *primaryKeyStr = [objClass primaryKey];
    // 数据库表名
    NSString *tableName = [XWXModelTool tableNameWithCls:objClass];
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@ = '%@'",tableName,[NSString stringWithFormat:@"%@ = '%@'",propertyKey,propertyValue],primaryKeyStr,primaryKeyObject];
    return sql;
}

/*
*  进行属性赋值
*/
+ (void)setProperty:(id)model value:(FMResultSet *)rs columnName:(NSString *)columnName propertyName:(NSString *)propertyName firstType:(NSString *)firstType
{
    //    @"f":@"float",
    //    @"i":@"int",
    //    @"d":@"double",
    //    @"l":@"long",
    //    @"c":@"BOOL",
    //    @"s":@"short",
    //    @"q":@"long",
    //    @"I":@"NSInteger",
    //    @"Q":@"NSUInteger",
    //    @"B":@"BOOL",
    
    
    if ([rs columnIsNull:columnName]) {
        return;
    }
    
    if ([firstType isEqualToString:@"f"]) {
        NSNumber *number = [rs objectForColumn:columnName];
        [model setValue:@(number.floatValue) forKey:propertyName];
        
    } else if([firstType isEqualToString:@"i"]){
        NSNumber *number = [rs objectForColumn:columnName];
        [model setValue:@(number.intValue) forKey:propertyName];
        
    } else if([firstType isEqualToString:@"d"]){
        [model setValue:[rs objectForColumn:columnName] forKey:propertyName];
        
    } else if([firstType isEqualToString:@"l"] || [firstType isEqualToString:@"q"]){
        [model setValue:[rs objectForColumn:columnName] forKey:propertyName];
        
    } else if([firstType isEqualToString:@"c"] || [firstType isEqualToString:@"B"]){
        NSNumber *number = [rs objectForColumn:columnName];
        [model setValue:@(number.boolValue) forKey:propertyName];
        
    } else if([firstType isEqualToString:@"s"]){
        NSNumber *number = [rs objectForColumn:columnName];
        [model setValue:@(number.shortValue) forKey:propertyName];
        
    } else if([firstType isEqualToString:@"I"]){
        NSNumber *number = [rs objectForColumn:columnName];
        [model setValue:@(number.integerValue) forKey:propertyName];
        
    } else if([firstType isEqualToString:@"Q"]){
        NSNumber *number = [rs objectForColumn:columnName];
        [model setValue:@(number.unsignedIntegerValue) forKey:propertyName];
        
    } else if([firstType isEqualToString:@"@\"NSData\""]){
        NSData *value = [rs dataForColumn:columnName];
        [model setValue:value forKey:propertyName];
        
    } else if([firstType isEqualToString:@"@\"NSDate\""]){
        NSDate *value = [rs dateForColumn:columnName];
        [model setValue:value forKey:propertyName];
        
    } else if([firstType isEqualToString:@"@\"NSString\""]){
        NSString *value = [rs stringForColumn:columnName];
        [model setValue:value forKey:propertyName];
        
    } else {
        [model setValue:[rs objectForColumn:columnName] forKey:propertyName];
    }
}

@end
