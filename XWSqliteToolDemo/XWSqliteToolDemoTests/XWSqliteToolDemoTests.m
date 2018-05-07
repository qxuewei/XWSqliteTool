//
//  XWSqliteToolDemoTests.m
//  XWSqliteToolDemoTests
//
//  Created by 邱学伟 on 2018/4/8.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "XWSqliteModelFMDBTool.h"
#import "XWPerson.h"
#import "XWStudent.h"
@interface XWSqliteToolDemoTests : XCTestCase

@end

@implementation XWSqliteToolDemoTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
    NSLog(@"%@",NSHomeDirectory());
}

- (void)testExample {
}

//根据模型建表
- (void)testCreateTableFromClass {
    [XWSqliteModelFMDBTool createTableFromClass:[XWPerson class] uid:nil callBack:^(BOOL isSuccess) {
        XCTAssertTrue(isSuccess);
    }];
}

// 模型对应的数据库是否需要更新
- (void)testIsTableRequiredUpdate {
    XCTAssertTrue([XWSqliteModelFMDBTool isTableRequiredUpdate:[XWPerson class]]);
//    XCTAssertFalse([XWSqliteModelFMDBTool isTableRequiredUpdate:[XWPerson class]]);
}

// 模型字段增加更新数据库
- (void)testUpdateModelTable {
    [XWSqliteModelFMDBTool updateTableFromCls:[XWPerson class] uid:nil callBack:^(BOOL isSuccess) {
        XCTAssert(isSuccess == 1);
    }];
}

- (void)testInsertOneObj {
    [XWSqliteModelFMDBTool insertOrUpdateDataToSQLiteWithModel:[self demoPerson] uid:nil isUpdateTable:YES callBack:^(BOOL isSuccess) {
        XCTAssert(isSuccess);
    }];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (XWPerson *)demoPerson {
    XWPerson *stu = [[XWPerson alloc] init];
    stu.name = @"极客学伟1";
    stu.sex = 1;
    stu.uid = @"1";
    stu.height = 183;
    stu.address = @"北京市霍营华龙苑";
//    stu.girlFriends = @[@"小红",@"小婕"];
    return stu;
}

@end
