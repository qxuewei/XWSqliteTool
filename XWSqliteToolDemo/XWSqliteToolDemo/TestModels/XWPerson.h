//
//  XWPerson.h
//  XWSqliteToolDemo
//
//  Created by 邱学伟 on 2018/4/10.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XWXModelProtocol.h"

@interface XWPerson : NSObject <XWXModelProtocol>

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, assign) NSInteger sex;
@property (nonatomic, assign) double height;
@end
