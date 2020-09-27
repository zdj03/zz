//
//  ViewController.m
//  SocketDemo
//
//  Created by 周登杰 on 2019/11/1.
//  Copyright © 2019 zdj. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    NSLog(@"1");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"2");
    });
    
    NSLog(@"3");
}


@end
