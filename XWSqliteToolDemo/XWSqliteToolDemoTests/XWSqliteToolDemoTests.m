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
    [XWSqliteModelFMDBTool createTableFromClass:[XWPerson class] callBack:^(BOOL isSuccess) {
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
    [XWSqliteModelFMDBTool updateTableFromCls:[XWPerson class] updateSqls:nil callBack:^(BOOL isSuccess) {
        XCTAssert(isSuccess == 1);
    }];
}

// 插入/更新 单条数据模型
- (void)testInsertOneObj {
    [XWSqliteModelFMDBTool insertOrUpdateDataToSQLiteWithModel:[self demoPerson] uid:nil isUpdateTable:YES callBack:^(BOOL isSuccess) {
        XCTAssertTrue(isSuccess);
    }];
}

// 插入/更新 多条数据模型
- (void)testInsertObjs {
    [XWSqliteModelFMDBTool insertOrUpdateDataToSQLiteWithModels:[self demoPersons] uid:nil isUpdateTable:YES callBack:^(BOOL isSuccess) {
        XCTAssertTrue(isSuccess);
    }];
}

- (void)testQuery {
    [XWSqliteModelFMDBTool objectFromDatabaseWithPrimaryValue:4 modelCls:[XWPerson class] resultCallBack:^(XWPerson *obj) {
        NSLog(@"name:%@",obj.name);
    }];
}

- (void)testUpdateAndQuery {
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [XWSqliteModelFMDBTool objectFromDatabaseWithPrimaryValue:4 modelCls:[XWPerson class] resultCallBack:^(XWPerson *obj) {
//            NSLog(@"name:%@",obj.name);
//        }];
//    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [XWSqliteModelFMDBTool insertOrUpdateDataToSQLiteWithModels:[self demoPersons] uid:nil isUpdateTable:YES callBack:^(BOOL isSuccess) {
            XCTAssertTrue(isSuccess);
        }];
    });
}

- (void)testUpdateOneObj {
    [XWSqliteModelFMDBTool updateDataToSQLiteWithPropertyKey:@"name" propertyValue:@"极客学伟" primaryKeyObject:@"4" modelCls:[XWPerson class] callBack:^(BOOL isSuccess) {
        XCTAssertTrue(isSuccess);
    }];
}


- (void)testSortData {
    [XWSqliteModelFMDBTool objectsFromDatabaseWithSortKey:@"weight2" isOrderDesc:NO modelCls:[XWPerson class] modelsCallBack:^(NSArray<id<XWXModelProtocol>> *models) {
        for (XWPerson *person in models) {
            NSLog(@"weight2: %f -- name: %@",person.weight2, person.name);
        }
    }];
}

- (void)testValueFromDatabaseWithPrimaryKey {
    [XWSqliteModelFMDBTool valueFromDatabaseWithPrimaryKey:@"4" modelCls:[XWPerson class] propertyKey:@"weight2" valueCallBack:^(id value) {
        NSLog(@"weight2 = %@",value);
    }];
}

- (void)testValuesFromDatabaseWithPrimaryKey {
    [XWSqliteModelFMDBTool valuesFromDatabaseWithPrimaryKey:@"4" modelCls:[XWPerson class] propertyKeys:@[@"name",@"age",@"weight2"] resultCallBack:^(XWPerson *person) {
        NSLog(@"weight2: %f -- name: %@  -- age: %ld",person.weight2, person.name, (long)person.age);
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
    stu.name = @"邱学伟";
    stu.sex = 1;
    stu.uid = @"4";
    stu.height = 173;
    stu.address = @"烟台";
//    stu.weight = 100;
//    stu.girlFriends = @[@"小红",@"小婕"];
    return stu;
}

- (NSArray *)demoPersons {
    NSMutableArray *persons = [NSMutableArray array];
    for (int i = 0; i < 30; i++) {
        XWPerson *stu = [[XWPerson alloc] init];
        stu.name = [NSString stringWithFormat:@"邱学伟_%d",i];
        stu.sex = 1;
        stu.uid = [NSString stringWithFormat:@"%d",i];
        stu.height = 18;
        stu.age = arc4random_uniform(120);
        stu.address = @"烟台";
        stu.weight2 = arc4random_uniform(200) + arc4random_uniform(1);
        [persons addObject:stu];
    }
    return persons.copy;
    
    //    stu.girlFriends = @[@"小红",@"小婕"];
}

@end
