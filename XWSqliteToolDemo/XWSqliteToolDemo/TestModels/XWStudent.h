//
//  XWStudent.h
//  XWSqliteToolDemo
//
//  Created by 邱学伟 on 2018/4/11.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

#import "XWPerson.h"
#import "XWXModelProtocol.h"

@interface XWStudent : XWPerson <XWXModelProtocol>
@property (nonatomic, assign) double score;
@property (nonatomic, assign) int number;
@end
