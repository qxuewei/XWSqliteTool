//
//  XWStuModel.h
//  XWSqliteTool
//
//  Created by 邱学伟 on 2017/2/8.
//  Copyright © 2017年 qxuewei@yeah.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XWXModelProtocol.h"

@interface XWStuModel : NSObject<XWXModelProtocol>{
    NSArray *array;
}
@property (nonatomic, assign) int stuNum;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) int age;
@property (nonatomic, assign) float score;
@property (nonatomic, assign) float score2;
@end
