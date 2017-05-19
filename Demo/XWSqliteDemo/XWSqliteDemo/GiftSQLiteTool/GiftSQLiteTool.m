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
   NSDictionary *DICT =  [XWXModelTool classIvarNameTypeDic:[GiftModel class]];
    
    [giftModles enumerateObjectsUsingBlock:^(GiftModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //INSERT INTO TABLE_NAME (column1, column2, column3,...columnN)]
        //VALUES (value1, value2, value3,...valueN)
        
    }];
}



@end
