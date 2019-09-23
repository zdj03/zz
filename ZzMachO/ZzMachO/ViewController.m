//
//  ViewController.m
//  ZzMachO
//
//  Created by 周登杰 on 2019/8/4.
//  Copyright © 2019 zdj. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [[NSRunLoop currentRunLoop] performBlock:^{
               
            NSLog(@"----------------runloop performblock");
               
           }];
           
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),  ^{
            
            dispatch_async(dispatch_get_main_queue(),^{
               
                
                NSLog(@"runLoop perform dispatch-block");
            });
            
        });
    
}


@end
