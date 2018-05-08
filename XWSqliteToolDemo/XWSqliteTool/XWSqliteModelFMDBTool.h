//
//  XWSqliteModelFMDBTool.h
//  XWSqliteTool
//
//  Created by 邱学伟 on 2017/2/8.
//  Copyright © 2017年 qxuewei@yeah.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XWXModelProtocol.h"

typedef void(^XWSqliteModelFMDBToolCallBack)(BOOL isSuccess);
typedef void(^XWSqliteModelFMDBToolSqlCallBack)(NSString *sql);
typedef void(^XWSqliteModelFMDBToolResultCallBack)(id <XWXModelProtocol>obj);
typedef void(^XWSqliteModelFMDBToolResultsCallBack)(NSArray <id <XWXModelProtocol>> *objs);

@interface XWSqliteModelFMDBTool : NSObject

/**
 根据模型建表

 @param cls 模型类
 */
+ (void)createTableFromClass:(Class)cls callBack:(XWSqliteModelFMDBToolCallBack)callBack;

/**
 当前模型是否需要更新已有数据库表

 @param cls  模型类

 */
+ (BOOL)isTableRequiredUpdate:(Class)cls;

/**
 倘若需要更新,则更新已有数据库表

 @param cls 模型类
 @param updateSqls 表迁移后更新sql (单纯更新表结构传nil)
 @param callBack 结果
 */
+ (void)updateTableFromCls:(Class)cls updateSqls:(NSArray <NSString *>*)updateSqls callBack:(XWSqliteModelFMDBToolCallBack)callBack;

/**
 对单个模型进行本地数据库新增或更新 - 若存在则更新所以字段,所不存在则插入本条数据
 
 @param obj 模型
 @param isUpdateTable 是否检查数据库表更新
 */
+ (void)insertOrUpdateDataToSQLiteWithModel:(NSObject <XWXModelProtocol>*)obj uid:(NSString *)uid isUpdateTable:(BOOL)isUpdateTable callBack:(XWSqliteModelFMDBToolCallBack)callback;

/**
 对模型数组进行本地数据库新增或更新 - 若存在则更新所以字段,所不存在则插入本条数据
 
 @param objs 模型数组
 @param isUpdateTable 是否检查数据库表更新
 
 */
+ (void)insertOrUpdateDataToSQLiteWithModels:(NSArray <NSObject <XWXModelProtocol>*>*)objs uid:(NSString *)uid isUpdateTable:(BOOL)isUpdateTable callBack:(XWSqliteModelFMDBToolCallBack)callback;

/**
 更新数据库中某单独字段 (保证数据表库中此数据必须存在)
 
 @param propertyKey 要更新的属性字段
 @param propertyValue 属性值
 @param primaryKeyObject 主键值
 @param objClass 模型类
 @param uid UID

 */
+ (void)insertOrUpdateDataToSQLiteWithPropertyKey:(NSString *)propertyKey propertyValue:(id)propertyValue primaryKeyObject:(NSString *)primaryKeyObject modelCls:(Class)objClass uid:(NSString *)uid callBack:(XWSqliteModelFMDBToolCallBack)callback;


/**
 传入模型主键值提取数据库中存储的此模型数据
 
 @param primaryValue 主键值
 @param cls 模型类
 @resultCallBack 数据库主键为primaryKey的模型
 */
+ (void)objectFromDatabaseWithPrimaryValue:(NSInteger)primaryValue  modelCls:(Class)cls  resultCallBack:(XWSqliteModelFMDBToolResultCallBack)resultCallBack ;

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
+ (NSArray <id<XWXModelProtocol>> *)objectsFromDatabaseWithSortKey:(NSString *)sortKey isOrderDesc:(BOOL)isOrderDesc modelCls:(Class)cls uid:(NSString *)uid;

/**
 传入模型主键值提取数据库中存储的此模型某字段数据
 
 @param primaryKey 主键值
 @param cls 模型类
 @param propertyKey 将要查询的属性字段
 @param uid uid
 @return 数据库主键为primaryKey的模型
 */
+ (id)valueFromDatabaseWithPrimaryKey:(NSString *)primaryKey modelCls:(Class)cls propertyKey:(NSString *)propertyKey uid:(NSString *)uid;

/**
 传入模型主键值提取数据库中存储的此模型某几个字段数据
 
 @param primaryKey 主键值
 @param cls 模型类
 @param propertyKeys 将要查询的属性字段数组
 @param uid uid
 @return 数据库主键为primaryKey的模型
 */
+ (id <XWXModelProtocol>)valuesFromDatabaseWithPrimaryKey:(NSString *)primaryKey modelCls:(Class)cls propertyKeys:(NSArray<NSString *>*)propertyKeys uid:(NSString *)uid;
@end
