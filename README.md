# XWSqliteTool
## iOS 数据库工具类分享
🏰 The model operation database, based on the encapsulation of the FMDB framework, implements the function of operating the database through the model. It does not need to handwritten SQL statements. As long as a Model is passed in, the framework will automatically save the data in the Model to the specified database, and the database will be automatically created. Create a table corresponding to the model, 
模型操作数据库，基于FMDB 框架的封装，实现通过模型操作数据库的功能，不需要手写SQL语句，只要传入一个Model，框架会自动将Model内数据保存到指定数据库中, 并且会自动创建数据库，自动创建模型对应的表。

## 功能列表
1. 根据 Model 动态建表
2. 若 Model 内字段发生变化自动进行表结构迁移
3. 传入 Model 自动将 Model 内数据保存到数据库对应的表中
4. 传入主键值获取 Model 模型数据
4. 大数据保存，传入多个数据模型批量存储
5. 多线程支持，多线程操作数据库需要使用 操作队列 进行操作。

### 使用说明
1. 导入 `XWSqliteTool` 库
2. 使需要操作的模型遵循 `XWXModelProtocol` 协议，并实现 `+(NSString *)primaryKey` 协议方法指定表的主键。

### 1. 动态建表

```objective-c
//根据模型建表
- (void)testCreateTableFromClass {
    [XWSqliteModelFMDBTool createTableFromClass:[XWPerson class] callBack:^(BOOL isSuccess) {
        XCTAssertTrue(isSuccess);
    }];
}
```

### 2. 模型字段改变自动进行表数据迁移


```objective-c
// 模型字段增加更新数据库
- (void)testUpdateModelTable {
    [XWSqliteModelFMDBTool updateTableFromCls:[XWPerson class] updateSqls:nil callBack:^(BOOL isSuccess) {
        XCTAssert(isSuccess == 1);
    }];
}
```

### 3. 自动保存一个Model到数据库 （自动创建数据库，自动建表）

```objective-c
// 插入/更新 单条数据模型
- (void)testInsertOneObj {
    [XWSqliteModelFMDBTool insertOrUpdateDataToSQLiteWithModel:[self demoPerson] isUpdateTable:YES callBack:^(BOOL isSuccess) {
        XCTAssertTrue(isSuccess);
    }];
}
```

### 4. 自动保存 Model 数组到数据库 （自动创建数据库，自动建表）

```
// 插入/更新 多条数据模型
- (void)testInsertObjs {
    [XWSqliteModelFMDBTool insertOrUpdateDataToSQLiteWithModels:[self demoPersons] isUpdateTable:YES callBack:^(BOOL isSuccess) {
        XCTAssertTrue(isSuccess);
    }];
}
```

### 5.传入主键值获取 Model 模型数据

```objective-c
// 查询 XWPerson 表中 主键 为 4 的模型
- (void)testQuery {
    [XWSqliteModelFMDBTool objectFromDatabaseWithPrimaryValue:4 modelCls:[XWPerson class] resultCallBack:^(XWPerson *obj) {
        NSLog(@"name:%@",obj.name);
    }];
}
```

### 6.多线程操作数据库

首先如果项目中需要多线程异步操作数据库，需要将对数据库操作集中管理，使用 `dispatch_queue_t` 进行统一管理。 例如Demo所示：


```objective-c
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

```



## Author

qxuewei@yeah.net, qxuewei@yeah.net

## License

XWSqliteTool is available under the MIT license. See the LICENSE file for more info.


