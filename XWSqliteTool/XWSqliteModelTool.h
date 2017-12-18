//
//  XWSqliteModelTool.h
//  XWSqliteTool
//
//  Created by 邱学伟 on 2017/2/8.
//  Copyright © 2017年 qxuewei@yeah.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XWXModelProtocol.h"
@interface XWSqliteModelTool : NSObject
/**
 根据模型建表

 @param cls 模型类
 @param uid 用户ID 可区分不同数据库
 @return 是否成功建表
 */
+(BOOL)createTableFromCls:(Class)cls uid:(NSString *)uid;

/**
 当前模型是否需要更新已有数据库表

 @param cls  模型类
 @param uid 用户ID 可区分不同数据库
 @return 当前模型是否需要更新已有数据库表
 */
+(BOOL)isTableRequiredUpdate:(Class)cls uid:(NSString *)uid;

/**
 倘若需要更新,则更新已有数据库表

 @param cls 模型类
 @param uid 用户ID 可区分不同数据库
 @return 倘若需要更新,是否成功更新已有数据库表
 */
+(BOOL)updateTableFromCls:(Class)cls uid:(NSString *)uid;

/**
 传入模型进行本地数据新增或更新 - 若存在则更新所以字段,所不存在则插入本条数据
 
 @param obj 要插入的模型
 @return 最终SQL语句
 */
+ (NSString *)sql_insertOrUpdateDataToSQLiteWithModel:(NSObject <XWXModelProtocol>*)obj uid:(NSString *)uid;

/**
 对模型进行本地数据库新增或更新 - 若存在则更新所以字段,所不存在则插入本条数据
 
 @param obj 模型
 @param isUpdateTable 是否检查数据库表更新
 @return 更新结果
 */
+ (BOOL)insertOrUpdateDataToSQLiteWithModel:(NSObject <XWXModelProtocol>*)obj uid:(NSString *)uid isUpdateTable:(BOOL)isUpdateTable;

/**
 对模型数组进行本地数据库新增或更新 - 若存在则更新所以字段,所不存在则插入本条数据
 
 @param objs 模型数组
 @param isUpdateTable 是否检查数据库表更新
 @return 更新结果
 */
+ (BOOL)insertOrUpdateDataToSQLiteWithModels:(NSArray <NSObject <XWXModelProtocol>*>*)objs uid:(NSString *)uid isUpdateTable:(BOOL)isUpdateTable;

/**
 传入模型主键值提取数据库中存储的此模型数据
 
 @param primaryKey 主键值
 @param cls 模型类
 @param uid uid
 @return 数据库主键为primaryKey的模型
 */
+ (id <XWXModelProtocol>)objectFromDatabaseWithPrimaryKey:(NSString *)primaryKey modelCls:(Class)cls uid:(NSString *)uid;

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
