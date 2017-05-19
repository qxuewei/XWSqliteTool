//
//  GiftSQLiteTool.h
//  XWSqliteDemo
//
//  Created by 邱学伟 on 2017/5/18.
//  Copyright © 2017年 邱学伟. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GiftModel;
@interface GiftSQLiteTool : NSObject
/// document 创建礼物数据库
+ (BOOL)creatGiftSQLite;
/// 存储展示的模型数组到数据库
+ (void)saveModelsWithShow:(NSArray <GiftModel *>*)giftModles;
@end
