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
    BOOL isSuccessNoUid =  [XWSqliteModelFMDBTool createTableFromClass:[XWPerson class] uid:nil];
    BOOL isSuccessUid = [XWSqliteModelFMDBTool createTableFromClass:[XWPerson class] uid:@"101"];
    XCTAssertTrue(isSuccessUid);
    XCTAssertTrue(isSuccessNoUid);
}

- (void)testIsTableRequiredUpdate {
    BOOL isUpdate = [XWSqliteModelFMDBTool isTableRequiredUpdate:[XWPerson class] uid:nil];
    XCTAssert(isUpdate == 0);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (XWStudent *)demoStu {
    XWStudent *stu = [[XWStudent alloc] init];
    stu.number = 010;
    stu.name = @"极客学伟";
    stu.sex = 1;
    stu.score = 60;
    return stu;
}

@end
