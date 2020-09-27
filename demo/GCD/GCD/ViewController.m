//
//  ViewController.m
//  GCD
//
//  Created by 周登杰 on 2019/10/8.
//  Copyright © 2019 zdj. All rights reserved.
//

#import "ViewController.h"
#import "GCDTimer.h"

@interface ViewController ()

{
    GCDTimer *timer;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.redColor;
    
   
    
}

//
//- (void)monitorFile{
//    int fd = open(filename, O_EVTONLY);
//           if (fd == -1) return NULL;
//
//           dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
//           dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, fd, DISPATCH_VNODE_RENAME, queue);
//           
//           // 保存原文件名
//           int length = strlen(filename);
//           char* newString = (char*)malloc(length + 1);
//           newString = strcpy(newString, filename);
//           dispatch_set_context(source, newString);
//
//           // 设置事件发生的回调
//           dispatch_source_set_event_handler(source, ^{
//               // 获取原文件名
//               const char*  oldFilename = (char*)dispatch_get_context(source);
//               
//               // 文件名变化逻辑处理
//               
//           });
//
//           // 设置取消回调
//           dispatch_source_set_cancel_handler(source, ^{
//               char* fileStr = (char*)dispatch_get_context(source);
//               free(fileStr);
//               close(fd);
//           });
//
//           // 启动
//           dispatch_resume(source);
//
//}
//
//
//
//- (void)timer {
//    
//    Task task = ^{
//        NSLog(@"timer");
//    };
//    
//    timer = [GCDTimer timerWithTask:task withTimeInterval:1];
//    
//    
//    sleep(5);
//    
//    [timer invalid];
//}
//


@end
