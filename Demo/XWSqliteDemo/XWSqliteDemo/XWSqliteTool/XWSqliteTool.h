//
//  XWSqliteTool.h
//  XWSqliteTool
//
//  Created by 邱学伟 on 2017/2/7.
//  Copyright © 2017年 qxuewei@yeah.net. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface XWSqliteTool : NSObject
/// 处理sql语句, 其中uid用户机制:uid = nil - XWCommon.sqlite(共有库)   uid != nil - uid.sqlite
+(BOOL)deal:(NSString *)url uid:(NSString *)uid;
/// 查询语句
+(NSMutableArray<NSMutableDictionary *> *)querySql:(NSString *)sql  uid:(NSString *)uid;
/// 事务处理多条语句
+(BOOL)dealSqls:(NSArray<NSString*>*)sqls uid:(NSString *)uid;
@end
