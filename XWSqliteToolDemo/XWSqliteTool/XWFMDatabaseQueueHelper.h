//
//  XWFMDatabaseQueueHelper.h
//  XWSqliteToolDemo
//
//  Created by 邱学伟 on 2018/5/7.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface XWFMDatabaseQueueHelper : NSObject

+ (XWFMDatabaseQueueHelper *)sharedInstance;

- (void)closeDB;

- (BOOL)executeUpdate:(NSString *)sql;

- (FMResultSet *)executeQuery:(NSString *)sql;

- (void)inDatabase:(void(^)(FMDatabase *db))block;

- (void)updateWithSqls:(NSArray<NSString*>*)sqls callBack:(void(^)(BOOL isSuccess))callBack;

@end
