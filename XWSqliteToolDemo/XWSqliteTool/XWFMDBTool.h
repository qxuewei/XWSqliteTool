//
//  XWFMDBTool.h
//  XWSqliteTool_Example
//
//  Created by 邱学伟 on 2018/4/4.
//  Copyright © 2018年 qxuewei@yeah.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
@interface XWFMDBTool : NSObject

/**
 执行更新
 
 在FMDB中，除查询以外的所有操作，都称为“更新”
 create、drop、insert、update、delete等

 @param sql 操作的 sql 语句
 @param uid 用户id  其中uid用户机制:uid = nil - XWCommon.sqlite(共有库)   uid != nil - uid.sqlite
 @return 执行结果
 */
+(BOOL)updateWithSql:(NSString *)sql uid:(NSString *)uid;

/**
  查询

 @param sql 查询语句
 @param uid 用户id  其中uid用户机制:uid = nil - XWCommon.sqlite(共有库)   uid != nil - uid.sqlite
 @return 查询结果
 */
+(FMResultSet *)querySql:(NSString *)sql uid:(NSString *)uid;

/// 更新事务操作

/**
 更新事务操作

 @param sqls 要执行更新的SQL语句数组
 @param uid 用户id  其中uid用户机制:uid = nil - XWCommon.sqlite(共有库)   uid != nil - uid.sqlite
 @param callBack 回调
 */
+(void)updateWithSqls:(NSArray<NSString*>*)sqls uid:(NSString *)uid callBack:(void(^)(BOOL isSuccess))callBack;

@end
