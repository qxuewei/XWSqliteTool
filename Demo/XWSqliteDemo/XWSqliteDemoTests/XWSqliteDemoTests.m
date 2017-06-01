//
//  XWSqliteDemoTests.m
//  XWSqliteDemoTests
//
//  Created by 邱学伟 on 2017/5/18.
//  Copyright © 2017年 邱学伟. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GiftModel.h"
#import "XWSqliteModelTool.h"
#import "GiftSQLiteTool.h"
#import "XWSqliteTool.h"

@interface XWSqliteDemoTests : XCTestCase

@end

@implementation XWSqliteDemoTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    
//    NSLog(@"%@",NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject);
//    [GiftSQLiteTool creatGiftSQLite];
//    GiftModel *testModel = [self testGiftModel];
//    BOOL I = [XWSqliteTool deal:[XWSqliteModelTool insertOrUpdateDataToSQLiteWithModel:testModel] uid:NULL];
    BOOL I = [XWSqliteModelTool insertOrUpdateDataToSQLiteWithModels:[self testGiftModels] uid:nil];
    XCTAssertTrue(I);
    
}

- (GiftModel *)testGiftModelgiftType:(NSString *)giftType giftID:(NSString *)giftID {
    GiftModel *model = [[GiftModel alloc] init];
    model.giftID = giftID;
    model.giftName = @"hahaha";
    model.giftType = giftType;
    model.giftPrice = @"1.99";
    model.giftUrl = @"www.qiuxuewei.com";
    return model;
}

- (NSArray *)testGiftModels {
    NSMutableArray *arrM = [NSMutableArray array];
    for (int i = 1; i < 10; i++) {
        NSString *type = [NSString stringWithFormat:@"%zd",arc4random_uniform(8)];
        [arrM addObject:[self testGiftModelgiftType:type giftID:[NSString stringWithFormat:@"%zd",i]]];
    }
    return arrM;
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
