//
//  XWFMDBTool.h
//  XWSqliteTool_Example
//
//  Created by 邱学伟 on 2018/4/4.
//  Copyright © 2018年 qxuewei@yeah.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XWFMDBTool : NSObject
/// 处理sql语句, 其中uid用户机制:uid = nil - XWCommon.sqlite(共有库)   uid != nil - uid.sqlite
+(BOOL)deal:(NSString *)url uid:(NSString *)uid;
@end
