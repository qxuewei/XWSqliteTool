//
//  ViewController.m
//  XWSqliteToolDemo
//
//  Created by 邱学伟 on 2018/4/8.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

#import "ViewController.h"
#import "XWSqliteModelFMDBTool.h"
#import "XWPerson.h"

@interface ViewController ()
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) dispatch_queue_t databaseQueue;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self testInsertObjs];
    self.databaseQueue = dispatch_queue_create("com.company.app.database", 0);
    
    [self testMuch];
}

- (void)testMuch {
    
    for (int i = 0; i < 200; i++) {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            XWPerson *stu = [[XWPerson alloc] init];
            stu.name = [NSString stringWithFormat:@"Q学伟_%d",i];
            stu.sex = 1;
            stu.uid = [NSString stringWithFormat:@"%d",i];
            stu.height = 188;
            stu.address = @"烟台";
        dispatch_sync(self.databaseQueue, ^{
            // do your database activity here
            [XWSqliteModelFMDBTool insertOrUpdateDataToSQLiteWithModel:stu isUpdateTable:YES callBack:^(BOOL isSuccess) {
                NSLog(@"保存成功 %@, 线程 %@",stu.name,[NSThread currentThread]);
            }];
        });
//        });
    }
    
}

- (void)testInsertObjs {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [XWSqliteModelFMDBTool insertOrUpdateDataToSQLiteWithModels:[self demoPersons] isUpdateTable:YES callBack:^(BOOL isSuccess) {
            NSLog(@"isSuccess : %@", isSuccess?@"成功":@"失败");
        }];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [XWSqliteModelFMDBTool objectFromDatabaseWithPrimaryValue:4 modelCls:[XWPerson class] resultCallBack:^(XWPerson *obj) {
            NSLog(@"name : %@",obj.name);
        }];
    });

}

- (NSArray *)demoPersons {
    NSMutableArray *persons = [NSMutableArray array];
    for (int i = 0; i < 200; i++) {
        XWPerson *stu = [[XWPerson alloc] init];
        stu.name = [NSString stringWithFormat:@"邱学伟_%d",i];
        stu.sex = 1;
        stu.uid = [NSString stringWithFormat:@"%d",i];
        stu.height = 188;
        stu.address = @"烟台";
        [persons addObject:stu];
    }
    return persons.copy;
    
    //    stu.girlFriends = @[@"小红",@"小婕"];
}

- (NSOperationQueue *)queue {
    if(!_queue){
        _queue = [[NSOperationQueue alloc] init];
    }
    return _queue;
}

@end
