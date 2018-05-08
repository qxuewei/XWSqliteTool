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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self testInsertObjs];
}

- (void)testInsertObjs {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [XWSqliteModelFMDBTool insertOrUpdateDataToSQLiteWithModels:[self demoPersons] uid:nil isUpdateTable:YES callBack:^(BOOL isSuccess) {
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

@end
