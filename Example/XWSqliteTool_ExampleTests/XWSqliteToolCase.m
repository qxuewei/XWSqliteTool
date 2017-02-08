//
//  XWSqliteToolCase.m
//  XWSqliteTool
//
//  Created by 邱学伟 on 2017/2/7.
//  Copyright © 2017年 qxuewei@yeah.net. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "XWSqliteTool.h"
#import "XWXModelTool.h"
#import "XWStuModel.h"
#import "XWSqliteModelTool.h"
#import "XWSqliteTableTool.h"

@interface XWSqliteToolCase : XCTestCase

@end

@implementation XWSqliteToolCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testSqlite{
    NSString *sql = @"create table if not exists XWStuModel(id integer primary key not null, name text, height real, image blob)";
    BOOL createDB = [XWSqliteTool deal:sql uid:nil];
    XCTAssertTrue(createDB);
}

-(void)testSqliteQuery{
    NSString *sql = @"select * from t_people";
    NSMutableArray *queryDBResult = [XWSqliteTool querySql:sql uid:nil];
    NSLog(@"%@",queryDBResult);
}

-(void)testSqliteTool{
    BOOL CREATETABLE = [XWSqliteModelTool createTableFromCls:[XWStuModel class] uid:nil];
    XCTAssertTrue(CREATETABLE);
}

-(void)testModelTool{
    NSString *types = [XWXModelTool createTableSql:[XWStuModel class]];
    NSLog(@"%@",types);
}

-(void)testTableTool{
//    [XWSqliteTableTool tableSortedColumnNames:[XWStuModel class] uid:nil];
    
    BOOL isRequire = [XWSqliteModelTool isTableRequiredUpdate:[XWStuModel class] uid:nil];
    if (isRequire) {
        BOOL result = [XWSqliteModelTool updateTableFromCls:[XWStuModel class] uid:nil];
        XCTAssertTrue(result);
    }
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
