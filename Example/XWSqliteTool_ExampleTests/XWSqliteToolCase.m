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
    // 根据模型创建数据库表
    BOOL CREATETABLE = [XWSqliteModelTool createTableFromCls:[XWStuModel class] uid:nil];
    XCTAssertTrue(CREATETABLE);
}

-(void)testModelTool{
    // 模型所有字段对应SQL语句 age integer,stuNum integer,score real,name text
    NSString *types = [XWXModelTool createTableSql:[XWStuModel class]];
    NSLog(@"%@",types);
}

-(void)testTableTool{
    // 数据库表排序
//    NSArray *stuDBArray = [XWSqliteTableTool tableSortedColumnNames:[XWStuModel class] uid:nil];
//    NSLog(@"%@",stuDBArray);
    
    // 当前模型字段是否需要更新->若更新表数据迁移
    BOOL isRequire = [XWSqliteModelTool isTableRequiredUpdate:[XWStuModel class] uid:nil];
    if (isRequire) {
        BOOL result = [XWSqliteModelTool updateTableFromCls:[XWStuModel class] uid:nil];
        XCTAssertTrue(result);
    }
    
}

// 测试数据库表中插入单条数据
- (void)testInsertOrUpdateDataToSQLiteWithModel {
    
    BOOL isInsertSuccess = [XWSqliteModelTool insertOrUpdateDataToSQLiteWithModel:[self stuModelWithStuNum:1] uid:nil isUpdateTable:NO];
    
    XCTAssertTrue(isInsertSuccess);
    
}

// 测试数据库表中插入单条数据
- (void)testInsertOrUpdateDataToSQLiteWithModelAndUpdateTable {
    
    BOOL isInsertSuccess = [XWSqliteModelTool insertOrUpdateDataToSQLiteWithModel:[self stuModelWithStuNum:1] uid:nil isUpdateTable:YES];
    
    XCTAssertTrue(isInsertSuccess);
    
}

// 测试数据库表中插入多条数据
- (void)testInsertOrUpdateDataToSQLiteWithModels {
    
    NSMutableArray *users = [NSMutableArray array];
    for (int i = 0; i < 10; i++) {
        [users addObject:[self stuModelWithStuNum:i]];
    }
    BOOL isInsertSuccess = [XWSqliteModelTool insertOrUpdateDataToSQLiteWithModels:users uid:nil isUpdateTable:NO];
    
    XCTAssertTrue(isInsertSuccess);
    
}

- (void)testObjectFromDatabaseWithPrimaryKey {
    id stu = [XWSqliteModelTool objectFromDatabaseWithPrimaryKey:@"4" modelCls:[XWStuModel class] uid:nil];
    NSLog(@"%@",stu);
}

- (XWStuModel *)stuModelWithStuNum:(int)stuNum {
    
    XWStuModel *stuM = [[XWStuModel alloc] init];
    stuM.stuNum = stuNum;
    stuM.name = [NSString stringWithFormat:@"Name&&%zd",arc4random_uniform(999)];
    stuM.score = arc4random_uniform(100);
    stuM.age = arc4random_uniform(30);
    stuM.sex = 2;
    
    return stuM;
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
