//
//  XWXModelTool.m
//  XWSqliteTool
//
//  Created by 邱学伟 on 2017/2/8.
//  Copyright © 2017年 qxuewei@yeah.net. All rights reserved.
//

#import "XWXModelTool.h"
#import <objc/runtime.h>
#import "XWXModelProtocol.h"
@implementation XWXModelTool
+(NSString *)tableNameWithCls:(Class)cls{
    return NSStringFromClass(cls);
}
+(NSString *)tempTableNameWithCls:(Class)cls{
    return [NSStringFromClass(cls) stringByAppendingString:@"_temp"];
}
+(NSDictionary *)classIvarNameTypeDic:(Class)cls{
    unsigned int outCount = 0;
    Ivar *varList = class_copyIvarList(cls,&outCount);
    NSMutableDictionary *varListDict = [NSMutableDictionary dictionary];
    NSArray *ignoreColumn = [NSArray array];
    if ([cls respondsToSelector:@selector(ignoreColumnNames)]) {
        ignoreColumn = [cls ignoreColumnNames];
    }
    for (int i = 0; i < outCount; i++) {
        Ivar var = varList[i];
        //成员变量名称
        NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(var)];
        if ([ivarName hasPrefix:@"_"]) {
            ivarName = [ivarName substringFromIndex:1];
        }
        if ([ignoreColumn containsObject:ivarName]) {
            continue;
        }
        //成员变量类型
        NSString *ivarType = [NSString stringWithUTF8String:ivar_getTypeEncoding(var)];
        ivarType = [ivarType stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@\""]];
        [varListDict setObject:ivarType forKey:ivarName];
    }
    return varListDict;
}
+(NSDictionary *)classIvarNameSqliteTypeDic:(Class)cls{
    NSMutableDictionary *varList = [[self classIvarNameTypeDic:cls] mutableCopy];
    NSDictionary *OCToSqliteDict = [self ocTypeToSqliteTypeDic];
    [varList enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL * _Nonnull stop) {
        varList[key] = OCToSqliteDict[obj];
    }];
    return varList;
}

+(NSString *)createTableSql:(Class)cls{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSDictionary *ivarSqliteTyleDict = [self classIvarNameSqliteTypeDic:cls];
    [ivarSqliteTyleDict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL * _Nonnull stop) {
        [result addObject:[NSString stringWithFormat:@"%@ %@",key,obj]];
    }];
    return [result componentsJoinedByString:@","];
}

+(NSArray *)allTableSortedIvarNames:(Class)cls{
    NSDictionary *classIvarNameSqliteTypeDic = [self classIvarNameSqliteTypeDic:cls];
    NSMutableArray *allKeys = [[classIvarNameSqliteTypeDic allKeys] mutableCopy];
    [allKeys sortUsingComparator:^NSComparisonResult(NSString* obj1, NSString*  obj2) {
        return [obj1 compare:obj2];
    }];
    return allKeys; 
}
#pragma mark - 私有的方法
+ (NSDictionary *)ocTypeToSqliteTypeDic {
    return @{
             @"d": @"real",     // double
             @"f": @"real",     // float
             @"i": @"integer",  // int
             @"q": @"integer",  // long
             @"Q": @"integer",  // long long
             @"B": @"integer",  // bool
             @"NSData": @"blob",
             @"NSDictionary": @"text",
             @"NSMutableDictionary": @"text",
             @"NSArray": @"text",
             @"NSMutableArray": @"text",
             @"NSString": @"text"
             };
}

@end
