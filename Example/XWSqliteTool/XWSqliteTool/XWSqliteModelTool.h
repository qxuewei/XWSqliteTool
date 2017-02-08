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
/// 根据模型建表
+(BOOL)createTableFromCls:(Class)cls uid:(NSString *)uid;
/// 当前模型是否需要更新已有数据库表
+(BOOL)isTableRequiredUpdate:(Class)cls uid:(NSString *)uid;
/// 倘若需要更新,则更新已有数据库表
+(BOOL)updateTableFromCls:(Class)cls uid:(NSString *)uid;
@end
