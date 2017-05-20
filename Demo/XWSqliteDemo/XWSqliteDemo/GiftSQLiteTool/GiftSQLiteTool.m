//
//  GiftSQLiteTool.m
//  XWSqliteDemo
//
//  Created by 邱学伟 on 2017/5/18.
//  Copyright © 2017年 邱学伟. All rights reserved.
//

#import "GiftSQLiteTool.h"
#import "XWSqliteTool.h"
#import "XWSqliteModelTool.h"
#import "XWXModelTool.h"
#import "XWSqliteTableTool.h"
#import "GiftModel.h"



@implementation GiftSQLiteTool

/// 创建礼物数据库
+ (BOOL)creatGiftSQLite {
    return [XWSqliteModelTool createTableFromCls:[GiftModel class] uid:nil];
}

/// 存储展示的模型数组到数据库
+ (void)saveModelsWithShow:(NSArray <GiftModel *>*)giftModles {
    NSString *tableName = [XWXModelTool tableNameWithCls:[GiftModel class]];
   NSDictionary *DICT =  [XWXModelTool classIvarNameTypeDic:[GiftModel class]];
    NSArray *allPropertys = [DICT allKeys];
    NSMutableArray *updateSQLArrM = [NSMutableArray array];
//    for (NSString *property in allPropertys) {
//        NSString *searchSql = @"SELECT * FROM %@ WHERE ''",tableName;
//    }
    
    
}



@end
