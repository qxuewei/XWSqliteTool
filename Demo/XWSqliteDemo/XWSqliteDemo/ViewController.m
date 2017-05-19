//
//  ViewController.m
//  XWSqliteDemo
//
//  Created by 邱学伟 on 2017/5/18.
//  Copyright © 2017年 邱学伟. All rights reserved.
//

#import "ViewController.h"
#import "GiftSQLiteTool.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [GiftSQLiteTool creatGiftSQLite];
    [GiftSQLiteTool saveModelsWithShow:NULL];
}



@end
