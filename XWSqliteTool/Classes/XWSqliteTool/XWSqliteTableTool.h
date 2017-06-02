//
//  XWSqliteTableTool.h
//  XWSqliteTool
//
//  Created by 邱学伟 on 2017/2/8.
//  Copyright © 2017年 qxuewei@yeah.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XWSqliteTableTool : NSObject
+(NSArray *)tableSortedColumnNames:(Class)cls uid:(NSString *)uid;
@end
