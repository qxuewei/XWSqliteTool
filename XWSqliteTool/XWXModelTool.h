//
//  XWXModelTool.h
//  XWSqliteTool
//
//  Created by 邱学伟 on 2017/2/8.
//  Copyright © 2017年 qxuewei@yeah.net. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface XWXModelTool : NSObject
/// 根据某模型获取表名
+(NSString *)tableNameWithCls:(Class)cls;
/// 根据某模型获取临时表名
+(NSString *)tempTableNameWithCls:(Class)cls;
/// 模型所有成员变量
+(NSDictionary *)classIvarNameTypeDic:(Class)cls;
/// 模型所有成员变量在sqlite数据库中对应的类型
+(NSDictionary *)classIvarNameSqliteTypeDic:(Class)cls;
/// 模型对应的 sql 语句
+(NSString *)createTableSql:(Class)cls;
/// 所有排序后的类型名称
+(NSArray *)allTableSortedIvarNames:(Class)cls;
@end
