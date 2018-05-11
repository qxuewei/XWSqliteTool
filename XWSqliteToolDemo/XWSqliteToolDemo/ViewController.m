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
@property (nonatomic, strong) dispatch_queue_t databaseQueue;
@end
@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.databaseQueue = dispatch_queue_create("com.company.app.database", 0);
    
    for (int i = 0; i < 1000; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            XWPerson *stu = [[XWPerson alloc] init];
            stu.name = [NSString stringWithFormat:@"极客学伟_%d",i];
            stu.sex = 1;
            stu.uid = [NSString stringWithFormat:@"%d",i];
            stu.height = 188;
            stu.address = @"北京回龙观";
            dispatch_sync(self.databaseQueue, ^{
                // do your database activity here
                [XWSqliteModelFMDBTool insertOrUpdateDataToSQLiteWithModel:stu isUpdateTable:YES callBack:^(BOOL isSuccess) {
                    NSLog(@"保存成功 %@, 线程 %@",stu.name,[NSThread currentThread]);
                }];
            });
        });
    }
}
@end
